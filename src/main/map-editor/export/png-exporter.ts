// PNG Exporter - Generate preview images of rooms
import type { Room, TilePlacement, Tile } from '../../shared/types/map-editor';

export class PNGExporter {
  /**
   * Generate PNG preview of room layout
   * Returns canvas data URL for download
   */
  exportToPNG(
    room: Room,
    tileImages: Map<string, HTMLImageElement>,
    scale: number = 1
  ): Promise<string> {
    return new Promise((resolve, reject) => {
      try {
        const canvas = document.createElement('canvas');
        const width = room.width * room.tileSize * scale;
        const height = room.height * room.tileSize * scale;

        canvas.width = width;
        canvas.height = height;

        const ctx = canvas.getContext('2d');
        if (!ctx) {
          reject(new Error('Could not get canvas context'));
          return;
        }

        // Fill background
        ctx.fillStyle = '#222';
        ctx.fillRect(0, 0, width, height);

        // Draw layers in order (ground -> objects -> overhead)
        const layerOrder: Array<keyof typeof room.layers> = ['ground', 'objects', 'overhead'];

        layerOrder.forEach((layerName) => {
          const placements = room.layers[layerName] || [];
          placements.forEach((placement) => {
            const tileImage = tileImages.get(placement.tileId);
            if (tileImage) {
              const x = (placement.x / room.tileSize) * room.tileSize * scale;
              const y = (placement.y / room.tileSize) * room.tileSize * scale;
              const w = (room.tileSize * scale);
              const h = (room.tileSize * scale);

              ctx.save();
              ctx.translate(x + w / 2, y + h / 2);

              if (placement.rotation) {
                ctx.rotate((placement.rotation * Math.PI) / 180);
              }

              if (placement.flipped) {
                ctx.scale(-1, 1);
              }

              ctx.drawImage(tileImage, -w / 2, -h / 2, w, h);
              ctx.restore();
            }
          });
        });

        // Add grid overlay
        ctx.strokeStyle = 'rgba(255, 255, 255, 0.1)';
        ctx.lineWidth = 1;

        for (let i = 0; i <= room.width; i++) {
          const x = (i * room.tileSize * scale);
          ctx.beginPath();
          ctx.moveTo(x, 0);
          ctx.lineTo(x, height);
          ctx.stroke();
        }

        for (let i = 0; i <= room.height; i++) {
          const y = (i * room.tileSize * scale);
          ctx.beginPath();
          ctx.moveTo(0, y);
          ctx.lineTo(width, y);
          ctx.stroke();
        }

        // Add metadata
        ctx.fillStyle = '#fff';
        ctx.font = '12px monospace';
        ctx.fillText(`Room: ${room.name} (${room.width}x${room.height})`, 10, 20);
        ctx.fillText(`Generated: ${new Date().toLocaleString()}`, 10, 35);

        // Convert to data URL
        resolve(canvas.toDataURL('image/png'));
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Download PNG file
   */
  downloadPNG(dataUrl: string, filename: string): void {
    const link = document.createElement('a');
    link.href = dataUrl;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  /**
   * Get file extension
   */
  getFileExtension(): string {
    return '.png';
  }
}

export default PNGExporter;
