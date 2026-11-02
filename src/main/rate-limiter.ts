/**
 * Rate Limiting Engine
 * Implements per-client and per-endpoint rate limiting with sliding window algorithm
 */

import { EventEmitter } from 'events';

export interface RateLimitConfig {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Max requests per window
  maxConnectionsPerIp: number; // Max connections per IP
}

export interface RateLimitEntry {
  count: number;
  resetAt: number;
}

export class RateLimitEngine extends EventEmitter {
  private clientLimits: Map<string, RateLimitEntry> = new Map();
  private ipLimits: Map<string, RateLimitEntry> = new Map();
  private endpointLimits: Map<string, Map<string, RateLimitEntry>> = new Map();
  private config: RateLimitConfig;
  private cleanupInterval: NodeJS.Timer | null = null;

  constructor(config: RateLimitConfig) {
    super();
    this.config = config;
    this.startCleanup();
  }

  /**
   * Check if client is rate limited
   */
  isClientLimited(clientId: string): boolean {
    const entry = this.clientLimits.get(clientId);
    if (!entry) return false;

    const now = Date.now();
    if (now >= entry.resetAt) {
      this.clientLimits.delete(clientId);
      return false;
    }

    return entry.count >= this.config.maxRequests;
  }

  /**
   * Check if IP is rate limited
   */
  isIpLimited(ip: string): boolean {
    const entry = this.ipLimits.get(ip);
    if (!entry) return false;

    const now = Date.now();
    if (now >= entry.resetAt) {
      this.ipLimits.delete(ip);
      return false;
    }

    return entry.count >= this.config.maxConnectionsPerIp;
  }

  /**
   * Record client request
   */
  recordClientRequest(clientId: string): boolean {
    if (this.isClientLimited(clientId)) {
      this.emit('rate-limit-exceeded', {
        type: 'client',
        identifier: clientId,
      });
      return false;
    }

    const now = Date.now();
    let entry = this.clientLimits.get(clientId);

    if (!entry || now >= entry.resetAt) {
      entry = {
        count: 1,
        resetAt: now + this.config.windowMs,
      };
    } else {
      entry.count++;
    }

    this.clientLimits.set(clientId, entry);
    return true;
  }

  /**
   * Record IP connection
   */
  recordIpConnection(ip: string): boolean {
    if (this.isIpLimited(ip)) {
      this.emit('rate-limit-exceeded', {
        type: 'ip',
        identifier: ip,
      });
      return false;
    }

    const now = Date.now();
    let entry = this.ipLimits.get(ip);

    if (!entry || now >= entry.resetAt) {
      entry = {
        count: 1,
        resetAt: now + this.config.windowMs,
      };
    } else {
      entry.count++;
    }

    this.ipLimits.set(ip, entry);
    return true;
  }

  /**
   * Record endpoint request
   */
  recordEndpointRequest(endpoint: string, clientId: string): boolean {
    if (!this.endpointLimits.has(endpoint)) {
      this.endpointLimits.set(endpoint, new Map());
    }

    const endpointMap = this.endpointLimits.get(endpoint)!;
    const now = Date.now();
    let entry = endpointMap.get(clientId);

    if (!entry || now >= entry.resetAt) {
      entry = {
        count: 1,
        resetAt: now + this.config.windowMs,
      };
    } else {
      entry.count++;

      if (entry.count > this.config.maxRequests) {
        this.emit('rate-limit-exceeded', {
          type: 'endpoint',
          endpoint,
          clientId,
        });
        return false;
      }
    }

    endpointMap.set(clientId, entry);
    return true;
  }

  /**
   * Get rate limit status for client
   */
  getClientStatus(clientId: string) {
    const entry = this.clientLimits.get(clientId);
    if (!entry) {
      return {
        limited: false,
        remaining: this.config.maxRequests,
        resetAt: Date.now() + this.config.windowMs,
      };
    }

    const now = Date.now();
    if (now >= entry.resetAt) {
      this.clientLimits.delete(clientId);
      return {
        limited: false,
        remaining: this.config.maxRequests,
        resetAt: now + this.config.windowMs,
      };
    }

    return {
      limited: entry.count >= this.config.maxRequests,
      remaining: Math.max(0, this.config.maxRequests - entry.count),
      resetAt: entry.resetAt,
    };
  }

  /**
   * Reset client limit
   */
  resetClient(clientId: string): void {
    this.clientLimits.delete(clientId);
    this.emit('rate-limit-reset', { type: 'client', identifier: clientId });
  }

  /**
   * Reset IP limit
   */
  resetIp(ip: string): void {
    this.ipLimits.delete(ip);
    this.emit('rate-limit-reset', { type: 'ip', identifier: ip });
  }

  /**
   * Clear all limits
   */
  clear(): void {
    this.clientLimits.clear();
    this.ipLimits.clear();
    this.endpointLimits.clear();
    this.emit('cleared');
  }

  /**
   * Get statistics
   */
  getStatistics() {
    return {
      clientLimiters: this.clientLimits.size,
      ipLimiters: this.ipLimits.size,
      endpointLimiters: this.endpointLimits.size,
      limitedClients: Array.from(this.clientLimits.values()).filter(
        (e) => e.count >= this.config.maxRequests
      ).length,
      limitedIps: Array.from(this.ipLimits.values()).filter(
        (e) => e.count >= this.config.maxConnectionsPerIp
      ).length,
    };
  }

  /**
   * Start periodic cleanup of expired entries
   */
  private startCleanup(): void {
    this.cleanupInterval = setInterval(() => {
      this.cleanup();
    }, 60000); // Cleanup every minute
  }

  /**
   * Cleanup expired entries
   */
  private cleanup(): void {
    const now = Date.now();

    // Clean client limits
    for (const [clientId, entry] of this.clientLimits.entries()) {
      if (now >= entry.resetAt) {
        this.clientLimits.delete(clientId);
      }
    }

    // Clean IP limits
    for (const [ip, entry] of this.ipLimits.entries()) {
      if (now >= entry.resetAt) {
        this.ipLimits.delete(ip);
      }
    }

    // Clean endpoint limits
    for (const [endpoint, endpointMap] of this.endpointLimits.entries()) {
      for (const [clientId, entry] of endpointMap.entries()) {
        if (now >= entry.resetAt) {
          endpointMap.delete(clientId);
        }
      }

      if (endpointMap.size === 0) {
        this.endpointLimits.delete(endpoint);
      }
    }
  }

  /**
   * Stop cleanup interval
   */
  stop(): void {
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
      this.cleanupInterval = null;
    }
  }

  updateConfig(config: Partial<RateLimitConfig>): void {
    this.config = { ...this.config, ...config };
    this.emit('config-updated', this.config);
  }
}
