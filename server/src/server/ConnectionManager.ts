import type { WebSocket } from 'ws';
import type { PeerState, GodotMessage, ChatType } from '../types/godot.js';
import { PROTOCOL_VERSION, MAIN_WORLD_ID } from '../types/godot.js';

export interface ConnectedPeer {
  ws: WebSocket;
  peer_id: number;
  state: PeerState;
  account_id?: string;
  authorized: boolean;
  last_heartbeat: number;
  user_api_key?: string; // BYOK for AI features
}

export class ConnectionManager {
  private peers: Map<number, ConnectedPeer> = new Map();
  private next_peer_id = 2; // 1 is reserved for server
  private readonly max_players: number;

  constructor(max_players: number) {
    this.max_players = max_players;
  }

  add_peer(ws: WebSocket, initial_state: Partial<PeerState>): number | null {
    if (this.peers.size >= this.max_players) {
      return null; // Server full
    }

    const peer_id = this.next_peer_id++;

    const peer: ConnectedPeer = {
      ws,
      peer_id,
      state: this.sanitize_initial_state(initial_state, peer_id),
      authorized: false,
      last_heartbeat: Date.now(),
    };

    this.peers.set(peer_id, peer);
    return peer_id;
  }

  remove_peer(peer_id: number): void {
    this.peers.delete(peer_id);
  }

  get_peer(peer_id: number): ConnectedPeer | undefined {
    return this.peers.get(peer_id);
  }

  get_all_peers(): ConnectedPeer[] {
    return Array.from(this.peers.values());
  }

  get_population(): number {
    return this.peers.size;
  }

  get_capacity(): number {
    return this.max_players;
  }

  update_peer_state(peer_id: number, updates: Partial<PeerState>): void {
    const peer = this.peers.get(peer_id);
    if (!peer) return;

    peer.state = { ...peer.state, ...updates };
  }

  authorize_peer(peer_id: number, account_id?: string): void {
    const peer = this.peers.get(peer_id);
    if (!peer) return;

    peer.authorized = true;
    if (account_id) {
      peer.account_id = account_id;
    }
  }

  set_user_api_key(peer_id: number, api_key: string): void {
    const peer = this.peers.get(peer_id);
    if (!peer) return;
    peer.user_api_key = api_key;
  }

  private sanitize_initial_state(initial: Partial<PeerState>, peer_id: number): PeerState {
    return {
      peer_id,
      name: String(initial.name || `Player${peer_id}`),
      area: String(initial.area || "street"),
      room_id: String(initial.room_id || ""),
      phase: String(initial.phase || "adult"),
      position: initial.position || { x: 5000, y: 200 },
      facing: Number(initial.facing || 1),
      walking: Boolean(initial.walking || false),
      home_instance_id: String(initial.home_instance_id || ""),

      color: String(initial.color || "a36e50"),
      pants_color: String(initial.pants_color || "101214"),
      skin: String(initial.skin || "b97855"),
      hair_style: String(initial.hair_style || "short"),
      body_style: String(initial.body_style || "standard"),
      hair_color: String(initial.hair_color || "17191b"),
      facial_hair_style: String(initial.facial_hair_style || "none"),
      facial_hair_color: String(initial.facial_hair_color || "17191b"),
      face_style: String(initial.face_style || "angular"),
      eye_style: String(initial.eye_style || "steady"),
      stature: String(initial.stature || "average"),
      outfit_style: String(initial.outfit_style || "jacket"),
      surreal_trait: String(initial.surreal_trait || "none"),
      accessory: String(initial.accessory || "none"),
      attack_weapon: String(initial.attack_weapon || "Fists"),

      health: Number(initial.health ?? 100),
      downed: Boolean(initial.downed || false),
      mark: String(initial.mark || ""),
      deceased: Boolean(initial.deceased || false),
      detained: Boolean(initial.detained || false),
      arrested: Boolean(initial.arrested || false),
      heat: Number(initial.heat || 0),
      warrant: String(initial.warrant || ""),

      protocol: PROTOCOL_VERSION,
    };
  }

  heartbeat(peer_id: number): void {
    const peer = this.peers.get(peer_id);
    if (peer) {
      peer.last_heartbeat = Date.now();
    }
  }

  check_timeouts(timeout_ms: number): number[] {
    const now = Date.now();
    const timed_out: number[] = [];

    for (const [peer_id, peer] of this.peers) {
      if (now - peer.last_heartbeat > timeout_ms) {
        timed_out.push(peer_id);
      }
    }

    return timed_out;
  }
}
