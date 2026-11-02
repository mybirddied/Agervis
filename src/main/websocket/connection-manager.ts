/**
 * Connection Manager
 * Manages WebSocket client connections with heartbeat monitoring and reconnection handling
 */

import { EventEmitter } from 'events';

export interface ClientConnection {
  clientId: string;
  playerId?: string;
  connectedAt: number;
  lastHeartbeat: number;
  latency: number;
  isAlive: boolean;
  sequenceId: number;
  metadata: Record<string, unknown>;
}

export class ConnectionManager extends EventEmitter {
  private connections: Map<string, ClientConnection> = new Map();
  private heartbeatInterval: NodeJS.Timer | null = null;
  private heartbeatTimeout: number = 30000; // 30 seconds
  private checkInterval: number = 5000; // Check every 5 seconds

  constructor() {
    super();
  }

  addConnection(clientId: string, playerId?: string): ClientConnection {
    const now = Date.now();
    const connection: ClientConnection = {
      clientId,
      playerId,
      connectedAt: now,
      lastHeartbeat: now,
      latency: 0,
      isAlive: true,
      sequenceId: 0,
      metadata: {},
    };

    this.connections.set(clientId, connection);
    this.emit('connection-added', { clientId, playerId });

    if (!this.heartbeatInterval) {
      this.startHeartbeatMonitoring();
    }

    return connection;
  }

  removeConnection(clientId: string): boolean {
    const connection = this.connections.get(clientId);
    if (!connection) return false;

    this.connections.delete(clientId);
    this.emit('connection-removed', { clientId });

    if (this.connections.size === 0 && this.heartbeatInterval) {
      this.stopHeartbeatMonitoring();
    }

    return true;
  }

  getConnection(clientId: string): ClientConnection | null {
    return this.connections.get(clientId) || null;
  }

  getAllConnections(): ClientConnection[] {
    return Array.from(this.connections.values());
  }

  getConnectionCount(): number {
    return this.connections.size;
  }

  updateHeartbeat(clientId: string, latency: number = 0): boolean {
    const connection = this.connections.get(clientId);
    if (!connection) return false;

    connection.lastHeartbeat = Date.now();
    connection.latency = latency;
    connection.isAlive = true;

    return true;
  }

  incrementSequence(clientId: string): number {
    const connection = this.connections.get(clientId);
    if (!connection) return 0;

    connection.sequenceId++;
    return connection.sequenceId;
  }

  setMetadata(clientId: string, key: string, value: unknown): boolean {
    const connection = this.connections.get(clientId);
    if (!connection) return false;

    connection.metadata[key] = value;
    return true;
  }

  private startHeartbeatMonitoring(): void {
    this.heartbeatInterval = setInterval(() => {
      this.checkHeartbeats();
    }, this.checkInterval);
  }

  private stopHeartbeatMonitoring(): void {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }

  private checkHeartbeats(): void {
    const now = Date.now();
    const deadConnections: string[] = [];

    this.connections.forEach((connection, clientId) => {
      const timeSinceHeartbeat = now - connection.lastHeartbeat;

      if (timeSinceHeartbeat > this.heartbeatTimeout) {
        deadConnections.push(clientId);
        this.emit('heartbeat-timeout', { clientId });
      }
    });

    deadConnections.forEach((clientId) => {
      this.removeConnection(clientId);
    });
  }

  setHeartbeatTimeout(timeout: number): void {
    this.heartbeatTimeout = timeout;
  }

  setCheckInterval(interval: number): void {
    this.checkInterval = interval;

    if (this.heartbeatInterval) {
      this.stopHeartbeatMonitoring();
      this.startHeartbeatMonitoring();
    }
  }

  clear(): void {
    this.stopHeartbeatMonitoring();
    this.connections.clear();
    this.emit('connections-cleared');
  }

  getStatistics() {
    return {
      totalConnections: this.connections.size,
      connectedAt: Array.from(this.connections.values()).map(
        (c) => c.connectedAt
      ),
      avgLatency:
        this.connections.size > 0
          ? Array.from(this.connections.values()).reduce(
              (sum, c) => sum + c.latency,
              0
            ) / this.connections.size
          : 0,
      aliveCount: Array.from(this.connections.values()).filter(
        (c) => c.isAlive
      ).length,
    };
  }
}
