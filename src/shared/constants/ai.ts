// AI Infrastructure Constants and Configuration Defaults
// Models, pricing, rate limits, and system constants

import type { AIConfig, AIModel } from '../types/ai';

// Model Configuration
export const MODELS: Record<string, AIModel> = {
  DIRECTOR: 'claude-sonnet-4-20250514',
  NPC_DEFAULT: 'claude-haiku-4-5-20251001',
  NPC_MAJOR: 'claude-sonnet-4-20250514',
  QUEST_GENERATION: 'claude-sonnet-4-20250514',
  MODERATION: 'claude-haiku-4-5-20251001',
  LORE_GENERATION: 'claude-sonnet-4-20250514',
} as const;

// Token Pricing (as of Oct 2026)
export const TOKEN_PRICING: Record<AIModel, { input: number; output: number }> = {
  'claude-opus-4-1': { input: 0.015, output: 0.075 },
  'claude-sonnet-4-20250514': { input: 0.003, output: 0.015 },
  'claude-haiku-4-5-20251001': { input: 0.00008, output: 0.0004 },
};

// Rate Limits
export const RATE_LIMITS = {
  REQUESTS_PER_PLAYER_PER_MINUTE: 10,
  REQUESTS_PER_PLAYER_PER_HOUR: 300,
  DAILY_TOKEN_BUDGET_FREE: 50000, // ~$0.15 at avg pricing
  DAILY_TOKEN_BUDGET_PAID: 500000, // ~$1.50 at avg pricing
  MAX_QUEUE_SIZE: 100,
  DIRECTOR_INTERVAL_MS: 30000, // 30 seconds
  REQUEST_TIMEOUT_MS: 30000,
  MAX_RETRY_ATTEMPTS: 3,
} as const;

// Cache Configuration
export const CACHE_CONFIG = {
  TTL_NPC_SECONDS: 3600, // 1 hour for NPC responses
  TTL_DIRECTOR_SECONDS: 300, // 5 minutes for Director context
  MAX_ENTRIES: 10000,
  SEMANTIC_SIMILARITY_THRESHOLD: 0.85,
} as const;

// Encryption Configuration
export const ENCRYPTION_CONFIG = {
  ALGORITHM: 'aes-256-gcm',
  KEY_LENGTH: 32, // 256 bits
  IV_LENGTH: 16,
  AUTH_TAG_LENGTH: 16,
  SALT_LENGTH: 32,
  ITERATIONS: 100000,
  DIGEST: 'sha256',
} as const;

// Database Configuration
export const DATABASE_CONFIG = {
  CONNECTION_TIMEOUT: 5000,
  BUSY_TIMEOUT: 30000,
  STATEMENT_CACHE_SIZE: 100,
} as const;

// Default Configuration
export const DEFAULT_AI_CONFIG: AIConfig = {
  baseUrl: 'https://api.anthropic.com',
  apiKey: '', // Must be provided at runtime
  models: {
    director: MODELS.DIRECTOR,
    npcDefault: MODELS.NPC_DEFAULT,
    npcMajor: MODELS.NPC_MAJOR,
    questGeneration: MODELS.QUEST_GENERATION,
    moderation: MODELS.MODERATION,
    loreGeneration: MODELS.LORE_GENERATION,
  },
  limits: {
    requestsPerPlayerPerMinute: RATE_LIMITS.REQUESTS_PER_PLAYER_PER_MINUTE,
    dailyTokenBudgetFree: RATE_LIMITS.DAILY_TOKEN_BUDGET_FREE,
    dailyTokenBudgetPaid: RATE_LIMITS.DAILY_TOKEN_BUDGET_PAID,
    maxQueueSize: RATE_LIMITS.MAX_QUEUE_SIZE,
  },
  director: {
    intervalMs: RATE_LIMITS.DIRECTOR_INTERVAL_MS,
    maxContextTokens: 100000, // Max tokens for Director context window
  },
  cache: {
    ttlNpcSeconds: CACHE_CONFIG.TTL_NPC_SECONDS,
    ttlDirectorSeconds: CACHE_CONFIG.TTL_DIRECTOR_SECONDS,
    maxEntries: CACHE_CONFIG.MAX_ENTRIES,
  },
};

