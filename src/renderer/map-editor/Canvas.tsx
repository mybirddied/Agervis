// Canvas.tsx - Canvas rendering component for map visualization
import React, { useEffect, useRef, useState } from 'react';
import CanvasRenderer from '../../main/map-editor/canvas-renderer';
import type { Room, TilePlacement, Tile, LayerType } from '../../shared/types/map-editor';

interface CanvasProps {
  room: Room;
  selectedLayer: LayerType;
  selectedTile: Tile | null;
  zoom: number;
  onAddTile: (placement: TilePlacement) => void;
  onRemoveTile: (placementId: string) => void;
  tileLibrary: Tile[];
}

export default function Canvas({
  room,
  selectedLayer,
  selectedTile,
  zoom,
  onAddTile,
  onRemoveTile,
  tileLibrary,
}: CanvasProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const rendererRef = useRef<CanvasRenderer | null>(null);
  const [tileImages, setTileImages] = useState<Map<string, HTMLImageElement>>(new Map());
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });

  // Load tile images
  useEffect(() => {
    const images = new Map<string, HTMLImageElement>();

    tileLibrary.forEach((tile) => {
      const img = new Image();
      img.src = tile.imageUrl;
      images.set(tile.id, img);
    });

    setTileImages(images);
  }, [tileLibrary]);

  // Initialize and render canvas
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas || tileImages.size === 0) return;

    try {
      if (!rendererRef.current) {
        rendererRef.current = new CanvasRenderer(canvas);
      }

      const renderer = rendererRef.current;
      renderer.setZoom(zoom);
      renderer.render(room, tileImages, selectedLayer);
    } catch (error) {
      console.error('Canvas rendering error:', error);
    }
  }, [room, selectedLayer, zoom, tileImages]);

  // Handle canvas resize
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const handleResize = () => {
      canvas.width = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
    };

    handleResize();
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  const handleMouseDown = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (e.button === 2) {
      // Right-click for panning
      setIsDragging(true);
      setDragStart({ x: e.clientX, y: e.clientY });
    } else if (e.button === 0 && selectedTile) {
      // Left-click to place tile
      const canvas = canvasRef.current;
      if (!canvas || !rendererRef.current) return;

      const rect = canvas.getBoundingClientRect();
      const screenX = e.clientX - rect.left;
      const screenY = e.clientY - rect.top;

      const renderer = rendererRef.current;
      const viewState = renderer.getViewState();
      const canvasCoords = renderer.screenToCanvas(screenX, screenY, room);

      // Snap to grid
      const snappedX = Math.floor(canvasCoords.x / room.tileSize) * room.tileSize;
      const snappedY = Math.floor(canvasCoords.y / room.tileSize) * room.tileSize;

      const placement: TilePlacement = {
        id: `placement_${Date.now()}`,
        tileId: selectedTile.id,
        x: snappedX,
        y: snappedY,
        layer: selectedLayer,
        rotation: 0,
        flipped: false,
      };

      onAddTile(placement);
    }
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (isDragging) {
      const dx = e.clientX - dragStart.x;
      const dy = e.clientY - dragStart.y;

      if (rendererRef.current) {
        rendererRef.current.pan(dx, dy);
        setDragStart({ x: e.clientX, y: e.clientY });
      }
    }
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleContextMenu = (e: React.MouseEvent) => {
    e.preventDefault();
  };

  const handleWheel = (e: React.WheelEvent<HTMLCanvasElement>) => {
    e.preventDefault();

    if (rendererRef.current) {
      const newZoom = zoom * (1 - e.deltaY * 0.001);
      const clampedZoom = Math.max(0.25, Math.min(newZoom, 4));

      if (clampedZoom !== zoom) {
        rendererRef.current.setZoom(clampedZoom);
      }
    }
  };

  return (
    <div className="w-full h-full flex flex-col bg-gray-900">
      <div className="flex-1 relative bg-gray-800">
        <canvas
          ref={canvasRef}
          onMouseDown={handleMouseDown}
          onMouseMove={handleMouseMove}
          onMouseUp={handleMouseUp}
          onMouseLeave={handleMouseUp}
          onContextMenu={handleContextMenu}
          onWheel={handleWheel}
          className="w-full h-full cursor-crosshair"
        />
      </div>

      {/* Status Bar */}
      <div className="px-4 py-2 border-t border-gray-700 bg-gray-800 text-sm text-gray-400">
        <p>
          Layer: <span className="text-white font-semibold">{selectedLayer}</span> | Tile:{' '}
          <span className="text-white font-semibold">{selectedTile?.name || 'None'}</span> | Zoom:{' '}
          <span className="text-white font-semibold">{zoom.toFixed(1)}x</span>
        </p>
        <p className="text-xs mt-1">Left-click to place tiles • Right-click + drag to pan • Scroll to zoom</p>
      </div>
    </div>
  );
}
