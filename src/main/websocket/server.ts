/**
 * WebSocket Server
 * Manages WebSocket connections, protocol handling, and message routing
 */

import WebSocket from 'ws';
import { EventEmitter } from 'events';
import { ConnectionManager } from './connection-manager';
import {
  ProtocolCodec,
  ProtocolMessage,
  MessageType,
  GODOT_PROTOCOL_VERSION,
} from './protocol';
import { AuthManager } from '../auth/auth-manager';

export interface WebSocketServerConfig {
  port: number;
  host?: string;
  perMessageDeflate?: boolean;
  maxPayload?: number;
}

export class WebSocketServer extends EventEmitter {
  private wss: WebSocket.Server | null = null;
  private connectionManager: ConnectionManager;
  private config: WebSocketServerConfig;
  private authManager: AuthManager | null = null;
  private messageHandlers: Map<
    MessageType,
    (message: ProtocolMessage, clientId: string) => Promise<void>
  > = new Map();
  private clientTokens: Map<string, string> = new Map();

  constructor(
    config: WebSocketServerConfig,
    connectionManager: ConnectionManager,
    authManager?: AuthManager
  ) {
    super();
    this.config = {
      perMessageDeflate: false,
      maxPayload: 1 * 1024 * 1024, // 1MB (reduced from 100MB)
      ...config,
    };
    this.connectionManager = connectionManager;
    this.authManager = authManager || null;
    this.registerDefaultHandlers();
  }

  async start(): Promise<void> {
    return new Promise((resolve, reject) => {
      try {
        this.wss = new WebSocket.Server(
          {
            port: this.config.port,
            host: this.config.host || '0.0.0.0',
            perMessageDeflate: this.config.perMessageDeflate,
            maxPayload: this.config.maxPayload,
          },
          () => {
            this.emit('started', {
              port: this.config.port,
              host: this.config.host,
            });
            resolve();
          }
        );

        this.wss.on('connection', (ws: WebSocket) => {
          this.handleConnection(ws);
        });

        this.wss.on('error', (error: Error) => {
          this.emit('error', error);
          reject(error);
        });
      } catch (error) {
        reject(error);
      }
    });
  }

  private handleConnection(ws: WebSocket): void {
    let clientId = '';

    ws.on('message', async (data: WebSocket.Data) => {
      try {
        const buffer = Buffer.isBuffer(data)
          ? data
          : Buffer.from(data as string);
        const message = ProtocolCodec.decode(buffer);

        if (!ProtocolCodec.isValidMessage(message)) {
          ws.send(
            ProtocolCodec.encode(
              ProtocolCodec.createError('Invalid message format', 400)
            )
          );
          return;
        }

        // First message must be handshake
        if (!clientId && message.type !== MessageType.HANDSHAKE) {
          ws.send(
            ProtocolCodec.encode(
              ProtocolCodec.createError('Handshake required', 401)
            )
          );
          ws.close();
          return;
        }

        if (message.type === MessageType.HANDSHAKE) {
          clientId = message.clientId || `client-${Date.now()}`;
          const payload = message.payload as any;
          const playerId = payload.playerId;
          const authToken = payload.authToken;

          // Validate authentication token if auth manager is available
          if (this.authManager) {
            const admin = await this.authManager.validateToken(authToken);
            if (!admin) {
              ws.send(
                ProtocolCodec.encode(
                  ProtocolCodec.createError('Invalid or expired authentication token', 401)
                )
              );
              ws.close();
              return;
            }
            this.clientTokens.set(clientId, authToken);
          }

          this.connectionManager.addConnection(clientId, playerId);
          this.emit('client-connected', { clientId, playerId });

          ws.send(
            ProtocolCodec.encode(
              ProtocolCodec.createHandshake(clientId, '1.0.0', playerId)
            )
          );
          return;
        }

        // Route to appropriate handler
        const handler = this.messageHandlers.get(message.type);
        if (handler) {
          await handler(message, clientId);
        }

        // Update latency for heartbeats
        if (message.type === MessageType.HEARTBEAT) {
          this.connectionManager.updateHeartbeat(
            clientId,
            (message.payload as any).latency || 0
          );
        }
      } catch (error) {
        this.emit('message-error', {
          clientId,
          error: error instanceof Error ? error.message : 'Unknown error',
        });

        ws.send(
          ProtocolCodec.encode(
            ProtocolCodec.createError(
              error instanceof Error ? error.message : 'Message processing error',
              500
            )
          )
        );
      }
    });

    ws.on('close', () => {
      if (clientId) {
        this.connectionManager.removeConnection(clientId);
        this.clientTokens.delete(clientId);
        this.emit('client-disconnected', { clientId });
      }
    });

    ws.on('error', (error: Error) => {
      this.emit('ws-error', { clientId, error: error.message });
      if (clientId) {
        this.connectionManager.removeConnection(clientId);
      }
    });

    ws.on('pong', () => {
      if (clientId) {
        this.connectionManager.updateHeartbeat(clientId);
      }
    });
  }

  private registerDefaultHandlers(): void {
    // Heartbeat handler
    this.messageHandlers.set(
      MessageType.HEARTBEAT,
      async (message: ProtocolMessage, clientId: string) => {
        this.connectionManager.updateHeartbeat(
          clientId,
          (message.payload as any).latency || 0
        );
      }
    );

    // Game state handler (will be extended by game logic)
    this.messageHandlers.set(
      MessageType.GAME_STATE,
      async (message: ProtocolMessage, clientId: string) => {
        this.emit('game-state-update', { clientId, message });
      }
    );

    // Game event handler
    this.messageHandlers.set(
      MessageType.GAME_EVENT,
      async (message: ProtocolMessage, clientId: string) => {
        this.emit('game-event', { clientId, message });
      }
    );

    // Command handler
    this.messageHandlers.set(
      MessageType.COMMAND,
      async (message: ProtocolMessage, clientId: string) => {
        this.emit('client-command', { clientId, message });
      }
    );
  }

  registerMessageHandler(
    type: MessageType,
    handler: (message: ProtocolMessage, clientId: string) => Promise<void>
  ): void {
    this.messageHandlers.set(type, handler);
  }

  broadcast(message: ProtocolMessage): void {
    if (!this.wss) return;

    const data = ProtocolCodec.encode(message);
    this.wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(data);
      }
    });
  }

  broadcastToClient(clientId: string, message: ProtocolMessage): boolean {
    if (!this.wss) return false;

    let sent = false;
    this.wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        // Find client by stored clientId (would need to track this)
        const data = ProtocolCodec.encode(message);
        client.send(data);
        sent = true;
      }
    });

    return sent;
  }

  getConnectionManager(): ConnectionManager {
    return this.connectionManager;
  }

  async stop(): Promise<void> {
    return new Promise((resolve) => {
      if (this.wss) {
        this.wss.close(() => {
          this.emit('stopped');
          resolve();
        });
      } else {
        resolve();
      }
    });
  }

  isRunning(): boolean {
    return this.wss !== null && this.wss.readyState === WebSocket.OPEN;
  }
}
