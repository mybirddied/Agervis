// AI Response Cache
// Semantic query hashing and response caching to reduce API calls

import type Database from 'better-sqlite3';
import crypto from 'node:crypto';
import { CACHE_CONFIG } from '../constants/ai';

export interface CacheEntry {
  id: string;
  queryHash: string;
  npcId: string | null;
  requestContext: Record<string, any>;
  cachedResponse: string;
  tokensSaved: number;
  createdAt: Date;
  expiresAt: Date;
  hitCount: number;
}

export class ResponseCache {
  private db: Database.Database;
  private ttlNpcSeconds: number;
  private ttlDirectorSeconds: number;

  constructor(
    db: Database.Database,
    ttlNpcSeconds: number = CACHE_CONFIG.TTL_NPC_SECONDS,
    ttlDirectorSeconds: number = CACHE_CONFIG.TTL_DIRECTOR_SECONDS
  ) {
    this.db = db;
    this.ttlNpcSeconds = ttlNpcSeconds;
    this.ttlDirectorSeconds = ttlDirectorSeconds;
  }

  /**
   * Generate semantic query hash for cache lookup
   * Hashes the context (NPC, mood, relationship) + sanitized message
   */
  generateQueryHash(npcId: string | null, sanitizedMessage: string, context: Record<string, any>): string {
    const contextStr = JSON.stringify({
      npc: npcId,
      mood: context.mood || 'neutral',
      relationship: context.relationship || 'neutral',
      location: context.location || 'unknown',
    });

    const combined = `${contextStr}|${sanitizedMessage}`;
    return crypto.createHash('sha256').update(combined).digest('hex');
  }

  /**
   * Sanitize message for cache matching (remove exact punctuation/capitalization differences)
   */
  sanitizeMessage(message: string): string {
    return message.toLowerCase().replace(/[^\w\s]/g, '').trim();
  }

  /**
   * Get cached response if available and not expired
   */
  getCached(queryHash: string): CacheEntry | null {
    const stmt = this.db.prepare(`
      SELECT * FROM ai_response_cache
      WHERE query_hash = ? AND expires_at > datetime('now')
    `);

    const row: any = stmt.get(queryHash);

    if (!row) {
      return null;
    }

    // Update hit count
    const updateStmt = this.db.prepare(`
      UPDATE ai_response_cache
      SET hit_count = hit_count + 1
      WHERE query_hash = ?
    `);
    updateStmt.run(queryHash);

    return {
      id: row.id,
      queryHash: row.query_hash,
      npcId: row.npc_id,
      requestContext: JSON.parse(row.request_context),
      cachedResponse: row.cached_response,
      tokensSaved: row.tokens_saved,
      createdAt: new Date(row.created_at),
      expiresAt: new Date(row.expires_at),
      hitCount: row.hit_count + 1,
    };
  }

  /**
   * Store response in cache
   */
  setCached(
    queryHash: string,
    response: string,
    npcId: string | null,
    context: Record<string, any>,
    tokensSaved: number,
    ttlSeconds?: number
  ): void {
    const ttl = ttlSeconds || (npcId ? this.ttlNpcSeconds : this.ttlDirectorSeconds);
    const now = new Date();
    const expiresAt = new Date(now.getTime() + ttl * 1000);

    const stmt = this.db.prepare(`
      INSERT OR REPLACE INTO ai_response_cache
      (query_hash, npc_id, request_context, cached_response, tokens_saved, created_at, expires_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);

    stmt.run(queryHash, npcId, JSON.stringify(context), response, tokensSaved, now.toISOString(), expiresAt.toISOString());
  }

  /**
   * Get cache statistics
   */
  getStats(): {
    totalEntries: number;
    hitRate: number;
    averageHits: number;
    tokensSaved: number;
  } {
    const countStmt = this.db.prepare(`
      SELECT COUNT(*) as count FROM ai_response_cache
      WHERE expires_at > datetime('now')
    `);
    const countRow: any = countStmt.get();

    const statsStmt = this.db.prepare(`
      SELECT
        COUNT(*) as total,
        SUM(hit_count) as total_hits,
        AVG(hit_count) as avg_hits,
        SUM(tokens_saved) as total_tokens_saved
      FROM ai_response_cache
      WHERE expires_at > datetime('now')
    `);
    const statsRow: any = statsStmt.get();

    const totalHits = statsRow?.total_hits || 0;
    const totalRequests = totalHits + (statsRow?.total || 0);
    const hitRate = totalRequests > 0 ? (totalHits / totalRequests) * 100 : 0;

    return {
      totalEntries: countRow?.count || 0,
      hitRate: Math.round(hitRate * 100) / 100,
      averageHits: statsRow?.avg_hits || 0,
      tokensSaved: statsRow?.total_tokens_saved || 0,
    };
  }

  /**
   * Clean up expired entries
   */
  pruneExpired(): number {
    const stmt = this.db.prepare(`
      DELETE FROM ai_response_cache
      WHERE expires_at <= datetime('now')
    `);

    const result = stmt.run();
    return (result.changes as number) || 0;
  }

  /**
   * Clear cache for specific NPC
   */
  clearNpcCache(npcId: string): number {
    const stmt = this.db.prepare(`
      DELETE FROM ai_response_cache
      WHERE npc_id = ?
    `);

    const result = stmt.run(npcId);
    return (result.changes as number) || 0;
  }

  /**
   * Clear all cache
   */
  clearAll(): number {
    const stmt = this.db.prepare(`DELETE FROM ai_response_cache`);
    const result = stmt.run();
    return (result.changes as number) || 0;
  }

  /**
   * Record cache statistics for monitoring
   */
  recordStats(): void {
    const stats = this.getStats();
    const stmt = this.db.prepare(`
      INSERT INTO cache_stats (recorded_at, total_entries, hit_rate, average_hit_count, memory_usage_bytes)
      VALUES (datetime('now'), ?, ?, ?, ?)
    `);

    stmt.run(stats.totalEntries, stats.hitRate, Math.round(stats.averageHits * 100) / 100, 0);
  }
}

export default ResponseCache;
