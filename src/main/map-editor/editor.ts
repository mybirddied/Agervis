// Core Map Editor Logic
// Manages room state, layers, undo/history, and tile operations

import GroundLayer from './layers/ground-layer';
import ObjectLayer from './layers/object-layer';
import OverheadLayer from './layers/overhead-layer';
import CollisionLayer from './layers/collision-layer';
import TileVisionMatcher from './ai/tile-vision';
import SemanticTagger from './ai/semantic-tagger';
import type { Room, TilePlacement, LayerType, Tile, VisionAnalysisResult, AITileVisionRequest } from '../shared/types/map-editor';

export class MapEditor {
  private currentRoom: Room | null = null;
  private groundLayer: GroundLayer = new GroundLayer();
  private objectLayer: ObjectLayer = new ObjectLayer();
  private overheadLayer: OverheadLayer = new OverheadLayer();
  private collisionLayer: CollisionLayer = new CollisionLayer();
  private history: Room[] = [];
  private historyIndex: number = -1;
  private selectedLayer: LayerType = 'objects';
  private tileVisionMatcher: TileVisionMatcher;
  private semanticTagger: SemanticTagger = new SemanticTagger();
  private maxHistorySize: number = 50;

  constructor(apiKey: string) {
    this.tileVisionMatcher = new TileVisionMatcher(apiKey);
  }

  /**
   * Create a new room with specified dimensions
   */
  createRoom(roomId: string, roomName: string, width: number, height: number, tileSize: number = 32): Room {
    this.currentRoom = {
      id: roomId,
      name: roomName,
      description: '',
      width,
      height,
      tileSize,
      layers: {
        ground: [],
        objects: [],
        overhead: [],
        collision: [],
      },
      metadata: {
        createdAt: new Date(),
        updatedAt: new Date(),
        aiGenerated: false,
      },
    };

    this.groundLayer.clear();
    this.objectLayer.clear();
    this.overheadLayer.clear();
    this.collisionLayer.clear();
    this.history = [];
    this.historyIndex = -1;

    return this.currentRoom;
  }

  /**
   * Load an existing room
   */
  loadRoom(room: Room): void {
    this.currentRoom = JSON.parse(JSON.stringify(room)); // Deep copy
    this.groundLayer.import(room.layers.ground);
    this.objectLayer.import(room.layers.objects);
    this.overheadLayer.import(room.layers.overhead);
    this.collisionLayer.import(room.layers.collision);
    this.history = [];
    this.historyIndex = -1;
  }

  /**
   * Update room description (used for AI analysis)
   */
  setRoomDescription(description: string): void {
    if (this.currentRoom) {
      this.currentRoom.description = description;
      this.currentRoom.metadata.updatedAt = new Date();
    }
  }

  /**
   * Add tile placement to selected layer
   */
  addTile(placement: TilePlacement): void {
    this.saveHistory();

    const layer = this.getLayer(placement.layer);
    layer.addTile(placement);
    this.updateCurrentRoom();
  }

  /**
   * Remove tile placement
   */
  removeTile(placementId: string, layer: LayerType): void {
    this.saveHistory();

    const layerObj = this.getLayer(layer);
    layerObj.removeTile(placementId);
    this.updateCurrentRoom();
  }

  /**
   * Update tile placement properties
   */
  updateTile(placementId: string, layer: LayerType, updates: Partial<TilePlacement>): void {
    this.saveHistory();

    const layerObj = this.getLayer(layer);
    layerObj.updateTile(placementId, updates);
    this.updateCurrentRoom();
  }

