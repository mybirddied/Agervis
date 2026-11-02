// API Integration - Backend service for map editor AI operations
import type { Room, VisionAnalysisResult, AITileVisionRequest, Tile } from '../../shared/types/map-editor';
import TileVisionMatcher from './ai/tile-vision';
import SemanticTagger from './ai/semantic-tagger';

export class MapEditorAPI {
  private visionMatcher: TileVisionMatcher;
  private semanticTagger: SemanticTagger;

  constructor(anthropicApiKey: string) {
    this.visionMatcher = new TileVisionMatcher(anthropicApiKey);
    this.semanticTagger = new SemanticTagger();
  }

  /**
   * Analyze room layout and get AI-suggested tile placements
   */
  async analyzeRoom(
    roomDescription: string,
    availableTiles: Tile[],
    roomDimensions: { width: number; height: number },
    layoutImage?: string
  ): Promise<VisionAnalysisResult> {
    const request: AITileVisionRequest = {
      roomDescription,
      existingTiles: availableTiles,
      roomDimensions,
      layoutImage,
    };

    return this.visionMatcher.analyzeRoomLayout(request);
  }

  /**
   * Accept placements to learn semantic relationships
   */
  recordAcceptedPlacement(
    roomDescription: string,
    placement: any,
    tile: Tile
  ): void {
    this.semanticTagger.recordAcceptance(roomDescription, placement, tile);
  }

  /**
   * Get learning progress
   */
  getLearningProgress() {
    return this.semanticTagger.getProgress();
  }

  /**
   * Get learned semantic tags
   */
  getSemanticTags() {
    return this.semanticTagger.getSemanticTags();
  }

  /**
   * Export learned knowledge for persistence
   */
  exportLearning() {
    return this.semanticTagger.export();
  }

  /**
   * Import previously learned knowledge
   */
  importLearning(data: Record<string, any>) {
    this.semanticTagger.import(data);
  }
}

export default MapEditorAPI;
