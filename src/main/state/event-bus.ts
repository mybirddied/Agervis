/**
 * Event Bus
 * Pub/sub system for internal server events
 */

import { EventEmitter } from 'events';

export type EventHandler = (data: unknown) => Promise<void> | void;

export interface EventSubscription {
  eventType: string;
  handler: EventHandler;
  once: boolean;
}

export class EventBus extends EventEmitter {
  private subscriptions: Map<string, EventHandler[]> = new Map();
  private eventHistory: Array<{
    type: string;
    data: unknown;
    timestamp: number;
  }> = [];
  private maxHistorySize: number = 1000;

  constructor() {
    super();
  }

  /**
   * Subscribe to an event
   */
  subscribe(eventType: string, handler: EventHandler): () => void {
    if (!this.subscriptions.has(eventType)) {
      this.subscriptions.set(eventType, []);
    }

    const handlers = this.subscriptions.get(eventType)!;
    handlers.push(handler);

    // Return unsubscribe function
    return () => {
      const index = handlers.indexOf(handler);
      if (index > -1) {
        handlers.splice(index, 1);
      }
    };
  }

  /**
   * Subscribe to event once
   */
  subscribeOnce(eventType: string, handler: EventHandler): void {
    const wrapper = async (data: unknown) => {
      await Promise.resolve(handler(data));
      this.unsubscribe(eventType, wrapper);
    };

    this.subscribe(eventType, wrapper);
  }

  /**
   * Unsubscribe from an event
   */
  unsubscribe(eventType: string, handler: EventHandler): boolean {
    const handlers = this.subscriptions.get(eventType);
    if (!handlers) return false;

    const index = handlers.indexOf(handler);
    if (index > -1) {
      handlers.splice(index, 1);
      return true;
    }

    return false;
  }

  /**
   * Publish an event
   */
  async publish(eventType: string, data: unknown = {}): Promise<void> {
    // Add to history
    this.eventHistory.push({
      type: eventType,
      data,
      timestamp: Date.now(),
    });

    // Maintain history size
    if (this.eventHistory.length > this.maxHistorySize) {
      this.eventHistory.shift();
    }

    // Get handlers for this event
    const handlers = this.subscriptions.get(eventType);
    if (!handlers || handlers.length === 0) {
      return;
    }

    // Execute all handlers in parallel
    const promises = handlers.map((handler) =>
      Promise.resolve().then(() => handler(data)).catch((error) => {
        this.emit('handler-error', {
          eventType,
          error: error instanceof Error ? error.message : 'Unknown error',
        });
      })
    );

    await Promise.all(promises);
  }

  /**
   * Publish multiple events
   */
  async publishBatch(
    events: Array<{ type: string; data?: unknown }>
  ): Promise<void> {
    const promises = events.map((event) =>
      this.publish(event.type, event.data)
    );
    await Promise.all(promises);
  }

  /**
   * Get subscription count for an event type
   */
  getSubscriberCount(eventType: string): number {
    return this.subscriptions.get(eventType)?.length || 0;
  }

  /**
   * Get all event types with subscribers
   */
  getAllEventTypes(): string[] {
    return Array.from(this.subscriptions.keys()).filter(
      (type) => this.subscriptions.get(type)!.length > 0
    );
  }

  /**
   * Get event history
   */
  getHistory(eventType?: string, limit: number = 100) {
    let history = this.eventHistory;

    if (eventType) {
      history = history.filter((e) => e.type === eventType);
    }

    return history.slice(-limit);
  }

  /**
   * Clear all subscriptions
   */
  clearSubscriptions(): void {
    this.subscriptions.clear();
  }

  /**
   * Clear event history
   */
  clearHistory(): void {
    this.eventHistory = [];
  }

  /**
   * Get statistics
   */
  getStatistics() {
    return {
      totalEventTypes: this.subscriptions.size,
      totalSubscribers: Array.from(this.subscriptions.values()).reduce(
        (sum, handlers) => sum + handlers.length,
        0
      ),
      historySize: this.eventHistory.length,
      eventTypes: Array.from(this.subscriptions.entries()).map(
        ([type, handlers]) => ({
          type,
          subscribers: handlers.length,
        })
      ),
    };
  }

  setMaxHistorySize(size: number): void {
    this.maxHistorySize = size;
  }
}