  /**
   * Analyze room layout using Claude Vision API and suggest tile placements
   */
  async analyzeRoomWithAI(
    roomDescription: string,
    availableTiles: Tile[],
    layoutImage?: string
  ): Promise<VisionAnalysisResult> {
    if (!this.currentRoom) {
      throw new Error('No room loaded');
    }

    const request: AITileVisionRequest = {
      roomDescription,
      existingTiles: availableTiles,
      roomDimensions: { width: this.currentRoom.width, height: this.currentRoom.height },
      layoutImage,
    };

    const result = await this.tileVisionMatcher.analyzeRoomLayout(request);

    // Mark room as AI-generated
    if (this.currentRoom) {
      this.currentRoom.metadata.aiGenerated = true;
      this.currentRoom.metadata.updatedAt = new Date();
    }

    return result;
  }

  /**
   * Accept AI-suggested placements and learn from them
   */
  acceptAISuggestions(placements: TilePlacement[], tiles: Map<string, Tile>): void {
    this.saveHistory();

    placements.forEach((placement) => {
      const tile = tiles.get(placement.tileId);
      if (tile) {
        this.addTile(placement);
        // Learn from accepted placement for Phase 2/3
        this.semanticTagger.recordAcceptance(
          this.currentRoom?.description || '',
          placement,
          tile
        );
      }
    });

    this.updateCurrentRoom();
  }

  /**
   * Get the current room state
   */
  getCurrentRoom(): Room | null {
    return this.currentRoom;
  }

  /**
   * Get tiles from a specific layer
   */
  getLayerTiles(layer: LayerType): TilePlacement[] {
    return this.getLayer(layer).getTiles();
  }

  /**
   * Set the active layer for editing
   */
  setSelectedLayer(layer: LayerType): void {
    this.selectedLayer = layer;
  }

  /**
   * Get the active layer
   */
  getSelectedLayer(): LayerType {
    return this.selectedLayer;
  }

  /**
   * Undo last change
   */
  undo(): boolean {
    if (this.historyIndex > 0) {
      this.historyIndex--;
      this.restoreFromHistory();
      return true;
    }
    return false;
  }

  /**
   * Redo last undone change
   */
  redo(): boolean {
    if (this.historyIndex < this.history.length - 1) {
      this.historyIndex++;
      this.restoreFromHistory();
      return true;
    }
    return false;
  }

  /**
   * Get learning progress for Phase 2/3 transition
   */
  getLearningProgress() {
    return this.semanticTagger.getProgress();
  }

  /**
   * Get estimated cost for AI analysis
   */
  getAIAnalysisCost(): number {
    return this.tileVisionMatcher.getEstimatedCost();
  }

  /**
   * Private: Save current state to history
   */
  private saveHistory(): void {
    if (!this.currentRoom) return;

    // Remove any redo history if we're making a new change
    if (this.historyIndex < this.history.length - 1) {
      this.history = this.history.slice(0, this.historyIndex + 1);
    }

    // Add current state
    this.history.push(JSON.parse(JSON.stringify(this.currentRoom)));
    this.historyIndex++;

    // Limit history size
    if (this.history.length > this.maxHistorySize) {
      this.history.shift();
      this.historyIndex--;
    }
  }

  /**
   * Private: Restore room state from history
   */
  private restoreFromHistory(): void {
    if (this.historyIndex >= 0 && this.historyIndex < this.history.length) {
      const room = this.history[this.historyIndex];
      this.loadRoom(room);
    }
  }

  /**
   * Private: Get layer object by type
   */
  private getLayer(type: LayerType) {
    switch (type) {
      case 'ground':
        return this.groundLayer;
      case 'objects':
        return this.objectLayer;
      case 'overhead':
        return this.overheadLayer;
      case 'collision':
        return this.collisionLayer;
      default:
        return this.objectLayer;
    }
  }

  /**
   * Private: Update current room with layer data
   */
  private updateCurrentRoom(): void {
    if (!this.currentRoom) return;

    this.currentRoom.layers = {
      ground: this.groundLayer.export(),
      objects: this.objectLayer.export(),
      overhead: this.overheadLayer.export(),
      collision: this.collisionLayer.export(),
    };

    this.currentRoom.metadata.updatedAt = new Date();
  }
}

export default MapEditor;
