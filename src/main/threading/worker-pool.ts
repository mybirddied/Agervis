/**
 * Worker Thread Pool
 * Manages worker threads for offloading compute-intensive tasks
 */

import { Worker } from 'worker_threads';
import { EventEmitter } from 'events';
import * as path from 'path';

export interface WorkerTask {
  id: string;
  type: string;
  data: any;
  priority: number;
  createdAt: number;
}

export interface WorkerResult {
  taskId: string;
  success: boolean;
  data?: any;
  error?: string;
  duration: number;
}

export class WorkerPool extends EventEmitter {
  private workers: Worker[] = [];
  private availableWorkers: Worker[] = [];
  private taskQueue: WorkerTask[] = [];
  private activeTasks: Map<string, { task: WorkerTask; worker: Worker; startTime: number }> = new Map();
  private poolSize: number;
  private workerScript: string;
  private tasksProcessed: number = 0;
  private totalDuration: number = 0;

  constructor(poolSize: number, workerScript: string) {
    super();
    this.poolSize = poolSize;
    this.workerScript = path.resolve(__dirname, workerScript);
    this.initializePool();
  }

  /**
   * Initialize worker threads
   */
  private initializePool(): void {
    for (let i = 0; i < this.poolSize; i++) {
      const worker = new Worker(this.workerScript);

      worker.on('message', (result: WorkerResult) => {
        this.handleWorkerResult(worker, result);
      });

      worker.on('error', (error) => {
        console.error('[WorkerPool] Worker error:', error);
        this.handleWorkerError(worker, error);
      });

      worker.on('exit', (code) => {
        if (code !== 0) {
          console.error(`[WorkerPool] Worker exited with code ${code}`);
          this.replaceWorker(worker);
        }
      });

      this.workers.push(worker);
      this.availableWorkers.push(worker);
    }

    console.log(`[WorkerPool] Initialized with ${this.poolSize} workers`);
  }

  /**
   * Submit a task to the pool
   */
  submitTask(type: string, data: any, priority: number = 0): Promise<WorkerResult> {
    const task: WorkerTask = {
      id: `task-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      type,
      data,
      priority,
      createdAt: Date.now(),
    };

    return new Promise((resolve, reject) => {
      // Add resolve/reject to task for later use
      (task as any).resolve = resolve;
      (task as any).reject = reject;

      this.taskQueue.push(task);
      this.taskQueue.sort((a, b) => b.priority - a.priority); // Higher priority first

      this.processQueue();
    });
  }

  /**
   * Process queued tasks
   */
  private processQueue(): void {
    while (this.availableWorkers.length > 0 && this.taskQueue.length > 0) {
      const worker = this.availableWorkers.shift()!;
      const task = this.taskQueue.shift()!;

      this.activeTasks.set(task.id, {
        task,
        worker,
        startTime: Date.now(),
      });

      worker.postMessage(task);
    }
  }

  /**
   * Handle worker result
   */
  private handleWorkerResult(worker: Worker, result: WorkerResult): void {
    const activeTask = Array.from(this.activeTasks.values()).find((t) => t.worker === worker);

    if (!activeTask) {
      console.warn('[WorkerPool] Received result for unknown task');
      return;
    }

    const { task } = activeTask;
    this.activeTasks.delete(task.id);

    // Update stats
    this.tasksProcessed++;
    this.totalDuration += result.duration;

    // Return worker to pool
    this.availableWorkers.push(worker);

    // Resolve promise
    if (result.success) {
      (task as any).resolve(result);
    } else {
      (task as any).reject(new Error(result.error || 'Task failed'));
    }

    // Emit event
    this.emit('task-complete', { taskId: task.id, result });

    // Process next task
    this.processQueue();
  }

  /**
   * Handle worker error
   */
  private handleWorkerError(worker: Worker, error: Error): void {
    const activeTask = Array.from(this.activeTasks.values()).find((t) => t.worker === worker);

    if (activeTask) {
      const { task } = activeTask;
      this.activeTasks.delete(task.id);
      (task as any).reject(error);
    }

    this.replaceWorker(worker);
  }

  /**
   * Replace a failed worker
   */
  private replaceWorker(oldWorker: Worker): void {
    const index = this.workers.indexOf(oldWorker);
    if (index !== -1) {
      this.workers.splice(index, 1);
    }

    const availableIndex = this.availableWorkers.indexOf(oldWorker);
    if (availableIndex !== -1) {
      this.availableWorkers.splice(availableIndex, 1);
    }

    // Terminate old worker
    oldWorker.terminate();

    // Create new worker
    const newWorker = new Worker(this.workerScript);
    newWorker.on('message', (result: WorkerResult) => {
      this.handleWorkerResult(newWorker, result);
    });
    newWorker.on('error', (error) => {
      console.error('[WorkerPool] Worker error:', error);
      this.handleWorkerError(newWorker, error);
    });

    this.workers.push(newWorker);
    this.availableWorkers.push(newWorker);
  }

  /**
   * Shutdown the pool
   */
  async shutdown(): Promise<void> {
    console.log('[WorkerPool] Shutting down...');

    // Wait for active tasks to complete (with timeout)
    const timeout = 5000;
    const startTime = Date.now();
    while (this.activeTasks.size > 0 && Date.now() - startTime < timeout) {
      await new Promise((resolve) => setTimeout(resolve, 100));
    }

    // Terminate all workers
    for (const worker of this.workers) {
      await worker.terminate();
    }

    this.workers = [];
    this.availableWorkers = [];
    console.log('[WorkerPool] Shutdown complete');
  }

  getStats() {
    return {
      poolSize: this.poolSize,
      activeWorkers: this.poolSize - this.availableWorkers.length,
      availableWorkers: this.availableWorkers.length,
      queuedTasks: this.taskQueue.length,
      activeTasks: this.activeTasks.size,
      tasksProcessed: this.tasksProcessed,
      averageDuration: this.tasksProcessed > 0 ? this.totalDuration / this.tasksProcessed : 0,
    };
  }
}
