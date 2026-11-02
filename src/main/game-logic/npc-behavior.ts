/**
 * NPC Behavior System
 * Handles NPC movement, actions, and AI-driven behaviors
 */

import { EventBus } from '../state/event-bus';
import { WorldStateManager } from '../state/world-state';

interface NPC {
  id: string;
  type: string;
  name: string;
  position: { x: number; y: number };
  state: string; // 'idle', 'walking', 'talking', 'working', 'fleeing'
  personality: string;
  currentAction?: string;
  targetPosition?: { x: number; y: number };
  conversationPartnerId?: string;
  lastUpdateTime: number;
}

export class NPCBehaviorSystem {
  private npcs: Map<string, NPC> = new Map();
  private updateInterval: number = 1000; // Update NPC behaviors every second
  private lastUpdateTime: number = 0;

  constructor(
    private eventBus: EventBus,
    private worldState: WorldStateManager
  ) {
    this.setupEventListeners();
    this.spawnInitialNPCs();
  }

  private setupEventListeners(): void {
    this.eventBus.subscribe('npc-spawn', (data: any) => {
      this.spawnNPC(data);
    });

    this.eventBus.subscribe('player-interact', (data: any) => {
      if (data.interactionType === 'talk') {
        this.startConversation(data.targetId, data.playerId);
      }
    });

    this.eventBus.subscribe('combat-damage', (data: any) => {
      const npc = this.npcs.get(data.targetId);
      if (npc && npc.type === 'civilian') {
        // Civilians flee when attacked
        this.makeNPCFlee(npc.id);
      }
    });
  }

  /**
   * Spawn initial NPCs
   */
  private spawnInitialNPCs(): void {
    const initialNPCs = [
      { type: 'shopkeeper', name: 'Marcus', x: 100, y: 50, personality: 'friendly' },
      { type: 'civilian', name: 'Jane', x: 200, y: 100, personality: 'nervous' },
      { type: 'civilian', name: 'Bob', x: 300, y: 150, personality: 'curious' },
      { type: 'police', name: 'Officer Davis', x: 400, y: 200, personality: 'stern' },
      { type: 'criminal', name: 'Shadow', x: 500, y: 250, personality: 'aggressive' },
    ];

    initialNPCs.forEach((npcData) => {
      this.spawnNPC(npcData);
    });
  }

