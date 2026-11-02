/**
 * Game Worker
 * Worker thread script for compute-intensive game tasks
 */

import { parentPort } from 'worker_threads';

interface WorkerTask {
  id: string;
  type: string;
  data: any;
  priority: number;
  createdAt: number;
}

interface WorkerResult {
  taskId: string;
  success: boolean;
  data?: any;
  error?: string;
  duration: number;
}

if (!parentPort) {
  throw new Error('This script must be run as a worker thread');
}

parentPort.on('message', async (task: WorkerTask) => {
  const startTime = Date.now();
  let result: WorkerResult;

  try {
    const data = await processTask(task);
    result = {
      taskId: task.id,
      success: true,
      data,
      duration: Date.now() - startTime,
    };
  } catch (error: any) {
    result = {
      taskId: task.id,
      success: false,
      error: error.message,
      duration: Date.now() - startTime,
    };
  }

  parentPort!.postMessage(result);
});

/**
 * Process different task types
 */
async function processTask(task: WorkerTask): Promise<any> {
  switch (task.type) {
    case 'pathfinding':
      return performPathfinding(task.data);

    case 'ai-decision':
      return performAIDecision(task.data);

    case 'physics-simulation':
      return performPhysicsSimulation(task.data);

    case 'world-generation':
      return performWorldGeneration(task.data);

    case 'collision-detection':
      return performCollisionDetection(task.data);

    case 'data-compression':
      return performDataCompression(task.data);

    default:
      throw new Error(`Unknown task type: ${task.type}`);
  }
}

/**
 * A* pathfinding algorithm
 */
function performPathfinding(data: {
  start: { x: number; y: number };
  end: { x: number; y: number };
  obstacles: Array<{ x: number; y: number }>;
  mapSize: { width: number; height: number };
}): { path: Array<{ x: number; y: number }>; cost: number } {
  const { start, end, obstacles, mapSize } = data;

  // Simple A* implementation
  const openSet: Array<{ pos: { x: number; y: number }; g: number; h: number; f: number; parent: any }> = [];
  const closedSet = new Set<string>();

  const heuristic = (a: { x: number; y: number }, b: { x: number; y: number }) => {
    return Math.abs(a.x - b.x) + Math.abs(a.y - b.y);
  };

  const posKey = (pos: { x: number; y: number }) => `${pos.x},${pos.y}`;

  const obstacleSet = new Set(obstacles.map(posKey));

  openSet.push({
    pos: start,
    g: 0,
    h: heuristic(start, end),
    f: heuristic(start, end),
    parent: null,
  });

  while (openSet.length > 0) {
    // Find node with lowest f score
    openSet.sort((a, b) => a.f - b.f);
    const current = openSet.shift()!;

    if (current.pos.x === end.x && current.pos.y === end.y) {
      // Reconstruct path
      const path: Array<{ x: number; y: number }> = [];
      let node = current;
      while (node) {
        path.unshift(node.pos);
        node = node.parent;
      }
      return { path, cost: current.g };
    }

    closedSet.add(posKey(current.pos));

    // Check neighbors
    const neighbors = [
      { x: current.pos.x + 1, y: current.pos.y },
      { x: current.pos.x - 1, y: current.pos.y },
      { x: current.pos.x, y: current.pos.y + 1 },
      { x: current.pos.x, y: current.pos.y - 1 },
    ];

    for (const neighbor of neighbors) {
      if (
        neighbor.x < 0 ||
        neighbor.x >= mapSize.width ||
        neighbor.y < 0 ||
        neighbor.y >= mapSize.height
      ) {
        continue;
      }

      if (closedSet.has(posKey(neighbor)) || obstacleSet.has(posKey(neighbor))) {
        continue;
      }

      const g = current.g + 1;
      const h = heuristic(neighbor, end);
      const f = g + h;

      const existing = openSet.find((n) => n.pos.x === neighbor.x && n.pos.y === neighbor.y);
      if (!existing) {
        openSet.push({
          pos: neighbor,
          g,
          h,
          f,
          parent: current,
        });
      } else if (g < existing.g) {
        existing.g = g;
        existing.f = f;
        existing.parent = current;
      }
    }
  }

  // No path found
  return { path: [], cost: Infinity };
}

/**
 * AI decision making
 */
