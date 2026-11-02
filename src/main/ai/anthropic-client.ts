// Anthropic Claude API Client Wrapper
// Handles API communication with custom base_url support, error handling, and request standardization

import Anthropic from '@anthropic-ai/sdk';
import type { AIConfig, AnthropicResponse, AnthropicMessage } from '../types/ai';
import { API_ERROR_MESSAGES } from '../constants/ai';

export class AnthropicClientWrapper {
  private client: Anthropic;
  private baseUrl: string;
  private apiKey: string;

  constructor(config: AIConfig) {
    this.baseUrl = config.baseUrl;
    this.apiKey = config.apiKey;

    // Initialize Anthropic SDK with custom base_url support
    this.client = new Anthropic({
      apiKey: config.apiKey,
      baseURL: config.baseUrl,
      timeout: 30000,
      maxRetries: 3,
    });
  }

  /**
   * Send a message to Claude API
   */
  async sendMessage(
    messages: AnthropicMessage[],
    model: string,
    systemPrompt: string,
    maxTokens: number = 1024
  ): Promise<AnthropicResponse> {
    try {
      const response = await this.client.messages.create({
        model,
        max_tokens: maxTokens,
        system: systemPrompt,
        messages: messages.map((msg) => ({
          role: msg.role,
          content: msg.content,
        })),
      });

      // Standardize response format
      return this.standardizeResponse(response as any);
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Stream a message response from Claude API
   */
  async *streamMessage(
    messages: AnthropicMessage[],
    model: string,
    systemPrompt: string,
    maxTokens: number = 1024
  ): AsyncGenerator<string> {
    try {
      const stream = this.client.messages.stream({
        model,
        max_tokens: maxTokens,
        system: systemPrompt,
        messages: messages.map((msg) => ({
          role: msg.role,
          content: msg.content,
        })),
      });

      for await (const chunk of stream) {
        if (chunk.type === 'content_block_delta' && chunk.delta.type === 'text_delta') {
          yield chunk.delta.text;
        }
      }
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Get token count for a message without making an API call
   */
  async countTokens(
    messages: AnthropicMessage[],
    systemPrompt: string
  ): Promise<number> {
    try {
      const response = await this.client.messages.countTokens({
        model: 'claude-3-5-sonnet-20241022', // Use any valid model for counting
        system: systemPrompt,
        messages: messages.map((msg) => ({
          role: msg.role,
          content: msg.content,
        })),
      });

      return response.input_tokens;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Test API connectivity and key validity
   */
  async testConnection(): Promise<boolean> {
    try {
      const response = await this.client.messages.create({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 10,
        messages: [
          {
            role: 'user',
            content: 'Say "ok" only.',
          },
        ],
      });

      return response.stop_reason === 'end_turn';
    } catch (error) {
      return false;
    }
  }

  /**
   * Update API key and base URL
   */
  updateConfig(apiKey: string, baseUrl: string): void {
    this.apiKey = apiKey;
    this.baseUrl = baseUrl;

    this.client = new Anthropic({
      apiKey: this.apiKey,
      baseURL: this.baseUrl,
      timeout: 30000,
      maxRetries: 3,
    });
  }

  /**
   * Standardize API response format
   */
  private standardizeResponse(response: any): AnthropicResponse {
    const textContent = response.content.find((c: any) => c.type === 'text');

    return {
      id: response.id,
      type: 'message',
      role: response.role || 'assistant',
      content: [
        {
          type: 'text',
          text: textContent?.text || '',
        },
      ],
      model: response.model,
      stop_reason: response.stop_reason,
      stop_sequence: response.stop_sequence || null,
      usage: {
        input_tokens: response.usage.input_tokens,
        output_tokens: response.usage.output_tokens,
      },
    };
  }

  /**
   * Handle API errors with standardized error messages
   */
  private handleError(error: any): Error {
    if (error.status === 401) {
      return new Error(API_ERROR_MESSAGES.INVALID_API_KEY);
    }
    if (error.status === 429) {
      return new Error(API_ERROR_MESSAGES.RATE_LIMIT_EXCEEDED);
    }
    if (error.status === 500 || error.status === 503) {
      return new Error(API_ERROR_MESSAGES.OVERLOADED);
    }
    if (error.code === 'ECONNREFUSED' || error.code === 'ENOTFOUND') {
      return new Error(API_ERROR_MESSAGES.INVALID_BASE_URL);
    }
    if (error.code === 'ETIMEDOUT') {
      return new Error(API_ERROR_MESSAGES.REQUEST_TIMEOUT);
    }

    return error instanceof Error ? error : new Error(API_ERROR_MESSAGES.UNKNOWN_ERROR);
  }

  /**
   * Get current configuration
   */
  getConfig(): { baseUrl: string; apiKey: string } {
    return {
      baseUrl: this.baseUrl,
      apiKey: this.apiKey.substring(0, 10) + '***', // Mask API key in logs
    };
  }
}

export default AnthropicClientWrapper;
