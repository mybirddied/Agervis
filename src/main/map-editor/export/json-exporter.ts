// JSON Exporter - Export rooms to portable JSON format
import type { Room, ExportOptions } from '../../shared/types/map-editor';

export class JSONExporter {
  /**
   * Export room to JSON format
   */
  exportToJSON(room: Room, options: ExportOptions = { format: 'json', includeCollision: true, includeLighting: true }): string {
    const exportData: any = {
      metadata: {
        id: room.id,
        name: room.name,
        description: room.description,
        width: room.width,
        height: room.height,
        tileSize: room.tileSize,
        createdAt: room.metadata.createdAt.toISOString(),
        updatedAt: room.metadata.updatedAt.toISOString(),
        aiGenerated: room.metadata.aiGenerated,
      },
      layers: {
        ground: room.layers.ground,
        objects: room.layers.objects,
        overhead: room.layers.overhead,
      },
    };

    // Optionally include collision layer
    if (options.includeCollision) {
      exportData.layers.collision = room.layers.collision;
    }

    return JSON.stringify(exportData, null, 2);
  }

  /**
   * Import room from JSON format
   */
  importFromJSON(jsonData: string): Room {
    const data = JSON.parse(jsonData);

    return {
      id: data.metadata.id,
      name: data.metadata.name,
      description: data.metadata.description,
      width: data.metadata.width,
      height: data.metadata.height,
      tileSize: data.metadata.tileSize,
      layers: {
        ground: data.layers.ground || [],
        objects: data.layers.objects || [],
        overhead: data.layers.overhead || [],
        collision: data.layers.collision || [],
      },
      metadata: {
        createdAt: new Date(data.metadata.createdAt),
        updatedAt: new Date(data.metadata.updatedAt),
        aiGenerated: data.metadata.aiGenerated || false,
      },
    };
  }

  /**
   * Get file extension
   */
  getFileExtension(): string {
    return '.json';
  }
}

export default JSONExporter;
