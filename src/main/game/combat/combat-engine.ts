/**
 * Combat Resolution Engine
 * Frame-based fighting mechanics with damage calculation
 */

export type MartialArtStyle =
  | 'boxing' | 'muay-thai' | 'karate' | 'judo'
  | 'wrestling' | 'kickboxing' | 'street-fighting';

export interface CombatStats {
  health: number;
  stamina: number;
  strength: number;
  agility: number;
  endurance: number;
}

export interface CombatAction {
  type: 'attack' | 'defend' | 'dodge' | 'grapple' | 'combo';
  martialArt: MartialArtStyle;
  power: number; // 0-100
  frame: number;
  staminarCost: number;
}

export interface CombatResult {
  damageDealt: number;
  damageReceived: number;
  staminaUsed: number;
  hitLanded: boolean;
  criticalHit: boolean;
  comboCounter: number;
}

export class CombatEngine {
  private frameRate: number = 60;
  private currentFrame: number = 0;

  /**
   * Calculate damage based on martial arts style and combat stats
   */
  calculateDamage(
    attacker: CombatStats,
    action: CombatAction,
    defender: CombatStats
  ): number {
    const baseMultiplier = this.getMartialArtMultiplier(action.martialArt);
    const powerFactor = action.power / 100;
    const strengthBonus = attacker.strength * 0.5;
    const agiltiyPenalty = defender.agility * 0.3;

    let damage = (baseMultiplier * 10 + strengthBonus) * powerFactor;
    damage = Math.max(0, damage - agiltiyPenalty);

    // Critical hit chance: 5% base + agility bonus
    const critChance = 0.05 + (attacker.agility * 0.001);
    if (Math.random() < critChance) {
      damage *= 1.5;
    }

    return Math.round(damage);
  }

  /**
   * Get martial art style multiplier
   */
  private getMartialArtMultiplier(style: MartialArtStyle): number {
    const multipliers: Record<MartialArtStyle, number> = {
      'boxing': 1.0,
      'muay-thai': 1.2,
      'karate': 1.1,
      'judo': 0.9,
      'wrestling': 0.85,
      'kickboxing': 1.15,
      'street-fighting': 0.95,
    };
    return multipliers[style] || 1.0;
  }

  /**
   * Resolve a combat exchange
   */
  resolveCombatTurn(
    attacker: CombatStats,
    attackerAction: CombatAction,
    defender: CombatStats,
    defenderAction: CombatAction
  ): CombatResult {
    const hitChance = this.calculateHitChance(
      attacker.agility,
      defender.agility,
      defenderAction
    );

    const hitLanded = Math.random() < hitChance;
    const damageDealt = hitLanded
      ? this.calculateDamage(attacker, attackerAction, defender)
      : 0;

    const defenderCounterDamage = defenderAction.type === 'defend'
      ? Math.round(defenderAction.power * 2)
      : 0;

    return {
      damageDealt,
      damageReceived: defenderCounterDamage,
      staminaUsed: attackerAction.staminarCost,
      hitLanded,
      criticalHit: damageDealt > this.calculateDamage(attacker, attackerAction, defender) * 1.3,
      comboCounter: hitLanded ? 1 : 0,
    };
  }

  /**
   * Calculate hit chance based on attacker agility, defender agility, and defense action
   */
  private calculateHitChance(
    attackerAgility: number,
    defenderAgility: number,
    defenderAction: CombatAction
  ): number {
    let baseHitChance = 0.75;
    baseHitChance += (attackerAgility - defenderAgility) * 0.01;

    if (defenderAction.type === 'dodge') {
      baseHitChance -= 0.3;
    } else if (defenderAction.type === 'defend') {
      baseHitChance -= 0.2;
    }

    return Math.max(0.1, Math.min(0.95, baseHitChance));
  }

  /**
   * Advance frame counter
   */
  advanceFrame(): void {
    this.currentFrame++;
  }

  /**
   * Get current frame
   */
  getCurrentFrame(): number {
    return this.currentFrame;
  }

  /**
   * Reset frame counter
   */
  resetFrameCounter(): void {
    this.currentFrame = 0;
  }
}
