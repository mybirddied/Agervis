// Director AI Engine
// Persistent agent monitoring game world state and making high-level decisions

import type Database from 'better-sqlite3';
import type { AIModel } from '../types/ai';
import AnthropicClientWrapper from '../anthropic-client';
import PromptTemplateEngine from '../prompts/template-engine';
import type { DirectorDecision } from '../types/ai';

export interface WorldState {
  playersOnline: number;
  activeEvents: Array<{ type: string; location: string; severity: string }>;
  npcStates: Record<string, { location: string; mood: string; recentInteractions: string[] }>;
  recentCrimes: Array<{ perpetrator: string; victim: string; heat: number }>;
  economyStatus: { totalMoney: number; dirtyMoney: number };
}

export interface DirectorContext {
  worldSnapshot: WorldState;
  recentEvents: Array<{ timestamp: string; event: string }>;
  playerBehaviors: Record<string, { actions: string[]; patterns: string[] }>;
}

export class DirectorAIEngine {
  private db: Database.Database;
  private anthropic: AnthropicClientWrapper;
  private templateEngine: PromptTemplateEngine;
  private model: AIModel;
  private updateIntervalMs: number;
  private isRunning: boolean = false;
  private lastUpdate: Date | null = null;

  constructor(
    db: Database.Database,
    anthropic: AnthropicClientWrapper,
    model: AIModel = 'claude-sonnet-4-20250514',
    updateIntervalMs: number = 30000
  ) {
    this.db = db;
    this.anthropic = anthropic;
    this.templateEngine = new PromptTemplateEngine();
    this.model = model;
    this.updateIntervalMs = updateIntervalMs;
  }

  /**
   * Start the Director AI loop (runs periodically)
   */
  start(): void {
    if (this.isRunning) {
      return;
    }

    this.isRunning = true;
    this.runLoop();
  }

  /**
   * Stop the Director AI loop
   */
  stop(): void {
    this.isRunning = false;
  }

  /**
   * Main loop - runs periodically
   */
  private async runLoop(): Promise<void> {
    while (this.isRunning) {
      try {
        await this.update();
        await new Promise((resolve) => setTimeout(resolve, this.updateIntervalMs));
      } catch (error) {
        console.error('Director AI update failed:', error);
        // Continue running despite errors
        await new Promise((resolve) => setTimeout(resolve, this.updateIntervalMs));
      }
    }
  }

  /**
   * Perform a Director AI update cycle
   */
  async update(): Promise<DirectorDecision> {
    // Gather world state
    const context = this.gatherWorldContext();

    // Generate prompts
    const { systemPrompt, userMessage } = this.templateEngine.generateDirectorPrompt(
      context.worldSnapshot,
      context.recentEvents,
      context.playerBehaviors as any,
      context.playerBehaviors
    );

    // Call Claude API
    const response = await this.anthropic.sendMessage(
      [{ role: 'user', content: userMessage }],
      this.model,
      systemPrompt,
      5000
    );

    // Parse response
    const decision = this.parseDirectorDecision(response.content[0].text);

    // Store decision and update game state
    this.storeDirectorState(decision);
    this.updateNPCMoods(decision.npcMoodUpdates);

    this.lastUpdate = new Date();
    return decision;
  }

  /**
   * Gather current world state for Director context
   */
  private gatherWorldContext(): DirectorContext {
    // This would integrate with game systems to get real-time state
    // For now, return a template structure

    const worldSnapshot: WorldState = {
      playersOnline: 0,
      activeEvents: [],
      npcStates: {},
      recentCrimes: [],
      economyStatus: { totalMoney: 0, dirtyMoney: 0 },
    };

    const recentEvents: Array<{ timestamp: string; event: string }> = [];
    const playerBehaviors: Record<string, { actions: string[]; patterns: string[] }> = {};

    return {
      worldSnapshot,
      recentEvents,
      playerBehaviors,
    };
  }

  /**
   * Parse Director AI decision from response text
   */
  private parseDirectorDecision(responseText: string): DirectorDecision {
    try {
      // Extract JSON from response
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in response');
      }

      const parsed = JSON.parse(jsonMatch[0]);

      return {
        timestamp: new Date(),
        npcMoodUpdates: parsed.npcMoodUpdates || {},
        eventsToSpawn: parsed.eventsToSpawn || [],
        narrativeNotes: parsed.narrativeNotes || [],
      };
    } catch (error) {
      console.error('Failed to parse Director decision:', error);
      // Return safe default
      return {
        timestamp: new Date(),
        npcMoodUpdates: {},
        eventsToSpawn: [],
        narrativeNotes: ['[Parse error - no changes made]'],
      };
    }
  }

  /**
   * Store Director state in database
   */
  private storeDirectorState(decision: DirectorDecision): void {
    const stmt = this.db.prepare(`
      INSERT INTO director_state (world_snapshot, npc_moods, recent_events, last_update, context_version)
      VALUES (?, ?, ?, ?, 1)
      ON CONFLICT(id) DO UPDATE SET
        world_snapshot = ?,
        npc_moods = ?,
        recent_events = ?,
        last_update = ?
    `);

    const worldSnapshot = JSON.stringify({});
    const npcMoods = JSON.stringify(decision.npcMoodUpdates);
    const recentEvents = JSON.stringify(decision.narrativeNotes);
    const now = new Date().toISOString();

    stmt.run(worldSnapshot, npcMoods, recentEvents, now, worldSnapshot, npcMoods, recentEvents, now);
  }

  /**
   * Update NPC moods based on Director decisions
   */
  private updateNPCMoods(moods: Record<string, string>): void {
    // This would update NPC state in the game systems
    // For now, just store in database
    for (const [npcId, mood] of Object.entries(moods)) {
      // Update NPC state (integration point with game systems)
    }
  }

  /**
   * Get last Director decision
   */
  getLastDecision(): DirectorDecision | null {
    const stmt = this.db.prepare(`
      SELECT npc_moods, recent_events, last_update
      FROM director_state
      ORDER BY last_update DESC
      LIMIT 1
    `);

    const row: any = stmt.get();
    if (!row) {
      return null;
    }

    return {
      timestamp: new Date(row.last_update),
      npcMoodUpdates: JSON.parse(row.npc_moods),
      eventsToSpawn: [],
      narrativeNotes: JSON.parse(row.recent_events),
    };
  }

  /**
   * Get Director engine status
   */
  getStatus(): { isRunning: boolean; lastUpdate: Date | null; model: AIModel } {
    return {
      isRunning: this.isRunning,
      lastUpdate: this.lastUpdate,
      model: this.model,
    };
  }
}

export default DirectorAIEngine;
