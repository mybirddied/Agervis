/**
 * Evidence Tracking System
 * Tracks blood, DNA, fingerprints, witnesses, and other forensic evidence
 */

export type EvidenceType = 'blood' | 'dna' | 'fingerprint' | 'witness' | 'weapon' | 'document' | 'audio';

export interface EvidenceItem {
  id: string;
  type: EvidenceType;
  location: string;
  timestamp: number;
  collectedBy?: string;
  description: string;
  metadata: Record<string, any>;
  quality: number; // 0-100, higher = better for prosecution
  connected: boolean; // linked to a crime
}

export interface CrimeScene {
  id: string;
  location: string;
  crimeType: string;
  timestamp: number;
  evidence: EvidenceItem[];
  investigated: boolean;
  solver?: string;
}

export class EvidenceTracker {
  private crimes: Map<string, CrimeScene> = new Map();
  private evidence: Map<string, EvidenceItem> = new Map();
  private investigations: Map<string, string[]> = new Map(); // crimeId -> evidence ids

  /**
   * Create a new crime scene
   */
  createCrimeScene(
    location: string,
    crimeType: string
  ): CrimeScene {
    const crimeId = `crime_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const scene: CrimeScene = {
      id: crimeId,
      location,
      crimeType,
      timestamp: Date.now(),
      evidence: [],
      investigated: false,
    };
    this.crimes.set(crimeId, scene);
    this.investigations.set(crimeId, []);
    return scene;
  }

  /**
   * Add evidence to a crime scene
   */
  addEvidence(
    crimeId: string,
    type: EvidenceType,
    description: string,
    metadata: Record<string, any> = {},
    quality: number = 50
  ): EvidenceItem | null {
    const crime = this.crimes.get(crimeId);
    if (!crime) return null;

    const evidenceId = `evidence_${crimeId}_${crime.evidence.length}`;
    const evidence: EvidenceItem = {
      id: evidenceId,
      type,
      location: crime.location,
      timestamp: Date.now(),
      description,
      metadata,
      quality: Math.min(100, Math.max(0, quality)),
      connected: false,
    };

    this.evidence.set(evidenceId, evidence);
    crime.evidence.push(evidence);
    return evidence;
  }

  /**
   * Collect evidence (official investigation)
   */
  collectEvidence(evidenceId: string, collectedBy: string): boolean {
    const evidence = this.evidence.get(evidenceId);
    if (!evidence) return false;

    evidence.collectedBy = collectedBy;
    evidence.connected = true;
    return true;
  }

  /**
   * Link evidence to investigation
   */
  linkEvidenceToInvestigation(crimeId: string, evidenceId: string): boolean {
    if (!this.crimes.has(crimeId)) return false;
    if (!this.evidence.has(evidenceId)) return false;

    const investigation = this.investigations.get(crimeId);
    if (investigation && !investigation.includes(evidenceId)) {
      investigation.push(evidenceId);
    }
    return true;
  }

  /**
   * Get all evidence for a crime
   */
  getEvidenceForCrime(crimeId: string): EvidenceItem[] {
    const crime = this.crimes.get(crimeId);
    return crime ? crime.evidence : [];
  }

  /**
   * Get collected evidence for a crime
   */
  getCollectedEvidenceForCrime(crimeId: string): EvidenceItem[] {
    return this.getEvidenceForCrime(crimeId).filter(e => e.collectedBy);
  }

  /**
   * Calculate evidence quality score for prosecution
   */
  calculateProsecutionScore(crimeId: string): number {
    const collected = this.getCollectedEvidenceForCrime(crimeId);
    if (collected.length === 0) return 0;

    const avgQuality = collected.reduce((sum, e) => sum + e.quality, 0) / collected.length;
    const witnessCount = collected.filter(e => e.type === 'witness').length;
    const physicalEvidence = collected.filter(e => e.type !== 'witness').length;

    // Higher quality, more evidence types, more witnesses = better prosecution
    return Math.round(
      (avgQuality * 0.6) +
      (Math.min(witnessCount, 5) * 8) +
      (Math.min(physicalEvidence, 10) * 4)
    );
  }

  /**
   * Mark crime as solved
   */
  solveCrime(crimeId: string, solvedBy: string): boolean {
    const crime = this.crimes.get(crimeId);
    if (!crime) return false;

    crime.investigated = true;
    crime.solver = solvedBy;
    return true;
  }

  /**
   * Get crime details
   */
  getCrime(crimeId: string): CrimeScene | null {
    return this.crimes.get(crimeId) || null;
  }

  /**
   * Get all unsolved crimes
   */
  getUnsolvedCrimes(): CrimeScene[] {
    return Array.from(this.crimes.values()).filter(c => !c.investigated);
  }

  /**
   * Get DNA match probability (simplified)
   */
  getDNAMatchProbability(dnaId1: string, dnaId2: string): number {
    const evidence1 = this.evidence.get(dnaId1);
    const evidence2 = this.evidence.get(dnaId2);

    if (!evidence1 || !evidence2 || evidence1.type !== 'dna' || evidence2.type !== 'dna') {
      return 0;
    }

    // Simplified: higher quality = higher match probability
    return Math.min(100, (evidence1.quality + evidence2.quality) / 2);
  }
}
