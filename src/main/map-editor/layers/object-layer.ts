// Object Layer - Furniture, interactive objects, items
import type { TilePlacement } from '../../shared/types/map-editor';

export class ObjectLayer {
  private placements: TilePlacement[] = [];

  addTile(placement: TilePlacement): void {
    this.placements.push(placement);
  }

  removeTile(placementId: string): void {
    this.placements = this.placements.filter((p) => p.id !== placementId);
  }

  updateTile(id: string, updates: Partial<TilePlacement>): void {
    const placement = this.placements.find((p) => p.id === id);
    if (placement) {
      Object.assign(placement, updates);
    }
  }

  getTiles(): TilePlacement[] {
    return [...this.placements];
  }

  clear(): void {
    this.placements = [];
  }

  getTile(id: string): TilePlacement | undefined {
    return this.placements.find((p) => p.id === id);
  }

  export(): TilePlacement[] {
    return this.getTiles();
  }

  import(tiles: TilePlacement[]): void {
    this.clear();
    tiles.forEach((tile) => this.addTile(tile));
  }
}

export default ObjectLayer;
