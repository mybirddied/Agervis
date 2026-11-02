/**
 * Configuration Manager
 * Handles configuration loading, validation, and hot-reload capability
 */

import { EventEmitter } from 'events';
import * as fs from 'fs';
import * as path from 'path';

export interface ServerConfig {
  server: {
    port: number;
    host: string;
    environment: 'development' | 'staging' | 'production';
  };
  database: {
    filename: string;
    backupDir?: string;
    autoBackupInterval?: number;
  };
  websocket: {
    perMessageDeflate: boolean;
    maxPayload: number;
    heartbeatTimeout: number;
    heartbeatCheckInterval: number;
  };
  gameLogic: {
    tickRate: number;
    maxEntities: number;
    entityUpdateBatchSize: number;
  };
  rateLimit: {
    enabled: boolean;
    windowMs: number;
    maxRequests: number;
    maxConnectionsPerIp: number;
  };
  logging: {
    level: 'debug' | 'info' | 'warn' | 'error';
    format: 'json' | 'text';
  };
}

export const DEFAULT_CONFIG: ServerConfig = {
  server: {
    port: 10813,
    host: '0.0.0.0',
    environment: 'development',
  },
  database: {
    filename: 'agervis.db',
    backupDir: 'backups',
    autoBackupInterval: 3600000, // 1 hour
  },
  websocket: {
    perMessageDeflate: false,
    maxPayload: 100 * 1024 * 1024, // 100MB
    heartbeatTimeout: 30000,
    heartbeatCheckInterval: 5000,
  },
  gameLogic: {
    tickRate: 60,
    maxEntities: 10000,
    entityUpdateBatchSize: 100,
  },
  rateLimit: {
    enabled: true,
    windowMs: 60000, // 1 minute
    maxRequests: 1000,
    maxConnectionsPerIp: 10,
  },
  logging: {
    level: 'info',
    format: 'json',
  },
};

export class ConfigManager extends EventEmitter {
  private config: ServerConfig;
  private configPath: string | null = null;
  private fileWatcher: fs.FSWatcher | null = null;
  private lastModified: number = 0;

  constructor(initialConfig: Partial<ServerConfig> = {}) {
    super();
    this.config = {
      ...DEFAULT_CONFIG,
      ...initialConfig,
    };
  }

  /**
   * Load configuration from file
   */
  loadFromFile(filePath: string): void {
    try {
      const resolvedPath = path.resolve(filePath);
      const fileContent = fs.readFileSync(resolvedPath, 'utf-8');
      const fileConfig = JSON.parse(fileContent);

      this.config = {
        ...DEFAULT_CONFIG,
        ...fileConfig,
      };

      this.configPath = resolvedPath;
      this.lastModified = fs.statSync(resolvedPath).mtimeMs;

      this.emit('loaded', { path: resolvedPath });
    } catch (error) {
      this.emit('error', {
        message: `Failed to load config from ${filePath}`,
        error: error instanceof Error ? error.message : 'Unknown error',
      });
      throw error;
    }
  }

  /**
   * Save configuration to file
   */
  saveToFile(filePath: string): void {
    try {
      const resolvedPath = path.resolve(filePath);
      const dir = path.dirname(resolvedPath);

      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
      }

      fs.writeFileSync(resolvedPath, JSON.stringify(this.config, null, 2));
      this.configPath = resolvedPath;

      this.emit('saved', { path: resolvedPath });
    } catch (error) {
      this.emit('error', {
        message: `Failed to save config to ${filePath}`,
        error: error instanceof Error ? error.message : 'Unknown error',
      });
      throw error;
    }
  }

  /**
   * Enable hot-reload
   */
  watchFile(): void {
    if (!this.configPath) {
      throw new Error('No config file path set. Call loadFromFile first.');
    }

    this.fileWatcher = fs.watch(this.configPath, (eventType) => {
      if (eventType === 'change') {
        // Debounce rapid changes
        const now = Date.now();
        if (now - this.lastModified > 1000) {
          try {
            this.loadFromFile(this.configPath!);
            this.emit('reloaded', { path: this.configPath });
          } catch (error) {
            this.emit('reload-error', error);
          }
        }

        this.lastModified = now;
      }
    });

    this.emit('watching', { path: this.configPath });
  }

  /**
   * Stop watching file
   */
  unwatchFile(): void {
    if (this.fileWatcher) {
      this.fileWatcher.close();
      this.fileWatcher = null;
      this.emit('unwatching');
    }
  }

  /**
   * Get full configuration
   */
  getConfig(): ServerConfig {
    return { ...this.config };
  }

  /**
   * Get specific config section
   */
  getSection<K extends keyof ServerConfig>(section: K): ServerConfig[K] {
    return { ...this.config[section] };
  }

  /**
   * Update configuration
   */
  update(updates: Partial<ServerConfig>): void {
    this.config = {
      ...this.config,
      ...updates,
    };
    this.emit('updated', updates);
  }

  /**
   * Update specific section
   */
  updateSection<K extends keyof ServerConfig>(
    section: K,
    updates: Partial<ServerConfig[K]>
  ): void {
    this.config[section] = {
      ...this.config[section],
      ...updates,
    };
    this.emit('section-updated', { section, updates });
  }

  /**
   * Validate configuration
   */
  validate(): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (this.config.server.port < 1 || this.config.server.port > 65535) {
      errors.push('Server port must be between 1 and 65535');
    }

    if (this.config.gameLogic.tickRate < 1 || this.config.gameLogic.tickRate > 1000) {
      errors.push('Game logic tick rate must be between 1 and 1000');
    }

    if (this.config.gameLogic.maxEntities < 1) {
      errors.push('Max entities must be at least 1');
    }

    if (this.config.rateLimit.windowMs < 100) {
      errors.push('Rate limit window must be at least 100ms');
    }

    return {
      valid: errors.length === 0,
      errors,
    };
  }

  /**
   * Get configuration as JSON string
   */
  toJSON(): string {
    return JSON.stringify(this.config, null, 2);
  }

  /**
   * Reset to defaults
   */
  reset(): void {
    this.config = { ...DEFAULT_CONFIG };
    this.emit('reset');
  }

  /**
   * Merge with defaults
   */
  mergeDefaults(): void {
    this.config = {
      ...DEFAULT_CONFIG,
      ...this.config,
    };
  }

  getStatus() {
    return {
      loaded: !!this.configPath,
      configPath: this.configPath,
      isWatching: !!this.fileWatcher,
      validation: this.validate(),
    };
  }
}
