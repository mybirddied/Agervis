/**
 * Advanced AI Features
 * Adaptive storytelling, economy balancing, behavior prediction, and more
 */

import { EventBus } from '../state/event-bus';
import { WorldStateManager } from '../state/world-state';
import { AIDirector } from './director';
import { WorkerPool } from '../threading/worker-pool';

interface StoryArc {
  playerId: string;
  arcType: string;
  title: string;
  description: string;
  stage: number;
  maxStages: number;
  objectives: string[];
  rewards: any[];
  startedAt: number;
  lastProgressAt: number;
}

interface PlayerProfile {
  playerId: string;
  playstyle: {
    combat: number;
    social: number;
    economy: number;
    exploration: number;
  };
  preferences: string[];
  completedArcs: string[];
  currentArc?: string;
}

interface EconomyBalance {
  averagePlayerMoney: number;
  totalMoneyInCirculation: number;
  priceInflation: number;
  transactionVolume: number;
  wealthDistribution: number[];
}

export class AdvancedAIFeatures {
  private storyArcs: Map<string, StoryArc> = new Map();
  private playerProfiles: Map<string, PlayerProfile> = new Map();
  private economyHistory: EconomyBalance[] = [];
  private behaviorPredictions: Map<string, { action: string; confidence: number }> = new Map();

  constructor(
    private eventBus: EventBus,
    private worldState: WorldStateManager,
    private aiDirector: AIDirector,
    private workerPool: WorkerPool | null
  ) {
    this.setupEventListeners();
  }

  private setupEventListeners(): void {
    this.eventBus.subscribe('player-spawned', (data: any) => {
      this.initializePlayerProfile(data.playerId);
    });

    this.eventBus.subscribe('player-action', (data: any) => {
      this.updatePlayerProfile(data.playerId, data.actionType);
    });

    this.eventBus.subscribe('story-arc-progress', (data: any) => {
      this.progressStoryArc(data.playerId, data.objective);
    });

    this.eventBus.subscribe('economy-transaction-success', (data: any) => {
      this.trackEconomyTransaction(data);
    });
  }

  /**
   * Initialize player profile for adaptive storytelling
   */
  private initializePlayerProfile(playerId: string): void {
    this.playerProfiles.set(playerId, {
      playerId,
      playstyle: {
        combat: 0,
        social: 0,
        economy: 0,
        exploration: 0,
      },
      preferences: [],
      completedArcs: [],
    });

    console.log(`[Advanced AI] Initialized profile for player ${playerId}`);
  }

  /**
   * Update player profile based on actions
   */
  private updatePlayerProfile(playerId: string, actionType: string): void {
    const profile = this.playerProfiles.get(playerId);
    if (!profile) return;

    // Update playstyle weights
    switch (actionType) {
      case 'attack':
      case 'combat':
        profile.playstyle.combat += 1;
        break;
      case 'chat':
      case 'interact':
        profile.playstyle.social += 1;
        break;
      case 'buy':
      case 'sell':
      case 'trade':
        profile.playstyle.economy += 1;
        break;
      case 'move':
      case 'explore':
        profile.playstyle.exploration += 1;
        break;
    }

    // Check if player should get a new story arc
    if (!profile.currentArc) {
      this.generateStoryArc(playerId);
    }
  }

