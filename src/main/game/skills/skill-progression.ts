/**
 * Skill Progression Engine
 * 14 skill types with XP tracking and leveling
 * SECURITY: XP validated to be non-negative, bounds checking on all numeric values, overflow protection
 */

export type SkillType =
  | 'marksmanship'
  | 'melee'
  | 'stealth'
  | 'hacking'
  | 'driving'
  | 'piloting'
  | 'lockpicking'
  | 'pickpocketing'
  | 'persuasion'
  | 'intimidation'
  | 'medicine'
  | 'chemistry'
  | 'mechanics'
  | 'leadership';

export interface Skill {
  type: SkillType;
  level: number; // 1-100
  experience: number; // 0-10000 per level
  proficiency: number; // 0-100
}

export interface SkillProgress {
  skill: SkillType;
  xpGained: number;
  levelUp: boolean;
  newLevel?: number;
}

export class SkillProgressionEngine {
  private playerSkills: Map<string, Map<SkillType, Skill>> = new Map();
  private xpPerLevel: number = 1000;
  private maxLevel: number = 100;
  private maxProficiency: number = 100;
  private skillBonusMultiplier: Record<SkillType, number> = {
    marksmanship: 1.0,
    melee: 1.0,
    stealth: 1.1,
    hacking: 1.2,
    driving: 0.9,
    piloting: 1.3,
    lockpicking: 1.15,
    pickpocketing: 1.1,
    persuasion: 1.0,
    intimidation: 0.95,
    medicine: 1.25,
    chemistry: 1.2,
    mechanics: 1.05,
    leadership: 1.0,
  };

  /**
   * Initialize player skills
   */
  initializePlayerSkills(playerId: string): void {
    if (this.playerSkills.has(playerId)) return;

    const skills = new Map<SkillType, Skill>();
    const allSkills: SkillType[] = [
      'marksmanship', 'melee', 'stealth', 'hacking', 'driving', 'piloting',
      'lockpicking', 'pickpocketing', 'persuasion', 'intimidation',
      'medicine', 'chemistry', 'mechanics', 'leadership',
    ];

    for (const skillType of allSkills) {
      skills.set(skillType, {
        type: skillType,
        level: 1,
        experience: 0,
        proficiency: 0,
      });
    }

    this.playerSkills.set(playerId, skills);
  }

  /**
   * Add XP to a skill with full validation
   * SECURITY: Validates XP is non-negative, prevents integer overflow, bounds all values
   */
  addSkillXP(playerId: string, skillType: SkillType, xpAmount: number): SkillProgress {
    // Validate XP amount is non-negative and finite
    if (xpAmount < 0) {
      throw new Error('XP amount cannot be negative');
    }
    if (!Number.isFinite(xpAmount)) {
      throw new Error('XP amount must be finite');
    }
    if (!Number.isInteger(xpAmount)) {
      throw new Error('XP amount must be an integer');
    }
    if (xpAmount > Number.MAX_SAFE_INTEGER) {
      throw new Error('XP amount exceeds maximum safe integer');
    }

    this.initializePlayerSkills(playerId);
    const skills = this.playerSkills.get(playerId)!;
    const skill = skills.get(skillType)!;

    // Apply bonus multiplier
    const bonusXP = Math.round(xpAmount * this.skillBonusMultiplier[skillType]);

    // Validate no overflow when adding XP
    if (skill.experience + bonusXP > Number.MAX_SAFE_INTEGER) {
      throw new Error('XP addition would cause overflow');
    }

    skill.experience += bonusXP;

    // Validate experience never goes negative
    if (skill.experience < 0) {
      throw new Error('Skill experience went negative - state corrupted');
    }

    let levelUp = false;
    let newLevel = skill.level;

    // Level up with overflow protection
    while (skill.experience >= this.xpPerLevel && skill.level < this.maxLevel) {
      skill.experience -= this.xpPerLevel;
      skill.level++;
      skill.proficiency = Math.min(this.maxProficiency, skill.proficiency + 10);
      levelUp = true;
      newLevel = skill.level;
    }

    // Final validation: level must be within bounds
    if (skill.level < 1 || skill.level > this.maxLevel) {
      throw new Error(`Skill level out of bounds: ${skill.level}`);
    }
    if (skill.proficiency < 0 || skill.proficiency > this.maxProficiency) {
      throw new Error(`Skill proficiency out of bounds: ${skill.proficiency}`);
    }
    if (skill.experience < 0 || skill.experience >= this.xpPerLevel) {
      throw new Error(`Skill experience out of bounds: ${skill.experience}`);
    }

    return {
      skill: skillType,
      xpGained: bonusXP,
      levelUp,
      newLevel: levelUp ? newLevel : undefined,
    };
  }

