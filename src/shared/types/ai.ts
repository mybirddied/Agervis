// AI Infrastructure Type Definitions
// Core types for Anthropic API, Director AI, NPC conversations, and BYOK system

export type AIModel = 'claude-opus-4-1' | 'claude-sonnet-4-20250514' | 'claude-haiku-4-5-20251001';

export type AIEndpoint = 'npc_chat' | 'director' | 'moderation' | 'quest_gen' | 'lore_generation' | 'event_narration';

export type AIKeyType = 'server' | 'player_byok';

export interface AIConfig {
  baseUrl: string;
  apiKey: string;
  models: {
    director: AIModel;
    npcDefault: AIModel;
    npcMajor: AIModel;
    questGeneration: AIModel;
    moderation: AIModel;
    loreGeneration: AIModel;
  };
  limits: {
    requestsPerPlayerPerMinute: number;
    dailyTokenBudgetFree: number;
    dailyTokenBudgetPaid: number;
    maxQueueSize: number;
  };
  director: {
    intervalMs: number;
    maxContextTokens: number;
  };
  cache: {
    ttlNpcSeconds: number;
    ttlDirectorSeconds: number;
    maxEntries: number;
  };
}

export interface AnthropicMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface AnthropicResponse {
  id: string;
  type: 'message';
  role: 'assistant';
  content: Array<{ type: string; text: string }>;
  model: string;
  stop_reason: string;
  stop_sequence: string | null;
  usage: {
    input_tokens: number;
    output_tokens: number;
  };
}

export interface TokenUsage {
  requestId: string;
  model: AIModel;
  inputTokens: number;
  outputTokens: number;
  totalTokens: number;
  costUsd: number;
  timestamp: Date;
}

export interface AIRequestContext {
  playerId: string;
  endpoint: AIEndpoint;
  keyType: AIKeyType;
  model: AIModel;
  priority: 'high' | 'medium' | 'low';
  timeoutMs: number;
  retryAttempts: number;
}

export interface ConversationMessage {
  id: string;
  npcId: string;
  playerId: string;
  role: 'user' | 'assistant';
  content: string;
  tokensUsed: number;
  model: AIModel;
  createdAt: Date;
}

export interface NPCPersonality {
  npcId: string;
  name: string;
  archetype: string;
  personality: string;
  speakingStyle: string;
  model: AIModel;
  memoryEnabled: boolean;
  historySizeLimit: number;
}

export interface DirectorDecision {
  timestamp: Date;
  npcMoodUpdates: Record<string, string>;
  eventsToSpawn: Array<{ eventType: string; location: string; severity: string }>;
  narrativeNotes: string[];
}

export interface AIHealth {
  isHealthy: boolean;
  lastCheckTime: Date;
  apiReachable: boolean;
  databaseConnected: boolean;
  queueBacklog: number;
  averageResponseTimeMs: number;
}
