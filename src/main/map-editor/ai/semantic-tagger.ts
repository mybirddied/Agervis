// Semantic Tagger - Phase 2 preparation for text-only API calls
// Learns semantic tags from accepted AI placements to reduce Vision API costs

import type { SemanticTag, Tile, TilePlacement } from '../../shared/types/map-editor';

export class SemanticTagger {
  private tagDatabase: Map<string, SemanticTag> = new Map();
  private acceptanceHistory: Array<{ description: string; placement: TilePlacement; tile: Tile }> = [];

  /**
   * Record an accepted placement to learn semantic relationships
   */
  recordAcceptance(description: string, placement: TilePlacement, tile: Tile): void {
    this.acceptanceHistory.push({ description, placement, tile });

    // Extract semantic tags from description
    const tags = this.extractTags(description, tile);
    tags.forEach((tag) => {
      this.updateTagDatabase(tag, tile.id);
    });
  }

  /**
   * Extract semantic tags from natural language description
   */
  private extractTags(description: string, tile: Tile): string[] {
    const tags: string[] = [];

    // Common semantic patterns
    const patterns = [
      { pattern: /window/i, tag: 'window' },
      { pattern: /door/i, tag: 'door' },
      { pattern: /desk/i, tag: 'desk' },
      { pattern: /chair/i, tag: 'chair' },
      { pattern: /filing cabinet/i, tag: 'cabinet' },
      { pattern: /plant/i, tag: 'plant' },
      { pattern: /carpet/i, tag: 'carpet' },
      { pattern: /wall/i, tag: 'wall' },
      { pattern: /floor/i, tag: 'floor' },
      { pattern: /ceiling/i, tag: 'ceiling' },
      { pattern: /lamp/i, tag: 'lamp' },
      { pattern: /table/i, tag: 'table' },
      { pattern: /corner/i, tag: 'corner' },
      { pattern: /entrance/i, tag: 'entrance' },
      { pattern: /exit/i, tag: 'exit' },
    ];

    patterns.forEach(({ pattern, tag }) => {
      if (pattern.test(description)) {
        tags.push(tag);
      }
    });

    // Add tile-specific tags
    tags.push(...tile.tags);
    tags.push(tile.category);

    return [...new Set(tags)]; // Remove duplicates
  }

  /**
   * Update the semantic tag database with new associations
   */
  private updateTagDatabase(tag: string, tileId: string): void {
    const key = tag.toLowerCase();

    if (!this.tagDatabase.has(key)) {
      this.tagDatabase.set(key, {
        tag: key,
        category: 'decoration', // Default, would be refined
        confidence: 0.5,
        tileIds: [],
      });
    }

    const entry = this.tagDatabase.get(key)!;
    if (!entry.tileIds.includes(tileId)) {
      entry.tileIds.push(tileId);
    }

    // Increase confidence with more data
    entry.confidence = Math.min(1, entry.confidence + 0.05);
  }

  /**
   * Get learned semantic tags for text-only matching (Phase 3)
   */
  getSemanticTags(): SemanticTag[] {
    return Array.from(this.tagDatabase.values()).filter((tag) => tag.confidence > 0.6);
  }

  /**
   * Find tiles by semantic tag with confidence filtering
   */
  findTilesByTag(tag: string, minConfidence: number = 0.6): string[] {
    const entry = this.tagDatabase.get(tag.toLowerCase());
    if (!entry || entry.confidence < minConfidence) {
      return [];
    }
    return entry.tileIds;
  }

  /**
   * Get learning progress (Phase 2/3 transition)
   */
  getProgress(): {
    totalAcceptances: number;
    uniqueTags: number;
    averageConfidence: number;
    readyForPhase3: boolean;
  } {
    const entries = Array.from(this.tagDatabase.values());
    const averageConfidence = entries.length > 0 ? entries.reduce((sum, e) => sum + e.confidence, 0) / entries.length : 0;

    return {
      totalAcceptances: this.acceptanceHistory.length,
      uniqueTags: this.tagDatabase.size,
      averageConfidence,
      readyForPhase3: this.acceptanceHistory.length > 50 && averageConfidence > 0.75,
    };
  }

  /**
   * Export learned tags for persistence
   */
  export(): Record<string, SemanticTag> {
    const result: Record<string, SemanticTag> = {};
    this.tagDatabase.forEach((tag, key) => {
      result[key] = tag;
    });
    return result;
  }

  /**
   * Import previously learned tags
   */
  import(data: Record<string, SemanticTag>): void {
    Object.entries(data).forEach(([key, tag]) => {
      this.tagDatabase.set(key, tag);
    });
  }
}

export default SemanticTagger;
