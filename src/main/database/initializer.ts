// Database Initialization and Schema Management
// Ensures all required tables exist and are properly configured

import type Database from 'better-sqlite3';
import fs from 'fs';
import path from 'path';

export class DatabaseInitializer {
  private db: Database.Database;
  private schemaVersion: number = 1;

  constructor(db: Database.Database) {
    this.db = db;
  }

  /**
   * Initialize database with full schema
   */
  async initialize(): Promise<void> {
    try {
      // Enable foreign keys
      this.db.pragma('foreign_keys = ON');

      // Create all tables
      this.createTables();

      // Verify schema integrity
      this.verifySchema();

      console.log('Database initialized successfully');
    } catch (error) {
      console.error('Database initialization failed:', error);
      throw error;
    }
  }

  /**
   * Create all required tables
   */
  private createTables(): void {
    const schema = `
      -- API Keys (BYOK) Table
      CREATE TABLE IF NOT EXISTS api_keys_byok (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          player_id TEXT NOT NULL UNIQUE,
          encrypted_key_blob TEXT NOT NULL,
          key_hash TEXT NOT NULL,
          created_at TEXT NOT NULL,
          last_used TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          provider_url TEXT NOT NULL DEFAULT 'https://api.anthropic.com',
          metadata TEXT DEFAULT '{}',
          FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE INDEX IF NOT EXISTS idx_api_keys_player_active ON api_keys_byok(player_id, is_active);
      CREATE INDEX IF NOT EXISTS idx_api_keys_last_used ON api_keys_byok(last_used DESC);

      -- Conversation History Table
      CREATE TABLE IF NOT EXISTS conversation_history (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          npc_id TEXT NOT NULL,
          player_id TEXT NOT NULL,
          message_role TEXT NOT NULL CHECK(message_role IN ('user', 'assistant')),
          message_content TEXT NOT NULL,
          tokens_used INTEGER DEFAULT 0,
          model_used TEXT DEFAULT 'claude-haiku-4-5-20251001',
          created_at TEXT NOT NULL,
          is_archived INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE INDEX IF NOT EXISTS idx_conversation_npc_player ON conversation_history(npc_id, player_id);
      CREATE INDEX IF NOT EXISTS idx_conversation_created_at ON conversation_history(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_conversation_archived ON conversation_history(is_archived);

      -- Token Usage Tracking Table
      CREATE TABLE IF NOT EXISTS token_usage (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          player_id TEXT NOT NULL,
          request_id TEXT UNIQUE NOT NULL,
          model TEXT NOT NULL,
          input_tokens INTEGER NOT NULL,
          output_tokens INTEGER NOT NULL,
          total_tokens INTEGER NOT NULL,
          cost_usd REAL NOT NULL,
          key_type TEXT NOT NULL CHECK(key_type IN ('server', 'player_byok')),
          endpoint TEXT NOT NULL CHECK(endpoint IN ('npc_chat', 'director', 'moderation', 'quest_gen', 'lore_generation', 'event_narration')),
          created_at TEXT NOT NULL,
          daily_aggregate TEXT NOT NULL,
          FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE INDEX IF NOT EXISTS idx_token_usage_player_date ON token_usage(player_id, daily_aggregate);
      CREATE INDEX IF NOT EXISTS idx_token_usage_endpoint ON token_usage(endpoint);
      CREATE INDEX IF NOT EXISTS idx_token_usage_created_at ON token_usage(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_token_usage_key_type ON token_usage(key_type);

      -- AI Response Cache Table
      CREATE TABLE IF NOT EXISTS ai_response_cache (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          query_hash TEXT NOT NULL UNIQUE,
          npc_id TEXT,
          request_context TEXT NOT NULL,
          cached_response TEXT NOT NULL,
          tokens_saved INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          expires_at TEXT NOT NULL,
          hit_count INTEGER DEFAULT 1
      );

      CREATE INDEX IF NOT EXISTS idx_cache_query_hash ON ai_response_cache(query_hash);
      CREATE INDEX IF NOT EXISTS idx_cache_expires_at ON ai_response_cache(expires_at);
      CREATE INDEX IF NOT EXISTS idx_cache_npc_id ON ai_response_cache(npc_id);

      -- Director AI State Table
      CREATE TABLE IF NOT EXISTS director_state (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          world_snapshot TEXT NOT NULL,
          npc_moods TEXT NOT NULL DEFAULT '{}',
          recent_events TEXT NOT NULL DEFAULT '[]',
          last_update TEXT NOT NULL,
          context_version INTEGER NOT NULL DEFAULT 1
      );

      CREATE INDEX IF NOT EXISTS idx_director_state_last_update ON director_state(last_update DESC);

      -- Conversation History Metadata
      CREATE TABLE IF NOT EXISTS conversation_metadata (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          npc_id TEXT NOT NULL,
          player_id TEXT NOT NULL,
          message_count INTEGER DEFAULT 0,
          total_tokens_used INTEGER DEFAULT 0,
          last_interaction TEXT,
          relationship_status TEXT DEFAULT 'neutral',
          UNIQUE(npc_id, player_id),
          FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE INDEX IF NOT EXISTS idx_conversation_metadata_npc_player ON conversation_metadata(npc_id, player_id);

      -- Token Usage Daily Summary
      CREATE TABLE IF NOT EXISTS token_usage_daily (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          player_id TEXT NOT NULL,
          aggregate_date TEXT NOT NULL,
          total_tokens INTEGER DEFAULT 0,
          total_cost_usd REAL DEFAULT 0,
          by_endpoint TEXT DEFAULT '{}',
          by_key_type TEXT DEFAULT '{}',
          UNIQUE(player_id, aggregate_date),
          FOREIGN KEY (player_id) REFERENCES players(id)
      );

      CREATE INDEX IF NOT EXISTS idx_token_daily_player_date ON token_usage_daily(player_id, aggregate_date DESC);

      -- Cache Statistics
      CREATE TABLE IF NOT EXISTS cache_stats (
          id TEXT PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
          recorded_at TEXT NOT NULL,
          total_entries INTEGER,
          hit_rate REAL,
          average_hit_count REAL,
          memory_usage_bytes INTEGER,
          oldest_entry_age_seconds INTEGER
      );

      CREATE INDEX IF NOT EXISTS idx_cache_stats_recorded_at ON cache_stats(recorded_at DESC);

      -- Players Table
      CREATE TABLE IF NOT EXISTS players (
          id TEXT PRIMARY KEY,
          username TEXT UNIQUE NOT NULL,
          is_premium INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
      );

      CREATE INDEX IF NOT EXISTS idx_players_premium ON players(is_premium);
    `;

    // Split schema into individual statements and execute
    const statements = schema
      .split(';')
      .map((s) => s.trim())
      .filter((s) => s.length > 0);

    for (const statement of statements) {
      try {
        this.db.exec(statement);
      } catch (error) {
        console.error(`Failed to execute statement: ${statement}`, error);
      }
    }

    // Initialize Director State with empty state
    try {
      const stmt = this.db.prepare(`
        INSERT OR IGNORE INTO director_state (world_snapshot, npc_moods, recent_events, last_update)
        VALUES (?, ?, ?, ?)
      `);
      stmt.run('{}', '{}', '[]', new Date().toISOString());
    } catch (error) {
      console.error('Failed to initialize director state:', error);
    }
  }