  /**
   * Spawn a new NPC
   */
  spawnNPC(data: {
    type: string;
    name: string;
    x: number;
    y: number;
    personality: string;
  }): string {
    const npcId = `npc-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

    const npc: NPC = {
      id: npcId,
      type: data.type,
      name: data.name,
      position: { x: data.x, y: data.y },
      state: 'idle',
      personality: data.personality,
      lastUpdateTime: Date.now(),
    };

    this.npcs.set(npcId, npc);

    // Add to world state
    this.worldState.updateEntity({
      id: npcId,
      type: 'npc',
      position: { x: data.x, y: data.y, z: 0 },
      state: {
        npcType: data.type,
        name: data.name,
        personality: data.personality,
        state: 'idle',
      },
    });

    // Publish spawn event
    this.eventBus.publish('npc-spawned', {
      npcId,
      type: data.type,
      name: data.name,
      position: npc.position,
      health: 50,
      maxHealth: 50,
      damage: 5,
      defense: 0,
      attackSpeed: 1.0,
    });

    console.log(`[NPC] Spawned ${data.name} (${data.type}) at ${data.x}, ${data.y}`);
    return npcId;
  }

  /**
   * Update all NPCs
   */
  update(deltaTime: number): void {
    const now = Date.now();

    // Only update NPCs every second (not every tick)
    if (now - this.lastUpdateTime < this.updateInterval) {
      return;
    }

    this.lastUpdateTime = now;

    this.npcs.forEach((npc) => {
      this.updateNPC(npc, deltaTime);
    });
  }

  /**
   * Update a single NPC
   */
  private updateNPC(npc: NPC, deltaTime: number): void {
    switch (npc.state) {
      case 'idle':
        this.updateIdleNPC(npc);
        break;
      case 'walking':
        this.updateWalkingNPC(npc, deltaTime);
        break;
      case 'talking':
        // Conversation is handled by AI system
        break;
      case 'working':
        // NPCs working at their jobs
        break;
      case 'fleeing':
        this.updateFleeingNPC(npc, deltaTime);
        break;
    }
  }

  /**
   * Update idle NPC (random chance to start walking)
   */
  private updateIdleNPC(npc: NPC): void {
    // 10% chance to start walking somewhere
    if (Math.random() < 0.1) {
      this.makeNPCWalk(npc.id);
    }
  }

  /**
   * Update walking NPC
   */
  private updateWalkingNPC(npc: NPC, deltaTime: number): void {
    if (!npc.targetPosition) {
      npc.state = 'idle';
      return;
    }

    const speed = 50; // pixels per second
    const dx = npc.targetPosition.x - npc.position.x;
    const dy = npc.targetPosition.y - npc.position.y;
    const distance = Math.sqrt(dx * dx + dy * dy);

    if (distance < 5) {
      // Reached destination
      npc.position = { ...npc.targetPosition };
      npc.targetPosition = undefined;
      npc.state = 'idle';
    } else {
      // Move towards target
      const moveX = (dx / distance) * speed * deltaTime;
      const moveY = (dy / distance) * speed * deltaTime;
      npc.position.x += moveX;
      npc.position.y += moveY;
    }

    // Update world state
    this.worldState.updateEntity({
      id: npc.id,
      position: { x: npc.position.x, y: npc.position.y, z: 0 },
      state: { state: npc.state },
    });
  }

  /**
   * Update fleeing NPC
   */
  private updateFleeingNPC(npc: NPC, deltaTime: number): void {
    if (!npc.targetPosition) {
      // Pick a random far-away position
      npc.targetPosition = {
        x: npc.position.x + (Math.random() - 0.5) * 500,
        y: npc.position.y + (Math.random() - 0.5) * 500,
      };
    }

    const speed = 100; // Flee faster than normal walk
    const dx = npc.targetPosition.x - npc.position.x;
    const dy = npc.targetPosition.y - npc.position.y;
    const distance = Math.sqrt(dx * dx + dy * dy);

    if (distance < 10) {
      // Safe now, return to idle
      npc.state = 'idle';
      npc.targetPosition = undefined;
    } else {
      const moveX = (dx / distance) * speed * deltaTime;
      const moveY = (dy / distance) * speed * deltaTime;
      npc.position.x += moveX;
      npc.position.y += moveY;
    }

    this.worldState.updateEntity({
      id: npc.id,
      position: { x: npc.position.x, y: npc.position.y, z: 0 },
      state: { state: npc.state },
    });
  }

  /**
   * Make NPC walk to a random location
   */
  private makeNPCWalk(npcId: string): void {
    const npc = this.npcs.get(npcId);
    if (!npc) return;

    npc.state = 'walking';
    npc.targetPosition = {
      x: npc.position.x + (Math.random() - 0.5) * 200,
      y: npc.position.y + (Math.random() - 0.5) * 200,
    };
  }

  /**
   * Make NPC flee from danger
   */
  private makeNPCFlee(npcId: string): void {
    const npc = this.npcs.get(npcId);
    if (!npc) return;

    npc.state = 'fleeing';
    npc.targetPosition = undefined; // Will be set in update

    this.eventBus.publish('npc-fleeing', { npcId, npcName: npc.name });
  }

  /**
   * Start conversation between player and NPC
   */
  private startConversation(npcId: string, playerId: string): void {
    const npc = this.npcs.get(npcId);
    if (!npc) return;

    npc.state = 'talking';
    npc.conversationPartnerId = playerId;

    this.worldState.updateEntity({
      id: npcId,
      state: { state: 'talking', conversationWith: playerId },
    });

    // Publish conversation start event (AI system will handle dialogue)
    this.eventBus.publish('conversation-start', {
      npcId,
      playerId,
      npcName: npc.name,
      npcPersonality: npc.personality,
      npcType: npc.type,
    });
  }

  /**
   * End conversation
   */
  endConversation(npcId: string): void {
    const npc = this.npcs.get(npcId);
    if (!npc) return;

    npc.state = 'idle';
    npc.conversationPartnerId = undefined;

    this.worldState.updateEntity({
      id: npcId,
      state: { state: 'idle', conversationWith: null },
    });
  }

  /**
   * Get NPC by ID
   */
  getNPC(npcId: string): NPC | undefined {
    return this.npcs.get(npcId);
  }

  /**
   * Get all NPCs
   */
  getAllNPCs(): NPC[] {
    return Array.from(this.npcs.values());
  }

  getStats() {
    const states = {
      idle: 0,
      walking: 0,
      talking: 0,
      working: 0,
      fleeing: 0,
    };

    this.npcs.forEach((npc) => {
      states[npc.state as keyof typeof states]++;
    });

    return {
      totalNPCs: this.npcs.size,
      stateBreakdown: states,
    };
  }
}
