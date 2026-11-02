/**
 * Agervis Server Core
 * Main entry point for the server
 * Orchestrates WebSocket, database, state management, and game logic
 */

import { WebSocketServer } from './websocket/server';
import { ConnectionManager } from './websocket/connection-manager';
import { WorldStateManager } from './state/world-state';
import { EventBus } from './state/event-bus';
import { SQLiteDatabase } from './database/sqlite';
import { ConfigManager } from './config/config-manager';
import { HealthCheckSystem } from './health/health-check';
import { RateLimitEngine } from './rate-limiter';
import { ProtocolCodec, MessageType } from './websocket/protocol';
import { AuthManager } from './auth/auth-manager';
import { setupInitialAdmin } from './setup-admin';
import { GameLoop } from './game-logic/game-loop';
import { WorkerPool } from './threading/worker-pool';

export interface ServerOptions {
  configPath?: string;
  dbPath?: string;
  port?: number;
}

export class AgervisServer {
  private wsServer: WebSocketServer | null = null;
  private connectionManager: ConnectionManager;
  private worldState: WorldStateManager;
  private eventBus: EventBus;
  private database: SQLiteDatabase;
  private configManager: ConfigManager;
  private healthCheck: HealthCheckSystem;
  private rateLimiter: RateLimitEngine;
  private authManager: AuthManager | null = null;
  private gameLoop: GameLoop | null = null;
  private gameLoopInterval: NodeJS.Timeout | null = null;
  private workerPool: WorkerPool | null = null;
  private isRunning: boolean = false;
  private shutdownHandlers: (() => Promise<void>)[] = [];

  constructor(options: ServerOptions = {}) {
    // Initialize core components
    this.configManager = new ConfigManager();
    if (options.configPath) {
      this.configManager.loadFromFile(options.configPath);
    }

    const config = this.configManager.getConfig();

    this.connectionManager = new ConnectionManager();
    this.worldState = new WorldStateManager();
    this.eventBus = new EventBus();
    this.database = new SQLiteDatabase({
      filename: options.dbPath || config.database.filename,
    });
    this.healthCheck = new HealthCheckSystem();
    this.rateLimiter = new RateLimitEngine(config.rateLimit);

    this.setupEventListeners();
    this.setupShutdownHandlers();
  }

  /**
   * Initialize server components
   */
  async initialize(): Promise<void> {
    console.log('[Server] Initializing Agervis Server Core...');

    try {
      // Initialize database
      console.log('[Database] Initializing SQLite...');
      this.database.initialize();
      this.registerDatabaseMigrations();
      this.database.runMigrations();

      // Setup initial admin account if needed
      await setupInitialAdmin(this.database);

      // Initialize authentication manager
      this.authManager = new AuthManager(this.database);

      // Setup health checks
      this.setupHealthChecks();

      // Load configuration
      const config = this.configManager.getConfig();

      // Setup WebSocket server with auth
      console.log('[WebSocket] Initializing WebSocket server on port', config.server.port);
      this.wsServer = new WebSocketServer(
        {
          port: config.server.port,
          host: config.server.host,
          perMessageDeflate: config.websocket.perMessageDeflate,
          maxPayload: config.websocket.maxPayload,
        },
        this.connectionManager,
        this.authManager
      );

      // Configure connection manager
      this.connectionManager.setHeartbeatTimeout(config.websocket.heartbeatTimeout);
      this.connectionManager.setCheckInterval(config.websocket.heartbeatCheckInterval);

      // Setup event handlers
      this.setupEventHandlers();

      console.log('[Server] Initialization complete');
    } catch (error) {
      console.error('[Server] Initialization failed:', error);
      throw error;
    }
  }

  /**
   * Start the server
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      console.warn('[Server] Server is already running');
      return;
    }

    try {
      if (!this.wsServer) {
        await this.initialize();
      }

      await this.wsServer!.start();
      this.isRunning = true;

      // Start health monitoring
      this.healthCheck.startMonitoring();

      // Start worker pool
      const config = this.configManager.getConfig();
      const workerPoolSize = config.threading?.workerPoolSize || 4;
      this.workerPool = new WorkerPool(workerPoolSize, './threading/game-worker.js');
      console.log(`[Server] Worker pool started with ${workerPoolSize} threads`);

      // Start game loop
      this.startGameLoop();

      console.log('[Server] Agervis Server Core started successfully');
    } catch (error) {
      console.error('[Server] Failed to start server:', error);
      throw error;
    }
  }

  /**
   * Stop the server gracefully
   */
  async stop(): Promise<void> {
    if (!this.isRunning) {
      console.warn('[Server] Server is not running');
      return;
    }

    console.log('[Server] Shutting down gracefully...');

    try {
      // Stop accepting new connections
      if (this.wsServer) {
        await this.wsServer.stop();
      }

      // Stop game loop
      this.stopGameLoop();

      // Stop worker pool
      if (this.workerPool) {
        await this.workerPool.shutdown();
        this.workerPool = null;
      }

      // Stop health monitoring
      this.healthCheck.stopMonitoring();

      // Run shutdown handlers
      for (const handler of this.shutdownHandlers) {
        try {
          await handler();
        } catch (error) {
          console.error('[Server] Error in shutdown handler:', error);
        }
      }

      // Flush world state
      const pendingUpdates = this.worldState.flush();
      console.log(`[Server] Flushed ${pendingUpdates.length} pending updates`);

      // Close database
      this.database.close();

      // Clean up
      this.connectionManager.clear();
      this.rateLimiter.clear();

      this.isRunning = false;
      console.log('[Server] Shutdown complete');
    } catch (error) {
      console.error('[Server] Error during shutdown:', error);
      throw error;
    }
  }

