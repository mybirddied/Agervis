import type { PeerState, Vector2, ChatType } from '../types/godot.js';
import { CHAT_RANGES } from '../types/godot.js';

export interface WorldSnapshot {
  peers: PeerState[];
  timestamp: number;
}

export class WorldState {
  private snapshot_dirty = false;
  private last_snapshot_time = 0;
  private snapshot_interval_ms = 100; // 10Hz snapshot rate

  constructor() {}

  mark_dirty(): void {
    this.snapshot_dirty = true;
  }

  should_broadcast_snapshot(now: number): boolean {
    if (!this.snapshot_dirty) return false;
    if (now - this.last_snapshot_time < this.snapshot_interval_ms) return false;
    return true;
  }

  mark_snapshot_sent(now: number): void {
    this.snapshot_dirty = false;
    this.last_snapshot_time = now;
  }

  create_snapshot(all_peers: PeerState[]): WorldSnapshot {
    return {
      peers: all_peers.map(p => ({ ...p })), // shallow copy
      timestamp: Date.now(),
    };
  }

  calculate_distance(a: Vector2, b: Vector2): number {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  can_hear_chat(
    sender: PeerState,
    receiver: PeerState,
    chat_type: ChatType
  ): boolean {
    const range = CHAT_RANGES[chat_type];

    // Global chat
    if (range >= 999999.0) {
      return true;
    }

    // Must be in same area
    if (sender.area !== receiver.area) {
      return false;
    }

    // Must be in same room
    if (sender.room_id !== receiver.room_id) {
      return false;
    }

    // Check distance
    const distance = this.calculate_distance(sender.position, receiver.position);
    return distance <= range;
  }

  get_peers_in_proximity(
    origin: PeerState,
    all_peers: PeerState[],
    radius: number
  ): PeerState[] {
    return all_peers.filter(peer => {
      if (peer.peer_id === origin.peer_id) return false;
      if (peer.area !== origin.area) return false;
      if (peer.room_id !== origin.room_id) return false;

      const distance = this.calculate_distance(origin.position, peer.position);
      return distance <= radius;
    });
  }
}
