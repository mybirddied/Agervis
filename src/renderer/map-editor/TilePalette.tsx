// TilePalette.tsx - Tile selection palette component
import React from 'react';
import type { Tile } from '../../shared/types/map-editor';

interface TilePaletteProps {
  tiles: Tile[];
  selectedTile: Tile | null;
  onSelectTile: (tile: Tile) => void;
}

export default function TilePalette({ tiles, selectedTile, onSelectTile }: TilePaletteProps) {
  const categories = Array.from(new Set(tiles.map((t) => t.category)));

  return (
    <div className="p-4">
      <h3 className="text-sm font-semibold mb-4">Tile Palette</h3>

      {categories.map((category) => {
        const categoryTiles = tiles.filter((t) => t.category === category);

        return (
          <div key={category} className="mb-4">
            <h4 className="text-xs font-semibold text-gray-400 uppercase mb-2">{category}</h4>
            <div className="space-y-2">
              {categoryTiles.map((tile) => (
                <button
                  key={tile.id}
                  onClick={() => onSelectTile(tile)}
                  className={`w-full text-left px-3 py-2 rounded text-sm transition-colors ${
                    selectedTile?.id === tile.id
                      ? 'bg-green-600 text-white'
                      : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                  }`}
                  title={tile.name}
                >
                  <div className="flex items-center gap-2">
                    <div
                      className="w-6 h-6 bg-gray-600 rounded flex-shrink-0"
                      style={{ backgroundImage: `url(${tile.imageUrl})`, backgroundSize: 'cover' }}
                    />
                    <div className="flex-1 min-w-0">
                      <p className="font-medium truncate">{tile.name}</p>
                      <p className="text-xs opacity-75">
                        {tile.collisionType === 'solid' ? 'Solid' : 'Passable'}
                      </p>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        );
      })}

      {tiles.length === 0 && (
        <div className="text-center py-8 text-gray-400 text-sm">
          <p>No tiles available</p>
          <p className="text-xs mt-2">Load tile graphics to get started</p>
        </div>
      )}
    </div>
  );
}
