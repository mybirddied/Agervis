/**
 * Injury & Health System
 * Damage, healing, and status effects
 */

export type StatusEffect = 'bleeding' | 'poisoned' | 'stunned' | 'exhausted' | 'infected' | 'broken_bone';

export interface Injury {
  id: string;
  type: string;
  severity: number; // 1-10
  location: string; // body part
  bleedingRate: number;
  healingProgress: number; // 0-100
}

export interface HealthState {
  playerId: string;
  health: number; // 0-100
  maxHealth: number;
  stamina: number; // 0-100
  maxStamina: number;
  injuries: Injury[];
  statusEffects: Map<StatusEffect, number>; // effect -> duration in minutes
}

export class HealthSystem {
  private playerHealth: Map<string, HealthState> = new Map();

  /**
   * Initialize player health
   */
  initializePlayerHealth(playerId: string): HealthState {
    if (this.playerHealth.has(playerId)) {
      return this.playerHealth.get(playerId)!;
    }

    const health: HealthState = {
      playerId,
      health: 100,
      maxHealth: 100,
      stamina: 100,
      maxStamina: 100,
      injuries: [],
      statusEffects: new Map(),
    };
    this.playerHealth.set(playerId, health);
    return health;
  }

  /**
   * Apply damage
   */
  takeDamage(playerId: string, amount: number, damageType: string = 'general'): void {
    const state = this.initializePlayerHealth(playerId);
    state.health = Math.max(0, state.health - amount);

    // Create injury if significant damage
    if (amount > 5) {
      this.createInjury(playerId, damageType, Math.ceil(amount / 10), 'torso');
    }

    // Check if dead
    if (state.health <= 0) {
      this.addStatusEffect(playerId, 'exhausted', 60); // penalty for near-death
    }
  }

  /**
   * Heal damage
   */
  heal(playerId: string, amount: number): void {
    const state = this.initializePlayerHealth(playerId);
    state.health = Math.min(state.maxHealth, state.health + amount);
  }

  /**
   * Create injury
   */
  createInjury(playerId: string, type: string, severity: number, location: string): Injury {
    const state = this.initializePlayerHealth(playerId);

    const injury: Injury = {
      id: `injury_${Date.now()}`,
      type,
      severity: Math.min(10, severity),
      location,
      bleedingRate: severity > 3 ? severity * 0.5 : 0,
      healingProgress: 0,
    };

    state.injuries.push(injury);

    // Add status effects based on injury
    if (type === 'fracture') {
      this.addStatusEffect(playerId, 'broken_bone', 1440); // 24 hours
    } else if (type === 'cut') {
      this.addStatusEffect(playerId, 'bleeding', 60 * severity); // scales with severity
    }

    return injury;
  }

  /**
   * Add status effect
   */
  addStatusEffect(playerId: string, effect: StatusEffect, durationMinutes: number): void {
    const state = this.initializePlayerHealth(playerId);
    state.statusEffects.set(effect, Math.max(durationMinutes, state.statusEffects.get(effect) || 0));
  }

  /**
   * Remove status effect
   */
  removeStatusEffect(playerId: string, effect: StatusEffect): void {
    const state = this.initializePlayerHealth(playerId);
    state.statusEffects.delete(effect);
  }

  /**
   * Update health over time
   */
  updateHealth(playerId: string, deltaMinutes: number): void {
    const state = this.initializePlayerHealth(playerId);

    // Bleeding damage
    let bleedingDamage = 0;
    for (const injury of state.injuries) {
      if (injury.bleedingRate > 0) {
        bleedingDamage += injury.bleedingRate * (deltaMinutes / 60);
      }
    }
    if (bleedingDamage > 0) {
      this.takeDamage(playerId, bleedingDamage, 'bleeding');
    }

    // Natural healing
    const naturalHealing = deltaMinutes * 0.1; // 0.1 hp per minute
    this.heal(playerId, naturalHealing);

    // Update injuries
    for (const injury of state.injuries) {
      injury.healingProgress = Math.min(100, injury.healingProgress + deltaMinutes * 0.5);
      if (injury.healingProgress >= 100) {
        state.injuries = state.injuries.filter((i) => i.id !== injury.id);
      }
    }

    // Decay status effects
    for (const [effect, duration] of state.statusEffects.entries()) {
      const newDuration = duration - deltaMinutes;
      if (newDuration <= 0) {
        state.statusEffects.delete(effect);
      } else {
        state.statusEffects.set(effect, newDuration);
      }
    }

    // Stamina recovery
    state.stamina = Math.min(state.maxStamina, state.stamina + deltaMinutes * 0.5);
  }

  /**
   * Use stamina
   */
  useStamina(playerId: string, amount: number): boolean {
    const state = this.initializePlayerHealth(playerId);
    if (state.stamina < amount) return false;
    state.stamina -= amount;
    return true;
  }

  /**
   * Get health state
   */
  getHealthState(playerId: string): HealthState {
    return this.initializePlayerHealth(playerId);
  }

  /**
   * Is player alive
   */
  isAlive(playerId: string): boolean {
    const state = this.getHealthState(playerId);
    return state.health > 0;
  }
}
