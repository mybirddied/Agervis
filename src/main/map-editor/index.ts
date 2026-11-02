// Map Editor Index - Central export for all map editor functionality
export { MapEditor as default } from './editor';
export { MapEditor } from './editor';

// Layers
export { default as GroundLayer } from './layers/ground-layer';
export { default as ObjectLayer } from './layers/object-layer';
export { default as OverheadLayer } from './layers/overhead-layer';
export { default as CollisionLayer } from './layers/collision-layer';

// AI
export { default as TileVisionMatcher } from './ai/tile-vision';
export { default as SemanticTagger } from './ai/semantic-tagger';

// Templates
export { default as RoomTemplateManager } from './templates/room-templates';

// Export
export { default as GodotExporter } from './export/godot-exporter';
export { default as JSONExporter } from './export/json-exporter';
export { default as PNGExporter } from './export/png-exporter';

// Canvas
export { default as CanvasRenderer } from './canvas-renderer';

// API
export { default as MapEditorAPI } from './api';

// Types
export type * from '../../shared/types/map-editor';
