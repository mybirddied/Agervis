// Canvas Renderer - Renders map with grid, tiles, and layers
import type { Room, TilePlacement, Tile } from '../../shared/types/map-editor';

export class CanvasRenderer {
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;
  private zoom: number = 1;
  private panX: number = 0;
  private panY: number = 0;
  private selectedPlacementId: string | null = null;

  constructor(canvas: HTMLCanvasElement) {
    this.canvas = canvas;
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      throw new Error('Could not get canvas context');
    }
    this.ctx = ctx;
  }

  /**
   * Render the complete room layout
   */
  render(room: Room, tileImages: Map<string, HTMLImageElement>, selectedLayer: string): void {
    this.clearCanvas();
    this.drawGrid(room);
    this.drawLayers(room, tileImages, selectedLayer);
  }

  /**
   * Clear the canvas
   */
  private clearCanvas(): void {
    this.ctx.fillStyle = '#1a1a2e';
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
  }

  /**
   * Draw grid background
   */
  private drawGrid(room: Room): void {
    const tileSize = room.tileSize * this.zoom;
    const gridColor = '#333';
    const gridWidth = 0.5;

    this.ctx.strokeStyle = gridColor;
    this.ctx.lineWidth = gridWidth;

    // Vertical lines
    for (let x = 0; x < room.width; x++) {
      const screenX = x * tileSize + this.panX;
      this.ctx.beginPath();
      this.ctx.moveTo(screenX, 0);
      this.ctx.lineTo(screenX, this.canvas.height);
      this.ctx.stroke();
    }

    // Horizontal lines
    for (let y = 0; y < room.height; y++) {
      const screenY = y * tileSize + this.panY;
      this.ctx.beginPath();
      this.ctx.moveTo(0, screenY);
      this.ctx.lineTo(this.canvas.width, screenY);
      this.ctx.stroke();
    }
  }

  /**
   * Draw all layers
   */
  private drawLayers(room: Room, tileImages: Map<string, HTMLImageElement>, selectedLayer: string): void {
    const layerOrder: Array<keyof typeof room.layers> = ['ground', 'objects', 'overhead', 'collision'];

    layerOrder.forEach((layerName) => {
      const opacity = selectedLayer === layerName ? 1 : 0.4;
      this.ctx.globalAlpha = opacity;

      const placements = room.layers[layerName] || [];
      placements.forEach((placement) => {
        this.drawPlacement(placement, room, tileImages);
      });

      this.ctx.globalAlpha = 1;
    });
  }

  /**
   * Draw a single tile placement
   */
  private drawPlacement(placement: TilePlacement, room: Room, tileImages: Map<string, HTMLImageElement>): void {
    const tileImage = tileImages.get(placement.tileId);
    if (!tileImage) {
      return;
    }

    const tileSize = room.tileSize;
    const x = placement.x + this.panX;
    const y = placement.y + this.panY;
    const w = tileSize * this.zoom;
    const h = tileSize * this.zoom;

    this.ctx.save();
    this.ctx.translate(x + w / 2, y + h / 2);

    if (placement.rotation) {
      this.ctx.rotate((placement.rotation * Math.PI) / 180);
    }

    if (placement.flipped) {
      this.ctx.scale(-1, 1);
    }

    this.ctx.drawImage(tileImage, -w / 2, -h / 2, w, h);

    // Draw selection highlight
    if (placement.id === this.selectedPlacementId) {
      this.ctx.strokeStyle = '#00ff00';
      this.ctx.lineWidth = 2;
      this.ctx.strokeRect(-w / 2, -h / 2, w, h);
    }

    this.ctx.restore();
  }

  /**
   * Set zoom level
   */
  setZoom(zoom: number): void {
    this.zoom = Math.max(0.25, Math.min(zoom, 4));
  }

  /**
   * Pan the view
   */
  pan(dx: number, dy: number): void {
    this.panX += dx;
    this.panY += dy;
  }

  /**
   * Select a tile placement
   */
  selectPlacement(placementId: string): void {
    this.selectedPlacementId = placementId;
  }

  /**
   * Deselect current placement
   */
  deselect(): void {
    this.selectedPlacementId = null;
  }

  /**
   * Get canvas coordinates for screen position
   */
  screenToCanvas(screenX: number, screenY: number, room: Room): { x: number; y: number } {
    const canvasX = (screenX - this.panX) / this.zoom;
    const canvasY = (screenY - this.panY) / this.zoom;
    return { x: canvasX, y: canvasY };
  }

  /**
   * Get current view state
   */
  getViewState(): { zoom: number; panX: number; panY: number } {
    return { zoom: this.zoom, panX: this.panX, panY: this.panY };
  }

  /**
   * Set view state
   */
  setViewState(zoom: number, panX: number, panY: number): void {
    this.zoom = zoom;
    this.panX = panX;
    this.panY = panY;
  }

  /**
   * Reset view to fit room
   */
  fitToView(room: Room): void {
    const roomWidth = room.width * room.tileSize;
    const roomHeight = room.height * room.tileSize;

    const scaleX = (this.canvas.width * 0.9) / roomWidth;
    const scaleY = (this.canvas.height * 0.9) / roomHeight;

    this.zoom = Math.min(scaleX, scaleY);
    this.panX = (this.canvas.width - roomWidth * this.zoom) / 2;
    this.panY = (this.canvas.height - roomHeight * this.zoom) / 2;
  }
}

export default CanvasRenderer;
