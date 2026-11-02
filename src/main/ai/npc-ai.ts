/**
 * NPC AI System
 * Handles NPC conversations and intelligent responses using Claude AI
 */

import { EventBus } from '../state/event-bus';
import { WorkerPool } from '../threading/worker-pool';

interface ConversationContext {
  npcId: string;
  npcName: string;
  npcPersonality: string;
  npcType: string;
  playerId: string;
  history: Array<{ role: 'user' | 'assistant'; content: string }>;
  lastMessageTime: number;
}

export class NPCAISystem {
  private conversations: Map<string, ConversationContext> = new Map();
  private claudeApiKey: string | null = null;
  private claudeApiUrl: string = 'https://api.openai-proxy.cloud/v1/chat/completions';
  private totalConversations: number = 0;
  private totalMessages: number = 0;

  constructor(
    private eventBus: EventBus,
    private workerPool: WorkerPool | null
  ) {
    this.setupEventListeners();
  }

  /**
   * Set Claude API key (BYOK)
   */
  setApiKey(apiKey: string): void {
    this.claudeApiKey = apiKey;
    console.log('[NPC AI] Claude API key configured');
  }

  private setupEventListeners(): void {
    this.eventBus.subscribe('conversation-start', (data: any) => {
      this.startConversation(data.npcId, data.npcName, data.npcPersonality, data.npcType, data.playerId);
    });

    this.eventBus.subscribe('conversation-message', async (data: any) => {
      const response = await this.processMessage(data.npcId, data.playerId, data.message);
      this.eventBus.publish('conversation-response', {
        npcId: data.npcId,
        playerId: data.playerId,
        message: response,
      });
    });

    this.eventBus.subscribe('conversation-end', (data: any) => {
      this.endConversation(data.npcId, data.playerId);
    });
  }

  /**
   * Start a conversation
   */
  startConversation(
    npcId: string,
    npcName: string,
    npcPersonality: string,
    npcType: string,
    playerId: string
  ): void {
    const conversationKey = `${npcId}-${playerId}`;

    this.conversations.set(conversationKey, {
      npcId,
      npcName,
      npcPersonality,
      npcType,
      playerId,
      history: [],
      lastMessageTime: Date.now(),
    });

    this.totalConversations++;
    console.log(`[NPC AI] Started conversation: ${npcName} with player ${playerId}`);
  }

  /**
   * Process a message from player
   */
  async processMessage(npcId: string, playerId: string, playerMessage: string): Promise<string> {
    const conversationKey = `${npcId}-${playerId}`;
    const context = this.conversations.get(conversationKey);

    if (!context) {
      console.warn(`[NPC AI] No active conversation for ${conversationKey}`);
      return "I don't think we've been introduced.";
    }

    context.lastMessageTime = Date.now();
    context.history.push({ role: 'user', content: playerMessage });
    this.totalMessages++;

    // If no API key, use fallback responses
    if (!this.claudeApiKey) {
      const response = this.generateFallbackResponse(context, playerMessage);
      context.history.push({ role: 'assistant', content: response });
      return response;
    }

    try {
      // Generate AI response
      const response = await this.generateAIResponse(context, playerMessage);
      context.history.push({ role: 'assistant', content: response });
      return response;
    } catch (error) {
      console.error('[NPC AI] Error generating response:', error);
      const fallback = this.generateFallbackResponse(context, playerMessage);
      context.history.push({ role: 'assistant', content: fallback });
      return fallback;
    }
  }

  /**
   * Generate AI response using Claude
   */
  private async generateAIResponse(context: ConversationContext, playerMessage: string): Promise<string> {
    const systemPrompt = this.buildSystemPrompt(context);

    const messages = [
      { role: 'system', content: systemPrompt },
      ...context.history,
    ];

    const response = await fetch(this.claudeApiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.claudeApiKey}`,
      },
      body: JSON.stringify({
        model: 'claude-3-5-sonnet-20241022',
        messages,
        max_tokens: 150,
        temperature: 0.8,
      }),
    });

    if (!response.ok) {
      throw new Error(`Claude API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    return data.choices[0].message.content;
  }