function performAIDecision(data: {
  npcId: string;
  state: any;
  nearbyEntities: any[];
}): { action: string; target?: string; data?: any } {
  const { npcId, state, nearbyEntities } = data;

  // Simple decision tree based on NPC state
  if (state.health < 20) {
    return { action: 'flee', data: { reason: 'low-health' } };
  }

  const enemies = nearbyEntities.filter((e) => e.type === 'enemy' || e.isHostile);
  if (enemies.length > 0) {
    const closest = enemies.sort((a, b) => a.distance - b.distance)[0];
    if (closest.distance < 50) {
      return { action: 'attack', target: closest.id };
    }
  }

  const players = nearbyEntities.filter((e) => e.type === 'player');
  if (players.length > 0 && state.personality === 'friendly') {
    const closest = players[0];
    if (closest.distance < 100) {
      return { action: 'greet', target: closest.id };
    }
  }

  return { action: 'idle' };
}

/**
 * Physics simulation
 */
function performPhysicsSimulation(data: {
  entities: Array<{ id: string; x: number; y: number; vx: number; vy: number; mass: number }>;
  deltaTime: number;
}): Array<{ id: string; x: number; y: number; vx: number; vy: number }> {
  const { entities, deltaTime } = data;
  const results = [];

  for (const entity of entities) {
    // Simple physics: apply velocity
    const newX = entity.x + entity.vx * deltaTime;
    const newY = entity.y + entity.vy * deltaTime;

    // Apply gravity
    const newVy = entity.vy + 9.8 * deltaTime;

    results.push({
      id: entity.id,
      x: newX,
      y: newY,
      vx: entity.vx,
      vy: newVy,
    });
  }

  return results;
}

/**
 * Procedural world generation
 */
function performWorldGeneration(data: {
  seed: number;
  chunkX: number;
  chunkY: number;
  chunkSize: number;
}): { tiles: number[][]; objects: any[] } {
  const { seed, chunkX, chunkY, chunkSize } = data;

  // Simple noise-based generation
  const tiles: number[][] = [];
  const objects: any[] = [];

  for (let y = 0; y < chunkSize; y++) {
    const row: number[] = [];
    for (let x = 0; x < chunkSize; x++) {
      const worldX = chunkX * chunkSize + x;
      const worldY = chunkY * chunkSize + y;

      // Simple pseudo-random tile selection
      const noise = (Math.sin(worldX * 12.9898 + worldY * 78.233 + seed) * 43758.5453) % 1;

      if (noise < 0.3) {
        row.push(0); // Grass
      } else if (noise < 0.6) {
        row.push(1); // Dirt
      } else if (noise < 0.8) {
        row.push(2); // Stone
      } else {
        row.push(3); // Water
      }

      // Spawn objects randomly
      if (noise > 0.95) {
        objects.push({
          type: 'tree',
          x: worldX,
          y: worldY,
        });
      }
    }
    tiles.push(row);
  }

  return { tiles, objects };
}

/**
 * Collision detection
 */
function performCollisionDetection(data: {
  entities: Array<{ id: string; x: number; y: number; width: number; height: number }>;
}): Array<{ entity1: string; entity2: string }> {
  const { entities } = data;
  const collisions: Array<{ entity1: string; entity2: string }> = [];

  for (let i = 0; i < entities.length; i++) {
    for (let j = i + 1; j < entities.length; j++) {
      const e1 = entities[i];
      const e2 = entities[j];

      // AABB collision detection
      if (
        e1.x < e2.x + e2.width &&
        e1.x + e1.width > e2.x &&
        e1.y < e2.y + e2.height &&
        e1.y + e1.height > e2.y
      ) {
        collisions.push({
          entity1: e1.id,
          entity2: e2.id,
        });
      }
    }
  }

  return collisions;
}

/**
 * Data compression for network transfer
 */
function performDataCompression(data: { payload: any }): { compressed: string; originalSize: number; compressedSize: number } {
  const original = JSON.stringify(data.payload);
  const originalSize = Buffer.byteLength(original);

  // Simple run-length encoding for demo
  const compressed = original; // In production, use zlib or similar

  return {
    compressed,
    originalSize,
    compressedSize: Buffer.byteLength(compressed),
  };
}

console.log('[GameWorker] Worker thread initialized');
