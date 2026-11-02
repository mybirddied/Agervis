// AI Request Queue
// Prioritizes requests (Director > Paid NPC > Free NPC), handles rate limiting, and manages retries

import PQueue from 'p-queue';
import type { AIRequestContext } from '../types/ai';
import { PRIORITY_LEVELS, RATE_LIMITS } from '../constants/ai';

export interface QueuedRequest {
  id: string;
  context: AIRequestContext;
  task: () => Promise<any>;
  createdAt: Date;
  attemptCount: number;
  priority: number;
}

export class AIRequestQueue {
  private queue: PQueue;
  private priorityQueues: Map<string, QueuedRequest[]> = new Map();
  private requestTimestamps: Map<string, number[]> = new Map();
  private maxRetries: number = 3;

  constructor(concurrency: number = 5, maxQueueSize: number = RATE_LIMITS.MAX_QUEUE_SIZE) {
    this.queue = new PQueue({
      concurrency,
      carryoverConcurrencyCount: true,
      timeout: RATE_LIMITS.REQUEST_TIMEOUT_MS,
      throwOnTimeout: true,
    });

    // Initialize priority queues
    this.priorityQueues.set('director', []);
    this.priorityQueues.set('paid', []);
    this.priorityQueues.set('free', []);
  }

  /**
   * Add request to queue with priority handling
   */
  async enqueue(
    context: AIRequestContext,
    task: () => Promise<any>
  ): Promise<any> {
    // Check rate limits
    if (!this.checkRateLimit(context.playerId)) {
      throw new Error(`Rate limit exceeded for player ${context.playerId}`);
    }

    // Calculate priority
    const priority = this.calculatePriority(context);

    const request: QueuedRequest = {
      id: `${context.playerId}-${Date.now()}-${Math.random()}`,
      context,
      task: this.withRetry(task, context),
      createdAt: new Date(),
      attemptCount: 0,
      priority,
    };

    // Add to appropriate priority queue
    return this.addToPriorityQueue(request);
  }

  /**
   * Check if player has exceeded rate limits
   */
  private checkRateLimit(playerId: string): boolean {
    const now = Date.now();
    const oneMinuteAgo = now - 60000;

    const timestamps = this.requestTimestamps.get(playerId) || [];
    const recentRequests = timestamps.filter((t) => t > oneMinuteAgo);

    if (recentRequests.length >= RATE_LIMITS.REQUESTS_PER_PLAYER_PER_MINUTE) {
      return false;
    }

    recentRequests.push(now);
    this.requestTimestamps.set(playerId, recentRequests.slice(-RATE_LIMITS.REQUESTS_PER_PLAYER_PER_MINUTE));

    return true;
  }

  /**
   * Calculate priority based on request type and player tier
   */
  private calculatePriority(context: AIRequestContext): number {
    if (context.endpoint === 'director') {
      return PRIORITY_LEVELS.DIRECTOR_AI;
    }

    if (context.priority === 'high') {
      return PRIORITY_LEVELS.PAID_NPC;
    }

    if (context.priority === 'medium') {
      return PRIORITY_LEVELS.FREE_NPC;
    }

    return PRIORITY_LEVELS.BACKGROUND_TASK;
  }

  /**
   * Add request to priority queue and process
   */
  private async addToPriorityQueue(request: QueuedRequest): Promise<any> {
    const priorityBucket = this.getPriorityBucket(request.priority);

    // Insert in sorted order (highest priority first)
    const bucket = this.priorityQueues.get(priorityBucket)!;
    let inserted = false;

    for (let i = 0; i < bucket.length; i++) {
      if (request.priority > bucket[i].priority) {
        bucket.splice(i, 0, request);
        inserted = true;
        break;
      }
    }

    if (!inserted) {
      bucket.push(request);
    }

    // Process queue
    return this.processQueue();
  }

  /**
   * Process queued requests in priority order
   */
  private async processQueue(): Promise<any> {
    const allBuckets = ['director', 'paid', 'free'];

    for (const bucket of allBuckets) {
      const requests = this.priorityQueues.get(bucket)!;

      if (requests.length > 0) {
        const request = requests.shift()!;

        try {
          return await this.queue.add(async () => {
            request.attemptCount++;
            return await request.task();
          });
        } catch (error) {
          if (request.attemptCount < this.maxRetries) {
            // Re-queue with exponential backoff
            const backoffMs = Math.pow(2, request.attemptCount - 1) * 1000;
            await new Promise((resolve) => setTimeout(resolve, backoffMs));
            return this.addToPriorityQueue(request);
          }

          throw error;
        }
      }
    }
  }

  /**
   * Map priority to bucket
   */
  private getPriorityBucket(priority: number): string {
    if (priority >= PRIORITY_LEVELS.DIRECTOR_AI) {
      return 'director';
    }
    if (priority >= PRIORITY_LEVELS.PAID_NPC) {
      return 'paid';
    }
    return 'free';
  }

  /**
   * Wrap task with retry logic
   */
  private withRetry(task: () => Promise<any>, context: AIRequestContext): () => Promise<any> {
    return async () => {
      let lastError: any;

      for (let attempt = 0; attempt < context.retryAttempts; attempt++) {
        try {
          return await Promise.race([
            task(),
            new Promise((_, reject) =>
              setTimeout(() => reject(new Error('Request timeout')), context.timeoutMs)
            ),
          ]);
        } catch (error) {
          lastError = error;

          if (attempt < context.retryAttempts - 1) {
            const backoffMs = Math.pow(2, attempt) * 1000;
            await new Promise((resolve) => setTimeout(resolve, backoffMs));
          }
        }
      }

      throw lastError;
    };
  }

  /**
   * Get queue statistics
   */
  getStats(): {
    queueSize: number;
    directorQueueSize: number;
    paidQueueSize: number;
    freeQueueSize: number;
  } {
    const directorQueue = this.priorityQueues.get('director')!.length;
    const paidQueue = this.priorityQueues.get('paid')!.length;
    const freeQueue = this.priorityQueues.get('free')!.length;

    return {
      queueSize: directorQueue + paidQueue + freeQueue,
      directorQueueSize: directorQueue,
      paidQueueSize: paidQueue,
      freeQueueSize: freeQueue,
    };
  }

  /**
   * Clear all queues
   */
  clear(): void {
    this.priorityQueues.forEach((bucket) => bucket.length = 0);
  }
}

export default AIRequestQueue;
