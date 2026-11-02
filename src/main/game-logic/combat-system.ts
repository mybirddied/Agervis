/**
 * Combat System
 * Handles all combat mechanics, damage calculation, and death
 */

import { EventBus } from '../state/event-bus';
import { WorldStateManager } from '../state/world-state';

interface CombatEntity {
  id: string;
  health: number;
  maxHealth: number;
  damage: number;
  defense: number;
  attackSpeed: number;
  lastAttackTime: number;
  isDead: boolean;
}

export class CombatSystem {
  private combatants: Map<string, CombatEntity> = new Map();
  private attackQueue: Array<{
    attackerId: string;
    targetId: string;
    weaponId?: string;
    timestamp: number;
  }> = [];
  private totalDamageDealt: number = 0;
  private totalKills: number = 0;

  constructor(
    private eventBus: EventBus,
    private worldState: WorldStateManager
  ) {
    this.setupEventListeners();
  }

  private setupEventListeners(): void {
    this.eventBus.subscribe('combat-attack', (data: any) => {
      this.attackQueue.push({
        attackerId: data.attackerId,
        targetId: data.targetId,
        weaponId: data.weaponId,
        timestamp: data.timestamp,
      });
    });

    this.eventBus.subscribe('player-spawned', (data: any) => {
      this.registerCombatant(data.playerId, {
        health: 100,
        maxHealth: 100,
        damage: 10,
        defense: 0,
        attackSpeed: 1.0,
      });
    });

    this.eventBus.subscribe('npc-spawned', (data: any) => {
      this.registerCombatant(data.npcId, {
        health: data.health || 50,
        maxHealth: data.maxHealth || 50,
        damage: data.damage || 5,
        defense: data.defense || 0,
        attackSpeed: data.attackSpeed || 1.0,
      });
    });
  }

  /**
   * Register an entity for combat
   */
  registerCombatant(
    entityId: string,
    stats: {
      health: number;
      maxHealth: number;
      damage: number;
      defense: number;
      attackSpeed: number;
    }
  ): void {
    this.combatants.set(entityId, {
      id: entityId,
      health: stats.health,
      maxHealth: stats.maxHealth,
      damage: stats.damage,
      defense: stats.defense,
      attackSpeed: stats.attackSpeed,
      lastAttackTime: 0,
      isDead: false,
    });
  }

  /**
   * Update combat system
   */
  update(deltaTime: number): void {
    const now = Date.now();

    // Process all queued attacks
    while (this.attackQueue.length > 0) {
      const attack = this.attackQueue.shift()!;
      this.processAttack(attack.attackerId, attack.targetId, attack.weaponId, now);
    }

    // Process ongoing effects (DoT, healing over time, etc.)
    this.processEffects(deltaTime);
  }

  /**
   * Process a single attack
   */
  private processAttack(
    attackerId: string,
    targetId: string,
    weaponId: string | undefined,
    timestamp: number
  ): void {
    const attacker = this.combatants.get(attackerId);
    const target = this.combatants.get(targetId);

    if (!attacker || !target) {
      console.warn(`[Combat] Invalid combatant: ${attackerId} -> ${targetId}`);
      return;
    }

    if (attacker.isDead) {
      console.warn(`[Combat] Dead attacker tried to attack: ${attackerId}`);
      return;
    }

    if (target.isDead) {
      console.warn(`[Combat] Attack on dead target: ${targetId}`);
      return;
    }

    // Check attack cooldown
    const cooldown = 1000 / attacker.attackSpeed;
    if (timestamp - attacker.lastAttackTime < cooldown) {
      return; // Attack too soon
    }

    attacker.lastAttackTime = timestamp;

    // Calculate damage
    const baseDamage = attacker.damage;
    const weaponBonus = weaponId ? this.getWeaponDamage(weaponId) : 0;
    const totalDamage = Math.max(1, baseDamage + weaponBonus - target.defense);

    // Apply damage
    target.health -= totalDamage;
    this.totalDamageDealt += totalDamage;

    // Update world state
    this.worldState.updateEntity({
      id: targetId,
      state: { health: target.health },
    });

    // Publish damage event
    this.eventBus.publish('combat-damage', {
      attackerId,
      targetId,
      damage: totalDamage,
      timestamp,
    });

    // Check for death
    if (target.health <= 0) {
      this.handleDeath(targetId, attackerId);
    }
  }

  /**
   * Handle entity death
   */
  private handleDeath(entityId: string, killerId: string): void {
    const entity = this.combatants.get(entityId);
    if (!entity) return;

    entity.isDead = true;
    entity.health = 0;
    this.totalKills++;

    // Update world state
    this.worldState.updateEntity({
      id: entityId,
      state: { isDead: true, health: 0 },
    });

    // Publish death event
    this.eventBus.publish('combat-death', {
      entityId,
      killerId,
      timestamp: Date.now(),
    });

    // Remove from combatants after a delay (for respawn logic)
    setTimeout(() => {
      this.combatants.delete(entityId);
    }, 5000);
  }

  /**
   * Process ongoing combat effects
   */
  private processEffects(deltaTime: number): void {
    // TODO: Implement DoT, HoT, buffs, debuffs
  }

  /**
   * Get weapon damage bonus
   */
  private getWeaponDamage(weaponId: string): number {
    // TODO: Look up weapon stats from database
    return 5; // Placeholder
  }

  /**
   * Heal an entity
   */
  heal(entityId: string, amount: number): void {
    const entity = this.combatants.get(entityId);
    if (!entity || entity.isDead) return;

    entity.health = Math.min(entity.maxHealth, entity.health + amount);

    this.worldState.updateEntity({
      id: entityId,
      state: { health: entity.health },
    });

    this.eventBus.publish('combat-heal', {
      entityId,
      amount,
      newHealth: entity.health,
    });
  }

  /**
   * Get combat stats for an entity
   */
  getCombatant(entityId: string): CombatEntity | undefined {
    return this.combatants.get(entityId);
  }

  getStats() {
    return {
      activeCombatants: this.combatants.size,
      queuedAttacks: this.attackQueue.length,
      totalDamageDealt: this.totalDamageDealt,
      totalKills: this.totalKills,
    };
  }
}
