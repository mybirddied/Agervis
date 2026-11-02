// Main AI Infrastructure Orchestrator
// Coordinates all AI subsystems: BYOK, queue, Director, NPC router, token tracking

import type Database from 'better-sqlite3';
import AnthropicClientWrapper from './anthropic-client';
import EncryptionService from './encryption/aes256';
import BYOKKeyManager from './byok/key-manager';
import ConversationStore from './storage/conversation-store';
import ResponseCache from './storage/cache';
import TokenUsageTracker from './storage/token-tracker';
import AIRequestQueue from './queue/request-queue';
import PromptTemplateEngine from './prompts/template-engine';
import DirectorAIEngine from './director/engine';
import NPCConversationRouter from './npc/router';
import type { AIConfig, AIHealth } from '../types/ai';
import { DEFAULT_AI_CONFIG } from '../constants/ai';

export class AIInfrastructure {
  private db: Database.Database;
  private config: AIConfig;
  private anthropic: AnthropicClientWrapper;
  private encryption: EncryptionService;
  private byokManager: BYOKKeyManager;
  private conversationStore: ConversationStore;
  private cache: ResponseCache;
  private tokenTracker: TokenUsageTracker;
  private queue: AIRequestQueue;
  private templateEngine: PromptTemplateEngine;
  private director: DirectorAIEngine;
  private npcRouter: NPCConversationRouter;
  private isInitialized: boolean = false;
  private healthCheckInterval: NodeJS.Timer | null = null;

  constructor(db: Database.Database, config: Partial<AIConfig> = {}) {
    this.db = db;
    this.config = { ...DEFAULT_AI_CONFIG, ...config };
  }

  /**
   * Initialize all AI subsystems
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      // Initialize Anthropic client
      this.anthropic = new AnthropicClientWrapper(this.config);

      // Test API connectivity
      const connected = await this.anthropic.testConnection();
      if (!connected) {
        console.warn('Warning: Could not verify API connection. Proceeding with caution.');
      }

      // Initialize encryption
      const masterKey = process.env.AI_ENCRYPTION_MASTER_KEY || EncryptionService.generateMasterKey();
      this.encryption = new EncryptionService(masterKey);

      // Initialize storage subsystems
      this.byokManager = new BYOKKeyManager(this.db, this.encryption);
      this.conversationStore = new ConversationStore(this.db, 50);
      this.cache = new ResponseCache(this.db, this.config.cache.ttlNpcSeconds, this.config.cache.ttlDirectorSeconds);
      this.tokenTracker = new TokenUsageTracker(this.db);

      // Initialize queue
      this.queue = new AIRequestQueue(5, this.config.limits.maxQueueSize);

      // Initialize template engine
      this.templateEngine = new PromptTemplateEngine();

      // Initialize Director AI
      this.director = new DirectorAIEngine(
        this.db,
        this.anthropic,
        this.config.models.director,
        this.config.director.intervalMs
      );

      // Initialize NPC router
      this.npcRouter = new NPCConversationRouter(
        this.db,
        this.anthropic,
        this.byokManager,
        this.conversationStore,
        this.cache,
        this.tokenTracker
      );

      // Start Director AI loop
      this.director.start();

      // Start health checks
      this.startHealthChecks();

      this.isInitialized = true;
      console.log('AI Infrastructure initialized successfully');
    } catch (error) {
      console.error('Failed to initialize AI Infrastructure:', error);
      throw error;
    }
  }

  /**
   * Shutdown all AI subsystems
   */
  async shutdown(): Promise<void> {
    if (!this.isInitialized) {
      return;
    }

    try {
      // Stop Director AI
      this.director.stop();

      // Stop health checks
      if (this.healthCheckInterval) {
        clearInterval(this.healthCheckInterval);
      }

      // Clean up caches
      this.cache.pruneExpired();

      this.isInitialized = false;
      console.log('AI Infrastructure shutdown complete');
    } catch (error) {
      console.error('Error during AI Infrastructure shutdown:', error);
    }
  }

  /**
   * Get subsystem accessors
   */
  getByokManager(): BYOKKeyManager {
    this.ensureInitialized();
    return this.byokManager;
  }

  getNpcRouter(): NPCConversationRouter {
    this.ensureInitialized();
    return this.npcRouter;
  }

  getTokenTracker(): TokenUsageTracker {
    this.ensureInitialized();
    return this.tokenTracker;
  }

  getConversationStore(): ConversationStore {
    this.ensureInitialized();
    return this.conversationStore;
  }

  getCache(): ResponseCache {
    this.ensureInitialized();
    return this.cache;
  }

  getDirector(): DirectorAIEngine {
    this.ensureInitialized();
    return this.director;
  }

  getTemplateEngine(): PromptTemplateEngine {
    this.ensureInitialized();
    return this.templateEngine;
  }

  getQueue(): AIRequestQueue {
    this.ensureInitialized();
    return this.queue;
  }

  /**
   * Update configuration at runtime
   */
  updateConfig(newConfig: Partial<AIConfig>): void {
    this.config = { ...this.config, ...newConfig };

    if (newConfig.apiKey || newConfig.baseUrl) {
      this.anthropic.updateConfig(this.config.apiKey, this.config.baseUrl);
    }
  }

  /**
   * Get current configuration (with masked API key)
   */
  getConfig(): { baseUrl: string; models: any } {
    return {
      baseUrl: this.config.baseUrl,
      models: this.config.models,
    };
  }

  /**
   * Get health status of all subsystems
   */
  async getHealth(): Promise<AIHealth> {
    const queueStats = this.queue.getStats();
    const cacheStats = this.cache.getStats();

    // Test API connectivity
    let apiReachable = false;
    try {
      apiReachable = await this.anthropic.testConnection();
    } catch (error) {
      apiReachable = false;
    }

    return {
      isHealthy: apiReachable && this.isInitialized,
      lastCheckTime: new Date(),
      apiReachable,
      databaseConnected: true,
      queueBacklog: queueStats.queueSize,
      averageResponseTimeMs: 0, // Would track from metrics
    };
  }

  /**
   * Start periodic health checks
   */
  private startHealthChecks(): void {
    this.healthCheckInterval = setInterval(async () => {
      try {
        const health = await this.getHealth();

        if (!health.isHealthy) {
          console.warn('AI Infrastructure health check failed:', health);
        }

        // Clean up expired cache entries
        const pruned = this.cache.pruneExpired();
        if (pruned > 0) {
          console.log(`Pruned ${pruned} expired cache entries`);
        }
      } catch (error) {
        console.error('Health check error:', error);
      }
    }, 60000); // Check every minute
  }

  /**
   * Private: Ensure infrastructure is initialized
   */
  private ensureInitialized(): void {
    if (!this.isInitialized) {
      throw new Error('AI Infrastructure not initialized. Call initialize() first.');
    }
  }
}

export default AIInfrastructure;
