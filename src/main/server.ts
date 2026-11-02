// Server Initialization Handler
// Entry point for initializing and managing the complete AI Infrastructure

import Database from 'better-sqlite3';
import AIInfrastructure from './ai/index';
import DatabaseInitializer from './database/initializer';
import AIHealthMonitor from './ai/health/monitor';
import type { AIConfig } from './shared/types/ai';
import { DEFAULT_AI_CONFIG } from './shared/constants/ai';

export interface ServerConfig {
  databasePath: string;
  aiConfig: Partial<AIConfig>;
}

export class AIInfrastructureServer {
  private db: Database.Database;
  private ai: AIInfrastructure;
  private healthMonitor: AIHealthMonitor;
  private isRunning: boolean = false;

  /**
   * Initialize the entire AI Infrastructure system
   */
  async start(config: ServerConfig): Promise<void> {
    try {
      console.log('Starting AI Infrastructure Server...');

      // 1. Initialize database
      console.log(`Initializing database at ${config.databasePath}...`);
      this.db = new Database(config.databasePath);
      const dbInitializer = new DatabaseInitializer(this.db);
      await dbInitializer.initialize();

      // 2. Initialize AI Infrastructure
      console.log('Initializing AI subsystems...');
      this.ai = new AIInfrastructure(this.db, config.aiConfig);
      await this.ai.initialize();

      // 3. Initialize health monitoring
      console.log('Starting health monitoring...');
      this.healthMonitor = new AIHealthMonitor(this.db);

      this.isRunning = true;
      console.log('AI Infrastructure Server started successfully');

      return this.printStatus();
    } catch (error) {
      console.error('Failed to start AI Infrastructure Server:', error);
      await this.stop();
      throw error;
    }
  }

  /**
   * Shutdown the entire system gracefully
   */
  async stop(): Promise<void> {
    if (!this.isRunning) {
      return;
    }

    try {
      console.log('Shutting down AI Infrastructure Server...');

      // Shutdown AI systems
      if (this.ai) {
        await this.ai.shutdown();
      }

      // Close database
      if (this.db) {
        this.db.close();
      }

      this.isRunning = false;
      console.log('AI Infrastructure Server stopped');
    } catch (error) {
      console.error('Error during shutdown:', error);
    }
  }

  /**
   * Get access to AI Infrastructure
   */
  getAI(): AIInfrastructure {
    if (!this.isRunning) {
      throw new Error('AI Infrastructure not running');
    }
    return this.ai;
  }

  /**
   * Get health monitor
   */
  getHealthMonitor(): AIHealthMonitor {
    if (!this.isRunning) {
      throw new Error('AI Infrastructure not running');
    }
    return this.healthMonitor;
  }

  /**
   * Check if server is running
   */
  getIsRunning(): boolean {
    return this.isRunning;
  }

  /**
   * Print status information
   */
  private printStatus(): void {
    if (!this.isRunning) {
      console.log('AI Infrastructure Server: STOPPED');
      return;
    }

    const health = this.healthMonitor.getCurrentHealth();
    const summary = this.healthMonitor.getMetricsSummary();

    console.log('\n=== AI Infrastructure Server Status ===');
    console.log(`Status: ${health.isHealthy ? 'HEALTHY' : 'DEGRADED'}`);
    console.log(`API Reachable: ${health.apiReachable}`);
    console.log(`Database Connected: ${health.databaseConnected}`);
    console.log(`Queue Backlog: ${health.queueBacklog}`);
    console.log(`Average Response Time: ${health.averageResponseTimeMs.toFixed(2)}ms`);
    console.log(`Total Requests: ${summary.totalRequests}`);
    console.log(`Cache Hit Rate: ${(summary.cacheHitRate * 100).toFixed(2)}%`);
    console.log(`Error Rate: ${(summary.errorRate * 100).toFixed(2)}%`);
    console.log('========================================\n');
  }

  /**
   * Get detailed status for monitoring dashboards
   */
  getDetailedStatus(): any {
    if (!this.isRunning) {
      throw new Error('AI Infrastructure not running');
    }

    const health = this.healthMonitor.getCurrentHealth();
    const summary = this.healthMonitor.getMetricsSummary();
    const metrics = this.healthMonitor.getRecentHistory(10);
    const queueStats = this.ai.getQueue().getStats();
    const cacheStats = this.ai.getCache().getStats();
    const directorStatus = this.ai.getDirector().getStatus();

    return {
      health,
      summary,
      recentMetrics: metrics,
      queue: queueStats,
      cache: cacheStats,
      director: directorStatus,
      isDegraded: this.healthMonitor.isDegraded(),
    };
  }
}

// Singleton instance
let serverInstance: AIInfrastructureServer | null = null;

/**
 * Global accessor for AI Infrastructure Server
 */
export function getAIServer(): AIInfrastructureServer {
  if (!serverInstance) {
    throw new Error('AI Infrastructure Server not initialized');
  }
  return serverInstance;
}

/**
 * Initialize global AI Infrastructure Server
 */
export async function initializeAIServer(
  config: ServerConfig
): Promise<AIInfrastructureServer> {
  if (serverInstance) {
    throw new Error('AI Infrastructure Server already initialized');
  }

  serverInstance = new AIInfrastructureServer();
  await serverInstance.start(config);

  return serverInstance;
}

/**
 * Shutdown global AI Infrastructure Server
 */
export async function shutdownAIServer(): Promise<void> {
  if (serverInstance) {
    await serverInstance.stop();
    serverInstance = null;
  }
}

export default AIInfrastructureServer;