  /**
   * Verify schema integrity
   */
  private verifySchema(): void {
    const requiredTables = [
      'api_keys_byok',
      'conversation_history',
      'token_usage',
      'ai_response_cache',
      'director_state',
      'conversation_metadata',
      'token_usage_daily',
      'cache_stats',
      'players',
    ];

    const stmt = this.db.prepare(
      `SELECT name FROM sqlite_master WHERE type='table' AND name=?`
    );

    for (const table of requiredTables) {
      const result: any = stmt.get(table);
      if (!result) {
        throw new Error(`Required table missing: ${table}`);
      }
    }

    console.log('Schema verification passed');
  }

  /**
   * Get database statistics
   */
  getStats(): {
    tableCount: number;
    indexCount: number;
    totalSize: number;
  } {
    const tables: any = this.db
      .prepare(`SELECT COUNT(*) as count FROM sqlite_master WHERE type='table'`)
      .get();

    const indexes: any = this.db
      .prepare(`SELECT COUNT(*) as count FROM sqlite_master WHERE type='index'`)
      .get();

    const pageCount: any = this.db.pragma('page_count');
    const pageSize: any = this.db.pragma('page_size');

    return {
      tableCount: tables.count,
      indexCount: indexes.count,
      totalSize: pageCount * pageSize,
    };
  }

  /**
   * Clear all data (for testing only)
   */
  clearAll(): void {
    const tables = [
      'api_keys_byok',
      'conversation_history',
      'token_usage',
      'ai_response_cache',
      'director_state',
      'conversation_metadata',
      'token_usage_daily',
      'cache_stats',
    ];

    for (const table of tables) {
      try {
        this.db.exec(`DELETE FROM ${table}`);
      } catch (error) {
        console.error(`Failed to clear table ${table}:`, error);
      }
    }
  }
}

export default DatabaseInitializer;
