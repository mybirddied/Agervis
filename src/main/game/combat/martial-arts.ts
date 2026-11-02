/**
 * Martial Arts Skill System
 * Defines martial arts styles and their characteristics
 */

export interface MartialArtStyle {
  name: string;
  baseDamage: number;
  speed: number; // 0-100, higher = faster
  accuracy: number; // 0-100
  staminaCost: number;
  requirements: {
    strength?: number;
    agility?: number;
    endurance?: number;
  };
  techniques: string[];
}

export const MARTIAL_ART_STYLES: Record<string, MartialArtStyle> = {
  boxing: {
    name: 'Boxing',
    baseDamage: 8,
    speed: 85,
    accuracy: 80,
    staminaCost: 15,
    requirements: { strength: 50, agility: 60 },
    techniques: ['jab', 'cross', 'uppercut', 'hook', 'bob-and-weave'],
  },
  muayThai: {
    name: 'Muay Thai',
    baseDamage: 12,
    speed: 70,
    accuracy: 75,
    staminaCost: 20,
    requirements: { strength: 60, agility: 55, endurance: 60 },
    techniques: ['kick', 'elbow-strike', 'knee-strike', 'clinch', 'round-kick'],
  },
  karate: {
    name: 'Karate',
    baseDamage: 10,
    speed: 80,
    accuracy: 85,
    staminaCost: 18,
    requirements: { strength: 55, agility: 65 },
    techniques: ['punch', 'kick', 'kata', 'block', 'palm-strike'],
  },
  judo: {
    name: 'Judo',
    baseDamage: 7,
    speed: 65,
    accuracy: 90,
    staminaCost: 12,
    requirements: { strength: 70, agility: 50 },
    techniques: ['throw', 'pin', 'lock', 'hip-throw', 'sacrifice-throw'],
  },
  wrestling: {
    name: 'Wrestling',
    baseDamage: 6,
    speed: 60,
    accuracy: 85,
    staminaCost: 10,
    requirements: { strength: 75, endurance: 70 },
    techniques: ['takedown', 'pin', 'submission', 'grapple', 'reversal'],
  },
  kickboxing: {
    name: 'Kickboxing',
    baseDamage: 11,
    speed: 75,
    accuracy: 78,
    staminaCost: 19,
    requirements: { strength: 55, agility: 65, endurance: 55 },
    techniques: ['kick', 'punch', 'spin-kick', 'low-kick', 'head-kick'],
  },
  streetFighting: {
    name: 'Street Fighting',
    baseDamage: 9,
    speed: 70,
    accuracy: 70,
    staminaCost: 16,
    requirements: { strength: 50, agility: 55 },
    techniques: ['headbutt', 'knee-strike', 'elbow-strike', 'dirty-tactics', 'dirty-box'],
  },
};

export class MartialArtsSystem {
  /**
   * Get martial art by name
   */
  getMartialArt(name: string): MartialArtStyle | null {
    return MARTIAL_ART_STYLES[name.toLowerCase()] || null;
  }

  /**
   * Check if player can learn martial art
   */
  canLearnMartialArt(playerStats: Record<string, number>, martialArtName: string): boolean {
    const style = this.getMartialArt(martialArtName);
    if (!style) return false;

    if (style.requirements.strength && playerStats.strength < style.requirements.strength) {
      return false;
    }
    if (style.requirements.agility && playerStats.agility < style.requirements.agility) {
      return false;
    }
    if (style.requirements.endurance && playerStats.endurance < style.requirements.endurance) {
      return false;
    }

    return true;
  }

  /**
   * Get all learnable martial arts for a player
   */
  getLearnableMartialArts(playerStats: Record<string, number>): MartialArtStyle[] {
    return Object.values(MARTIAL_ART_STYLES).filter(style =>
      this.canLearnMartialArt(playerStats, style.name)
    );
  }

  /**
   * Calculate technique damage with skill multiplier
   */
  calculateTechniqueDamage(
    style: MartialArtStyle,
    skillLevel: number, // 0-100
    baseDamage: number
  ): number {
    const skillMultiplier = 1 + (skillLevel / 100) * 0.5; // 1x to 1.5x
    return Math.round(style.baseDamage * skillMultiplier);
  }
}
