import * as fs from 'fs';
import * as path from 'path';
import { app } from 'electron';

export interface ServerConfig {
  apiKey: string;
  baseUrl: string;
  port: number;
  serverName: string;
  maxPlayers: number;
}

export class ConfigManager {
  private configDir: string;
  private configFile: string;

  constructor() {
    this.configDir = path.join(app.getPath('userData'), 'config');
    this.configFile = path.join(this.configDir, 'server-config.json');
    this.ensureConfigDir();
  }

  private ensureConfigDir() {
    if (!fs.existsSync(this.configDir)) {
      fs.mkdirSync(this.configDir, { recursive: true });
    }
  }

  loadConfig(): ServerConfig | null {
    try {
      if (fs.existsSync(this.configFile)) {
        const data = fs.readFileSync(this.configFile, 'utf-8');
        return JSON.parse(data);
      }
      return this.getDefaultConfig();
    } catch (error) {
      console.error('Error loading config:', error);
      return this.getDefaultConfig();
    }
  }

  saveConfig(config: ServerConfig): { success: boolean; error?: string } {
    try {
      const validation = this.validateConfig(config);
      if (!validation.valid) {
        return { success: false, error: validation.errors?.join(', ') };
      }

      this.ensureConfigDir();
      fs.writeFileSync(this.configFile, JSON.stringify(config, null, 2), 'utf-8');
      return { success: true };
    } catch (error) {
      return { success: false, error: String(error) };
    }
  }

  validateConfig(config: any): { valid: boolean; errors?: string[] } {
    const errors: string[] = [];

    if (!config.apiKey || typeof config.apiKey !== 'string') {
      errors.push('API key is required and must be a string');
    }

    if (!config.baseUrl || typeof config.baseUrl !== 'string') {
      errors.push('Base URL is required and must be a string');
    } else if (!this.isValidUrl(config.baseUrl)) {
      errors.push('Base URL must be a valid URL');
    }

    if (!config.port || typeof config.port !== 'number') {
      errors.push('Port is required and must be a number');
    } else if (config.port < 1 || config.port > 65535) {
      errors.push('Port must be between 1 and 65535');
    }

    if (!config.serverName || typeof config.serverName !== 'string') {
      errors.push('Server name is required and must be a string');
    } else if (config.serverName.length < 1 || config.serverName.length > 50) {
      errors.push('Server name must be between 1 and 50 characters');
    }

    if (!config.maxPlayers || typeof config.maxPlayers !== 'number') {
      errors.push('Max players is required and must be a number');
    } else if (config.maxPlayers < 1 || config.maxPlayers > 10000) {
      errors.push('Max players must be between 1 and 10000');
    }

    return {
      valid: errors.length === 0,
      errors: errors.length > 0 ? errors : undefined,
    };
  }

  private isValidUrl(url: string): boolean {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  }

  private getDefaultConfig(): ServerConfig {
    return {
      apiKey: '',
      baseUrl: 'http://localhost:8000',
      port: 3000,
      serverName: 'Agervis Server',
      maxPlayers: 100,
    };
  }
}
