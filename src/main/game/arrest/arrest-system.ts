/**
 * Arrest & Jail System
 * Police arrests, court, sentencing, and parole
 */

export type CrimeCategory = 'misdemeanor' | 'felony' | 'violent' | 'organized';
export type ArrestStatus = 'free' | 'arrested' | 'in_court' | 'sentenced' | 'appealing';

export interface Charge {
  id: string;
  crime: string;
  category: CrimeCategory;
  severity: number; // 1-10
  evidence_quality: number; // 0-100
}

export interface ArrestRecord {
  id: string;
  playerId: string;
  charges: Charge[];
  arrestDate: number;
  courtDate: number;
  status: ArrestStatus;
  sentence: number; // minutes in jail
  timeServed: number;
  bail: number;
  bailPaid: boolean;
  attorney?: string;
  parole?: { startDate: number; endDate: number; conditions: string[] };
}

export class ArrestSystem {
  private arrests: Map<string, ArrestRecord> = new Map();
  private playerStatus: Map<string, ArrestStatus> = new Map();
  private jailPopulation: Map<string, string[]> = new Map(); // jail -> prisoner ids

  /**
   * Arrest player
   */
  arrestPlayer(playerId: string, charges: Charge[], location: string = 'police_station'): ArrestRecord {
    const arrestId = `arrest_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Calculate bail and sentence based on charges
    let totalSeverity = 0;
    for (const charge of charges) {
      totalSeverity += charge.severity;
    }

    const record: ArrestRecord = {
      id: arrestId,
      playerId,
      charges,
      arrestDate: Date.now(),
      courtDate: Date.now() + 3 * 24 * 60 * 60 * 1000, // 3 days later
      status: 'arrested',
      sentence: totalSeverity * 1440, // minutes (1 day per severity point)
      timeServed: 0,
      bail: totalSeverity * 5000,
      bailPaid: false,
    };

    this.arrests.set(arrestId, record);
    this.playerStatus.set(playerId, 'arrested');

    // Add to jail population
    if (!this.jailPopulation.has(location)) {
      this.jailPopulation.set(location, []);
    }
    this.jailPopulation.get(location)!.push(playerId);

    return record;
  }

  /**
   * Pay bail
   */
  payBail(arrestId: string): boolean {
    const record = this.arrests.get(arrestId);
    if (!record || record.bailPaid) return false;

    record.bailPaid = true;
    record.status = 'free';
    this.playerStatus.set(record.playerId, 'free');

    return true;
  }

  /**
   * Court hearing - determine sentence
   */
  courtHearing(arrestId: string): number {
    const record = this.arrests.get(arrestId);
    if (!record) return 0;

    record.status = 'in_court';

    // Calculate sentence based on evidence quality and charges
    let sentenceMultiplier = 1.0;
    let totalEvidenceQuality = 0;

    for (const charge of record.charges) {
      totalEvidenceQuality += charge.evidence_quality;
    }

    const avgEvidence = totalEvidenceQuality / record.charges.length;
    sentenceMultiplier = 0.5 + (avgEvidence / 100) * 1.5; // 0.5x to 2x

    record.sentence = Math.round(record.sentence * sentenceMultiplier);
    record.status = 'sentenced';

    this.playerStatus.set(record.playerId, 'sentenced');

    return record.sentence;
  }

  /**
   * Serve jail time
   */
  serveJailTime(arrestId: string, minutesServed: number): boolean {
    const record = this.arrests.get(arrestId);
    if (!record || record.status !== 'sentenced') return false;

    record.timeServed += minutesServed;

    if (record.timeServed >= record.sentence) {
      // Parole phase
      record.status = 'appealing';
      this.playerStatus.set(record.playerId, 'free');

      // Grant parole
      record.parole = {
        startDate: Date.now(),
        endDate: Date.now() + 30 * 24 * 60 * 60 * 1000, // 30 days parole
        conditions: ['report_weekly', 'no_crime', 'curfew'],
      };

      return true;
    }

    return false;
  }

  /**
   * Get arrest record
   */
  getArrestRecord(arrestId: string): ArrestRecord | null {
    return this.arrests.get(arrestId) || null;
  }

  /**
   * Get player's current arrest status
   */
  getPlayerStatus(playerId: string): ArrestStatus {
    return this.playerStatus.get(playerId) || 'free';
  }

  /**
   * Violate parole
   */
  violateParole(arrestId: string): void {
    const record = this.arrests.get(arrestId);
    if (!record || !record.parole) return;

    // Reset parole conditions, add more time
    record.parole.endDate += 15 * 24 * 60 * 60 * 1000; // add 15 days
    record.parole.conditions.push('stricter_curfew');
  }

  /**
   * Get jail population
   */
  getJailPopulation(location: string): string[] {
    return this.jailPopulation.get(location) || [];
  }
}
