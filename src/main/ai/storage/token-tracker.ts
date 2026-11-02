// Token Usage Tracker
// Real-time tracking and aggregation of AI token usage per player

import type Database from 'better-sqlite3';
import { TOKEN_PRICING } from '../constants/ai';
import type { AIModel, AIEndpoint, AIKeyType } from '../types/ai';

export interface DailyTokenStats {
  date: string;
  totalTokens: number;
  totalCostUsd: number;
  byEndpoint: Record<AIEndpoint, { tokens: number; cost: number }>;
  byKeyType: Record<AIKeyType, { tokens: number; cost: number }>;
}

export class TokenUsageTracker {
  private db: Database.Database;
  private inMemoryCache: Map<string, { tokens: number; cost: number }> = new Map();

  constructor(db: Database.Database) {
    this.db = db;
  }

  /**
   * Track a single API request's token usage
   */
  trackUsage(
    playerId: string,
    requestId: string,
    model: AIModel,
    inputTokens: number,
    outputTokens: number,
    endpoint: AIEndpoint,
    keyType: AIKeyType
  ): number {
    const totalTokens = inputTokens + outputTokens;
    const pricing = TOKEN_PRICING[model] || { input: 0.001, output: 0.001 };
    const costUsd = (inputTokens * pricing.input + outputTokens * pricing.output) / 1_000_000; // Convert to cents to dollars

    const now = new Date();
    const dailyDate = now.toISOString().split('T')[0];

    const stmt = this.db.prepare(`
      INSERT INTO token_usage
      (player_id, request_id, model, input_tokens, output_tokens, total_tokens, cost_usd, key_type, endpoint, created_at, daily_aggregate)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    stmt.run(
      playerId,
      requestId,
      model,
      inputTokens,
      outputTokens,
      totalTokens,
      costUsd,
      keyType,
      endpoint,
      now.toISOString(),
      dailyDate
    );

    // Update daily summary
    this.updateDailySummary(playerId, dailyDate, totalTokens, costUsd, endpoint, keyType);

    // Update in-memory cache
    const cacheKey = `${playerId}:${dailyDate}`;
    const cached = this.inMemoryCache.get(cacheKey) || { tokens: 0, cost: 0 };
    this.inMemoryCache.set(cacheKey, {
      tokens: cached.tokens + totalTokens,
      cost: cached.cost + costUsd,
    });

    return totalTokens;
  }

  /**
   * Get daily token usage for a player
   */
  getDailyUsage(playerId: string, date?: string): DailyTokenStats {
    const queryDate = date || new Date().toISOString().split('T')[0];

    const stmt = this.db.prepare(`
      SELECT
        total_tokens,
        total_cost_usd,
        by_endpoint,
        by_key_type
      FROM token_usage_daily
      WHERE player_id = ? AND aggregate_date = ?
    `);

    const row: any = stmt.get(playerId, queryDate);

    if (!row) {
      return {
        date: queryDate,
        totalTokens: 0,
        totalCostUsd: 0,
        byEndpoint: this.initEndpointStats(),
        byKeyType: { server: { tokens: 0, cost: 0 }, player_byok: { tokens: 0, cost: 0 } },
      };
    }

    return {
      date: queryDate,
      totalTokens: row.total_tokens,
      totalCostUsd: row.total_cost_usd,
      byEndpoint: JSON.parse(row.by_endpoint),
      byKeyType: JSON.parse(row.by_key_type),
    };
  }

  /**
   * Get usage for a date range
   */
  getRangeUsage(playerId: string, startDate: string, endDate: string): DailyTokenStats[] {
    const stmt = this.db.prepare(`
      SELECT
        aggregate_date,
        total_tokens,
        total_cost_usd,
        by_endpoint,
        by_key_type
      FROM token_usage_daily
      WHERE player_id = ? AND aggregate_date BETWEEN ? AND ?
      ORDER BY aggregate_date DESC
    `);

    const rows: any[] = stmt.all(playerId, startDate, endDate);

    return rows.map((row) => ({
      date: row.aggregate_date,
      totalTokens: row.total_tokens,
      totalCostUsd: row.total_cost_usd,
      byEndpoint: JSON.parse(row.by_endpoint),
      byKeyType: JSON.parse(row.by_key_type),
    }));
  }

  /**
   * Get total tokens used today
   */
  getTodayUsage(playerId: string): number {
    const today = new Date().toISOString().split('T')[0];
    const cacheKey = `${playerId}:${today}`;

    // Try in-memory cache first
    const cached = this.inMemoryCache.get(cacheKey);
    if (cached) {
      return cached.tokens;
    }

    // Fall back to database
    const daily = this.getDailyUsage(playerId, today);
    return daily.totalTokens;
  }

  /**
   * Check if player has exceeded daily budget
   */
  hasExceededBudget(playerId: string, isPremium: boolean, dailyBudget: number): boolean {
    const today = this.getTodayUsage(playerId);
    return today >= dailyBudget;
  }

  /**
   * Get token usage by endpoint (for optimization)
   */
  getUsageByEndpoint(playerId: string, date?: string): Record<AIEndpoint, number> {
    const stats = this.getDailyUsage(playerId, date);
    const result: Record<AIEndpoint, number> = {} as any;

    for (const [endpoint, data] of Object.entries(stats.byEndpoint)) {
      result[endpoint as AIEndpoint] = (data as any).tokens;
    }

    return result;
  }

  /**
   * Get aggregate stats for all players (admin dashboard)
   */
  getAggregateStats(date?: string): {
    totalTokens: number;
    totalCostUsd: number;
    activeUsers: number;
    averagePerUser: number;
  } {
    const queryDate = date || new Date().toISOString().split('T')[0];

    const stmt = this.db.prepare(`
      SELECT
        SUM(total_tokens) as total_tokens,
        SUM(total_cost_usd) as total_cost_usd,
        COUNT(DISTINCT player_id) as active_users
      FROM token_usage_daily
      WHERE aggregate_date = ?
    `);

    const row: any = stmt.get(queryDate);

    return {
      totalTokens: row?.total_tokens || 0,
      totalCostUsd: row?.total_cost_usd || 0,
      activeUsers: row?.active_users || 0,
      averagePerUser: row?.active_users ? Math.round((row.total_tokens || 0) / row.active_users) : 0,
    };
  }

  /**
   * Clean up old records (older than 90 days)
   */
  archiveOldRecords(daysToKeep: number = 90): number {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);
    const cutoffDateStr = cutoffDate.toISOString().split('T')[0];

    const stmt = this.db.prepare(`
      DELETE FROM token_usage
      WHERE created_at < ?
    `);

    const result = stmt.run(cutoffDateStr);
    return (result.changes as number) || 0;
  }

  /**
   * Private: Update daily summary table
   */
  private updateDailySummary(
    playerId: string,
    date: string,
    totalTokens: number,
    costUsd: number,
    endpoint: AIEndpoint,
    keyType: AIKeyType
  ): void {
    // Get current summary
    const getStmt = this.db.prepare(`
      SELECT total_tokens, total_cost_usd, by_endpoint, by_key_type
      FROM token_usage_daily
      WHERE player_id = ? AND aggregate_date = ?
    `);

    const row: any = getStmt.get(playerId, date);
    const byEndpoint = row ? JSON.parse(row.by_endpoint) : this.initEndpointStats();
    const byKeyType = row
      ? JSON.parse(row.by_key_type)
      : { server: { tokens: 0, cost: 0 }, player_byok: { tokens: 0, cost: 0 } };

    // Update endpoint stats
    if (!byEndpoint[endpoint]) {
      byEndpoint[endpoint] = { tokens: 0, cost: 0 };
    }
    byEndpoint[endpoint].tokens += totalTokens;
    byEndpoint[endpoint].cost += costUsd;

    // Update key type stats
    if (!byKeyType[keyType]) {
      byKeyType[keyType] = { tokens: 0, cost: 0 };
    }
    byKeyType[keyType].tokens += totalTokens;
    byKeyType[keyType].cost += costUsd;

    // Upsert summary
    const upsertStmt = this.db.prepare(`
      INSERT INTO token_usage_daily (player_id, aggregate_date, total_tokens, total_cost_usd, by_endpoint, by_key_type)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(player_id, aggregate_date) DO UPDATE SET
        total_tokens = total_tokens + ?,
        total_cost_usd = total_cost_usd + ?,
        by_endpoint = ?,
        by_key_type = ?
    `);

    upsertStmt.run(
      playerId,
      date,
      row ? 0 : totalTokens,
      row ? 0 : costUsd,
      row ? byEndpoint : JSON.stringify(byEndpoint),
      row ? byKeyType : JSON.stringify(byKeyType),
      totalTokens,
      costUsd,
      JSON.stringify(byEndpoint),
      JSON.stringify(byKeyType)
    );
  }

  /**
   * Initialize endpoint stats structure
   */
  private initEndpointStats(): Record<AIEndpoint, { tokens: number; cost: number }> {
    return {
      npc_chat: { tokens: 0, cost: 0 },
      director: { tokens: 0, cost: 0 },
      moderation: { tokens: 0, cost: 0 },
      quest_gen: { tokens: 0, cost: 0 },
      lore_generation: { tokens: 0, cost: 0 },
      event_narration: { tokens: 0, cost: 0 },
    };
  }
}

export default TokenUsageTracker;
