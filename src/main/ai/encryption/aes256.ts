// AES-256-GCM Encryption Module
// Handles BYOK API key encryption, decryption, and validation

import crypto from 'node:crypto';
import { ENCRYPTION_CONFIG } from '../constants/ai';

export interface EncryptedData {
  ciphertext: Buffer;
  iv: Buffer;
  authTag: Buffer;
  salt: Buffer;
}

export class EncryptionService {
  private masterKey: Buffer;

  constructor(masterKeyHex: string) {
    if (!masterKeyHex || masterKeyHex.length < 64) {
      throw new Error('Master key must be at least 32 bytes (64 hex characters)');
    }
    this.masterKey = Buffer.from(masterKeyHex.substring(0, 64), 'hex');
  }

  /**
   * Encrypt data with AES-256-GCM
   */
  encrypt(plaintext: string, associatedData?: string): EncryptedData {
    const salt = crypto.randomBytes(ENCRYPTION_CONFIG.SALT_LENGTH);
    const derivedKey = crypto.pbkdf2Sync(
      this.masterKey,
      salt,
      ENCRYPTION_CONFIG.ITERATIONS,
      ENCRYPTION_CONFIG.KEY_LENGTH,
      ENCRYPTION_CONFIG.DIGEST
    );

    const iv = crypto.randomBytes(ENCRYPTION_CONFIG.IV_LENGTH);
    const cipher = crypto.createCipheriv(ENCRYPTION_CONFIG.ALGORITHM, derivedKey, iv);

    if (associatedData) {
      cipher.setAAD(Buffer.from(associatedData, 'utf-8'));
    }

    let ciphertext = cipher.update(plaintext, 'utf-8');
    ciphertext = Buffer.concat([ciphertext, cipher.final()]);

    const authTag = cipher.getAuthTag();

    return {
      ciphertext,
      iv,
      authTag,
      salt,
    };
  }

  /**
   * Decrypt data encrypted with AES-256-GCM
   */
  decrypt(encryptedData: EncryptedData, associatedData?: string): string {
    const derivedKey = crypto.pbkdf2Sync(
      this.masterKey,
      encryptedData.salt,
      ENCRYPTION_CONFIG.ITERATIONS,
      ENCRYPTION_CONFIG.KEY_LENGTH,
      ENCRYPTION_CONFIG.DIGEST
    );

    const decipher = crypto.createDecipheriv(
      ENCRYPTION_CONFIG.ALGORITHM,
      derivedKey,
      encryptedData.iv
    );

    decipher.setAuthTag(encryptedData.authTag);

    if (associatedData) {
      decipher.setAAD(Buffer.from(associatedData, 'utf-8'));
    }

    let plaintext = decipher.update(encryptedData.ciphertext);
    plaintext = Buffer.concat([plaintext, decipher.final()]);

    return plaintext.toString('utf-8');
  }

  /**
   * Encrypt to hex string (for storage)
   */
  encryptToHex(plaintext: string, associatedData?: string): string {
    const encrypted = this.encrypt(plaintext, associatedData);
    const combined = Buffer.concat([
      encrypted.salt,
      encrypted.iv,
      encrypted.authTag,
      encrypted.ciphertext,
    ]);
    return combined.toString('hex');
  }

  /**
   * Decrypt from hex string (from storage)
   */
  decryptFromHex(hexData: string, associatedData?: string): string {
    const buffer = Buffer.from(hexData, 'hex');
    let offset = 0;

    const salt = buffer.subarray(offset, (offset += ENCRYPTION_CONFIG.SALT_LENGTH));
    const iv = buffer.subarray(offset, (offset += ENCRYPTION_CONFIG.IV_LENGTH));
    const authTag = buffer.subarray(offset, (offset += ENCRYPTION_CONFIG.AUTH_TAG_LENGTH));
    const ciphertext = buffer.subarray(offset);

    return this.decrypt({ salt, iv, authTag, ciphertext }, associatedData);
  }

  /**
   * Generate a validation hash of plaintext (for quick validation without decryption)
   */
  generateValidationHash(plaintext: string): string {
    return crypto.createHash('sha256').update(plaintext).digest('hex');
  }

  /**
   * Verify plaintext matches validation hash
   */
  verifyValidationHash(plaintext: string, hash: string): boolean {
    const computedHash = this.generateValidationHash(plaintext);
    return crypto.timingSafeEqual(Buffer.from(computedHash), Buffer.from(hash));
  }

  /**
   * Rotate master key (re-encrypt all data with new key)
   */
  rotateKey(newMasterKeyHex: string, encryptedDataList: string[]): string[] {
    const decrypted = encryptedDataList.map((hexData) => this.decryptFromHex(hexData));

    const newService = new EncryptionService(newMasterKeyHex);
    this.masterKey = Buffer.from(newMasterKeyHex.substring(0, 64), 'hex');

    return decrypted.map((plaintext) => newService.encryptToHex(plaintext));
  }

  /**
   * Generate a secure random encryption key
   */
  static generateMasterKey(): string {
    return crypto.randomBytes(32).toString('hex');
  }

  /**
   * Verify API key format (basic validation)
   */
  static validateApiKeyFormat(apiKey: string): boolean {
    // Anthropic keys typically start with 'sk-ant-' and are reasonably long
    return apiKey.startsWith('sk-ant-') && apiKey.length > 20;
  }
}

export default EncryptionService;
