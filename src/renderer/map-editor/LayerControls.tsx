// LayerControls.tsx - Layer selection component
import React from 'react';
import type { LayerType } from '../../shared/types/map-editor';

interface LayerControlsProps {
  selectedLayer: LayerType;
  onSelectLayer: (layer: LayerType) => void;
}

const layers: Array<{ id: LayerType; name: string; description: string }> = [
  { id: 'ground', name: 'Ground', description: 'Floor tiles and terrain' },
  { id: 'objects', name: 'Objects', description: 'Furniture and interactive items' },
  { id: 'overhead', name: 'Overhead', description: 'Ceiling and sky elements' },
  { id: 'collision', name: 'Collision', description: 'Walkable areas and obstacles' },
];

export default function LayerControls({ selectedLayer, onSelectLayer }: LayerControlsProps) {
  return (
    <div className="mb-4">
      <label className="block text-sm font-semibold mb-2">Active Layer</label>
      <div className="space-y-2">
        {layers.map((layer) => (
          <button
            key={layer.id}
            onClick={() => onSelectLayer(layer.id)}
            className={`w-full text-left px-3 py-2 rounded text-sm transition-colors ${
              selectedLayer === layer.id
                ? 'bg-blue-600 text-white'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }`}
            title={layer.description}
          >
            {layer.name}
          </button>
        ))}
      </div>
    </div>
  );
}