  /**
   * Build system prompt for NPC
   */
  private buildSystemPrompt(context: ConversationContext): string {
    const personalityTraits: Record<string, string> = {
      friendly: 'You are warm, welcoming, and eager to help. You smile often and make people feel comfortable.',
      nervous: 'You are anxious and jumpy. You speak quickly and look around nervously. You worry about everything.',
      curious: 'You ask lots of questions and are fascinated by everything around you. You love learning new things.',
      stern: 'You are serious and no-nonsense. You speak directly and expect others to follow the rules.',
      aggressive: 'You are confrontational and quick to anger. You speak roughly and threaten those who cross you.',
      mysterious: 'You speak in riddles and hints. You know more than you let on and enjoy keeping secrets.',
    };

    const typeContext: Record<string, string> = {
      shopkeeper: 'You run a shop in the city. You know about items, prices, and local trade.',
      civilian: 'You are an ordinary citizen living in the city. You know local gossip and daily life.',
      police: 'You are a law enforcement officer. You care about order, safety, and catching criminals.',
      criminal: 'You are involved in illegal activities. You speak in code and are wary of authority.',
      informant: 'You gather and sell information. You know secrets about people and places.',
    };

    return `You are ${context.npcName}, a ${context.npcType} in the city of Agervis.

Personality: ${personalityTraits[context.npcPersonality] || context.npcPersonality}

Role: ${typeContext[context.npcType] || 'You live in the city and interact with people.'}

IMPORTANT RULES:
- Keep responses SHORT (1-3 sentences max)
- Stay in character at all times
- You are in a crime/city roleplay game
- Respond naturally to what the player says
- If asked about quests, offer simple tasks related to your role
- Don't break the fourth wall or mention you're an AI

Player has said: "${context.history.length > 0 ? context.history[context.history.length - 1].content : 'nothing yet'}"`;
  }

  /**
   * Generate fallback response without AI
   */
  private generateFallbackResponse(context: ConversationContext, playerMessage: string): string {
    const lowerMessage = playerMessage.toLowerCase();

    // Greeting
    if (lowerMessage.includes('hello') || lowerMessage.includes('hi') || lowerMessage.includes('hey')) {
      return `Hello there! I'm ${context.npcName}.`;
    }

    // Questions about quests
    if (lowerMessage.includes('quest') || lowerMessage.includes('job') || lowerMessage.includes('work')) {
      if (context.npcType === 'shopkeeper') {
        return "I could use help restocking inventory. Bring me 5 health potions and I'll pay you.";
      } else if (context.npcType === 'police') {
        return "We need vigilant citizens. Report any suspicious activity you see.";
      } else {
        return "I don't have anything for you right now.";
      }
    }

    // Buying/selling
    if (lowerMessage.includes('buy') || lowerMessage.includes('sell') || lowerMessage.includes('shop')) {
      if (context.npcType === 'shopkeeper') {
        return "Check my inventory. I've got what you need.";
      } else {
        return "I'm not a merchant. Try the shops downtown.";
      }
    }

    // Information
    if (lowerMessage.includes('where') || lowerMessage.includes('who') || lowerMessage.includes('what')) {
      return "I'm not sure about that. Maybe ask around?";
    }

    // Goodbye
    if (lowerMessage.includes('bye') || lowerMessage.includes('goodbye') || lowerMessage.includes('see you')) {
      return "Take care out there!";
    }

    // Default personality-based responses
    switch (context.npcPersonality) {
      case 'friendly':
        return "That's interesting! Tell me more.";
      case 'nervous':
        return "Uh... I... I don't know about that...";
      case 'curious':
        return "Really? That's fascinating!";
      case 'stern':
        return "Get to the point.";
      case 'aggressive':
        return "Watch your tone.";
      case 'mysterious':
        return "Perhaps... perhaps not.";
      default:
        return "I see.";
    }
  }

  /**
   * End a conversation
   */
  endConversation(npcId: string, playerId: string): void {
    const conversationKey = `${npcId}-${playerId}`;
    this.conversations.delete(conversationKey);
    console.log(`[NPC AI] Ended conversation: ${conversationKey}`);
  }

  /**
   * Clean up old conversations (after 5 minutes of inactivity)
   */
  cleanupOldConversations(): void {
    const now = Date.now();
    const timeout = 5 * 60 * 1000; // 5 minutes

    const keysToDelete: string[] = [];
    this.conversations.forEach((context, key) => {
      if (now - context.lastMessageTime > timeout) {
        keysToDelete.push(key);
      }
    });

    keysToDelete.forEach((key) => {
      this.conversations.delete(key);
      console.log(`[NPC AI] Cleaned up inactive conversation: ${key}`);
    });
  }

  getStats() {
    return {
      activeConversations: this.conversations.size,
      totalConversations: this.totalConversations,
      totalMessages: this.totalMessages,
      hasApiKey: !!this.claudeApiKey,
    };
  }
}
