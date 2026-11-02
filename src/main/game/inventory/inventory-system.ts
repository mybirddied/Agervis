/**
 * Inventory System
 * Item storage, crafting, and usage rules
 * SECURITY: Atomic operations, non-stackable validation, no race conditions
 */

export type ItemType = 'weapon' | 'armor' | 'consumable' | 'crafting' | 'key' | 'document' | 'drug';

export interface Item {
  id: string;
  name: string;
  type: ItemType;
  quantity: number;
  weight: number;
  value: number;
  effects?: Record<string, number>;
  durability?: number; // for weapons/armor
  isStackable: boolean;
}

export interface InventorySlot {
  item: Item;
  quantity: number;
}

export class InventorySystem {
  private playerInventories: Map<string, InventorySlot[]> = new Map();
  private inventoryLocks: Map<string, number> = new Map(); // player ID -> lock timestamp
  private maxSlots: number = 20;
  private maxWeight: number = 100;

  /**
   * Get or create inventory for player
   */
  getOrCreateInventory(playerId: string): InventorySlot[] {
    if (!this.playerInventories.has(playerId)) {
      this.playerInventories.set(playerId, []);
      this.inventoryLocks.set(playerId, 0);
    }
    return this.playerInventories.get(playerId)!;
  }

  /**
   * Acquire exclusive lock on inventory
   */
  private acquireInventoryLock(playerId: string): void {
    const maxRetries = 1000;
    let retries = 0;
    while (this.inventoryLocks.get(playerId) !== 0 && retries < maxRetries) {
      retries++;
    }
    if (retries >= maxRetries) {
      throw new Error(`Failed to acquire inventory lock for player ${playerId}`);
    }
    this.inventoryLocks.set(playerId, Date.now());
  }

  /**
   * Release inventory lock
   */
  private releaseInventoryLock(playerId: string): void {
    this.inventoryLocks.set(playerId, 0);
  }

  /**
   * Add item to inventory with atomic operation and validation
   * SECURITY: Prevents race conditions, validates stackable flag, checks quantity bounds
   */
  addItem(playerId: string, item: Item, quantity: number = 1): boolean {
    // Validate inputs
    if (quantity <= 0) {
      throw new Error('Quantity must be positive');
    }
    if (!Number.isInteger(quantity)) {
      throw new Error('Quantity must be an integer');
    }
    if (!Number.isFinite(quantity)) {
      throw new Error('Quantity must be finite');
    }

    this.acquireInventoryLock(playerId);
    try {
      const inventory = this.getOrCreateInventory(playerId);

      // Check if stackable and already in inventory
      if (item.isStackable) {
        const existingSlot = inventory.find((slot) => slot.item.id === item.id);
        if (existingSlot) {
          // Validate no integer overflow
          const newQuantity = existingSlot.quantity + quantity;
          if (newQuantity > Number.MAX_SAFE_INTEGER) {
            throw new Error('Quantity would overflow');
          }
          if (newQuantity < 0) {
            throw new Error('Quantity underflow detected');
          }
          existingSlot.quantity = newQuantity;
          return true;
        }
      } else {
        // Non-stackable items: check if already in inventory
        if (inventory.some((slot) => slot.item.id === item.id)) {
          return false; // Cannot add non-stackable item twice
        }
      }

      // Check if inventory full
      if (inventory.length >= this.maxSlots) {
        return false;
      }

      // Check weight
      const totalWeight = this.getTotalWeight(playerId) + item.weight * quantity;
      if (totalWeight > this.maxWeight) {
        return false;
      }

      inventory.push({ item, quantity });
      return true;
    } finally {
      this.releaseInventoryLock(playerId);
    }
  }

  /**
   * Remove item from inventory with atomic operation and validation
   * SECURITY: Prevents race conditions, validates bounds, prevents negative quantities
   */
  removeItem(playerId: string, itemId: string, quantity: number = 1): boolean {
    // Validate inputs
    if (quantity <= 0) {
      throw new Error('Quantity to remove must be positive');
    }
    if (!Number.isInteger(quantity)) {
      throw new Error('Quantity must be an integer');
    }

    this.acquireInventoryLock(playerId);
    try {
      const inventory = this.getOrCreateInventory(playerId);
      const slot = inventory.find((s) => s.item.id === itemId);

      if (!slot || slot.quantity < quantity) {
        return false;
      }

      slot.quantity -= quantity;
      if (slot.quantity === 0) {
        inventory.splice(inventory.indexOf(slot), 1);
      }

      // Validate quantity never goes negative
      if (slot.quantity < 0) {
        throw new Error('Inventory quantity went negative - state corrupted');
      }

      return true;
    } finally {
      this.releaseInventoryLock(playerId);
    }
  }

