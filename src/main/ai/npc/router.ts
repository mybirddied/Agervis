// NPC Conversation Router
// Routes player messages to appropriate NPC with context injection, BYOK key selection, and streaming

import type Database from 'better-sqlite3';
import AnthropicClientWrapper from '../anthropic-client';
import BYOKKeyManager from '../byok/key-manager';
import ConversationStore from '../storage/conversation-store';
import ResponseCache from '../storage/cache';
import TokenUsageTracker from '../storage/token-tracker';
import PromptTemplateEngine from '../prompts/template-engine';
import type { AnthropicMessage } from '../types/ai';

export class NPCConversationRouter {
  private db: Database.Database;
  private anthropic: AnthropicClientWrapper;
  private byokManager: BYOKKeyManager;
  private conversationStore: ConversationStore;
  private cache: ResponseCache;
  private tokenTracker: TokenUsageTracker;
  private templateEngine: PromptTemplateEngine;

  constructor(
    db: Database.Database,
    anthropic: AnthropicClientWrapper,
    byokManager: BYOKKeyManager,
    conversationStore: ConversationStore,
    cache: ResponseCache,
    tokenTracker: TokenUsageTracker
  ) {
    this.db = db;
    this.anthropic = anthropic;
    this.byokManager = byokManager;
    this.conversationStore = conversationStore;
    this.cache = cache;
    this.tokenTracker = tokenTracker;
    this.templateEngine = new PromptTemplateEngine();
  }

  /**
   * Route and process a player message to an NPC
   */
  async handlePlayerMessage(
    npcId: string,
    playerId: string,
    playerMessage: string,
    isPremium: boolean = false
  ): Promise<{ response: string; tokensUsed: number; cached: boolean }> {
    // Check cache first
    const sanitized = this.cache.sanitizeMessage(playerMessage);
    const metadata = this.conversationStore.getMetadata(npcId, playerId);
    const queryHash = this.cache.generateQueryHash(npcId, sanitized, {
      relationship: metadata.relationshipStatus,
      mood: 'neutral', // Would get from Director AI in production
    });

    const cachedEntry = this.cache.getCached(queryHash);
    if (cachedEntry) {
      // Add to conversation history (without re-calling API)
      this.conversationStore.addMessage(npcId, playerId, 'user', playerMessage, 0);
      this.conversationStore.addMessage(npcId, playerId, 'assistant', cachedEntry.cachedResponse, cachedEntry.tokensSaved);

      return {
        response: cachedEntry.cachedResponse,
        tokensUsed: 0, // Cached, so no tokens used
        cached: true,
      };
    }

    // Add user message to history
    this.conversationStore.addMessage(npcId, playerId, 'user', playerMessage, 0);

    // Get conversation history for context
    const history = this.conversationStore.getRecentHistory(npcId, playerId, 20);
    const conversationMessages: AnthropicMessage[] = history.map((msg) => ({
      role: msg.role,
      content: msg.content,
    }));

    // Get current mood from Director AI (would be integrated)
    const mood = 'neutral';

    // Generate NPC prompt
    const { systemPrompt, userMessage } = this.templateEngine.generateNPCPrompt(
      npcId,
      'Player', // Would get actual player name from DB
      mood,
      metadata.relationshipStatus,
      history.map((h) => ({ role: h.role, content: h.content })),
      playerMessage
    );

    // Determine which API key to use (BYOK or server fallback)
    const useByok = this.byokManager.hasPlayerKey(playerId);
    let apiClient = this.anthropic;

    if (useByok) {
      const playerKey = this.byokManager.getPlayerKey(playerId);
      const providerUrl = this.byokManager.getPlayerProviderUrl(playerId);

      if (playerKey) {
        // Create player-specific client with their key
        apiClient = new AnthropicClientWrapper({
          apiKey: playerKey,
          baseUrl: providerUrl,
          models: {
            director: 'claude-sonnet-4-20250514',
            npcDefault: 'claude-haiku-4-5-20251001',
            npcMajor: 'claude-sonnet-4-20250514',
            questGeneration: 'claude-sonnet-4-20250514',
            moderation: 'claude-haiku-4-5-20251001',
            loreGeneration: 'claude-sonnet-4-20250514',
          },
          limits: {
            requestsPerPlayerPerMinute: 10,
            dailyTokenBudgetFree: 50000,
            dailyTokenBudgetPaid: 500000,
            maxQueueSize: 100,
          },
          director: { intervalMs: 30000, maxContextTokens: 100000 },
          cache: { ttlNpcSeconds: 3600, ttlDirectorSeconds: 300, maxEntries: 10000 },
        } as any);

        this.byokManager.updateKeyUsage(playerId);
      }
    }

    // Call API
    try {
      const response = await apiClient.sendMessage(
        [...conversationMessages, { role: 'user', content: userMessage }],
        'claude-haiku-4-5-20251001',
        systemPrompt,
        1024
      );

      const responseText = response.content[0].text;
      const tokensUsed = response.usage.output_tokens;

      // Add response to history
      this.conversationStore.addMessage(npcId, playerId, 'assistant', responseText, tokensUsed);

      // Track tokens
      const keyType = useByok ? 'player_byok' : 'server';
      this.tokenTracker.trackUsage(
        playerId,
        response.id,
        'claude-haiku-4-5-20251001',
        response.usage.input_tokens,
        response.usage.output_tokens,
        'npc_chat',
        keyType
      );

      // Cache response
      this.cache.setCached(queryHash, responseText, npcId, { relationship: metadata.relationshipStatus }, 0);

      return {
        response: responseText,
        tokensUsed: response.usage.total_tokens,
        cached: false,
      };
    } catch (error) {
      console.error(`Failed to get NPC response for ${npcId}:`, error);
      throw error;
    }
  }

  /**
   * Stream a player message response (for real-time chat)
   */
  async *streamPlayerMessage(
    npcId: string,
    playerId: string,
    playerMessage: string
  ): AsyncGenerator<string> {
    // Get conversation history
    const history = this.conversationStore.getRecentHistory(npcId, playerId, 20);
    const metadata = this.conversationStore.getMetadata(npcId, playerId);

    // Generate prompt
    const { systemPrompt, userMessage } = this.templateEngine.generateNPCPrompt(
      npcId,
      'Player',
      'neutral',
      metadata.relationshipStatus,
      history.map((h) => ({ role: h.role, content: h.content })),
      playerMessage
    );

    // Stream response
    const conversationMessages: AnthropicMessage[] = history.map((msg) => ({
      role: msg.role,
      content: msg.content,
    }));

    let fullResponse = '';

    try {
      for await (const chunk of this.anthropic.streamMessage(
        [...conversationMessages, { role: 'user', content: userMessage }],
        'claude-haiku-4-5-20251001',
        systemPrompt,
        1024
      )) {
        fullResponse += chunk;
        yield chunk;
      }

      // Save full response to history after streaming completes
      this.conversationStore.addMessage(npcId, playerId, 'assistant', fullResponse, 0);
    } catch (error) {
      console.error(`Failed to stream NPC response for ${npcId}:`, error);
      throw error;
    }
  }

  /**
   * Get NPC conversation statistics
   */
  getConversationStats(npcId: string, playerId: string): {
    messageCount: number;
    lastInteraction: Date | null;
    relationshipStatus: string;
  } {
    return this.conversationStore.getMetadata(npcId, playerId);
  }
}

export default NPCConversationRouter;
