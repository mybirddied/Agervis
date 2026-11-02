// Prompt Template Engine
// Dynamic prompt generation with context injection and variable substitution

import { SYSTEM_PROMPTS, NPC_PERSONALITY_TEMPLATES } from '../constants/ai';
import type { AIModel } from '../types/ai';

export interface TemplateContext {
  [key: string]: string | number | boolean | Record<string, any>;
}

export class PromptTemplateEngine {
  private templates: Map<string, string> = new Map();
  private systemPrompts: Map<string, string> = new Map();

  constructor() {
    // Load system prompts
    this.systemPrompts.set('director', SYSTEM_PROMPTS.DIRECTOR);
    this.systemPrompts.set('npc', SYSTEM_PROMPTS.NPC_SYSTEM);
    this.systemPrompts.set('moderation', SYSTEM_PROMPTS.MODERATION);
    this.systemPrompts.set('quest_generation', SYSTEM_PROMPTS.QUEST_GENERATION);
  }

  /**
   * Compile a prompt template with context variables
   */
  compile(templateName: string, context: TemplateContext): string {
    let template = this.templates.get(templateName) || this.getDefaultTemplate(templateName);

    if (!template) {
      throw new Error(`Unknown template: ${templateName}`);
    }

    return this.substituteVariables(template, context);
  }

  /**
   * Generate NPC conversation prompt
   */
  generateNPCPrompt(
    npcId: string,
    playerName: string,
    currentMood: string,
    relationshipStatus: string,
    conversationHistory: Array<{ role: string; content: string }>,
    playerMessage: string
  ): { systemPrompt: string; userMessage: string } {
    const npcData = this.getNPCPersonalityData(npcId);
    const historyText = this.formatConversationHistory(conversationHistory);

    const context = {
      npcName: npcData.name,
      npcPersonality: npcData.personality,
      npcSpeakingStyle: npcData.speakingStyle,
      playerName,
      currentMood,
      relationshipStatus,
      conversationHistory: historyText,
      playerMessage,
    };

    const systemPrompt = this.compile('npc', context);

    const userMessage = `
${relationshipStatus !== 'neutral' ? `[Relationship: ${relationshipStatus}]` : ''}
[Current Mood: ${currentMood}]

${historyText}

${playerName}: "${playerMessage}"

Respond as ${npcData.name}:`;

    return { systemPrompt, userMessage };
  }

  /**
   * Generate Director AI prompt
   */
  generateDirectorPrompt(
    worldSnapshot: Record<string, any>,
    recentEvents: Array<{ timestamp: string; event: string }>,
    npcStates: Record<string, any>,
    playerBehaviors: Record<string, any>
  ): { systemPrompt: string; userMessage: string } {
    const systemPrompt = this.systemPrompts.get('director') || '';

    const userMessage = `
Current World State:
${JSON.stringify(worldSnapshot, null, 2)}

Recent Events (last 60 seconds):
${recentEvents.map((e) => `- ${e.timestamp}: ${e.event}`).join('\n')}

NPC States:
${JSON.stringify(npcStates, null, 2)}

Player Behaviors:
${JSON.stringify(playerBehaviors, null, 2)}

Analyze the situation and provide decisions in JSON format:
{
  "npcMoodUpdates": { "npcId": "mood", ... },
  "eventsToSpawn": [{ "eventType": "...", "location": "...", "severity": "..." }],
  "narrativeNotes": ["...", "..."]
}`;

    return { systemPrompt, userMessage };
  }

  /**
   * Generate moderation check prompt
   */
  generateModerationPrompt(text: string, context: string = 'chat'): { systemPrompt: string; userMessage: string } {
    const systemPrompt = this.systemPrompts.get('moderation') || '';

    const userMessage = `
Context: ${context}

Text to analyze:
"${text}"

Provide moderation decision in JSON format only (no markdown):
{
  "flag": boolean,
  "severity": "none" | "low" | "medium" | "high",
  "category": "string",
  "reason": "string"
}`;

    return { systemPrompt, userMessage };
  }

  /**
   * Generate quest generation prompt
   */
  generateQuestPrompt(
    playerName: string,
    playerSkills: Record<string, number>,
    recentActions: string[],
    worldState: Record<string, any>
  ): { systemPrompt: string; userMessage: string } {
    const systemPrompt = this.systemPrompts.get('quest_generation') || '';

    const userMessage = `
Player: ${playerName}

Skills:
${Object.entries(playerSkills)
  .map(([skill, level]) => `- ${skill}: ${level}`)
  .join('\n')}

Recent Actions:
${recentActions.map((action) => `- ${action}`).join('\n')}

Current World State:
${JSON.stringify(worldState, null, 2)}

Generate a quest for this player in JSON format:
{
  "title": "string",
  "description": "string",
  "objectives": ["string", "string"],
  "reward_money": number,
  "reward_xp": number,
  "difficulty": "easy" | "medium" | "hard"
}`;

    return { systemPrompt, userMessage };
  }

  /**
   * Get system prompt by type
   */
  getSystemPrompt(type: string): string {
    return this.systemPrompts.get(type) || '';
  }

  /**
   * Register custom template
   */
  registerTemplate(name: string, template: string): void {
    this.templates.set(name, template);
  }

  /**
   * Private: Substitute variables in template
   */
  private substituteVariables(template: string, context: TemplateContext): string {
    let result = template;

    for (const [key, value] of Object.entries(context)) {
      const regex = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
      const stringValue = typeof value === 'string' ? value : JSON.stringify(value, null, 2);
      result = result.replace(regex, stringValue);
    }

    return result;
  }

  /**
   * Private: Get default template by name
   */
  private getDefaultTemplate(templateName: string): string | null {
    const templates: Record<string, string> = {
      npc: `You are {{npcName}}, a {{npcPersonality}} character in the Agervis urban RPG.

Personality: {{npcPersonality}}
Speaking Style: {{npcSpeakingStyle}}

Your relationship with {{playerName}} is {{relationshipStatus}}.
Your current mood is {{currentMood}}.

Conversation History:
{{conversationHistory}}

Respond naturally and stay in character. Keep responses concise (1-2 sentences).`,

      lore: `Generate a compelling lore entry for {{subject}} in the Agervis urban RPG.

Context: {{context}}

Requirements:
- 2-3 sentences
- Fits the urban crime RPG setting
- Generates mystery and intrigue
- Includes specific details (names, locations, events)`,
    };

    return templates[templateName] || null;
  }

  /**
   * Private: Format conversation history for prompt injection
   */
  private formatConversationHistory(history: Array<{ role: string; content: string }>): string {
    if (history.length === 0) {
      return '(No prior conversation)';
    }

    return history
      .map((msg) => {
        if (msg.role === 'user') {
          return `Player: "${msg.content}"`;
        }
        return `NPC: "${msg.content}"`;
      })
      .join('\n');
  }

  /**
   * Private: Get NPC personality data
   */
  private getNPCPersonalityData(npcId: string): any {
    const upperNpcId = npcId.toUpperCase();
    const templates = NPC_PERSONALITY_TEMPLATES as Record<string, any>;

    return templates[upperNpcId] || {
      name: npcId,
      personality: 'Neutral character',
      speakingStyle: 'Standard speech',
    };
  }
}

export default PromptTemplateEngine;
