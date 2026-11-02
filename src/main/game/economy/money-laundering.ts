/**
 * Money Laundering System
 * Advanced money laundering mechanics with fronts and risks
 */

export interface LaunderingFront {
  id: string;
  name: string;
  type: 'business' | 'casino' | 'restaurant' | 'laundromat';
  location: string;
  capacity: number; // max dirty money per cycle
  efficiency: number; // 0.5-0.9
  suspicion: number; // 0-100, higher = more likely to be investigated
  owner: string;
}

export class MoneyLaunderingSystem {
  private fronts: Map<string, LaunderingFront> = new Map();
  private launderingCycles: Array<{ frontId: string; amount: number; timestamp: number }> = [];
  private fbiSuspicionThreshold: number = 80;

  /**
   * Create a money laundering front
   */
  createFront(
    name: string,
    type: LaunderingFront['type'],
    location: string,
    owner: string
  ): LaunderingFront {
    const frontId = `front_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const front: LaunderingFront = {
      id: frontId,
      name,
      type,
      location,
      capacity: type === 'casino' ? 100000 : type === 'business' ? 50000 : 20000,
      efficiency: 0.65 + Math.random() * 0.25,
      suspicion: 0,
      owner,
    };
    this.fronts.set(frontId, front);
    return front;
  }

  /**
   * Launder money through a front
   */
  launderThroughFront(frontId: string, amount: number): { cleanMoney: number; riskAdded: number } {
    const front = this.fronts.get(frontId);
    if (!front) return { cleanMoney: 0, riskAdded: 0 };

    if (amount > front.capacity) {
      return { cleanMoney: 0, riskAdded: 50 }; // over capacity = high risk
    }

    const cleanMoney = Math.round(amount * front.efficiency);
    const riskAdded = (amount / front.capacity) * 20; // risk scales with percentage of capacity used

    front.suspicion += riskAdded;
    this.launderingCycles.push({
      frontId,
      amount,
      timestamp: Date.now(),
    });

    return { cleanMoney, riskAdded };
  }

  /**
   * Check if front is under investigation
   */
  isFrontUnderInvestigation(frontId: string): boolean {
    const front = this.fronts.get(frontId);
    return front ? front.suspicion > this.fbiSuspicionThreshold : false;
  }

  /**
   * Reduce front suspicion (bribery, time passing)
   */
  reduceFrontSuspicion(frontId: string, amount: number): void {
    const front = this.fronts.get(frontId);
    if (front) {
      front.suspicion = Math.max(0, front.suspicion - amount);
    }
  }

  /**
   * Get front by ID
   */
  getFront(frontId: string): LaunderingFront | null {
    return this.fronts.get(frontId) || null;
  }

  /**
   * Get all fronts for owner
   */
  getFrontsForOwner(owner: string): LaunderingFront[] {
    return Array.from(this.fronts.values()).filter((f) => f.owner === owner);
  }
}
