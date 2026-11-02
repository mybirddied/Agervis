import { WebSocketServer, WebSocket } from 'ws';
import { ConnectionManager } from './ConnectionManager.js';
import { WorldState } from './WorldState.js';
import { GodotProtocol } from './GodotProtocol.js';
import { MAIN_MAX_PLAYERS } from '../types/godot.js';

export interface AgervisServerConfig {
  port: number;
  max_players?: number;
  world_id: string;
}

export class AgervisServer {
  private wss: WebSocketServer;
  private connections: ConnectionManager;
  private world: WorldState;
  private protocol: GodotProtocol;
  private tick_interval: NodeJS.Timeout | null = null;
  private readonly config: Required<AgervisServerConfig>;

  constructor(config: AgervisServerConfig) {
    this.config = {
      ...config,
      max_players: config.max_players ?? MAIN_MAX_PLAYERS,
    };

    this.connections = new ConnectionManager(this.config.max_players);
    this.world = new WorldState();
    this.protocol = new GodotProtocol(this.connections, this.world);

    this.wss = new WebSocketServer({ port: this.config.port });
    this.setup_websocket_handlers();
  }

  private setup_websocket_handlers(): void {
    this.wss.on('connection', (ws: WebSocket) => {
      this.handle_new_connection(ws);
    });

    this.wss.on('error', (err) => {
      console.error('WebSocket server error:', err);
    });
  }

  private handle_new_connection(ws: WebSocket): void {
    let peer_id: number | null = null;

    ws.on('message', (data: Buffer) => {
      const raw = data.toString('utf8');

      // First message should contain initial state
      if (peer_id === null) {
        try {
          const initial = JSON.parse(raw);
          peer_id = this.connections.add_peer(ws, initial.data || {});

          if (peer_id === null) {
            ws.send(JSON.stringify({
              type: 'connection_rejected',
              data: { reason: 'SERVER_FULL' }
            }));
            ws.close();
            return;
          }

          // Authorize and welcome the peer
          this.connections.authorize_peer(peer_id);
          this.protocol.send_connection_accepted(peer_id);
          this.protocol.broadcast_population();
          this.world.mark_dirty();

          console.log(`[Agervis] Peer ${peer_id} connected (${this.connections.get_population()}/${this.config.max_players})`);
        } catch (err) {
          console.error('Failed to handle initial connection:', err);
          ws.close();
        }
      } else {
        // Handle regular message
        this.protocol.handle_client_message(peer_id, raw);
        this.connections.heartbeat(peer_id);
      }
    });

    ws.on('close', () => {
      if (peer_id !== null) {
        console.log(`[Agervis] Peer ${peer_id} disconnected`);
        this.connections.remove_peer(peer_id);
        this.protocol.broadcast_population();
        this.world.mark_dirty();
      }
    });

    ws.on('error', (err) => {
      console.error(`WebSocket error for peer ${peer_id}:`, err);
    });
  }

  start(): void {
    console.log(`[Agervis] Server starting on port ${this.config.port}`);
    console.log(`[Agervis] World: ${this.config.world_id}`);
    console.log(`[Agervis] Max players: ${this.config.max_players}`);

    // Start game loop (60 FPS tick rate)
    this.tick_interval = setInterval(() => this.tick(), 1000 / 60);

    console.log(`[Agervis] Server running! Waiting for players...`);
  }

  private tick(): void {
    const now = Date.now();

    // Broadcast snapshot if dirty and enough time has passed
    if (this.world.should_broadcast_snapshot(now)) {
      this.protocol.broadcast_snapshot();
    }

    // Check for timed-out connections (30 second timeout)
    const timed_out = this.connections.check_timeouts(30000);
    if (timed_out.length > 0) {
      for (const peer_id of timed_out) {
        const peer = this.connections.get_peer(peer_id);
        if (peer) {
          console.log(`[Agervis] Peer ${peer_id} timed out`);
          peer.ws.close();
        }
        this.connections.remove_peer(peer_id);
      }
      this.protocol.broadcast_population();
      this.world.mark_dirty();
    }
  }

  stop(): void {
    if (this.tick_interval) {
      clearInterval(this.tick_interval);
      this.tick_interval = null;
    }

    this.wss.close(() => {
      console.log('[Agervis] Server stopped');
    });
  }
}
