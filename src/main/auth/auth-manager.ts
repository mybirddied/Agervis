/**
 * Authentication Manager
 * Handles token generation, validation, and session management
 */

import { randomBytes, createHash, timingSafeEqual } from 'crypto';
import { SQLiteDatabase } from '../database/sqlite';

export interface AuthToken {
  token: string;
  adminId: string;
  expiresAt: Date;
  createdAt: Date;
}

export interface AdminAccount {
  id: string;
  username: string;
  passwordHash: string;
  role: 'admin' | 'viewer';
  createdAt: Date;
  lastLogin: Date | null;
  isActive: boolean;
}

export class AuthManager {
  private db: SQLiteDatabase;
  private sessions: Map<string, AuthToken> = new Map();

  constructor(db: SQLiteDatabase) {
    this.db = db;
  }

  async createAdmin(
    username: string,
    password: string,
    role: 'admin' | 'viewer' = 'admin'
  ): Promise<string> {
    const id = this.generateId();
    const passwordHash = this.hashPassword(password);
    const createdAt = new Date().toISOString();

    await this.db.execute(
      `INSERT INTO admin_accounts (id, username, password_hash, role, created_at, is_active)
       VALUES (?, ?, ?, ?, ?, 1)`,
      [id, username, passwordHash, role, createdAt]
    );

    return id;
  }

  async authenticate(username: string, password: string): Promise<string | null> {
    const admin = await this.db.queryOne<AdminAccount>(
      `SELECT * FROM admin_accounts WHERE username = ? AND is_active = 1`,
      [username]
    );

    if (!admin) {
      return null;
    }

    const providedHash = this.hashPassword(password);
    const storedHash = Buffer.from(admin.passwordHash, 'hex');
    const providedBuffer = Buffer.from(providedHash, 'hex');

    if (storedHash.length !== providedBuffer.length ||
        !timingSafeEqual(storedHash, providedBuffer)) {
      return null;
    }

    await this.db.execute(
      `UPDATE admin_accounts SET last_login = ? WHERE id = ?`,
      [new Date().toISOString(), admin.id]
    );

    const token = this.generateToken();
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

    await this.db.execute(
      `INSERT INTO auth_sessions (token, admin_id, expires_at, created_at)
       VALUES (?, ?, ?, ?)`,
      [token, admin.id, expiresAt.toISOString(), new Date().toISOString()]
    );

    this.sessions.set(token, {
      token,
      adminId: admin.id,
      expiresAt,
      createdAt: new Date(),
    });

    return token;
  }

  async validateToken(token: string): Promise<AdminAccount | null> {
    let session = this.sessions.get(token);

    if (!session) {
      const dbSession = await this.db.queryOne<{
        token: string;
        admin_id: string;
        expires_at: string;
        created_at: string;
      }>(
        `SELECT * FROM auth_sessions WHERE token = ? AND expires_at > datetime('now')`,
        [token]
      );

      if (!dbSession) {
        return null;
      }

      session = {
        token: dbSession.token,
        adminId: dbSession.admin_id,
        expiresAt: new Date(dbSession.expires_at),
        createdAt: new Date(dbSession.created_at),
      };

      this.sessions.set(token, session);
    }

    if (session.expiresAt < new Date()) {
      this.sessions.delete(token);
      await this.db.execute(`DELETE FROM auth_sessions WHERE token = ?`, [token]);
      return null;
    }

    const admin = await this.db.queryOne<AdminAccount>(
      `SELECT * FROM admin_accounts WHERE id = ? AND is_active = 1`,
      [session.adminId]
    );

    return admin || null;
  }

  async revokeToken(token: string): Promise<void> {
    this.sessions.delete(token);
    await this.db.execute(`DELETE FROM auth_sessions WHERE token = ?`, [token]);
  }

  async revokeAllTokensForAdmin(adminId: string): Promise<void> {
    for (const [token, session] of this.sessions.entries()) {
      if (session.adminId === adminId) {
        this.sessions.delete(token);
      }
    }
    await this.db.execute(`DELETE FROM auth_sessions WHERE admin_id = ?`, [adminId]);
  }

  async cleanupExpiredSessions(): Promise<void> {
    const now = new Date();
    for (const [token, session] of this.sessions.entries()) {
      if (session.expiresAt < now) {
        this.sessions.delete(token);
      }
    }

    await this.db.execute(
      `DELETE FROM auth_sessions WHERE expires_at < datetime('now')`
    );
  }

  private generateToken(): string {
    return randomBytes(32).toString('hex');
  }

  private generateId(): string {
    return randomBytes(16).toString('hex');
  }

  private hashPassword(password: string): string {
    return createHash('sha256').update(password).digest('hex');
  }

  async changePassword(adminId: string, newPassword: string): Promise<void> {
    const passwordHash = this.hashPassword(newPassword);
    await this.db.execute(
      `UPDATE admin_accounts SET password_hash = ? WHERE id = ?`,
      [passwordHash, adminId]
    );
    await this.revokeAllTokensForAdmin(adminId);
  }

  async updateAdminRole(adminId: string, role: 'admin' | 'viewer'): Promise<void> {
    await this.db.execute(
      `UPDATE admin_accounts SET role = ? WHERE id = ?`,
      [role, adminId]
    );
  }

  async deactivateAdmin(adminId: string): Promise<void> {
    await this.db.execute(
      `UPDATE admin_accounts SET is_active = 0 WHERE id = ?`,
      [adminId]
    );
    await this.revokeAllTokensForAdmin(adminId);
  }
}