// System Prompts
export const SYSTEM_PROMPTS = {
  DIRECTOR: `You are the Director AI for Agervis, a multiplayer urban RPG. Your role is to monitor the entire game world, detect significant events, and make high-level decisions about NPC moods and world state changes.

You have access to:
- Current player actions and locations
- NPC schedules and relationships
- Crime evidence and heat levels
- Economy transactions
- Recent events and player conflicts

Your responsibilities:
1. Analyze player behavior patterns
2. Determine NPC emotional states based on witnessed events
3. Identify opportunities for dynamic events
4. Suggest consequences for player actions
5. Maintain narrative coherence

Output your decisions as valid JSON only (no markdown, no explanation).`,

  NPC_SYSTEM: `You are an NPC in Agervis, a multiplayer urban RPG. Stay in character. Respond based on your personality, current mood, and relationship with the player.

Remember:
- Speak naturally and authentically
- Reference the conversation history to maintain continuity
- Consider your current emotional state
- Adapt your response based on player reputation with you
- Keep responses concise (1-2 sentences typically)`,

  MODERATION: `You are a content moderation classifier for an urban RPG server. Analyze the provided text for:
1. Toxic language or harassment
2. Griefing patterns
3. Exploitative content
4. Real-world harmful content

Output JSON: { "flag": boolean, "severity": "none"|"low"|"medium"|"high", "category": string, "reason": string }`,

  QUEST_GENERATION: `You are a dynamic quest generator for an urban RPG. Based on the player's recent behavior, skills, and world state, generate an engaging side quest.

Output valid JSON only with: { "title": string, "description": string, "objectives": [string], "reward_money": number, "reward_xp": number, "difficulty": "easy"|"medium"|"hard" }`,
} as const;

// NPC Personalities (predefined templates)
export const NPC_PERSONALITY_TEMPLATES = {
  MOTH: {
    name: 'Moth',
    archetype: 'drug_dealer',
    personality: 'Cautious, trust-based, street-smart',
    speakingStyle: 'Slang-heavy, evasive when threatened',
    model: MODELS.NPC_MAJOR,
  },
  OFFICER_PIKE: {
    name: 'Officer Pike',
    archetype: 'police_officer',
    personality: 'Professional, duty-bound, by-the-book',
    speakingStyle: 'Formal, authoritative, enforcement-focused',
    model: MODELS.NPC_MAJOR,
  },
  BOSS: {
    name: 'Boss',
    archetype: 'crime_boss',
    personality: 'Calculating, power-hungry, business-minded',
    speakingStyle: 'Direct, threatening, businesslike',
    model: MODELS.NPC_MAJOR,
  },
  SHOPKEEPER: {
    name: 'Shopkeeper',
    archetype: 'merchant',
    personality: 'Friendly, profit-motivated, gossipy',
    speakingStyle: 'Casual, sales-focused, conversational',
    model: MODELS.NPC_DEFAULT,
  },
  HOMELESS_NPC: {
    name: 'Street Person',
    archetype: 'homeless',
    personality: 'Weathered, observant, paranoid',
    speakingStyle: 'Fragmented, unpredictable, cryptic',
    model: MODELS.NPC_DEFAULT,
  },
} as const;

// API Error Messages
export const API_ERROR_MESSAGES = {
  INVALID_API_KEY: 'Invalid API key. Please check your configuration.',
  RATE_LIMIT_EXCEEDED: 'Rate limit exceeded. Please try again later.',
  OVERLOADED: 'API is overloaded. Request queued for retry.',
  NETWORK_ERROR: 'Network error. Retrying request.',
  INVALID_BASE_URL: 'Invalid base URL. Unable to reach API endpoint.',
  REQUEST_TIMEOUT: 'Request timeout. Retrying with backoff.',
  MALFORMED_RESPONSE: 'Received malformed response from API.',
  UNKNOWN_ERROR: 'Unknown API error occurred.',
} as const;

// Request Priority Levels
export const PRIORITY_LEVELS = {
  DIRECTOR_AI: 100,
  PAID_NPC: 50,
  FREE_NPC: 25,
  BACKGROUND_TASK: 10,
} as const;
