/**
 * World State Manager
 * Manages game world state with atomic updates and change tracking
 */

import { EventEmitter } from 'events';

export interface Entity {
  id: string;
  type: string;
  position: { x: number; y: number; z: number };
  rotation: { x: number; y: number; z: number };
  scale: { x: number; y: number; z: number };
  state: Record<string, unknown>;
  owner?: string;
  createdAt: number;
  updatedAt: number;
  dirty: boolean;
}

export interface WorldState {
  entities: Map<string, Entity>;
  metadata: Record<string, unknown>;
  version: number;
  lastUpdated: number;
}

export class WorldStateManager extends EventEmitter {
  private state: WorldState;
  private pendingUpdates: Map<string, Entity> = new Map();
  private updateBuffer: Entity[] = [];
  private flushInterval: NodeJS.Timeout | null = null;
  private maxBufferSize: number = 1000;
  private flushIntervalMs: number = 100;

  constructor() {
    super();
    this.state = {
      entities: new Map(),
      metadata: {},
      version: 0,
      lastUpdated: Date.now(),
    };
  }

  /**
   * Add or update an entity atomically
   */
  updateEntity(entity: Partial<Entity> & { id: string }): Entity {
    const existingEntity = this.state.entities.get(entity.id);
    const now = Date.now();

    const updated: Entity = {
      id: entity.id,
      type: entity.type || existingEntity?.type || 'unknown',
      position: entity.position || existingEntity?.position || { x: 0, y: 0, z: 0 },
      rotation: entity.rotation || existingEntity?.rotation || { x: 0, y: 0, z: 0 },
      scale: entity.scale || existingEntity?.scale || { x: 1, y: 1, z: 1 },
      state: entity.state || existingEntity?.state || {},
      owner: entity.owner || existingEntity?.owner,
      createdAt: existingEntity?.createdAt || now,
      updatedAt: now,
      dirty: true,
    };

    this.state.entities.set(entity.id, updated);
    this.pendingUpdates.set(entity.id, updated);
    this.updateBuffer.push(updated);

    this.state.version++;
    this.state.lastUpdated = now;

    this.emit('entity-updated', updated);

    // Start flush interval if not running
    if (!this.flushInterval && this.updateBuffer.length > 0) {
      this.startFlushInterval();
    }

    // Flush if buffer is full
    if (this.updateBuffer.length >= this.maxBufferSize) {
      this.flush();
    }

    return updated;
  }

  /**
   * Get entity by ID
   */
  getEntity(id: string): Entity | null {
    return this.state.entities.get(id) || null;
  }

  /**
   * Get all entities
   */
  getAllEntities(): Entity[] {
    return Array.from(this.state.entities.values());
  }

  /**
   * Get entities by type
   */
  getEntitiesByType(type: string): Entity[] {
    return Array.from(this.state.entities.values()).filter(
      (e) => e.type === type
    );
  }

  /**
   * Get entities in range (simple distance check)
   */
  getEntitiesInRange(
    center: { x: number; y: number; z: number },
    radius: number
  ): Entity[] {
    return Array.from(this.state.entities.values()).filter((entity) => {
      const dx = entity.position.x - center.x;
      const dy = entity.position.y - center.y;
      const dz = entity.position.z - center.z;
      const distance = Math.sqrt(dx * dx + dy * dy + dz * dz);
      return distance <= radius;
    });
  }

  /**
   * Remove entity
   */
  removeEntity(id: string): boolean {
    const existed = this.state.entities.has(id);
    this.state.entities.delete(id);
    this.pendingUpdates.delete(id);
    this.state.version++;
    this.state.lastUpdated = Date.now();

    if (existed) {
      this.emit('entity-removed', { id });
    }

    return existed;
  }

  /**
   * Batch update entities
   */
  batchUpdateEntities(entities: (Partial<Entity> & { id: string })[]): Entity[] {
    const updated: Entity[] = [];
    entities.forEach((entity) => {
      updated.push(this.updateEntity(entity));
    });
    return updated;
  }

  /**
   * Flush pending updates
   */
  flush(): Entity[] {
    if (this.updateBuffer.length === 0) {
      return [];
    }

    const flushed = [...this.updateBuffer];
    this.updateBuffer = [];

    // Mark all as no longer dirty
    flushed.forEach((entity) => {
      entity.dirty = false;
    });

    this.emit('flush', {
      count: flushed.length,
      version: this.state.version,
    });

    return flushed;
  }

  /**
   * Get pending updates
   */
  getPendingUpdates(): Entity[] {
    return Array.from(this.pendingUpdates.values());
  }

  /**
   * Get world state snapshot
   */
  getSnapshot(): WorldState {
    return {
      entities: new Map(this.state.entities),
      metadata: { ...this.state.metadata },
      version: this.state.version,
      lastUpdated: this.state.lastUpdated,
    };
  }

  /**
   * Clear all state
   */
  clear(): void {
    this.state.entities.clear();
    this.pendingUpdates.clear();
    this.updateBuffer = [];
    this.state.version++;
    this.state.lastUpdated = Date.now();
    this.emit('cleared');
  }

  /**
   * Set metadata
   */
  setMetadata(key: string, value: unknown): void {
    this.state.metadata[key] = value;
    this.emit('metadata-updated', { key, value });
  }

  /**
   * Get metadata
   */
  getMetadata(key: string): unknown {
    return this.state.metadata[key];
  }

  private startFlushInterval(): void {
    this.flushInterval = setInterval(() => {
      if (this.updateBuffer.length > 0) {
        this.flush();
      } else {
        this.stopFlushInterval();
      }
    }, this.flushIntervalMs);
  }

  private stopFlushInterval(): void {
    if (this.flushInterval) {
      clearInterval(this.flushInterval);
      this.flushInterval = null;
    }
  }

  getStatistics() {
    return {
      entityCount: this.state.entities.size,
      pendingUpdates: this.updateBuffer.length,
      version: this.state.version,
      lastUpdated: this.state.lastUpdated,
    };
  }

  setFlushInterval(ms: number): void {
    this.flushIntervalMs = ms;
  }

  setMaxBufferSize(size: number): void {
    this.maxBufferSize = size;
  }
}
