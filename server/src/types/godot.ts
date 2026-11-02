// Godot Protocol Constants - MUST match private_session.gd exactly
export const PROTOCOL_VERSION = 11;
export const DEFAULT_PORT = 24860;
export const MAIN_MAX_PLAYERS = 25;
export const MAIN_WORLD_ID = "AGERVIS-MAIN-FIRST-BLOCK";
export const LOCAL_TEST_WORLD_ID = "AGERVIS-LOCAL-TEST-WORLD";

// Peer replication field names (must match REMOTE_REPLICATION_FIELDS)
export const REMOTE_REPLICATION_FIELDS = [
  "peer_id", "name", "area", "room_id", "phase", "position", "facing", "walking",
  "home_instance_id",
  "color", "pants_color", "skin", "hair_style", "body_style", "hair_color",
  "facial_hair_style", "facial_hair_color", "face_style", "eye_style", "stature",
  "outfit_style", "surreal_trait", "accessory", "attack_weapon", "health", "downed",
  "mark", "deceased", "detained", "arrested", "heat", "warrant",
] as const;

export const REMOTE_IDENTITY_FIELDS = [
  "peer_id", "resident_key", "name", "color", "pants_color", "skin", "hair_style", "body_style",
  "hair_color", "facial_hair_style", "facial_hair_color", "face_style", "eye_style",
  "stature", "outfit_style", "surreal_trait", "accessory", "attack_weapon",
] as const;

export const REMOTE_MOTION_FIELDS = [
  "area", "room_id", "phase", "home_instance_id", "position", "facing", "walking", "health", "downed",
  "mark", "deceased", "detained", "arrested", "heat", "warrant",
] as const;

// Game Constants
export const ATTACK_DISTANCE = 94.0;
export const ATTACK_COOLDOWN_MS = 580;
export const DOWNED_RECOVERY_SECONDS = 3.0;
export const LEO_DETENTION_MIN_HEAT = 50;
export const LEO_ARREST_MIN_HEAT = 100;
export const BLOOD_CLEANING_DISTANCE = 125.0;

// Proximity Chat Constants
export enum ChatType {
  WHISPER = 0,
  NORMAL = 1,
  SHOUT = 2,
  GLOBAL = 3,
  RADIO = 4
}

export const CHAT_RANGES = {
  [ChatType.WHISPER]: 150.0,
  [ChatType.NORMAL]: 400.0,
  [ChatType.SHOUT]: 800.0,
  [ChatType.GLOBAL]: 999999.0,
  [ChatType.RADIO]: 999999.0,
} as const;

// Vector2 position type
export interface Vector2 {
  x: number;
  y: number;
}

// Peer state structure
export interface PeerState {
  peer_id: number;
  name: string;
  area: string;
  room_id: string;
  phase: string;
  position: Vector2;
  facing: number;
  walking: boolean;
  home_instance_id: string;

  // Appearance
  color: string;
  pants_color: string;
  skin: string;
  hair_style: string;
  body_style: string;
  hair_color: string;
  facial_hair_style: string;
  facial_hair_color: string;
  face_style: string;
  eye_style: string;
  stature: string;
  outfit_style: string;
  surreal_trait: string;
  accessory: string;
  attack_weapon: string;

  // Game state
  health: number;
  downed: boolean;
  mark: string;
  deceased: boolean;
  detained: boolean;
  arrested: boolean;
  heat: number;
  warrant: string;

  // Connection metadata
  protocol?: number;
  invite_token?: string;
  tester_id?: string;
  resident_slot?: number;
}

// RPC method signatures (client->server)
export interface ServerRPCMethods {
  submit_state_to_server(candidate: Partial<PeerState>): void;
  submit_motion_to_server(candidate: Partial<PeerState>): void;
  submit_proximity_chat_server(sender_name: string, message: string, chat_type: ChatType): void;
  submit_chat_server(sender_name: string, message: string): void;
  // Economy/transaction RPCs will be added as we build them
}

// RPC method signatures (server->client)
export interface ClientRPCMethods {
  receive_snapshot(snapshot: Partial<PeerState>[]): void;
  receive_snapshot_chunk(chunk_index: number, chunk_count: number, chunk_data: string): void;
  receive_proximity_chat(sender_name: string, message: string, chat_type: ChatType): void;
  receive_chat(sender_name: string, message: string): void;
  server_roster_update(roster: Record<string, any>, world_id: string): void;
  server_population_update(population: number, capacity: number): void;
}

// Godot packet structure (simplified WebSocket message wrapper)
export interface GodotMessage {
  type: string;  // RPC method name
  data: any;     // Method arguments
  peer_id?: number;
}
