import type { GodotMessage, PeerState, ChatType } from '../types/godot.js';
import type { ConnectedPeer } from './ConnectionManager.js';
import { ConnectionManager } from './ConnectionManager.js';
import { WorldState } from './WorldState.js';
import { PROTOCOL_VERSION, MAIN_WORLD_ID } from '../types/godot.js';

export class GodotProtocol {
  constructor(
    private connections: ConnectionManager,
    private world: WorldState
  ) {}

  handle_client_message(peer_id: number, raw_message: string): void {
    try {
      const msg: GodotMessage = JSON.parse(raw_message);

      switch (msg.type) {
        case 'submit_state_to_server':
          this.handle_submit_state(peer_id, msg.data);
          break;
        case 'submit_motion_to_server':
          this.handle_submit_motion(peer_id, msg.data);
          break;
        case 'submit_proximity_chat_server':
          this.handle_proximity_chat(peer_id, msg.data);
          break;
        case 'submit_chat_server':
          this.handle_chat(peer_id, msg.data);
          break;
        default:
          console.warn(`Unknown message type: ${msg.type} from peer ${peer_id}`);
      }
    } catch (err) {
      console.error(`Failed to parse message from peer ${peer_id}:`, err);
    }
  }

  private handle_submit_state(peer_id: number, state: Partial<PeerState>): void {
    const peer = this.connections.get_peer(peer_id);
    if (!peer || !peer.authorized) return;

    // Validate protocol version on first connection
    if (state.protocol && state.protocol !== PROTOCOL_VERSION) {
      this.send_to_peer(peer_id, {
        type: 'connection_rejected',
        data: {
          reason: 'PROTOCOL_MISMATCH',
          server_protocol: PROTOCOL_VERSION,
          client_protocol: state.protocol,
        }
      });
      return;
    }

    // Update peer state
    this.connections.update_peer_state(peer_id, state);
    this.world.mark_dirty();
  }

  private handle_submit_motion(peer_id: number, motion: Partial<PeerState>): void {
    const peer = this.connections.get_peer(peer_id);
    if (!peer || !peer.authorized) return;

    // Motion updates are frequent and unreliable-ordered
    this.connections.update_peer_state(peer_id, motion);
    this.world.mark_dirty();
  }

  private handle_proximity_chat(
    peer_id: number,
    data: { sender_name: string; message: string; chat_type: ChatType }
  ): void {
    const sender = this.connections.get_peer(peer_id);
    if (!sender || !sender.authorized) return;

    const { sender_name, message, chat_type } = data;
    const all_peers = this.connections.get_all_peers();

    // Determine who can hear this message
    for (const receiver of all_peers) {
      if (receiver.peer_id === peer_id) continue; // Don't echo back to sender

      if (this.world.can_hear_chat(sender.state, receiver.state, chat_type)) {
        this.send_to_peer(receiver.peer_id, {
          type: 'receive_proximity_chat',
          data: { sender_name, message, chat_type }
        });
      }
    }
  }

  private handle_chat(peer_id: number, data: { sender_name: string; message: string }): void {
    const sender = this.connections.get_peer(peer_id);
    if (!sender || !sender.authorized) return;

    // Global chat - broadcast to all
    const all_peers = this.connections.get_all_peers();
    for (const receiver of all_peers) {
      if (receiver.peer_id === peer_id) continue;

      this.send_to_peer(receiver.peer_id, {
        type: 'receive_chat',
        data: data
      });
    }
  }

  send_to_peer(peer_id: number, message: GodotMessage): void {
    const peer = this.connections.get_peer(peer_id);
    if (!peer) return;

    try {
      const json = JSON.stringify(message);
      peer.ws.send(json);
    } catch (err) {
      console.error(`Failed to send to peer ${peer_id}:`, err);
    }
  }

  broadcast_snapshot(): void {
    const all_peers = this.connections.get_all_peers();
    const snapshot = this.world.create_snapshot(all_peers.map(p => p.state));

    for (const peer of all_peers) {
      if (!peer.authorized) continue;

      this.send_to_peer(peer.peer_id, {
        type: 'receive_snapshot',
        data: snapshot.peers
      });
    }

    this.world.mark_snapshot_sent(Date.now());
  }

  broadcast_population(): void {
    const population = this.connections.get_population();
    const capacity = this.connections.get_capacity();

    const all_peers = this.connections.get_all_peers();
    for (const peer of all_peers) {
      if (!peer.authorized) continue;

      this.send_to_peer(peer.peer_id, {
        type: 'server_population_update',
        data: { population, capacity }
      });
    }
  }

  send_connection_accepted(peer_id: number): void {
    this.send_to_peer(peer_id, {
      type: 'connection_accepted',
      data: {
        peer_id,
        world_id: MAIN_WORLD_ID,
        protocol: PROTOCOL_VERSION,
      }
    });
  }
}