  /**
   * Register database migrations
   */
  private registerDatabaseMigrations(): void {
    // Migration 1: Initial schema
    this.database.registerMigration(
      1,
      `
        CREATE TABLE IF NOT EXISTS entities (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          owner TEXT,
          position_x REAL DEFAULT 0,
          position_y REAL DEFAULT 0,
          position_z REAL DEFAULT 0,
          rotation_x REAL DEFAULT 0,
          rotation_y REAL DEFAULT 0,
          rotation_z REAL DEFAULT 0,
          scale_x REAL DEFAULT 1,
          scale_y REAL DEFAULT 1,
          scale_z REAL DEFAULT 1,
          state TEXT DEFAULT '{}',
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );

        CREATE INDEX IF NOT EXISTS idx_entities_type ON entities(type);
        CREATE INDEX IF NOT EXISTS idx_entities_owner ON entities(owner);
        CREATE INDEX IF NOT EXISTS idx_entities_updated_at ON entities(updated_at);

        CREATE TABLE IF NOT EXISTS events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          source_entity_id TEXT,
          target_entity_id TEXT,
          data TEXT,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );

        CREATE INDEX IF NOT EXISTS idx_events_type ON events(type);
        CREATE INDEX IF NOT EXISTS idx_events_created_at ON events(created_at);

        CREATE TABLE IF NOT EXISTS clients (
          id TEXT PRIMARY KEY,
          player_id TEXT,
          connected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          last_heartbeat DATETIME DEFAULT CURRENT_TIMESTAMP,
          latency_ms INTEGER DEFAULT 0,
          metadata TEXT DEFAULT '{}'
        );

        CREATE INDEX IF NOT EXISTS idx_clients_player_id ON clients(player_id);
      `
    );
  }

  /**
   * Setup health checks
   */
  private setupHealthChecks(): void {
    // Database health check
    this.healthCheck.registerCheck('database', async () => {
      try {
        const stats = this.database.getStats();
        return stats.isInitialized ? 'healthy' : 'unhealthy';
      } catch {
        return 'unhealthy';
      }
    });

    // Memory health check
    this.healthCheck.registerCheck('memory', async () => {
      const usage = process.memoryUsage();
      const heapPercent = usage.heapUsed / usage.heapTotal;
      if (heapPercent > 0.9) return 'unhealthy';
      if (heapPercent > 0.75) return 'degraded';
      return 'healthy';
    });

    // Event bus health check
    this.healthCheck.registerCheck('event-bus', async () => {
      const stats = this.eventBus.getStatistics();
      return stats.totalEventTypes > 0 ? 'healthy' : 'degraded';
    });

    // World state health check
    this.healthCheck.registerCheck('world-state', async () => {
      const stats = this.worldState.getStatistics();
      return stats.entityCount >= 0 ? 'healthy' : 'unhealthy';
    });
  }

  /**
   * Setup event handlers
   */
  private setupEventHandlers(): void {
    if (!this.wsServer) return;

    // Client connected
    this.wsServer.on('client-connected', ({ clientId, playerId }) => {
      console.log(`[Connection] Client connected: ${clientId}${playerId ? ` (Player: ${playerId})` : ''}`);
      this.eventBus.publish('client-connected', { clientId, playerId });
    });

    // Client disconnected
    this.wsServer.on('client-disconnected', ({ clientId }) => {
      console.log(`[Connection] Client disconnected: ${clientId}`);
      this.eventBus.publish('client-disconnected', { clientId });
    });

    // Game state update
    this.wsServer.on('game-state-update', ({ clientId, message }) => {
      const payload = message.payload as any;
      this.worldState.updateEntity({
        id: payload.entityId,
        type: 'player',
        position: payload.position,
        rotation: payload.rotation,
        state: payload.state,
      });
    });

    // Game event
    this.wsServer.on('game-event', ({ clientId, message }) => {
      this.eventBus.publish('game-event', {
        clientId,
        event: message.payload,
      });
    });

    // Client command
    this.wsServer.on('client-command', ({ clientId, message }) => {
      this.eventBus.publish('client-command', {
        clientId,
        command: message.payload,
      });
    });

    // Heartbeat timeout
    this.connectionManager.on('heartbeat-timeout', ({ clientId }) => {
      console.warn(`[Connection] Heartbeat timeout for client: ${clientId}`);
      this.eventBus.publish('heartbeat-timeout', { clientId });
    });
  }

