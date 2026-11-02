/**
 * Godot WebSocket Protocol v13 Implementation
 * Handles protocol versioning, message serialization, and compatibility
 */

export const GODOT_PROTOCOL_VERSION = 13;
export const SUPPORTED_PROTOCOL_VERSIONS = [13];

export enum MessageType {
  HANDSHAKE = 0,
  HEARTBEAT = 1,
  GAME_STATE = 2,
  GAME_EVENT = 3,
  COMMAND = 4,
  ERROR = 5,
  DISCONNECT = 6,
}

export interface ProtocolMessage {
  type: MessageType;
  version: number;
  timestamp: number;
  clientId?: string;
  payload: Record<string, unknown>;
  sequenceId?: number;
}

export interface HandshakePayload {
  protocolVersion: number;
  clientVersion: string;
  clientId: string;
  playerId?: string;
}

export interface HeartbeatPayload {
  clientId: string;
  timestamp: number;
  latency?: number;
}

export interface GameStatePayload {
  entityId: string;
  position?: { x: number; y: number; z: number };
  rotation?: { x: number; y: number; z: number };
  state: Record<string, unknown>;
  dirty?: boolean;
}

export interface GameEventPayload {
  eventType: string;
  sourceEntityId: string;
  targetEntityId?: string;
  data: Record<string, unknown>;
}

export class ProtocolCodec {
  static encode(message: ProtocolMessage): Buffer {
    const json = JSON.stringify(message);
    return Buffer.from(json, 'utf-8');
  }

  static decode(data: Buffer): ProtocolMessage {
    const json = data.toString('utf-8');
    return JSON.parse(json) as ProtocolMessage;
  }

  static createHandshake(
    clientId: string,
    clientVersion: string,
    playerId?: string
  ): ProtocolMessage {
    return {
      type: MessageType.HANDSHAKE,
      version: GODOT_PROTOCOL_VERSION,
      timestamp: Date.now(),
      clientId,
      payload: {
        protocolVersion: GODOT_PROTOCOL_VERSION,
        clientVersion,
        clientId,
        playerId,
      } as HandshakePayload,
    };
  }

  static createHeartbeat(clientId: string, latency?: number): ProtocolMessage {
    return {
      type: MessageType.HEARTBEAT,
      version: GODOT_PROTOCOL_VERSION,
      timestamp: Date.now(),
      clientId,
      payload: {
        clientId,
        timestamp: Date.now(),
        latency,
      } as HeartbeatPayload,
    };
  }

  static createGameState(
    entityId: string,
    state: GameStatePayload
  ): ProtocolMessage {
    return {
      type: MessageType.GAME_STATE,
      version: GODOT_PROTOCOL_VERSION,
      timestamp: Date.now(),
      payload: state,
      sequenceId: Math.floor(Math.random() * 1000000),
    };
  }

  static createGameEvent(event: GameEventPayload): ProtocolMessage {
    return {
      type: MessageType.GAME_EVENT,
      version: GODOT_PROTOCOL_VERSION,
      timestamp: Date.now(),
      payload: event,
    };
  }

  static createError(message: string, code: number): ProtocolMessage {
    return {
      type: MessageType.ERROR,
      version: GODOT_PROTOCOL_VERSION,
      timestamp: Date.now(),
      payload: {
        message,
        code,
      },
    };
  }

  static isValidVersion(version: number): boolean {
    return SUPPORTED_PROTOCOL_VERSIONS.includes(version);
  }

  static isValidMessage(data: unknown): data is ProtocolMessage {
    if (typeof data !== 'object' || data === null) return false;
    const msg = data as Record<string, unknown>;
    return (
      typeof msg.type === 'number' &&
      typeof msg.version === 'number' &&
      typeof msg.timestamp === 'number' &&
      typeof msg.payload === 'object'
    );
  }
}
