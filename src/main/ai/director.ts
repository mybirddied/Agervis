/**
 * AI Director
 * Monitors game state and orchestrates AI-driven events and interventions
 */

import { EventBus } from '../state/event-bus';
import { WorldStateManager } from '../state/world-state';

interface DirectorStats {
  totalInterventions: number;
  eventsCaused: number;
  playersMonitored: number;
  lastAnalysisTime: number;
}

export class AIDirector {
  private stats: DirectorStats = {
    totalInterventions: 0,
    eventsCaused: 0,
    playersMonitored: 0,
    lastAnalysisTime: 0,
  };

  private playerBehaviorHistory: Map<string, any[]> = new Map();
  private gameStateHistory: any[] = [];

  constructor(
    private eventBus: EventBus,
    private worldState: WorldStateManager
  ) {
    this.setupEventListeners();
  }

  private setupEventListeners(): void {
    // Track player actions for behavior analysis
    this.eventBus.subscribe('player-moved', (data: any) => {
      this.recordPlayerAction(data.playerId, 'move', data);
    });

    this.eventBus.subscribe('combat-attack', (data: any) => {
      this.recordPlayerAction(data.attackerId, 'attack', data);
    });

    this.eventBus.subscribe('chat-message', (data: any) => {
      this.recordPlayerAction(data.playerId, 'chat', data);
    });

    this.eventBus.subscribe('economy-buy', (data: any) => {
      this.recordPlayerAction(data.playerId, 'buy', data);
    });

    this.eventBus.subscribe('economy-sell', (data: any) => {
      this.recordPlayerAction(data.playerId, 'sell', data);
    });
  }

  /**
   * Record player action for behavior analysis
   */
  private recordPlayerAction(playerId: string, actionType: string, data: any): void {
    if (!this.playerBehaviorHistory.has(playerId)) {
      this.playerBehaviorHistory.set(playerId, []);
    }

    const history = this.playerBehaviorHistory.get(playerId)!;
    history.push({
      type: actionType,
      data,
      timestamp: Date.now(),
    });

    // Keep only last 100 actions per player
    if (history.length > 100) {
      history.shift();
    }
  }

  /**
   * Analyze game state and make decisions
   */
  analyze(): void {
    const now = Date.now();
    this.stats.lastAnalysisTime = now;
    this.stats.playersMonitored = this.playerBehaviorHistory.size;

    // Get current world state
    const worldStats = this.worldState.getStatistics();
    this.gameStateHistory.push({
      timestamp: now,
      entityCount: worldStats.entityCount,
      pendingUpdates: worldStats.pendingUpdates,
    });

    // Keep only last hour of history
    const oneHourAgo = now - 3600000;
    this.gameStateHistory = this.gameStateHistory.filter(
      (entry) => entry.timestamp > oneHourAgo
    );

    // Analyze player behavior patterns
    this.analyzePlayerBehavior();

    // Check for intervention opportunities
    this.considerInterventions();
  }

  /**
   * Analyze player behavior patterns
   */
  private analyzePlayerBehavior(): void {
    this.playerBehaviorHistory.forEach((history, playerId) => {
      if (history.length < 10) return; // Not enough data

      // Detect griefing behavior
      const recentActions = history.slice(-20);
      const attackCount = recentActions.filter((a) => a.type === 'attack').length;

      if (attackCount > 15) {
        // Player is attacking a lot
        this.eventBus.publish('director-alert', {
          type: 'potential-griefer',
          playerId,
          reason: 'excessive-combat',
          attackCount,
        });
      }

      // Detect stuck players (not moving much)
      const moveActions = recentActions.filter((a) => a.type === 'move');
      if (moveActions.length < 3 && history.length > 30) {
        this.eventBus.publish('director-alert', {
          type: 'stuck-player',
          playerId,
          reason: 'low-movement',
        });

        // Offer hint or tutorial
        this.offerHelp(playerId);
      }

      // Detect wealthy players (for dynamic events)
      const buyActions = history.filter((a) => a.type === 'buy');
      if (buyActions.length > 20) {
        this.eventBus.publish('director-alert', {
          type: 'wealthy-player',
          playerId,
          reason: 'frequent-buyer',
        });
      }
    });
  }

