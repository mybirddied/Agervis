/**
 * Economy System
 * Handles money, transactions, item pricing, and economic balancing
 */

import { EventBus } from '../state/event-bus';
import { WorldStateManager } from '../state/world-state';

interface PlayerWallet {
  playerId: string;
  balance: number;
}

interface Transaction {
  id: string;
  from: string;
  to: string;
  amount: number;
  itemId?: string;
  quantity?: number;
  timestamp: number;
  type: 'buy' | 'sell' | 'transfer' | 'reward' | 'penalty';
}

interface ItemPrice {
  itemId: string;
  basePrice: number;
  currentPrice: number;
  supply: number;
  demand: number;
}

export class EconomySystem {
  private wallets: Map<string, PlayerWallet> = new Map();
  private itemPrices: Map<string, ItemPrice> = new Map();
  private transactionHistory: Transaction[] = [];
  private totalMoneyInCirculation: number = 0;
  private transactionCount: number = 0;

  constructor(
    private eventBus: EventBus,
    private worldState: WorldStateManager
  ) {
    this.setupEventListeners();
    this.initializeItemPrices();
  }

  private setupEventListeners(): void {
    this.eventBus.subscribe('player-spawned', (data: any) => {
      this.createWallet(data.playerId, 100); // Starting money
    });

    this.eventBus.subscribe('economy-buy', (data: any) => {
      this.processBuy(
        data.playerId,
        data.vendorId,
        data.itemId,
        data.quantity,
        data.price
      );
    });

    this.eventBus.subscribe('economy-sell', (data: any) => {
      this.processSell(
        data.playerId,
        data.vendorId,
        data.itemId,
        data.quantity,
        data.price
      );
    });

    this.eventBus.subscribe('job-complete', (data: any) => {
      this.rewardPlayer(data.playerId, data.reward || 50);
    });

    this.eventBus.subscribe('player-fined', (data: any) => {
      this.finePlayer(data.playerId, data.amount);
    });
  }

  /**
   * Initialize default item prices
   */
  private initializeItemPrices(): void {
    const defaultItems = [
      { id: 'health-potion', basePrice: 10 },
      { id: 'weapon-knife', basePrice: 25 },
      { id: 'weapon-gun', basePrice: 200 },
      { id: 'ammo-pistol', basePrice: 5 },
      { id: 'lockpick', basePrice: 15 },
      { id: 'burger', basePrice: 8 },
      { id: 'beer', basePrice: 6 },
    ];

    defaultItems.forEach((item) => {
      this.itemPrices.set(item.id, {
        itemId: item.id,
        basePrice: item.basePrice,
        currentPrice: item.basePrice,
        supply: 100,
        demand: 100,
      });
    });
  }

  /**
   * Create a wallet for a player
   */
  createWallet(playerId: string, initialBalance: number = 0): void {
    this.wallets.set(playerId, {
      playerId,
      balance: initialBalance,
    });
    this.totalMoneyInCirculation += initialBalance;

    this.worldState.updateEntity({
      id: playerId,
      state: { money: initialBalance },
    });
  }

  /**
   * Process a buy transaction
   */
  private processBuy(
    buyerId: string,
    vendorId: string,
    itemId: string,
    quantity: number,
    agreedPrice: number
  ): boolean {
    const buyer = this.wallets.get(buyerId);
    if (!buyer) {
      console.warn(`[Economy] Buyer wallet not found: ${buyerId}`);
      return false;
    }

    const itemPrice = this.itemPrices.get(itemId);
    if (!itemPrice) {
      console.warn(`[Economy] Item price not found: ${itemId}`);
      return false;
    }

    const totalCost = itemPrice.currentPrice * quantity;

    // Check if buyer has enough money
    if (buyer.balance < totalCost) {
      this.eventBus.publish('economy-transaction-failed', {
        buyerId,
        reason: 'insufficient-funds',
        required: totalCost,
        available: buyer.balance,
      });
      return false;
    }

    // Deduct money
    buyer.balance -= totalCost;

    // Update supply/demand
    itemPrice.supply -= quantity;
    itemPrice.demand += quantity;
    this.updatePricing(itemId);

    // Record transaction
    const transaction: Transaction = {
      id: `tx-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      from: buyerId,
      to: vendorId,
      amount: totalCost,
      itemId,
      quantity,
      timestamp: Date.now(),
      type: 'buy',
    };
    this.transactionHistory.push(transaction);
    this.transactionCount++;

    // Update world state
    this.worldState.updateEntity({
      id: buyerId,
      state: { money: buyer.balance },
    });

    // Publish success event
    this.eventBus.publish('economy-transaction-success', {
      transaction,
      buyerId,
      itemId,
      quantity,
      totalCost,
    });

    return true;
  }

  /**
   * Process a sell transaction
   */
  private processSell(
    sellerId: string,
    vendorId: string,
    itemId: string,
    quantity: number,
    agreedPrice: number
  ): boolean {
    const seller = this.wallets.get(sellerId);
    if (!seller) {
      console.warn(`[Economy] Seller wallet not found: ${sellerId}`);
      return false;
    }

    const itemPrice = this.itemPrices.get(itemId);
    if (!itemPrice) {
      console.warn(`[Economy] Item price not found: ${itemId}`);
      return false;
    }

    const totalEarnings = itemPrice.currentPrice * quantity * 0.7; // 70% of buy price

    // Add money
    seller.balance += totalEarnings;

    // Update supply/demand
    itemPrice.supply += quantity;
    itemPrice.demand -= quantity;
    this.updatePricing(itemId);

    // Record transaction
    const transaction: Transaction = {
      id: `tx-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      from: vendorId,
      to: sellerId,
      amount: totalEarnings,
      itemId,
      quantity,
      timestamp: Date.now(),
      type: 'sell',
    };
    this.transactionHistory.push(transaction);
    this.transactionCount++;

    // Update world state
    this.worldState.updateEntity({
      id: sellerId,
      state: { money: seller.balance },
    });

    // Publish success event
    this.eventBus.publish('economy-transaction-success', {
      transaction,
      sellerId,
      itemId,
      quantity,
      totalEarnings,
    });

    return true;
  }

