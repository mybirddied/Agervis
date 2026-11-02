// MapEditor.tsx - Main React component for the map editor
import React, { useEffect, useRef, useState } from 'react';
import { Download, Plus, Trash2, RotateCcw, RotateCw, Zap, Undo2, Redo2 } from 'lucide-react';
import Canvas from './Canvas';
import LayerControls from './LayerControls';
import TilePalette from './TilePalette';
import ExportDialog from './ExportDialog';
import type { Room, TilePlacement, Tile, LayerType, VisionAnalysisResult } from '../../shared/types/map-editor';

interface MapEditorProps {
  roomId?: string;
  onSave?: (room: Room) => void;
}

export default function MapEditor({ roomId = 'room_01', onSave }: MapEditorProps) {
  const [room, setRoom] = useState<Room | null>(null);
  const [selectedLayer, setSelectedLayer] = useState<LayerType>('objects');
  const [selectedTile, setSelectedTile] = useState<Tile | null>(null);
  const [zoom, setZoom] = useState(1);
  const [roomDescription, setRoomDescription] = useState('');
  const [aiAnalyzing, setAiAnalyzing] = useState(false);
  const [aiSuggestions, setAiSuggestions] = useState<TilePlacement[]>([]);
  const [showExportDialog, setShowExportDialog] = useState(false);
  const [tileLibrary, setTileLibrary] = useState<Tile[]>([]);

  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Initialize room on mount
  useEffect(() => {
    // Load sample room data
    const sampleRoom: Room = {
      id: roomId,
      name: `Room ${roomId}`,
      description: '',
      width: 12,
      height: 10,
      tileSize: 32,
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

    setRoom(sampleRoom);

    // Load sample tile library
    const sampleTiles: Tile[] = [
      {
        id: 'tile_floor_1',
        name: 'Wood Floor',
        category: 'floor',
        imageUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mN8//8/AwAI/AL+ho2Z4gAAAABJRU5ErkJggg==',
        width: 32,
        height: 32,
        collisionType: 'none',
        tags: ['floor', 'wood'],
      },
      {
        id: 'tile_wall_1',
        name: 'Stone Wall',
        category: 'wall',
        imageUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        width: 32,
        height: 32,
        collisionType: 'solid',
        tags: ['wall', 'stone'],
      },
      {
        id: 'tile_desk_1',
        name: 'Wooden Desk',
        category: 'furniture',
        imageUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNgYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        width: 32,
        height: 32,
        collisionType: 'solid',
        tags: ['desk', 'furniture'],
      },
      {
        id: 'tile_chair_1',
        name: 'Office Chair',
        category: 'furniture',
        imageUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        width: 32,
        height: 32,
        collisionType: 'solid',
        tags: ['chair', 'furniture'],
      },
      {
        id: 'tile_window_1',
        name: 'Window',
        category: 'decoration',
        imageUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        width: 32,
        height: 32,
        collisionType: 'none',
        lightValue: { r: 255, g: 255, b: 255, intensity: 0.5 },
        tags: ['window', 'light'],
      },
      {
        id: 'tile_door_1',
        name: 'Door',
        category: 'wall',
        imageUrl: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNgYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
        width: 32,
        height: 32,
        collisionType: 'partial',
        tags: ['door', 'entrance'],
      },
    ];

    setTileLibrary(sampleTiles);
  }, [roomId]);

  const handleAddTile = (placement: TilePlacement) => {
    if (!room) return;

    const updatedRoom = {
      ...room,
      layers: {
        ...room.layers,
        [selectedLayer]: [...room.layers[selectedLayer], placement],
      },
    };

    setRoom(updatedRoom);
  };

  const handleRemoveTile = (placementId: string) => {
    if (!room) return;

    const updatedRoom = {
      ...room,
      layers: {
        ...room.layers,
        [selectedLayer]: room.layers[selectedLayer].filter((p) => p.id !== placementId),
      },
    };

    setRoom(updatedRoom);
  };

  const handleAnalyzeWithAI = async () => {
    if (!roomDescription.trim() || !room) {
      alert('Please enter a room description');
      return;
    }

    setAiAnalyzing(true);

    try {
      // In production, this would call the backend API
      const response: VisionAnalysisResult = {
        suggestedPlacements: [
          {
            id: `placement_${Date.now()}_1`,
            tileId: 'tile_desk_1',
            x: 32,
            y: 64,
            layer: 'objects',
            rotation: 0,
            flipped: false,
          },
          {
            id: `placement_${Date.now()}_2`,
            tileId: 'tile_chair_1',
            x: 96,
            y: 64,
            layer: 'objects',
            rotation: 0,
            flipped: false,
          },
        ],
        confidence: 0.85,
        reasoning: 'Suggested desk by window with office chair',
        costUsd: 0.02,
      };

      setAiSuggestions(response.suggestedPlacements);
    } catch (error) {
      console.error('AI analysis error:', error);
      alert('Failed to analyze room with AI');
    } finally {
      setAiAnalyzing(false);
    }
  };

  const handleAcceptSuggestions = () => {
    if (!room) return;

    const updatedRoom = {
      ...room,
      layers: {
        ...room.layers,
        [selectedLayer]: [...room.layers[selectedLayer], ...aiSuggestions],
      },
      metadata: {
        ...room.metadata,
        aiGenerated: true,
        updatedAt: new Date(),
      },
    };

    setRoom(updatedRoom);
    setAiSuggestions([]);

    if (onSave) {
      onSave(updatedRoom);
    }
  };

  const handleZoom = (direction: 'in' | 'out') => {
    setZoom((prev) => {
      if (direction === 'in') {
        return Math.min(prev * 1.2, 4);
      } else {
        return Math.max(prev / 1.2, 0.25);
      }
    });
  };

  const handleSave = () => {
    if (room && onSave) {
      onSave(room);
      alert('Room saved successfully!');
    }
  };

  if (!room) {
    return <div className="flex items-center justify-center h-screen">Loading...</div>;
  }

  return (
    <div className="flex h-screen bg-gray-900 text-gray-100">
      {/* Left Sidebar - Tools */}
      <div className="w-64 border-r border-gray-700 bg-gray-800 overflow-y-auto">
        <div className="p-4">
          <h2 className="text-lg font-bold mb-4">Map Editor</h2>

          {/* Room Info */}
          <div className="mb-4 p-3 bg-gray-700 rounded">
            <p className="text-sm">Room: {room.name}</p>
            <p className="text-xs text-gray-400">ID: {room.id}</p>
            <p className="text-xs text-gray-400">Size: {room.width}x{room.height}</p>
          </div>

          {/* Layer Controls */}
          <LayerControls selectedLayer={selectedLayer} onSelectLayer={setSelectedLayer} />

          {/* Zoom Controls */}
          <div className="mb-4">
            <label className="block text-sm font-semibold mb-2">Zoom: {zoom.toFixed(1)}x</label>
            <div className="flex gap-2">
              <button
                onClick={() => handleZoom('out')}
                className="flex-1 px-3 py-2 bg-gray-700 hover:bg-gray-600 rounded text-sm"
              >
                −
              </button>
              <button
                onClick={() => handleZoom('in')}
                className="flex-1 px-3 py-2 bg-gray-700 hover:bg-gray-600 rounded text-sm"
              >
                +
              </button>
            </div>
          </div>

          {/* AI Analysis Section */}
          <div className="mb-4 p-3 bg-blue-900 rounded">
            <label className="block text-sm font-semibold mb-2 flex items-center gap-2">
              <Zap size={16} /> AI-Assisted Placement
            </label>
            <textarea
              value={roomDescription}
              onChange={(e) => setRoomDescription(e.target.value)}
              placeholder="Describe your room layout..."
              className="w-full p-2 bg-gray-700 text-white text-sm rounded mb-2"
              rows={4}
            />
            <button
              onClick={handleAnalyzeWithAI}
              disabled={aiAnalyzing}
              className="w-full px-3 py-2 bg-blue-600 hover:bg-blue-500 disabled:bg-blue-800 rounded text-sm font-medium"
            >
              {aiAnalyzing ? 'Analyzing...' : 'Analyze with AI'}
            </button>

            {aiSuggestions.length > 0 && (
              <button
                onClick={handleAcceptSuggestions}
                className="w-full mt-2 px-3 py-2 bg-green-600 hover:bg-green-500 rounded text-sm font-medium"
              >
                Accept {aiSuggestions.length} Suggestions
              </button>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex gap-2">
            <button
              onClick={handleSave}
              className="flex-1 px-3 py-2 bg-green-600 hover:bg-green-500 rounded text-sm font-medium flex items-center justify-center gap-1"
            >
              Save
            </button>
            <button
              onClick={() => setShowExportDialog(true)}
              className="flex-1 px-3 py-2 bg-purple-600 hover:bg-purple-500 rounded text-sm font-medium flex items-center justify-center gap-1"
            >
              <Download size={14} /> Export
            </button>
          </div>
        </div>
      </div>

      {/* Center - Canvas Editor */}
      <div className="flex-1 flex flex-col">
        <div className="flex-1 bg-gray-900">
          <Canvas
            room={room}
            selectedLayer={selectedLayer}
            selectedTile={selectedTile}
            zoom={zoom}
            onAddTile={handleAddTile}
            onRemoveTile={handleRemoveTile}
            tileLibrary={tileLibrary}
          />
        </div>
      </div>

      {/* Right Sidebar - Tile Palette */}
      <div className="w-64 border-l border-gray-700 bg-gray-800 overflow-y-auto">
        <TilePalette tiles={tileLibrary} selectedTile={selectedTile} onSelectTile={setSelectedTile} />
      </div>

      {/* Export Dialog */}
      {showExportDialog && room && (
        <ExportDialog room={room} onClose={() => setShowExportDialog(false)} tileLibrary={tileLibrary} />
      )}
    </div>
  );
}
