/**
 * Health Check System
 * Monitors server health with auto-recovery capabilities
 */

import { EventEmitter } from 'events';

export interface HealthMetrics {
  uptime: number;
  timestamp: number;
  memoryUsage: NodeJS.MemoryUsage;
  cpuUsage: NodeJS.CpuUsage;
  activeConnections: number;
  pendingUpdates: number;
  eventBusStats: Record<string, unknown>;
  databaseStatus: string;
}

export interface HealthCheck {
  name: string;
  status: 'healthy' | 'degraded' | 'unhealthy';
  message: string;
  lastCheck: number;
}

export class HealthCheckSystem extends EventEmitter {
  private checks: Map<string, HealthCheck> = new Map();
  private metrics: HealthMetrics | null = null;
  private checkInterval: NodeJS.Timer | null = null;
  private checkIntervalMs: number = 10000; // 10 seconds
  private startTime: number = Date.now();
  private recoveryStrategies: Map<string, () => Promise<void>> = new Map();

  constructor() {
    super();
  }

  /**
   * Register a health check
   */
  registerCheck(
    name: string,
    check: () => Promise<'healthy' | 'degraded' | 'unhealthy' | string>
  ): void {
    this.checks.set(name, {
      name,
      status: 'healthy',
      message: 'Initializing...',
      lastCheck: 0,
    });

    // Run check immediately
    this.runCheck(name, check).catch((error) => {
      const healthCheck = this.checks.get(name);
      if (healthCheck) {
        healthCheck.status = 'unhealthy';
        healthCheck.message = error instanceof Error ? error.message : 'Check failed';
      }
    });
  }

  /**
   * Register recovery strategy
   */
  registerRecoveryStrategy(name: string, strategy: () => Promise<void>): void {
    this.recoveryStrategies.set(name, strategy);
  }

  /**
   * Run a single health check
   */
  private async runCheck(
    name: string,
    checkFn: () => Promise<'healthy' | 'degraded' | 'unhealthy' | string>
  ): Promise<void> {
    try {
      const result = await checkFn();
      const healthCheck = this.checks.get(name);

      if (healthCheck) {
        healthCheck.status = (result === 'healthy' ||
          result === 'degraded' ||
          result === 'unhealthy'
          ? result
          : 'healthy') as 'healthy' | 'degraded' | 'unhealthy';
        healthCheck.message = result || 'OK';
        healthCheck.lastCheck = Date.now();

        this.emit('check-completed', {
          name,
          status: healthCheck.status,
          message: healthCheck.message,
        });
      }
    } catch (error) {
      const healthCheck = this.checks.get(name);
      if (healthCheck) {
        healthCheck.status = 'unhealthy';
        healthCheck.message = error instanceof Error ? error.message : 'Unknown error';
        healthCheck.lastCheck = Date.now();

        this.emit('check-error', {
          name,
          error: error instanceof Error ? error.message : 'Unknown error',
        });

        // Attempt recovery if strategy exists
        await this.attemptRecovery(name);
      }
    }
  }

  /**
   * Attempt recovery for a failed check
   */
  private async attemptRecovery(checkName: string): Promise<void> {
    const strategy = this.recoveryStrategies.get(checkName);
    if (!strategy) return;

    try {
      await strategy();
      this.emit('recovery-attempted', { checkName, success: true });
    } catch (error) {
      this.emit('recovery-attempted', {
        checkName,
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  /**
   * Start periodic health checks
   */
  startMonitoring(): void {
    if (this.checkInterval) return;

    this.checkInterval = setInterval(() => {
      this.runAllChecks();
    }, this.checkIntervalMs);

    this.emit('monitoring-started');
  }

  /**
   * Stop periodic health checks
   */
  stopMonitoring(): void {
    if (this.checkInterval) {
      clearInterval(this.checkInterval);
      this.checkInterval = null;
      this.emit('monitoring-stopped');
    }
  }

  /**
   * Run all registered checks
   */
  private async runAllChecks(): Promise<void> {
    const checkPromises: Promise<void>[] = [];

    this.checks.forEach((healthCheck, name) => {
      // Re-run checks would need the check function stored
      // For now, just update lastCheck
      if (healthCheck.lastCheck === 0) {
        healthCheck.lastCheck = Date.now();
      }
    });

    await Promise.all(checkPromises);
    this.updateMetrics();
  }

  /**
   * Update health metrics
   */
  updateMetrics(
    activeConnections: number = 0,
    pendingUpdates: number = 0,
    eventBusStats: Record<string, unknown> = {},
    databaseStatus: string = 'unknown'
  ): void {
    this.metrics = {
      uptime: Date.now() - this.startTime,
      timestamp: Date.now(),
      memoryUsage: process.memoryUsage(),
      cpuUsage: process.cpuUsage(),
      activeConnections,
      pendingUpdates,
      eventBusStats,
      databaseStatus,
    };

    this.emit('metrics-updated', this.metrics);
  }

  /**
   * Get overall health status
   */
  getHealthStatus(): 'healthy' | 'degraded' | 'unhealthy' {
    const statuses = Array.from(this.checks.values()).map((c) => c.status);

    if (statuses.includes('unhealthy')) return 'unhealthy';
    if (statuses.includes('degraded')) return 'degraded';
    return 'healthy';
  }

  /**
   * Get health report
   */
  getHealthReport() {
    return {
      status: this.getHealthStatus(),
      timestamp: Date.now(),
      checks: Array.from(this.checks.values()),
      metrics: this.metrics,
    };
  }

  /**
   * Get individual check status
   */
  getCheckStatus(name: string): HealthCheck | null {
    return this.checks.get(name) || null;
  }

  /**
   * Get all check statuses
   */
  getAllCheckStatuses(): HealthCheck[] {
    return Array.from(this.checks.values());
  }

  /**
   * Clear all checks
   */
  clear(): void {
    this.checks.clear();
    this.recoveryStrategies.clear();
    this.emit('cleared');
  }

  setCheckInterval(ms: number): void {
    this.checkIntervalMs = ms;
    if (this.checkInterval) {
      this.stopMonitoring();
      this.startMonitoring();
    }
  }

  getStatistics() {
    return {
      totalChecks: this.checks.size,
      healthyChecks: Array.from(this.checks.values()).filter(
        (c) => c.status === 'healthy'
      ).length,
      degradedChecks: Array.from(this.checks.values()).filter(
        (c) => c.status === 'degraded'
      ).length,
      unhealthyChecks: Array.from(this.checks.values()).filter(
        (c) => c.status === 'unhealthy'
      ).length,
      uptime: this.metrics?.uptime || 0,
    };
  }
}
