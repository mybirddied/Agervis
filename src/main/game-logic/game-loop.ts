/**
 * Game Logic Loop
 * Processes all game systems at 60 Hz
 */

import { EventBus } from '../state/event-bus';
import { WorldStateManager } from '../state/world-state';
import { PlayerCommandProcessor } from './player-commands';
import { CombatSystem } from './combat-system';
import { EconomySystem } from './economy-system';
import { NPCBehaviorSystem } from './npc-behavior';
import { AIDirector } from '../ai/director';
import { NPCAISystem } from '../ai/npc-ai';
import { AdvancedAIFeatures } from '../ai/advanced-features';
import { WorkerPool } from '../threading/worker-pool';

export interface GameLoopConfig {
  tickRate: number;
  deltaTimeMs: number;
}

export class GameLoop {
  private tickRate: number;
  private deltaTime: number;
  private lastTickTime: number = 0;
  private tickCount: number = 0;

  private playerCommandProcessor: PlayerCommandProcessor;
  private combatSystem: CombatSystem;
  private economySystem: EconomySystem;
  private npcBehaviorSystem: NPCBehaviorSystem;
  private aiDirector: AIDirector;
  private npcAI: NPCAISystem;
  private advancedAI: AdvancedAIFeatures;

  constructor(
    private eventBus: EventBus,
    private worldState: WorldStateManager,
    config: GameLoopConfig,
    private workerPool: WorkerPool | null = null
  ) {
    this.tickRate = config.tickRate;
    this.deltaTime = config.deltaTimeMs / 1000; // Convert to seconds

    // Initialize game systems
    this.playerCommandProcessor = new PlayerCommandProcessor(eventBus, worldState);
    this.combatSystem = new CombatSystem(eventBus, worldState);
    this.economySystem = new EconomySystem(eventBus, worldState);
    this.npcBehaviorSystem = new NPCBehaviorSystem(eventBus, worldState);
    this.aiDirector = new AIDirector(eventBus, worldState);
    this.npcAI = new NPCAISystem(eventBus, workerPool);
    this.advancedAI = new AdvancedAIFeatures(eventBus, worldState, this.aiDirector, workerPool);
  }

  /**
   * Execute one game tick
   */
  tick(): void {
    const now = Date.now();
    const actualDeltaTime = this.lastTickTime > 0 ? (now - this.lastTickTime) / 1000 : this.deltaTime;
    this.lastTickTime = now;
    this.tickCount++;

    // Process player commands first
    this.playerCommandProcessor.process(actualDeltaTime);

    // Update NPC behaviors
    this.npcBehaviorSystem.update(actualDeltaTime);

    // Process combat
    this.combatSystem.update(actualDeltaTime);

    // Update economy (transactions, prices, etc.)
    this.economySystem.update(actualDeltaTime);

    // AI Director monitors and intervenes
    if (this.tickCount % 60 === 0) {
      // Run AI Director at 1 Hz
      this.aiDirector.analyze();
    }

    // Clean up old NPC conversations every 10 seconds
    if (this.tickCount % 600 === 0) {
      this.npcAI.cleanupOldConversations();
    }

    // Advanced AI features every 5 seconds
    if (this.tickCount % 300 === 0) {
      this.advancedAI.analyzeAndBalanceEconomy();
    }

    // Publish tick event for other systems
    this.eventBus.publish('game-tick', {
      tickCount: this.tickCount,
      deltaTime: actualDeltaTime,
      timestamp: now,
    });
  }

  /**
   * Get tick statistics
   */
  getStats() {
    return {
      tickRate: this.tickRate,
      tickCount: this.tickCount,
      lastTickTime: this.lastTickTime,
      systems: {
        playerCommands: this.playerCommandProcessor.getStats(),
        combat: this.combatSystem.getStats(),
        economy: this.economySystem.getStats(),
        npcBehavior: this.npcBehaviorSystem.getStats(),
        aiDirector: this.aiDirector.getStats(),
        npcAI: this.npcAI.getStats(),
        advancedAI: this.advancedAI.getStats(),
      },
    };
  }

  /**
   * Set Claude API key for NPC AI
   */
  setClaudeApiKey(apiKey: string): void {
    this.npcAI.setApiKey(apiKey);
  }

  /**
   * Reset tick counter (for testing)
   */
  reset(): void {
    this.tickCount = 0;
    this.lastTickTime = 0;
  }
}