  /**
   * Generate adaptive story arc based on player behavior
   */
  generateStoryArc(playerId: string): void {
    const profile = this.playerProfiles.get(playerId);
    if (!profile) return;

    // Determine dominant playstyle
    const styles = profile.playstyle;
    const total = styles.combat + styles.social + styles.economy + styles.exploration;
    if (total < 20) return; // Not enough data yet

    const dominant = Object.entries(styles)
      .sort(([, a], [, b]) => b - a)[0][0] as keyof typeof styles;

    // Generate appropriate story arc
    const arcTemplates: Record<string, { title: string; description: string; objectives: string[] }> = {
      combat: {
        title: 'Gang War',
        description: 'A rival gang is threatening your territory. Fight back and establish dominance.',
        objectives: [
          'Defeat 5 rival gang members',
          'Capture their hideout',
          'Defeat the gang leader',
        ],
      },
      social: {
        title: 'The Informant Network',
        description: 'Build a network of informants across the city to gather valuable intel.',
        objectives: [
          'Talk to 10 different NPCs',
          'Complete 3 information gathering tasks',
          'Establish your reputation as a reliable contact',
        ],
      },
      economy: {
        title: 'Business Empire',
        description: 'Build your fortune through smart trading and business ventures.',
        objectives: [
          'Accumulate $1000',
          'Complete 10 successful trades',
          'Own a business property',
        ],
      },
      exploration: {
        title: 'Hidden Secrets',
        description: 'Discover the hidden corners of Agervis and uncover its mysteries.',
        objectives: [
          'Explore 5 different districts',
          'Find 3 hidden locations',
          'Discover the secret underground area',
        ],
      },
    };

    const template = arcTemplates[dominant];
    const arcId = `arc-${playerId}-${Date.now()}`;

    const arc: StoryArc = {
      playerId,
      arcType: dominant,
      title: template.title,
      description: template.description,
      stage: 0,
      maxStages: template.objectives.length,
      objectives: template.objectives,
      rewards: [
        { type: 'money', amount: 500 },
        { type: 'item', itemId: 'special-weapon' },
        { type: 'title', title: `${dominant}-master` },
      ],
      startedAt: Date.now(),
      lastProgressAt: Date.now(),
    };

    this.storyArcs.set(arcId, arc);
    profile.currentArc = arcId;

    this.eventBus.publish('story-arc-started', {
      playerId,
      arc,
    });

    console.log(`[Advanced AI] Generated ${dominant} story arc for player ${playerId}`);
  }

  /**
   * Progress a story arc
   */
  private progressStoryArc(playerId: string, objectiveCompleted: string): void {
    const profile = this.playerProfiles.get(playerId);
    if (!profile || !profile.currentArc) return;

    const arc = this.storyArcs.get(profile.currentArc);
    if (!arc) return;

    arc.stage++;
    arc.lastProgressAt = Date.now();

    if (arc.stage >= arc.maxStages) {
      // Arc complete
      this.completeStoryArc(playerId, profile.currentArc);
    } else {
      this.eventBus.publish('story-arc-progress', {
        playerId,
        arc,
        nextObjective: arc.objectives[arc.stage],
      });
    }
  }

  /**
   * Complete a story arc and give rewards
   */
  private completeStoryArc(playerId: string, arcId: string): void {
    const profile = this.playerProfiles.get(playerId);
    const arc = this.storyArcs.get(arcId);
    if (!profile || !arc) return;

    profile.completedArcs.push(arcId);
    profile.currentArc = undefined;

    // Give rewards
    arc.rewards.forEach((reward) => {
      this.eventBus.publish('player-reward', {
        playerId,
        rewardType: reward.type,
        reward,
      });
    });

    this.eventBus.publish('story-arc-completed', {
      playerId,
      arc,
    });

    console.log(`[Advanced AI] Player ${playerId} completed story arc: ${arc.title}`);

    // Generate next arc after a delay
    setTimeout(() => {
      this.generateStoryArc(playerId);
    }, 60000); // 1 minute cooldown
  }

  /**
   * Track economy transactions for balancing
   */
  private trackEconomyTransaction(data: any): void {
    // This would be called by economy system
    // Aggregate and analyze for balancing
  }

