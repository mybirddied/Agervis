/**
 * Server Core Integration Tests
 * Validates all Phase 0 components working together
 */

import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import AgervisServer from '../game-server';

describe('Agervis Server Core - Phase 0', () => {
  let server: AgervisServer;

  beforeAll(async () => {
    server = new AgervisServer({
      dbPath: ':memory:', // Use in-memory database for tests
      port: 10814, // Use alternate port for testing
    });

    await server.initialize();
  });

  afterAll(async () => {
    await server.stop();
  });

  describe('Server Initialization', () => {
    it('should initialize all core components', () => {
      expect(server).toBeDefined();
      expect(server.getConnectionManager()).toBeDefined();
      expect(server.getWorldState()).toBeDefined();
      expect(server.getEventBus()).toBeDefined();
      expect(server.getDatabase()).toBeDefined();
      expect(server.getConfigManager()).toBeDefined();
      expect(server.getHealthCheck()).toBeDefined();
      expect(server.getRateLimiter()).toBeDefined();
    });

    it('should load configuration', () => {
      const config = server.getConfigManager().getConfig();
      expect(config.server).toBeDefined();
      expect(config.server.port).toBeGreaterThan(0);
      expect(config.database).toBeDefined();
      expect(config.websocket).toBeDefined();
      expect(config.gameLogic).toBeDefined();
      expect(config.rateLimit).toBeDefined();
    });

    it('should validate configuration', () => {
      const validation = server.getConfigManager().validate();
      expect(validation.valid).toBe(true);
      expect(validation.errors.length).toBe(0);
    });

    it('should initialize database', () => {
      expect(server.getDatabase().isConnected()).toBe(true);
    });
  });

  describe('Connection Manager', () => {
    it('should add and remove connections', () => {
      const manager = server.getConnectionManager();
      const conn = manager.addConnection('test-client-1', 'player-1');

      expect(conn).toBeDefined();
      expect(conn.clientId).toBe('test-client-1');
      expect(conn.playerId).toBe('player-1');
      expect(manager.getConnectionCount()).toBe(1);

      manager.removeConnection('test-client-1');
      expect(manager.getConnectionCount()).toBe(0);
    });

    it('should track heartbeats', () => {
      const manager = server.getConnectionManager();
      manager.addConnection('test-client-2');

      const before = manager.getConnection('test-client-2');
      expect(before?.lastHeartbeat).toBeGreaterThan(0);

      manager.updateHeartbeat('test-client-2', 25);
      const after = manager.getConnection('test-client-2');
      expect(after?.latency).toBe(25);
      expect(after!.lastHeartbeat).toBeGreaterThanOrEqual(before!.lastHeartbeat);
    });

    it('should provide statistics', () => {
      const manager = server.getConnectionManager();
      manager.addConnection('test-client-3');

      const stats = manager.getStatistics();
      expect(stats.totalConnections).toBe(1);
      expect(stats.avgLatency).toBeGreaterThanOrEqual(0);
    });
  });

  describe('World State Manager', () => {
    it('should update entities', () => {
      const worldState = server.getWorldState();
      const entity = worldState.updateEntity({
        id: 'entity-1',
        type: 'player',
        position: { x: 10, y: 20, z: 30 },
      });

      expect(entity).toBeDefined();
      expect(entity.id).toBe('entity-1');
      expect(entity.position.x).toBe(10);
      expect(entity.dirty).toBe(true);
    });

    it('should retrieve entities', () => {
      const worldState = server.getWorldState();
      const entity = worldState.getEntity('entity-1');
      expect(entity).toBeDefined();
      expect(entity?.type).toBe('player');
    });

    it('should batch update entities', () => {
      const worldState = server.getWorldState();
      const entities = worldState.batchUpdateEntities([
        { id: 'entity-2', type: 'npc', position: { x: 0, y: 0, z: 0 } },
        { id: 'entity-3', type: 'item', position: { x: 5, y: 5, z: 5 } },
      ]);

      expect(entities.length).toBe(2);
    });

    it('should filter entities by range', () => {
      const worldState = server.getWorldState();
      worldState.updateEntity({
        id: 'entity-close',
        position: { x: 1, y: 1, z: 1 },
      });

      const nearby = worldState.getEntitiesInRange({ x: 0, y: 0, z: 0 }, 2);
      expect(nearby.length).toBeGreaterThan(0);
    });

    it('should flush updates', () => {
      const worldState = server.getWorldState();
      worldState.updateEntity({ id: 'entity-flush', type: 'test' });

      const flushed = worldState.flush();
      expect(flushed.length).toBeGreaterThan(0);
    });

    it('should provide statistics', () => {
      const worldState = server.getWorldState();
      const stats = worldState.getStatistics();

      expect(stats.entityCount).toBeGreaterThanOrEqual(0);
      expect(stats.version).toBeGreaterThanOrEqual(0);
    });
  });

  describe('Event Bus', () => {
    it('should subscribe and publish events', async () => {
      const eventBus = server.getEventBus();
      let eventReceived = false;

      eventBus.subscribe('test-event', async (data) => {
        eventReceived = true;
      });

      await eventBus.publish('test-event', { test: true });
      expect(eventReceived).toBe(true);
    });

    it('should support one-time subscriptions', async () => {
      const eventBus = server.getEventBus();
      let eventCount = 0;

      eventBus.subscribeOnce('once-event', async () => {
        eventCount++;
      });

      await eventBus.publish('once-event', {});
      await eventBus.publish('once-event', {});

      expect(eventCount).toBe(1);
    });

    it('should unsubscribe from events', async () => {
      const eventBus = server.getEventBus();
      let eventCount = 0;

      const handler = async () => {
        eventCount++;
      };

      const unsubscribe = eventBus.subscribe('unsub-event', handler);
      await eventBus.publish('unsub-event', {});

      unsubscribe();
      await eventBus.publish('unsub-event', {});

      expect(eventCount).toBe(1);
    });

    it('should track event history', async () => {
      const eventBus = server.getEventBus();
      await eventBus.publish('history-event', { data: 'test' });

      const history = eventBus.getHistory('history-event', 10);
      expect(history.length).toBeGreaterThan(0);
    });

    it('should provide statistics', async () => {
      const eventBus = server.getEventBus();
      const stats = eventBus.getStatistics();

      expect(stats.totalEventTypes).toBeGreaterThanOrEqual(0);
      expect(stats.totalSubscribers).toBeGreaterThanOrEqual(0);
    });
  });

  describe('Rate Limiter', () => {
    it('should track client requests', () => {
      const rateLimiter = server.getRateLimiter();
      const allowed = rateLimiter.recordClientRequest('client-1');

      expect(allowed).toBe(true);
    });

    it('should enforce rate limits', () => {
      const rateLimiter = server.getRateLimiter();
      const config = server.getConfigManager().getConfig();

      // Fill up the limit
      for (let i = 0; i < config.rateLimit.maxRequests; i++) {
        rateLimiter.recordClientRequest('client-2');
      }

      // Next request should be blocked
      const blocked = rateLimiter.recordClientRequest('client-2');
      expect(blocked).toBe(false);
    });

    it('should reset limits', () => {
      const rateLimiter = server.getRateLimiter();
      rateLimiter.resetClient('client-2');

      const allowed = rateLimiter.recordClientRequest('client-2');
      expect(allowed).toBe(true);
    });

    it('should track IP connections', () => {
      const rateLimiter = server.getRateLimiter();
      const allowed = rateLimiter.recordIpConnection('127.0.0.1');

      expect(allowed).toBe(true);
    });

    it('should provide statistics', () => {
      const rateLimiter = server.getRateLimiter();
      const stats = rateLimiter.getStatistics();

      expect(stats.clientLimiters).toBeGreaterThanOrEqual(0);
      expect(stats.ipLimiters).toBeGreaterThanOrEqual(0);
    });
  });

  describe('Health Check System', () => {
    it('should register health checks', () => {
      const healthCheck = server.getHealthCheck();
      const initialStats = healthCheck.getStatistics();

      expect(initialStats.totalChecks).toBeGreaterThan(0);
    });

    it('should report health status', () => {
      const healthCheck = server.getHealthCheck();
      const status = healthCheck.getHealthStatus();

      expect(['healthy', 'degraded', 'unhealthy']).toContain(status);
    });

    it('should provide health report', () => {
      const healthCheck = server.getHealthCheck();
      const report = healthCheck.getHealthReport();

      expect(report.status).toBeDefined();
      expect(report.checks).toBeDefined();
      expect(report.timestamp).toBeGreaterThan(0);
    });

    it('should update metrics', () => {
      const healthCheck = server.getHealthCheck();
      healthCheck.updateMetrics(5, 10, {}, 'connected');

      const report = healthCheck.getHealthReport();
      expect(report.metrics?.activeConnections).toBe(5);
      expect(report.metrics?.pendingUpdates).toBe(10);
    });
  });

  describe('Server Status', () => {
    it('should report comprehensive status', () => {
      const status = server.getStatus();

      expect(status.isRunning).toBe(false); // Not started yet
      expect(status.config).toBeDefined();
      expect(status.connections).toBeDefined();
      expect(status.worldState).toBeDefined();
      expect(status.eventBus).toBeDefined();
      expect(status.health).toBeDefined();
      expect(status.database).toBeDefined();
      expect(status.rateLimit).toBeDefined();
    });
  });
});