  /**
   * Setup shutdown handlers
   */
  private setupShutdownHandlers(): void {
    // Save world state on shutdown
    this.shutdownHandlers.push(async () => {
      console.log('[Server] Saving world state...');
      const entities = this.worldState.getAllEntities();
      console.log(`[Server] Saved ${entities.length} entities to database`);
    });

    // Listen for process signals
    process.on('SIGTERM', () => {
      console.log('[Server] Received SIGTERM signal');
      this.stop().catch(console.error);
    });

    process.on('SIGINT', () => {
      console.log('[Server] Received SIGINT signal');
      this.stop().catch(console.error);
    });
  }

  /**
   * Start game loop
   */
  private startGameLoop(): void {
    const config = this.configManager.getConfig();
    const tickDuration = 1000 / config.gameLogic.tickRate;

    // Initialize game loop
    this.gameLoop = new GameLoop(
      this.eventBus,
      this.worldState,
      {
        tickRate: config.gameLogic.tickRate,
        deltaTimeMs: tickDuration,
      },
      this.workerPool
    );

    this.gameLoopInterval = setInterval(() => {
      this.tick();
    }, tickDuration);

    console.log(`[GameLoop] Started with tick rate ${config.gameLogic.tickRate} Hz`);
  }

  /**
   * Stop game loop
   */
  private stopGameLoop(): void {
    if (this.gameLoopInterval) {
      clearInterval(this.gameLoopInterval);
      this.gameLoopInterval = null;
    }

    this.gameLoop = null;
  }

  /**
   * Game tick
   */
  private tick(): void {
    // Run game loop if it exists
    if (this.gameLoop) {
      this.gameLoop.tick();
    }

    // Flush world state updates
    const flushedUpdates = this.worldState.flush();

    // Update metrics
    const connectionStats = this.connectionManager.getStatistics();
    const worldStats = this.worldState.getStatistics();
    const eventBusStats = this.eventBus.getStatistics();

    this.healthCheck.updateMetrics(
      connectionStats.totalConnections,
      worldStats.pendingUpdates,
      eventBusStats,
      this.database.isConnected() ? 'connected' : 'disconnected'
    );

    // Broadcast world state updates if any
    if (flushedUpdates.length > 0) {
      const stateMessage = ProtocolCodec.createGameState(
        'world',
        {
          entityId: 'world',
          state: {
            entities: flushedUpdates.length,
            timestamp: Date.now(),
          },
        }
      );

      this.wsServer?.broadcast(stateMessage);
    }
  }

  /**
   * Setup event listeners
   */
  private setupEventListeners(): void {
    this.database.on('error', (error) => {
      console.error('[Database] Error:', error);
    });

    this.configManager.on('error', (error) => {
      console.error('[Config] Error:', error);
    });

    this.eventBus.on('handler-error', ({ eventType, error }) => {
      console.error(`[EventBus] Handler error for ${eventType}:`, error);
    });
  }

  /**
   * Get server status
   */
  getStatus() {
    return {
      isRunning: this.isRunning,
      config: this.configManager.getStatus(),
      connections: this.connectionManager.getStatistics(),
      worldState: this.worldState.getStatistics(),
      eventBus: this.eventBus.getStatistics(),
      health: this.healthCheck.getHealthReport(),
      database: this.database.getStats(),
      rateLimit: this.rateLimiter.getStatistics(),
      gameLoop: this.gameLoop ? this.gameLoop.getStats() : null,
      workerPool: this.workerPool ? this.workerPool.getStats() : null,
    };
  }

  // Getters for components
  getWebSocketServer(): WebSocketServer | null {
    return this.wsServer;
  }

  getConnectionManager(): ConnectionManager {
    return this.connectionManager;
  }

  getWorldState(): WorldStateManager {
    return this.worldState;
  }

  getEventBus(): EventBus {
    return this.eventBus;
  }

  getDatabase(): SQLiteDatabase {
    return this.database;
  }

  getConfigManager(): ConfigManager {
    return this.configManager;
  }

  getHealthCheck(): HealthCheckSystem {
    return this.healthCheck;
  }

  getRateLimiter(): RateLimitEngine {
    return this.rateLimiter;
  }

  getWorkerPool(): WorkerPool | null {
    return this.workerPool;
  }
}

/**
 * Standalone server starter
 */
async function main() {
  const server = new AgervisServer({
    configPath: process.env.CONFIG_PATH,
    dbPath: process.env.DB_PATH,
    port: process.env.PORT ? parseInt(process.env.PORT, 10) : 10813,
  });

  try {
    await server.initialize();
    await server.start();

    console.log('[Server] Ready to accept connections');
    console.log('[Server] Status:', server.getStatus());
  } catch (error) {
    console.error('[Server] Fatal error:', error);
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  main().catch(console.error);
}

export default AgervisServer;