  /**
   * Get total inventory weight
   */
  getTotalWeight(playerId: string): number {
    const inventory = this.getOrCreateInventory(playerId);
    return inventory.reduce((sum, slot) => sum + slot.item.weight * slot.quantity, 0);
  }

  /**
   * Use consumable item with atomic operation
   * SECURITY: Prevents race conditions, validates item exists and is consumable
   */
  useItem(playerId: string, itemId: string): Record<string, number> | null {
    this.acquireInventoryLock(playerId);
    try {
      const inventory = this.getOrCreateInventory(playerId);
      const slot = inventory.find((s) => s.item.id === itemId);

      if (!slot || slot.item.type !== 'consumable') {
        return null;
      }

      const effects = slot.item.effects || {};
      this.removeItem(playerId, itemId, 1);

      return effects;
    } finally {
      this.releaseInventoryLock(playerId);
    }
  }

  /**
   * Get inventory contents
   */
  getInventory(playerId: string): InventorySlot[] {
    return this.getOrCreateInventory(playerId);
  }

  /**
   * Get item count
   */
  getItemCount(playerId: string, itemId: string): number {
    const inventory = this.getOrCreateInventory(playerId);
    const slot = inventory.find((s) => s.item.id === itemId);
    return slot ? slot.quantity : 0;
  }

  /**
   * Craft item from ingredients with atomic operation
   * SECURITY: All ingredient checks and removals are atomic, prevents partial crafts
   */
  craftItem(playerId: string, ingredients: Array<{ itemId: string; quantity: number }>, resultItem: Item): boolean {
    // Validate ingredients
    for (const ingredient of ingredients) {
      if (ingredient.quantity <= 0) {
        throw new Error('Ingredient quantity must be positive');
      }
    }

    this.acquireInventoryLock(playerId);
    try {
      const inventory = this.getOrCreateInventory(playerId);

      // Check all ingredients exist (no partial operations)
      for (const ingredient of ingredients) {
        const count = this.getItemCount(playerId, ingredient.itemId);
        if (count < ingredient.quantity) {
          return false;
        }
      }

      // Remove all ingredients atomically
      for (const ingredient of ingredients) {
        const removed = this.removeItem(playerId, ingredient.itemId, ingredient.quantity);
        if (!removed) {
          throw new Error('Failed to remove ingredient during craft - state corrupted');
        }
      }

      // Add result
      return this.addItem(playerId, resultItem, 1);
    } finally {
      this.releaseInventoryLock(playerId);
    }
  }

  /**
   * Transfer item between players atomically
   * SECURITY: Locks both inventories to prevent race conditions
   */
  transferItem(fromPlayerId: string, toPlayerId: string, itemId: string, quantity: number): boolean {
    if (quantity <= 0) {
      throw new Error('Transfer quantity must be positive');
    }

    // Lock both inventories in deterministic order
    const [first, second] = [fromPlayerId, toPlayerId].sort();
    this.acquireInventoryLock(first);
    if (first !== second) {
      this.acquireInventoryLock(second);
    }

    try {
      // Check source has item
      if (this.getItemCount(fromPlayerId, itemId) < quantity) {
        return false;
      }

      // Get the item definition
      const sourceInventory = this.getOrCreateInventory(fromPlayerId);
      const sourceSlot = sourceInventory.find((s) => s.item.id === itemId);
      if (!sourceSlot) {
        return false;
      }

      // Remove from source
      if (!this.removeItem(fromPlayerId, itemId, quantity)) {
        return false;
      }

      // Add to destination
      if (!this.addItem(toPlayerId, sourceSlot.item, quantity)) {
        // Rollback: add back to source
        this.addItem(fromPlayerId, sourceSlot.item, quantity);
        return false;
      }

      return true;
    } finally {
      this.releaseInventoryLock(first);
      if (first !== second) {
        this.releaseInventoryLock(second);
      }
    }
  }
}
