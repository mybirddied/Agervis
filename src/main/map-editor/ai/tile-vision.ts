// Tile Matcher - AI Vision Integration for semantic tile matching
// Phase 1: Vision-based matching using Claude Vision API

import Anthropic from '@anthropic-ai/sdk';
import type { Tile, TilePlacement, VisionAnalysisResult, AITileVisionRequest } from '../../shared/types/map-editor';

export class TileVisionMatcher {
  private client: Anthropic;
  private costPerRoomUsd: number = 0.02; // Estimated cost

  constructor(apiKey: string) {
    this.client = new Anthropic({
      apiKey,
    });
  }

  /**
   * Analyze room description and layout image to suggest tile placements
   * Uses Claude Vision API to match user's description with available tiles
   */
  async analyzeRoomLayout(request: AITileVisionRequest): Promise<VisionAnalysisResult> {
    try {
      const systemPrompt = `You are an expert game map designer. Analyze the room description and suggest tile placements from the available tiles.

Return a JSON object with this structure:
{
  "placements": [
    {
      "tileId": "tile_id_string",
      "x": number,
      "y": number,
      "layer": "ground|objects|overhead|collision",
      "rotation": 0|90|180|270,
      "reasoning": "why this tile placement makes sense"
    }
  ],
  "layoutAnalysis": "overall analysis of the room layout",
  "suggestions": ["additional design suggestions"]
}`;

      const availableTilesJson = JSON.stringify(request.existingTiles, null, 2);

      const messageContent: Anthropic.MessageParam['content'] = [
        {
          type: 'text',
          text: `Room Description: ${request.roomDescription}

Available Tiles:
${availableTilesJson}

Room Dimensions: ${request.roomDimensions.width}x${request.roomDimensions.height}

Analyze this room and suggest optimal tile placements. Consider:
1. Spatial arrangement (doors on walls, furniture against walls)
2. Layer organization (ground covers, objects in middle, overhead details)
3. Visual balance and accessibility
4. Thematic consistency`,
        },
      ];

      // Add layout image if provided
      if (request.layoutImage) {
        (messageContent as any).push({
          type: 'image',
          source: {
            type: 'base64',
            media_type: 'image/png',
            data: request.layoutImage,
          },
        });
      }

      const response = await this.client.messages.create({
        model: 'claude-3-5-sonnet-20241022',
        max_tokens: 2048,
        system: systemPrompt,
        messages: [
          {
            role: 'user',
            content: messageContent,
          },
        ],
      });

      // Parse Claude's response
      const textContent = response.content.find((c) => c.type === 'text');
      if (!textContent || textContent.type !== 'text') {
        throw new Error('No text response from Claude');
      }

      // Extract JSON from response
      const jsonMatch = textContent.text.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('Could not parse JSON from response');
      }

      const analysis = JSON.parse(jsonMatch[0]);

      // Convert to TilePlacement format
      const suggestedPlacements: TilePlacement[] = analysis.placements.map(
        (p: any, index: number) => ({
          id: `placement_${Date.now()}_${index}`,
          tileId: p.tileId,
          x: p.x,
          y: p.y,
          layer: p.layer,
          rotation: p.rotation || 0,
          flipped: false,
        })
      );

      return {
        suggestedPlacements,
        confidence: 0.85, // Vision API typically has high confidence
        reasoning: analysis.layoutAnalysis,
        costUsd: this.costPerRoomUsd,
      };
    } catch (error) {
      console.error('Error analyzing room layout:', error);
      throw error;
    }
  }

  /**
   * Match semantic descriptions to tiles (Phase 2 foundation)
   * This will learn from accepted placements over time
   */
  async matchSemanticTags(
    description: string,
    availableTiles: Tile[]
  ): Promise<Array<{ tileId: string; score: number }>> {
    // Phase 2: Will parse semantic tags from vision analysis
    // For now, return a basic text-based match as placeholder
    const response = await this.client.messages.create({
      model: 'claude-haiku-4-5-20251001', // Cheaper model for text-only
      max_tokens: 512,
      messages: [
        {
          role: 'user',
          content: `Given this description: "${description}"

And these available tiles: ${JSON.stringify(availableTiles.map((t) => ({ id: t.id, name: t.name, category: t.category })))}

Return a JSON array of matching tile IDs with confidence scores (0-1).
Example: [{"tileId": "tile_1", "score": 0.95}]`,
        },
      ],
    });

    const textContent = response.content.find((c) => c.type === 'text');
    if (!textContent || textContent.type !== 'text') {
      return [];
    }

    try {
      const jsonMatch = textContent.text.match(/\[[\s\S]*\]/);
      if (!jsonMatch) {
        return [];
      }
      return JSON.parse(jsonMatch[0]);
    } catch {
      return [];
    }
  }

  /**
   * Get estimated cost for a room analysis
   */
  getEstimatedCost(): number {
    return this.costPerRoomUsd;
  }
}

export default TileVisionMatcher;