  /**
   * Balance economy based on trends
   */
  analyzeAndBalanceEconomy(): void {
    if (this.economyHistory.length < 10) return; // Need more data

    const recent = this.economyHistory.slice(-10);
    const avgInflation = recent.reduce((sum, e) => sum + e.priceInflation, 0) / 10;

    if (avgInflation > 1.5) {
      // High inflation, reduce money rewards
      this.eventBus.publish('economy-adjustment', {
        type: 'reduce-rewards',
        factor: 0.8,
        reason: 'high-inflation',
      });
      console.log('[Advanced AI] Reducing rewards due to inflation');
    } else if (avgInflation < 0.5) {
      // Deflation, increase money circulation
      this.eventBus.publish('economy-adjustment', {
        type: 'increase-rewards',
        factor: 1.2,
        reason: 'deflation',
      });
      console.log('[Advanced AI] Increasing rewards due to deflation');
    }
  }

  /**
   * Predict player's next action
   */
  predictPlayerAction(playerId: string): { action: string; confidence: number } | null {
    const profile = this.playerProfiles.get(playerId);
    if (!profile) return null;

    const prediction = this.aiDirector.predictPlayerAction(playerId);
    if (prediction) {
      const styles = profile.playstyle;
      const total = styles.combat + styles.social + styles.economy + styles.exploration;

      // Calculate confidence based on consistency
      let confidence = 0;
      if (prediction === 'attack') confidence = styles.combat / total;
      else if (prediction === 'interact') confidence = styles.social / total;
      else if (prediction === 'buy') confidence = styles.economy / total;

      this.behaviorPredictions.set(playerId, { action: prediction, confidence });
      return { action: prediction, confidence };
    }

    return null;
  }

  /**
   * Dungeon Master Mode: Dynamically adjust difficulty
   */
  adjustDifficulty(playerId: string): void {
    const profile = this.playerProfiles.get(playerId);
    if (!profile) return;

    // Analyze player performance
    const recentArc = profile.currentArc ? this.storyArcs.get(profile.currentArc) : null;

    if (recentArc) {
      const timeSinceStart = Date.now() - recentArc.startedAt;
      const progressRate = recentArc.stage / (timeSinceStart / 1000 / 60); // stages per minute

      if (progressRate > 2) {
        // Player progressing too fast, increase difficulty
        this.eventBus.publish('difficulty-adjustment', {
          playerId,
          adjustment: 'increase',
          factor: 1.2,
        });
        console.log(`[Advanced AI] Increasing difficulty for player ${playerId}`);
      } else if (progressRate < 0.5) {
        // Player struggling, decrease difficulty
        this.eventBus.publish('difficulty-adjustment', {
          playerId,
          adjustment: 'decrease',
          factor: 0.8,
        });
        console.log(`[Advanced AI] Decreasing difficulty for player ${playerId}`);
      }
    }
  }

  /**
   * Faction system with AI-driven relationships
   */
  updateFactionRelationship(playerId: string, faction: string, delta: number): void {
    this.eventBus.publish('faction-relationship-change', {
      playerId,
      faction,
      delta,
    });

    // AI analyzes consequences
    if (delta < -10) {
      // Player made an enemy
      this.eventBus.publish('faction-hostile', {
        playerId,
        faction,
        consequence: 'faction-members-attack-on-sight',
      });
    } else if (delta > 20) {
      // Player made an ally
      this.eventBus.publish('faction-friendly', {
        playerId,
        faction,
        benefit: 'discount-at-faction-shops',
      });
    }
  }

  /**
   * Player mentor system
   */
  assignMentor(newPlayerId: string, veteranPlayerId: string): void {
    this.eventBus.publish('mentor-assigned', {
      mentee: newPlayerId,
      mentor: veteranPlayerId,
      rewards: {
        mentee: { type: 'xp-boost', amount: 1.5 },
        mentor: { type: 'money', amount: 100 },
      },
    });

    console.log(`[Advanced AI] Assigned ${veteranPlayerId} as mentor to ${newPlayerId}`);
  }

  getStats() {
    return {
      activeStoryArcs: this.storyArcs.size,
      trackedPlayers: this.playerProfiles.size,
      economyDataPoints: this.economyHistory.length,
      behaviorPredictions: this.behaviorPredictions.size,
    };
  }
}
