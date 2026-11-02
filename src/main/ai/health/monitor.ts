// AI Infrastructure Health Monitoring
// Tracks system health, metrics, and performance across all subsystems

import type Database from 'better-sqlite3';
import type { AIHealth } from '../types/ai';

export interface HealthMetric {
  timestamp: Date;
  apiReachable: boolean;
  databaseConnected: boolean;
  queueBacklog: number;
  cacheHitRate: number;
  averageResponseTimeMs: number;
  errorRate: number;
  memoryUsageMB: number;
}

export class AIHealthMonitor {
  private db: Database.Database;
  private metrics: HealthMetric[] = [];
  private maxMetricsHistory: number = 1000;
  private lastErrorTime: Date | null = null;
  private errorCount: number = 0;
  private totalRequests: number = 0;

  constructor(db: Database.Database) {
    this.db = db;
  }

  /**
   * Record a health metric snapshot
   */
  recordMetric(metric: HealthMetric): void {
    this.metrics.push(metric);

    // Keep only recent metrics
    if (this.metrics.length > this.maxMetricsHistory) {
      this.metrics.shift();
    }

    // Persist to database
    this.persistMetric(metric);
  }

  /**
   * Record an error occurrence
   */
  recordError(error: Error): void {
    this.errorCount++;
    this.lastErrorTime = new Date();
  }

  /**
   * Record a successful request
   */
  recordRequest(responseTimeMs: number): void {
    this.totalRequests++;
  }

  /**
   * Get current health status
   */
  getCurrentHealth(): AIHealth {
    const recentMetrics = this.metrics.slice(-10);

    if (recentMetrics.length === 0) {
      return {
        isHealthy: true,
        lastCheckTime: new Date(),
        apiReachable: true,
        databaseConnected: true,
        queueBacklog: 0,
        averageResponseTimeMs: 0,
      };
    }

    const latest = recentMetrics[recentMetrics.length - 1];
    const avgResponseTime =
      recentMetrics.reduce((sum, m) => sum + m.averageResponseTimeMs, 0) /
      recentMetrics.length;

    const isHealthy =
      latest.apiReachable &&
      latest.databaseConnected &&
      this.errorCount < 10 &&
      avgResponseTime < 5000;

    return {
      isHealthy,
      lastCheckTime: latest.timestamp,
      apiReachable: latest.apiReachable,
      databaseConnected: latest.databaseConnected,
      queueBacklog: latest.queueBacklog,
      averageResponseTimeMs: avgResponseTime,
    };
  }

  /**
   * Get detailed metrics summary
   */
  getMetricsSummary(): {
    uptime: number;
    averageResponseTime: number;
    cacheHitRate: number;
    errorRate: number;
    totalRequests: number;
  } {
    if (this.metrics.length === 0) {
      return {
        uptime: 0,
        averageResponseTime: 0,
        cacheHitRate: 0,
        errorRate: 0,
        totalRequests: 0,
      };
    }

    const avgResponseTime =
      this.metrics.reduce((sum, m) => sum + m.averageResponseTimeMs, 0) /
      this.metrics.length;

    const avgCacheHitRate =
      this.metrics.reduce((sum, m) => sum + m.cacheHitRate, 0) /
      this.metrics.length;

    const avgErrorRate =
      this.metrics.reduce((sum, m) => sum + m.errorRate, 0) /
      this.metrics.length;

    const uptime =
      this.metrics.length > 0
        ? new Date().getTime() - this.metrics[0].timestamp.getTime()
        : 0;

    return {
      uptime,
      averageResponseTime: avgResponseTime,
      cacheHitRate: avgCacheHitRate,
      errorRate: avgErrorRate,
      totalRequests: this.totalRequests,
    };
  }

  /**
   * Get recent metric history (for graphing/dashboards)
   */
  getRecentHistory(limit: number = 100): HealthMetric[] {
    return this.metrics.slice(-limit);
  }

  /**
   * Check if system is degraded
   */
  isDegraded(): boolean {
    const health = this.getCurrentHealth();
    const summary = this.getMetricsSummary();

    return (
      !health.apiReachable ||
      !health.databaseConnected ||
      summary.errorRate > 0.05 ||
      summary.averageResponseTime > 2000 ||
      health.queueBacklog > 50
    );
  }

  /**
   * Reset error counters
   */
  resetErrorCounters(): void {
    this.errorCount = 0;
    this.lastErrorTime = null;
  }

  /**
   * Persist metric to database for long-term analytics
   */
  private persistMetric(metric: HealthMetric): void {
    try {
      const stmt = this.db.prepare(`
        INSERT INTO cache_stats
        (recorded_at, total_entries, hit_rate, average_hit_count, memory_usage_bytes, oldest_entry_age_seconds)
        VALUES (?, ?, ?, ?, ?, ?)
      `);

      stmt.run(
        metric.timestamp.toISOString(),
        0, // placeholder
        metric.cacheHitRate,
        0, // placeholder
        Math.floor(metric.memoryUsageMB * 1024 * 1024),
        0 // placeholder
      );
    } catch (error) {
      console.error('Failed to persist health metric:', error);
    }
  }
}

export default AIHealthMonitor;
