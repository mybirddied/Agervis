/**
 * Drug Economy System
 * Production, distribution, and effects management
 */

export type DrugType = 'marijuana' | 'cocaine' | 'heroin' | 'methamphetamine' | 'ecstasy' | 'fentanyl';

export interface DrugProduction {
  id: string;
  type: DrugType;
  location: string;
  operator: string;
  productionRate: number; // units per hour
  quality: number; // 0-100
  suspicion: number; // 0-100, risk of detection
  operational: boolean;
}

export interface DrugDeal {
  id: string;
  type: DrugType;
  seller: string;
  buyer: string;
  quantity: number;
  pricePerUnit: number;
  timestamp: number;
  completed: boolean;
}

export interface DrugEffect {
  type: DrugType;
  duration: number; // minutes
  effects: Record<string, number>; // stat changes
  addiction_risk: number; // 0-100
  overdose_risk: number; // 0-100
}

export class DrugEconomySystem {
  private productions: Map<string, DrugProduction> = new Map();
  private deals: Map<string, DrugDeal> = new Map();
  private playerAddiction: Map<string, Map<DrugType, number>> = new Map(); // player -> drug -> addiction level
  private marketPrices: Map<DrugType, number> = new Map();
  private fbiSuspicionThreshold: number = 80;

  constructor() {
    // Initialize market prices
    this.marketPrices.set('marijuana', 100);
    this.marketPrices.set('cocaine', 500);
    this.marketPrices.set('heroin', 800);
    this.marketPrices.set('methamphetamine', 600);
    this.marketPrices.set('ecstasy', 200);
    this.marketPrices.set('fentanyl', 1200);
  }

  /**
   * Create a drug production facility
   */
  createProduction(
    type: DrugType,
    location: string,
    operator: string,
    productionRate: number
  ): DrugProduction {
    const prodId = `prod_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const production: DrugProduction = {
      id: prodId,
      type,
      location,
      operator,
      productionRate,
      quality: 50 + Math.random() * 40, // 50-90
      suspicion: 0,
      operational: true,
    };
    this.productions.set(prodId, production);
    return production;
  }

  /**
   * Operate production facility
   */
  operateProduction(prodId: string, hours: number): number {
    const production = this.productions.get(prodId);
    if (!production || !production.operational) return 0;

    const produced = Math.round(production.productionRate * hours);
    production.suspicion += hours * 2; // suspicion increases over time

    if (production.suspicion > this.fbiSuspicionThreshold) {
      production.operational = false; // facility busted
      return 0;
    }

    return produced;
  }

  /**
   * Execute a drug deal
   */
  executeDeal(
    seller: string,
    buyer: string,
    type: DrugType,
    quantity: number,
    pricePerUnit?: number
  ): DrugDeal | null {
    const dealId = `deal_${Date.now()}`;
    const price = pricePerUnit || this.marketPrices.get(type) || 100;

    const deal: DrugDeal = {
      id: dealId,
      type,
      seller,
      buyer,
      quantity,
      pricePerUnit: price,
      timestamp: Date.now(),
      completed: true,
    };

    this.deals.set(dealId, deal);

    // Add heat to both parties
    // Larger deals = more risk
    const heatAmount = Math.min(40, quantity / 10);

    return deal;
  }

  /**
   * Use drug and apply effects
   */
  useDrug(playerId: string, type: DrugType): Record<string, number> {
    const effects: Record<DrugType, DrugEffect> = {
      marijuana: {
        type: 'marijuana',
        duration: 120,
        effects: { stress_reduction: -20, perception: -10, speed: -5 },
        addiction_risk: 10,
        overdose_risk: 0,
      },
      cocaine: {
        type: 'cocaine',
        duration: 60,
        effects: { energy: 30, perception: 15, stress: 40 },
        addiction_risk: 60,
        overdose_risk: 15,
      },
      heroin: {
        type: 'heroin',
        duration: 180,
        effects: { pain_reduction: 40, energy: -40, perception: -20 },
        addiction_risk: 90,
        overdose_risk: 50,
      },
      methamphetamine: {
        type: 'methamphetamine',
        duration: 240,
        effects: { energy: 50, perception: 30, health: -10 },
        addiction_risk: 80,
        overdose_risk: 35,
      },
      ecstasy: {
        type: 'ecstasy',
        duration: 300,
        effects: { mood: 50, energy: 20, perception: 20 },
        addiction_risk: 40,
        overdose_risk: 20,
      },
      fentanyl: {
        type: 'fentanyl',
        duration: 90,
        effects: { pain_reduction: 60, energy: -50, perception: -30 },
        addiction_risk: 95,
        overdose_risk: 80,
      },
    };

    const effect = effects[type];

    // Check overdose risk
    if (Math.random() * 100 < effect.overdose_risk) {
      return { overdose: 1, death_risk: 50 };
    }

    // Track addiction
    if (!this.playerAddiction.has(playerId)) {
      this.playerAddiction.set(playerId, new Map());
    }

    const addictionMap = this.playerAddiction.get(playerId)!;
    const currentAddiction = addictionMap.get(type) || 0;
    addictionMap.set(type, Math.min(100, currentAddiction + effect.addiction_risk));

    return effect.effects;
  }

  /**
   * Get player addiction level
   */
  getAddictionLevel(playerId: string, type: DrugType): number {
    if (!this.playerAddiction.has(playerId)) return 0;
    return this.playerAddiction.get(playerId)?.get(type) || 0;
  }

  /**
   * Reduce addiction over time
   */
  reduceAddiction(playerId: string, type: DrugType, amount: number): void {
    if (!this.playerAddiction.has(playerId)) return;
    const addiction = this.playerAddiction.get(playerId)!.get(type) || 0;
    this.playerAddiction.get(playerId)!.set(type, Math.max(0, addiction - amount));
  }

  /**
   * Get market price for drug
   */
  getMarketPrice(type: DrugType): number {
    return this.marketPrices.get(type) || 100;
  }

  /**
   * Fluctuate market prices based on supply/demand
   */
  fluctuatePrices(): void {
    for (const type of this.marketPrices.keys()) {
      const currentPrice = this.marketPrices.get(type) || 100;
      const change = (Math.random() - 0.5) * 50; // -25 to +25
      const newPrice = Math.max(50, currentPrice + change);
      this.marketPrices.set(type, Math.round(newPrice));
    }
  }

  /**
   * Get production facility
   */
  getProduction(prodId: string): DrugProduction | null {
    return this.productions.get(prodId) || null;
  }

  /**
   * Get all productions
   */
  getAllProductions(): DrugProduction[] {
    return Array.from(this.productions.values());
  }

  /**
   * Get player's deals
   */
  getPlayerDeals(playerId: string): DrugDeal[] {
    return Array.from(this.deals.values()).filter(
      (deal) => deal.seller === playerId || deal.buyer === playerId
    );
  }
}
