/**
 * NPC Controller System
 * Manages NPC behavior, roaming, and customer cycles
 */

export type NPCState = 'idle' | 'roaming' | 'working' | 'eating' | 'sleeping' | 'interacting';
export type NPCRole = 'shopkeeper' | 'customer' | 'employee' | 'criminal' | 'police' | 'civilian';

export interface NPCStats {
  energy: number; // 0-100
  hunger: number; // 0-100
  stress: number; // 0-100
  mood: number; // -100 to 100
}

export interface NPC {
  id: string;
  name: string;
  role: NPCRole;
  location: string;
  state: NPCState;
  stats: NPCStats;
  schedule: ScheduleEntry[];
  currentScheduleIndex: number;
  reactions: Map<string, number>; // event -> stress impact
}

export interface ScheduleEntry {
  time: number; // 0-1439 (minutes in day)
  location: string;
  action: string;
  duration: number; // minutes
}

export class NPCController {
  private npcs: Map<string, NPC> = new Map();
  private gameTime: number = 0; // minutes since game start

  /**
   * Create a new NPC
   */
  createNPC(
    name: string,
    role: NPCRole,
    startLocation: string,
    schedule: ScheduleEntry[]
  ): NPC {
    const npcId = `npc_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const npc: NPC = {
      id: npcId,
      name,
      role,
      location: startLocation,
      state: 'idle',
      stats: {
        energy: 80,
        hunger: 50,
        stress: 0,
        mood: 50,
      },
      schedule,
      currentScheduleIndex: 0,
      reactions: new Map(),
    };
    this.npcs.set(npcId, npc);
    return npc;
  }

  /**
   * Update NPC state based on schedule and time
   */
  updateNPC(npcId: string, deltaTime: number): void {
    const npc = this.npcs.get(npcId);
    if (!npc) return;

    this.gameTime += deltaTime;

    // Check schedule
    const currentMinute = this.gameTime % 1440; // 24 hours in minutes
    const scheduleEntry = npc.schedule.find(
      (entry) =>
        currentMinute >= entry.time &&
        currentMinute < entry.time + entry.duration
    );

    if (scheduleEntry) {
      npc.location = scheduleEntry.location;
      npc.state = scheduleEntry.action as NPCState;
    } else {
      npc.state = 'roaming';
    }

    // Update stats
    this.updateNPCStats(npc, deltaTime);
  }

  /**
   * Update NPC stats over time
   */
  private updateNPCStats(npc: NPC, deltaTime: number): void {
    // Energy drains over time, faster when working
    const energyDrainRate = npc.state === 'working' ? 0.5 : 0.2;
    npc.stats.energy = Math.max(0, npc.stats.energy - (energyDrainRate * deltaTime) / 60);

    // Hunger increases over time
    npc.stats.hunger = Math.min(100, npc.stats.hunger + (0.3 * deltaTime) / 60);

    // Stress naturally decreases slowly
    npc.stats.stress = Math.max(0, npc.stats.stress - (0.1 * deltaTime) / 60);

    // Mood improves with rest, decreases with hunger/stress
    const moodFactors = {
      sleep: npc.state === 'sleeping' ? 20 : 0,
      hunger: -npc.stats.hunger * 0.5,
      stress: -npc.stats.stress * 0.3,
    };

    npc.stats.mood = Math.max(
      -100,
      Math.min(100, npc.stats.mood + Object.values(moodFactors).reduce((a, b) => a + b, 0) * (deltaTime / 60))
    );

    // Restore energy when sleeping
    if (npc.state === 'sleeping') {
      npc.stats.energy = Math.min(100, npc.stats.energy + 1 * deltaTime / 60);
    }

    // Reduce hunger when eating
    if (npc.state === 'eating') {
      npc.stats.hunger = Math.max(0, npc.stats.hunger - 2 * deltaTime / 60);
    }
  }

  /**
   * NPC reacts to events (crimes, explosions, etc.)
   */
  reactToEvent(npcId: string, eventType: string, stressAmount: number = 20): void {
    const npc = this.npcs.get(npcId);
    if (!npc) return;

    npc.stats.stress = Math.min(100, npc.stats.stress + stressAmount);
    npc.reactions.set(eventType, (npc.reactions.get(eventType) || 0) + 1);

    // High stress changes state
    if (npc.stats.stress > 80) {
      npc.state = 'idle'; // freeze in fear
    }
  }

  /**
   * Get NPC by ID
   */
  getNPC(npcId: string): NPC | null {
    return this.npcs.get(npcId) || null;
  }

  /**
   * Get all NPCs in location
   */
  getNPCsInLocation(location: string): NPC[] {
    return Array.from(this.npcs.values()).filter((npc) => npc.location === location);
  }

  /**
   * Get all NPCs by role
   */
  getNPCsByRole(role: NPCRole): NPC[] {
    return Array.from(this.npcs.values()).filter((npc) => npc.role === role);
  }
}