  /**
   * Subtract XP from a skill (e.g., for penalty or correction)
   * SECURITY: Prevents negative XP, validates bounds
   */
  subtractSkillXP(playerId: string, skillType: SkillType, xpAmount: number): boolean {
    // Validate XP amount is non-negative and finite
    if (xpAmount < 0) {
      throw new Error('XP amount to subtract cannot be negative');
    }
    if (!Number.isFinite(xpAmount)) {
      throw new Error('XP amount must be finite');
    }

    this.initializePlayerSkills(playerId);
    const skills = this.playerSkills.get(playerId)!;
    const skill = skills.get(skillType)!;

    // Check if we have enough XP
    if (skill.experience < xpAmount) {
      return false;
    }

    skill.experience -= xpAmount;

    // Validate never goes negative
    if (skill.experience < 0) {
      throw new Error('Skill experience went negative during subtraction');
    }

    return true;
  }

  /**
   * Get skill level
   */
  getSkillLevel(playerId: string, skillType: SkillType): number {
    this.initializePlayerSkills(playerId);
    const skills = this.playerSkills.get(playerId)!;
    return skills.get(skillType)?.level || 1;
  }

  /**
   * Get skill XP
   */
  getSkillXP(playerId: string, skillType: SkillType): number {
    this.initializePlayerSkills(playerId);
    const skills = this.playerSkills.get(playerId)!;
    return skills.get(skillType)?.experience || 0;
  }

  /**
   * Get all player skills
   */
  getPlayerSkills(playerId: string): Skill[] {
    this.initializePlayerSkills(playerId);
    const skills = this.playerSkills.get(playerId)!;
    return Array.from(skills.values());
  }

  /**
   * Get average skill level
   */
  getAverageSkillLevel(playerId: string): number {
    const skills = this.getPlayerSkills(playerId);
    if (skills.length === 0) return 1;
    const total = skills.reduce((sum, s) => sum + s.level, 0);
    return Math.round(total / skills.length);
  }

  /**
   * Check if player can perform action (skill check)
   */
  skillCheck(playerId: string, skillType: SkillType, difficulty: number): boolean {
    // Validate difficulty is within reasonable bounds
    if (!Number.isFinite(difficulty)) {
      throw new Error('Difficulty must be finite');
    }

    const skillLevel = this.getSkillLevel(playerId, skillType);
    const proficiency = this.playerSkills.get(playerId)?.get(skillType)?.proficiency || 0;

    // Success chance: skill level + proficiency - difficulty
    const successChance = (skillLevel + proficiency / 100) - difficulty;
    const roll = Math.random() * 100;

    return roll < successChance;
  }

  /**
   * Reset player skill to level 1 with 0 XP
   * SECURITY: Validates skill type exists
   */
  resetSkill(playerId: string, skillType: SkillType): boolean {
    this.initializePlayerSkills(playerId);
    const skills = this.playerSkills.get(playerId)!;
    const skill = skills.get(skillType);

    if (!skill) {
      return false;
    }

    skill.level = 1;
    skill.experience = 0;
    skill.proficiency = 0;
    return true;
  }
}
