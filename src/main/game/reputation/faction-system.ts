/**
 * Reputation/Faction System
 * Tracks faction standings per player
 */

export type FactionType = 'police' | 'mafia' | 'gang' | 'corporate' | 'underground' | 'government';

export interface Faction {
  id: string;
  name: string;
  type: FactionType;
  description: string;
  leader: string;
  members: string[];
  resources: number; // money/power
}

export interface FactionReputation {
  factionId: string;
  playerId: string;
  standing: number; // -100 to 100
  missions_completed: number;
  missions_failed: number;
  last_interaction: number;
}

export class ReputationEngine {
  private factions: Map<string, Faction> = new Map();
  private reputations: Map<string, FactionReputation> = new Map();

  /**
   * Create a faction
   */
  createFaction(
    name: string,
    type: FactionType,
    description: string,
    leader: string
  ): Faction {
    const factionId = `faction_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const faction: Faction = {
      id: factionId,
      name,
      type,
      description,
      leader,
      members: [leader],
      resources: 10000,
    };
    this.factions.set(factionId, faction);
    return faction;
  }

  /**
   * Add player to faction
   */
  joinFaction(playerId: string, factionId: string): FactionReputation | null {
    const faction = this.factions.get(factionId);
    if (!faction) return null;

    if (!faction.members.includes(playerId)) {
      faction.members.push(playerId);
    }

    const repId = `rep_${factionId}_${playerId}`;
    let rep = this.reputations.get(repId);

    if (!rep) {
      rep = {
        factionId,
        playerId,
        standing: 0,
        missions_completed: 0,
        missions_failed: 0,
        last_interaction: Date.now(),
      };
      this.reputations.set(repId, rep);
    }

    return rep;
  }

  /**
   * Modify faction standing
   */
  modifyStanding(playerId: string, factionId: string, amount: number): number {
    const repId = `rep_${factionId}_${playerId}`;
    let rep = this.reputations.get(repId);

    if (!rep) {
      rep = {
        factionId,
        playerId,
        standing: 0,
        missions_completed: 0,
        missions_failed: 0,
        last_interaction: Date.now(),
      };
      this.reputations.set(repId, rep);
    }

    rep.standing = Math.max(-100, Math.min(100, rep.standing + amount));
    rep.last_interaction = Date.now();

    return rep.standing;
  }

  /**
   * Complete mission for faction
   */
  completeMission(playerId: string, factionId: string, standing_reward: number): void {
    const repId = `rep_${factionId}_${playerId}`;
    let rep = this.reputations.get(repId);

    if (!rep) {
      rep = {
        factionId,
        playerId,
        standing: 0,
        missions_completed: 0,
        missions_failed: 0,
        last_interaction: Date.now(),
      };
      this.reputations.set(repId, rep);
    }

    rep.missions_completed++;
    rep.standing = Math.min(100, rep.standing + standing_reward);
  }

  /**
   * Fail mission for faction
   */
  failMission(playerId: string, factionId: string): void {
    const repId = `rep_${factionId}_${playerId}`;
    let rep = this.reputations.get(repId);

    if (!rep) {
      rep = {
        factionId,
        playerId,
        standing: 0,
        missions_completed: 0,
        missions_failed: 0,
        last_interaction: Date.now(),
      };
      this.reputations.set(repId, rep);
    }

    rep.missions_failed++;
    rep.standing = Math.max(-100, rep.standing - 10);
  }

  /**
   * Get standing with faction
   */
  getStanding(playerId: string, factionId: string): number {
    const repId = `rep_${factionId}_${playerId}`;
    const rep = this.reputations.get(repId);
    return rep ? rep.standing : 0;
  }

  /**
   * Get all factions player is aligned with
   */
  getPlayerFactions(playerId: string): Faction[] {
    const playerFactions: Faction[] = [];
    for (const rep of this.reputations.values()) {
      if (rep.playerId === playerId && rep.standing > 0) {
        const faction = this.factions.get(rep.factionId);
        if (faction) playerFactions.push(faction);
      }
    }
    return playerFactions;
  }

  /**
   * Get faction by ID
   */
  getFaction(factionId: string): Faction | null {
    return this.factions.get(factionId) || null;
  }
}
