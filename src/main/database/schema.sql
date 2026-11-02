-- Agervis AI Infrastructure Database Schema
-- SQLite schema for BYOK keys, conversations, token tracking, caching, and director state

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

-- Conversation History Metadata (for efficient queries)
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

-- Token Usage Daily Summary (for fast aggregation)
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

-- Cache Statistics (for monitoring and optimization)
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

-- Players table (basic reference - full schema in game systems)
CREATE TABLE IF NOT EXISTS players (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    is_premium INTEGER DEFAULT 0,
    created_at TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_players_premium ON players(is_premium);

-- Admin Accounts Table
CREATE TABLE IF NOT EXISTS admin_accounts (
    id TEXT PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('admin', 'viewer')),
    created_at TEXT NOT NULL,
    last_login TEXT,
    is_active INTEGER NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_admin_accounts_username ON admin_accounts(username);
CREATE INDEX IF NOT EXISTS idx_admin_accounts_active ON admin_accounts(is_active);

-- Authentication Sessions Table
CREATE TABLE IF NOT EXISTS auth_sessions (
    token TEXT PRIMARY KEY,
    admin_id TEXT NOT NULL,
    expires_at TEXT NOT NULL,
    created_at TEXT NOT NULL,
    FOREIGN KEY (admin_id) REFERENCES admin_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_auth_sessions_admin_id ON auth_sessions(admin_id);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_expires_at ON auth_sessions(expires_at);

-- Initialize Director State with empty state
INSERT OR IGNORE INTO director_state (world_snapshot, npc_moods, recent_events, last_update)
VALUES ('{}', '{}', '[]', datetime('now'));
