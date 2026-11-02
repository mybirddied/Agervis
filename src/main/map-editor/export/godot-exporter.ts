// Godot Exporter - Export rooms to Godot TileMap format (.tscn)
import type { Room, TilePlacement } from '../../shared/types/map-editor';

export class GodotExporter {
  /**
   * Export room to Godot TileMap TSCN format
   */
  exportToGodot(room: Room, tilesetPath: string = 'res://assets/tilesets/main.tres'): string {
    const sceneContent = this.generateTscnContent(room, tilesetPath);
    return sceneContent;
  }

  /**
   * Generate TSCN file content
   */
  private generateTscnContent(room: Room, tilesetPath: string): string {
    const tileSize = room.tileSize;
    const width = room.width;
    const height = room.height;

    let tscn = `; TSCN file format
[gd_scene load_steps=2 format=3 uid="uid://d${Math.random().toString().slice(2, 12)}"]

[ext_resource type="TileSet" path="${tilesetPath}" id="1_abc123"]

[node name="Room_${room.id}" type="Node2D"]

`;

    // Create TileMap for each layer
    const layers = ['ground', 'objects', 'overhead', 'collision'];
    layers.forEach((layerName, layerIndex) => {
      tscn += `[node name="${layerName}_tilemap" type="TileMap" parent="."]
tile_set = SubResource("1_abc123")
format = 2
layer_0/name = "${layerName}"
layer_0/tile_data = PackedInt32Array(`;

      const placements = room.layers[layerName as keyof typeof room.layers] || [];
      const tileData: number[] = [];

      placements.forEach((placement) => {
        const x = Math.floor(placement.x / tileSize);
        const y = Math.floor(placement.y / tileSize);
        const cellKey = (y * width + x) * 16; // Godot's internal encoding
        tileData.push(cellKey, parseInt(placement.tileId.replace(/\D/g, '')) || 0);
      });

      tscn += tileData.join(', ') + ')
\n\n';
    });

    tscn += `[node name="metadata" type="Node" parent="."]
script = SubResource("2_metadata")

[sub_resource type="GDScript" id="2_metadata"]
script/source = "extends Node
var room_id = '${room.id}'
var room_name = '${room.name}'
var room_width = ${width}
var room_height = ${height}
var tile_size = ${tileSize}
"
`;

    return tscn;
  }

  /**
   * Get file extension
   */
  getFileExtension(): string {
    return '.tscn';
  }
}

export default GodotExporter;