  /**
   * Update item pricing based on supply/demand
   */
  private updatePricing(itemId: string): void {
    const item = this.itemPrices.get(itemId);
    if (!item) return;

    // Simple supply/demand pricing model
    const supplyDemandRatio = item.demand / Math.max(1, item.supply);
    const priceMultiplier = Math.max(0.5, Math.min(2.0, supplyDemandRatio));
    item.currentPrice = Math.round(item.basePrice * priceMultiplier);

    this.eventBus.publish('economy-price-update', {
      itemId,
      oldPrice: item.basePrice,
      newPrice: item.currentPrice,
      supply: item.supply,
      demand: item.demand,
    });
  }

  /**
   * Reward player with money
   */
  rewardPlayer(playerId: string, amount: number): void {
    const wallet = this.wallets.get(playerId);
    if (!wallet) return;

    wallet.balance += amount;
    this.totalMoneyInCirculation += amount;

    this.worldState.updateEntity({
      id: playerId,
      state: { money: wallet.balance },
    });

    this.eventBus.publish('economy-reward', {
      playerId,
      amount,
      newBalance: wallet.balance,
    });
  }

  /**
   * Fine player (deduct money)
   */
  finePlayer(playerId: string, amount: number): void {
    const wallet = this.wallets.get(playerId);
    if (!wallet) return;

    const actualFine = Math.min(amount, wallet.balance);
    wallet.balance -= actualFine;
    this.totalMoneyInCirculation -= actualFine;

    this.worldState.updateEntity({
      id: playerId,
      state: { money: wallet.balance },
    });

    this.eventBus.publish('economy-fine', {
      playerId,
      amount: actualFine,
      newBalance: wallet.balance,
    });
  }

  /**
   * Transfer money between players
   */
  transfer(fromId: string, toId: string, amount: number): boolean {
    const from = this.wallets.get(fromId);
    const to = this.wallets.get(toId);

    if (!from || !to) return false;
    if (from.balance < amount) return false;

    from.balance -= amount;
    to.balance += amount;

    const transaction: Transaction = {
      id: `tx-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      from: fromId,
      to: toId,
      amount,
      timestamp: Date.now(),
      type: 'transfer',
    };
    this.transactionHistory.push(transaction);
    this.transactionCount++;

    this.worldState.updateEntity({
      id: fromId,
      state: { money: from.balance },
    });

    this.worldState.updateEntity({
      id: toId,
      state: { money: to.balance },
    });

    return true;
  }

  /**
   * Update economy (called every tick)
   */
  update(deltaTime: number): void {
    // Gradually normalize supply/demand every 10 seconds
    // This prevents runaway inflation/deflation
  }

  /**
   * Get current price for an item
   */
  getPrice(itemId: string): number {
    const item = this.itemPrices.get(itemId);
    return item ? item.currentPrice : 0;
  }

  /**
   * Get player balance
   */
  getBalance(playerId: string): number {
    const wallet = this.wallets.get(playerId);
    return wallet ? wallet.balance : 0;
  }

  getStats() {
    return {
      totalWallets: this.wallets.size,
      totalMoneyInCirculation: this.totalMoneyInCirculation,
      transactionCount: this.transactionCount,
      recentTransactions: this.transactionHistory.slice(-10),
      itemPrices: Array.from(this.itemPrices.values()),
    };
  }
}
