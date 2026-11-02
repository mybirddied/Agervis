/**
 * Heat/Wanted System
 * Tracks police heat and wanted level (0-140 scale)
 */

export interface HeatThreshold {
  level: number;
  policeResponse: string;
  description: string;
  consequences: string[];
}

export const HEAT_THRESHOLDS: HeatThreshold[] = [
  {
    level: 0,
    policeResponse: 'none',
    description: 'No heat',
    consequences: [],
  },
  {
    level: 20,
    policeResponse: 'patrol',
    description: 'Low heat - increased patrols',
    consequences: ['police_presence_increased'],
  },
  {
    level: 40,
    policeResponse: 'investigation',
    description: 'Medium heat - active investigation',
    consequences: ['suspects_tracked', 'assets_monitored'],
  },
  {
    level: 60,
    policeResponse: 'wanted',
    description: 'High heat - wanted for questioning',
    consequences: ['bounty_hunters_active', 'bail_set'],
  },
  {
    level: 80,
    policeResponse: 'manhunt',
    description: 'Very high heat - active manhunt',
    consequences: ['armed_police', 'helicopter_patrols', 'roadblocks'],
  },
  {
    level: 100,
    policeResponse: 'critical',
    description: 'Critical heat - felony charges',
    consequences: ['swat_teams', 'federal_involvement'],
  },
  {
    level: 140,
    policeResponse: 'maximum',
    description: 'Maximum heat - all-out war',
    consequences: ['shoot_on_sight', 'assets_seized', 'bounty_maximum'],
  },
];

export class WantedSystem {
  private playerHeat: number = 0;
  private crimeLog: Array<{ crime: string; heat: number; timestamp: number }> = [];
  private heatDecayRate: number = 0.1; // per minute
  private lastDecayTime: number = Date.now();

  /**
   * Add heat from a crime
   */
  addHeat(crime: string, amount: number): void {
    this.playerHeat += amount;
    this.playerHeat = Math.min(140, this.playerHeat);
    this.crimeLog.push({
      crime,
      heat: amount,
      timestamp: Date.now(),
    });
  }

  /**
   * Reduce heat over time
   */
  decayHeat(minutes: number = 1): void {
    const decayAmount = minutes * this.heatDecayRate;
    this.playerHeat = Math.max(0, this.playerHeat - decayAmount);
  }

  /**
   * Get current heat level
   */
  getCurrentHeat(): number {
    return Math.round(this.playerHeat);
  }

  /**
   * Get heat threshold info
   */
  getHeatThreshold(): HeatThreshold {
    for (let i = HEAT_THRESHOLDS.length - 1; i >= 0; i--) {
      if (this.playerHeat >= HEAT_THRESHOLDS[i].level) {
        return HEAT_THRESHOLDS[i];
      }
    }
    return HEAT_THRESHOLDS[0];
  }

  /**
   * Check if wanted
   */
  isWanted(): boolean {
    return this.playerHeat >= 60;
  }

  /**
   * Get police response level
   */
  getPoliceResponse(): string {
    return this.getHeatThreshold().policeResponse;
  }

  /**
   * Get active consequences
   */
  getActiveConsequences(): string[] {
    return this.getHeatThreshold().consequences;
  }

  /**
   * Get heat percentage (0-100)
   */
  getHeatPercentage(): number {
    return Math.round((this.playerHeat / 140) * 100);
  }

  /**
   * Clear heat (bribe, fake death, etc.)
   */
  clearHeat(): void {
    this.playerHeat = 0;
  }

  /**
   * Get crime log
   */
  getCrimeLog(): Array<{ crime: string; heat: number; timestamp: number }> {
    return [...this.crimeLog];
  }
}
