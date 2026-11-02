// Map Editor Type Definitions
// Core types for tile system, room management, and AI-assisted placement

export type LayerType = 'ground' | 'objects' | 'overhead' | 'collision';
export type TileCategory = 'floor' | 'wall' | 'furniture' | 'decoration' | 'obstacle' | 'light';

export interface Tile {
  id: string;
  name: string;
  category: TileCategory;
  imageUrl: string;
  width: number;
  height: number;
  collisionType?: 'solid' | 'partial' | 'none';
  lightValue?: { r: number; g: number; b: number; intensity: number };
  tags: string[];
}

export interface TilePlacement {
  id: string;
  tileId: string;
  x: number;
  y: number;
  layer: LayerType;
  rotation?: 0 | 90 | 180 | 270;
  flipped?: boolean;
}

export interface Room {
  id: string;
  name: string;
  description: string;
  width: number;
  height: number;
  tileSize: number;
  layers: Record<LayerType, TilePlacement[]>;
  metadata: {
    createdAt: Date;
    updatedAt: Date;
    aiGenerated: boolean;
  };
}

export interface RoomTemplate {
  id: string;
  name: string;
  description: string;
  width: number;
  height: number;
  defaultTiles: TilePlacement[];
  category: 'office' | 'apartment' | 'street' | 'alley' | 'custom';
}

export interface VisionAnalysisResult {
  suggestedPlacements: TilePlacement[];
  confidence: number;
  reasoning: string;
  costUsd: number;
}

export interface TileMatchResult {
  tileId: string;
  matchScore: number;
  reasoning: string;
}

export interface MapEditorState {
  currentRoom: Room | null;
  selectedLayer: LayerType;
  selectedTile: Tile | null;
  history: Room[];
  historyIndex: number;
  zoom: number;
  panX: number;
  panY: number;
}

export interface ExportOptions {
  format: 'godot' | 'json' | 'png';
  includeCollision: boolean;
  includeLighting: boolean;
}

export interface AITileVisionRequest {
  roomDescription: string;
  existingTiles: Tile[];
  roomDimensions: { width: number; height: number };
  layoutImage?: string; // base64 encoded image from canvas
}

export interface SemanticTag {
  tag: string;
  category: TileCategory;
  confidence: number;
  tileIds: string[];
}
