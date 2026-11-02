// BYOK Key Manager
// Handles encryption, storage, retrieval, and validation of player API keys

import EncryptionService from './aes256';
import type Database from 'better-sqlite3';

export interface BYOKKeyRecord {
  id: string;
  playerId: string;
  encryptedKeyBlob: string;
  keyHash: string;
  createdAt: Date;
  lastUsed: Date;
  isActive: boolean;
  providerUrl: string;
  metadata: Record<string, any>;
}

export class BYOKKeyManager {
  private encryption: EncryptionService;
  private db: Database.Database;

  constructor(db: Database.Database, encryptionService: EncryptionService) {
    this.db = db;
    this.encryption = encryptionService;
  }

  /**
   * Store a player's BYOK API key (encrypted)
   */
  storePlayerKey(
    playerId: string,
    apiKey: string,
    providerUrl: string = 'https://api.anthropic.com',
    metadata: Record<string, any> = {}
  ): BYOKKeyRecord {
    // Validate API key format
    if (!this.validateApiKey(apiKey)) {
      throw new Error('Invalid API key format');
    }

    const now = new Date();
    const keyHash = this.encryption.generateValidationHash(apiKey);
    const encryptedKeyBlob = this.encryption.encryptToHex(apiKey, playerId);

    const stmt = this.db.prepare(`
      INSERT INTO api_keys_byok (player_id, encrypted_key_blob, key_hash, created_at, last_used, is_active, provider_url, metadata)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);

    stmt.run(playerId, encryptedKeyBlob, keyHash, now.toISOString(), now.toISOString(), 1, providerUrl, JSON.stringify(metadata));

    return {
      id: playerId,
      playerId,
      encryptedKeyBlob,
      keyHash,
      createdAt: now,
      lastUsed: now,
      isActive: true,
      providerUrl,
      metadata,
    };
  }

  /**
   * Retrieve a player's BYOK API key (decrypted in-memory)
   */
  getPlayerKey(playerId: string): string | null {
    const stmt = this.db.prepare(`
      SELECT encrypted_key_blob FROM api_keys_byok
      WHERE player_id = ? AND is_active = 1
      ORDER BY last_used DESC
      LIMIT 1
    `);

    const row: any = stmt.get(playerId);
    if (!row) {
      return null;
    }

    try {
      // Decrypt only in-memory, never store plaintext
      return this.encryption.decryptFromHex(row.encrypted_key_blob, playerId);
    } catch (error) {
      console.error(`Failed to decrypt key for player ${playerId}:`, error);
      return null;
    }
  }

  /**
   * Validate that a stored key matches the validation hash
   */
  validateStoredKey(playerId: string, apiKey: string): boolean {
    const stmt = this.db.prepare(`
      SELECT key_hash FROM api_keys_byok
      WHERE player_id = ? AND is_active = 1
      LIMIT 1
    `);

    const row: any = stmt.get(playerId);
    if (!row) {
      return false;
    }

    try {
      return this.encryption.verifyValidationHash(apiKey, row.key_hash);
    } catch (error) {
      return false;
    }
  }

  /**
   * Update last_used timestamp when key is used
   */
  updateKeyUsage(playerId: string): void {
    const stmt = this.db.prepare(`
      UPDATE api_keys_byok
      SET last_used = ?
      WHERE player_id = ? AND is_active = 1
    `);

    stmt.run(new Date().toISOString(), playerId);
  }

  /**
   * Rotate player's API key (re-encrypt old key with new one, or replace)
   */
  rotatePlayerKey(playerId: string, newApiKey: string, providerUrl?: string): BYOKKeyRecord {
    // Validate new key
    if (!this.validateApiKey(newApiKey)) {
      throw new Error('Invalid new API key format');
    }

    // Deactivate old key
    const deactivateStmt = this.db.prepare(`
      UPDATE api_keys_byok
      SET is_active = 0
      WHERE player_id = ? AND is_active = 1
    `);
    deactivateStmt.run(playerId);

    // Store new key
    return this.storePlayerKey(playerId, newApiKey, providerUrl);
  }

  /**
   * Check if player has BYOK enabled
   */
  hasPlayerKey(playerId: string): boolean {
    const stmt = this.db.prepare(`
      SELECT 1 FROM api_keys_byok
      WHERE player_id = ? AND is_active = 1
      LIMIT 1
    `);

    return stmt.get(playerId) !== undefined;
  }

  /**
   * Get provider URL for player (custom base_url)
   */
  getPlayerProviderUrl(playerId: string): string {
    const stmt = this.db.prepare(`
      SELECT provider_url FROM api_keys_byok
      WHERE player_id = ? AND is_active = 1
      LIMIT 1
    `);

    const row: any = stmt.get(playerId);
    return row?.provider_url || 'https://api.anthropic.com';
  }

  /**
   * Revoke all keys for a player
   */
  revokeAllKeys(playerId: string): void {
    const stmt = this.db.prepare(`
      UPDATE api_keys_byok
      SET is_active = 0
      WHERE player_id = ?
    `);

    stmt.run(playerId);
  }

  /**
   * Get BYOK statistics for dashboard
   */
  getBYOKStats(): { totalPlayers: number; activeKeys: number; totalUsageToday: number } {
    const activeStmt = this.db.prepare(`
      SELECT COUNT(DISTINCT player_id) as count FROM api_keys_byok WHERE is_active = 1
    `);

    const activeRow: any = activeStmt.get();

    return {
      totalPlayers: activeRow?.count || 0,
      activeKeys: activeRow?.count || 0,
      totalUsageToday: 0, // Will be populated by token tracker
    };
  }

  /**
   * Validate API key format (Anthropic keys start with 'sk-ant-')
   */
  private validateApiKey(apiKey: string): boolean {
    return apiKey.startsWith('sk-ant-') && apiKey.length > 20 && apiKey.length < 500;
  }
}

export default BYOKKeyManager;