  /**
   * Consider interventions to improve gameplay
   */
  private considerInterventions(): void {
    const worldStats = this.worldState.getStatistics();

    // If no recent activity, spawn an event
    if (this.gameStateHistory.length > 10) {
      const recentActivity = this.gameStateHistory.slice(-10);
      const avgUpdates =
        recentActivity.reduce((sum, entry) => sum + entry.pendingUpdates, 0) / 10;

      if (avgUpdates < 5) {
        // Game is quiet, create excitement
        this.spawnRandomEvent();
      }
    }

    // Balance economy if needed
    this.eventBus.publish('director-economy-check', {
      timestamp: Date.now(),
    });
  }

  /**
   * Spawn a random dynamic event
   */
  private spawnRandomEvent(): void {
    const events = [
      'crime-wave',
      'police-raid',
      'street-race',
      'gang-war',
      'blackout',
      'discount-sale',
    ];

    const randomEvent = events[Math.floor(Math.random() * events.length)];

    this.eventBus.publish('director-spawn-event', {
      eventType: randomEvent,
      timestamp: Date.now(),
    });

    this.stats.eventsCaused++;
    this.stats.totalInterventions++;

    console.log(`[AI Director] Spawned event: ${randomEvent}`);
  }

  /**
   * Offer help to a stuck player
   */
  private offerHelp(playerId: string): void {
    this.eventBus.publish('director-offer-help', {
      playerId,
      helpType: 'tutorial-hint',
      timestamp: Date.now(),
    });

    this.stats.totalInterventions++;
  }

  /**
   * Predict what a player is likely to do next
   */
  predictPlayerAction(playerId: string): string | null {
    const history = this.playerBehaviorHistory.get(playerId);
    if (!history || history.length < 5) return null;

    // Simple pattern detection
    const recentActions = history.slice(-5);
    const actionTypes = recentActions.map((a) => a.type);

    // If player is in a shop and browsing, predict buy
    const buyCount = actionTypes.filter((t) => t === 'buy').length;
    if (buyCount > 0) return 'buy';

    // If player is moving towards NPCs, predict interaction
    const moveCount = actionTypes.filter((t) => t === 'move').length;
    if (moveCount > 3) return 'interact';

    // If player has been attacking, predict more combat
    const attackCount = actionTypes.filter((t) => t === 'attack').length;
    if (attackCount > 2) return 'attack';

    return null;
  }

  /**
   * Generate a personalized story arc for a player
   */
  generateStoryArc(playerId: string): any {
    const history = this.playerBehaviorHistory.get(playerId);
    if (!history || history.length < 20) {
      return {
        type: 'tutorial',
        description: 'Welcome to Agervis. Learn the basics.',
      };
    }

    // Analyze player's playstyle
    const actionCounts = {
      combat: 0,
      social: 0,
      economy: 0,
      exploration: 0,
    };

    history.forEach((action) => {
      if (action.type === 'attack') actionCounts.combat++;
      if (action.type === 'chat') actionCounts.social++;
      if (action.type === 'buy' || action.type === 'sell') actionCounts.economy++;
      if (action.type === 'move') actionCounts.exploration++;
    });

    // Generate story based on dominant playstyle
    const dominant = Object.entries(actionCounts).sort((a, b) => b[1] - a[1])[0][0];

    const storyArcs: any = {
      combat: {
        type: 'gang-rivalry',
        description: 'A rival gang has noticed your fighting skills.',
      },
      social: {
        type: 'investigation',
        description: 'An NPC has a mystery for you to solve through conversation.',
      },
      economy: {
        type: 'business-empire',
        description: 'Become a wealthy business owner in the city.',
      },
      exploration: {
        type: 'hidden-secrets',
        description: 'Discover the hidden secrets of Agervis.',
      },
    };

    return storyArcs[dominant];
  }

  getStats() {
    return {
      ...this.stats,
      playerBehaviorTracked: this.playerBehaviorHistory.size,
      gameStateHistoryLength: this.gameStateHistory.length,
    };
  }
}
