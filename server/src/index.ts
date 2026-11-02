import { AgervisServer } from './server/AgervisServer.js';
import * as dotenv from 'dotenv';

dotenv.config();

const PORT = parseInt(process.env.PORT || '10813', 10);
const MAX_PLAYERS = parseInt(process.env.MAX_PLAYERS || '25', 10);
const WORLD_ID = process.env.WORLD_ID || 'AGERVIS-MAIN-FIRST-BLOCK';

const server = new AgervisServer({
  port: PORT,
  max_players: MAX_PLAYERS,
  world_id: WORLD_ID,
});

server.start();

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n[Agervis] Shutting down gracefully...');
  server.stop();
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n[Agervis] Shutting down gracefully...');
  server.stop();
  process.exit(0);
});
