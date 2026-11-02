/**
 * Player Command Processor
 * Handles all player actions and commands
 */

import { EventBus } from '../state/event-bus';
import { WorldStateManager } from '../state/world-state';

export interface PlayerCommand {
  clientId: string;
  playerId: string;
  type: string;
  data: any;
  timestamp: number;
}

export class PlayerCommandProcessor {
  private commandQueue: PlayerCommand[] = [];
  private processedCount: number = 0;

  constructor(
    private eventBus: EventBus,
    private worldState: WorldStateManager
  ) {
    this.setupEventListeners();
  }

  private setupEventListeners(): void {
    // Listen for client commands
    this.eventBus.subscribe('client-command', (data: any) => {
      this.queueCommand({
        clientId: data.clientId,
        playerId: data.command.playerId || data.clientId,
        type: data.command.type,
        data: data.command.data,
        timestamp: Date.now(),
      });
    });
  }

  /**
   * Queue a command for processing
   */
  queueCommand(command: PlayerCommand): void {
    this.commandQueue.push(command);
  }

  /**
   * Process all queued commands
   */
  process(deltaTime: number): void {
    while (this.commandQueue.length > 0) {
      const command = this.commandQueue.shift()!;
      this.processCommand(command);
      this.processedCount++;
    }
  }

  /**
   * Process a single command
   */
  private processCommand(command: PlayerCommand): void {
    switch (command.type) {
      case 'move':
        this.handleMove(command);
        break;
      case 'attack':
        this.handleAttack(command);
        break;
      case 'interact':
        this.handleInteract(command);
        break;
      case 'chat':
        this.handleChat(command);
        break;
      case 'use-item':
        this.handleUseItem(command);
        break;
      case 'pick-up':
        this.handlePickUp(command);
        break;
      case 'drop-item':
        this.handleDropItem(command);
        break;
      case 'equip':
        this.handleEquip(command);
        break;
      case 'unequip':
        this.handleUnequip(command);
        break;
      case 'buy':
        this.handleBuy(command);
        break;
      case 'sell':
        this.handleSell(command);
        break;
      case 'start-job':
        this.handleStartJob(command);
        break;
      case 'complete-job':
        this.handleCompleteJob(command);
        break;
      default:
        console.warn(`[PlayerCommands] Unknown command type: ${command.type}`);
    }
  }

  private handleMove(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { x, y, direction } = data;

    this.worldState.updateEntity({
      id: playerId,
      type: 'player',
      position: { x, y, z: 0 },
      state: { direction, moving: true },
    });

    this.eventBus.publish('player-moved', { playerId, x, y, direction });
  }

  private handleAttack(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { targetId, weaponId } = data;

    this.eventBus.publish('combat-attack', {
      attackerId: playerId,
      targetId,
      weaponId,
      timestamp: command.timestamp,
    });
  }

  private handleInteract(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { targetId, interactionType } = data;

    this.eventBus.publish('player-interact', {
      playerId,
      targetId,
      interactionType,
    });
  }

  private handleChat(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { message, channel } = data;

    this.eventBus.publish('chat-message', {
      playerId,
      message,
      channel: channel || 'global',
      timestamp: command.timestamp,
    });
  }

  private handleUseItem(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { itemId, targetId } = data;

    this.eventBus.publish('item-use', {
      playerId,
      itemId,
      targetId,
    });
  }

  private handlePickUp(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { itemId } = data;

    this.eventBus.publish('item-pickup', {
      playerId,
      itemId,
    });
  }

  private handleDropItem(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { itemId, x, y } = data;

    this.eventBus.publish('item-drop', {
      playerId,
      itemId,
      position: { x, y },
    });
  }

  private handleEquip(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { itemId, slot } = data;

    this.eventBus.publish('item-equip', {
      playerId,
      itemId,
      slot,
    });
  }

  private handleUnequip(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { slot } = data;

    this.eventBus.publish('item-unequip', {
      playerId,
      slot,
    });
  }

  private handleBuy(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { vendorId, itemId, quantity, price } = data;

    this.eventBus.publish('economy-buy', {
      playerId,
      vendorId,
      itemId,
      quantity,
      price,
    });
  }

  private handleSell(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { vendorId, itemId, quantity, price } = data;

    this.eventBus.publish('economy-sell', {
      playerId,
      vendorId,
      itemId,
      quantity,
      price,
    });
  }

  private handleStartJob(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { jobId } = data;

    this.eventBus.publish('job-start', {
      playerId,
      jobId,
    });
  }

  private handleCompleteJob(command: PlayerCommand): void {
    const { playerId, data } = command;
    const { jobId } = data;

    this.eventBus.publish('job-complete', {
      playerId,
      jobId,
    });
  }

  getStats() {
    return {
      queuedCommands: this.commandQueue.length,
      processedCount: this.processedCount,
    };
  }
}
