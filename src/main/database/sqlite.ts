/**
 * SQLite Database Layer
 * Handles persistence with automatic migrations
 */

import Database from 'better-sqlite3';
import { EventEmitter } from 'events';
import * as fs from 'fs';
import * as path from 'path';

export interface DatabaseConfig {
  filename: string;
  readonly?: boolean;
  fileMustExist?: boolean;
  timeout?: number;
  verbose?: boolean;
}

export class SQLiteDatabase extends EventEmitter {
  private db: Database.Database | null = null;
  private config: DatabaseConfig;
  private isInitialized: boolean = false;
  private migrations: Map<number, string> = new Map();

  constructor(config: DatabaseConfig) {
    super();
    this.config = {
      timeout: 5000,
      readonly: false,
      fileMustExist: false,
      ...config,
    };
  }

  /**
   * Initialize database connection
   */
  initialize(): void {
    if (this.isInitialized) return;

    try {
      this.db = new Database(this.config.filename, {
        readonly: this.config.readonly,
        fileMustExist: this.config.fileMustExist,
        timeout: this.config.timeout,
      });

      // Enable foreign keys
      this.db.pragma('foreign_keys = ON');
      this.db.pragma('journal_mode = WAL');

      this.isInitialized = true;
      this.emit('initialized');
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }

  /**
   * Execute raw SQL
   */
  exec(sql: string): void {
    if (!this.db) throw new Error('Database not initialized');
    this.db.exec(sql);
  }

  /**
   * Prepare and execute statement
   */
  prepare(sql: string) {
    if (!this.db) throw new Error('Database not initialized');
    return this.db.prepare(sql);
  }

  /**
   * Run a transaction
   */
  transaction<T>(callback: () => T): T {
    if (!this.db) throw new Error('Database not initialized');

    const transactionFn = this.db.transaction(callback);
    return transactionFn();
  }

  /**
   * Register migration
   */
  registerMigration(version: number, sql: string): void {
    this.migrations.set(version, sql);
  }

  /**
   * Run migrations
   */
  runMigrations(): void {
    if (!this.db) throw new Error('Database not initialized');

    try {
      // Create migrations table if not exists
      this.db.exec(`
        CREATE TABLE IF NOT EXISTS _migrations (
          id INTEGER PRIMARY KEY,
          version INTEGER UNIQUE NOT NULL,
          appliedAt DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      `);

      // Get applied migrations
      const appliedStmt = this.db.prepare(
        'SELECT version FROM _migrations ORDER BY version'
      );
      const applied = new Set(
        appliedStmt.all().map((row: any) => row.version)
      );

      // Apply pending migrations
      const sortedMigrations = Array.from(this.migrations.entries()).sort(
        (a, b) => a[0] - b[0]
      );

      for (const [version, sql] of sortedMigrations) {
        if (!applied.has(version)) {
          this.transaction(() => {
            this.db!.exec(sql);
            const insertStmt = this.db!.prepare(
              'INSERT INTO _migrations (version) VALUES (?)'
            );
            insertStmt.run(version);
          });

          this.emit('migration-applied', { version });
        }
      }

      this.emit('migrations-complete');
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }

  /**
   * Create table helper
   */
  createTable(
    name: string,
    columns: Record<string, string>,
    options?: { ifNotExists?: boolean }
  ): void {
    if (!this.db) throw new Error('Database not initialized');

    const columnDefs = Object.entries(columns)
      .map(([name, type]) => `${name} ${type}`)
      .join(', ');

    const ifNotExists = options?.ifNotExists ? 'IF NOT EXISTS' : '';
    const sql = `CREATE TABLE ${ifNotExists} ${name} (${columnDefs})`;

    this.db.exec(sql);
    this.emit('table-created', { table: name });
  }

  /**
   * Create index
   */
  createIndex(
    name: string,
    table: string,
    columns: string[],
    options?: { unique?: boolean; ifNotExists?: boolean }
  ): void {
    if (!this.db) throw new Error('Database not initialized');

    const unique = options?.unique ? 'UNIQUE' : '';
    const ifNotExists = options?.ifNotExists ? 'IF NOT EXISTS' : '';
    const columnList = columns.join(', ');

    const sql = `CREATE ${unique} INDEX ${ifNotExists} ${name} ON ${table} (${columnList})`;
    this.db.exec(sql);

    this.emit('index-created', { index: name, table });
  }

  /**
   * Backup database
   */
  backup(targetPath: string): void {
    if (!this.db) throw new Error('Database not initialized');

    const backupDb = new Database(targetPath);
    this.db.backup(backupDb);
    backupDb.close();

    this.emit('backup-created', { path: targetPath });
  }

  /**
   * Get database stats
   */
  getStats() {
    if (!this.db) throw new Error('Database not initialized');

    const pageCount = this.db.pragma('page_count', { simple: true });
    const pageSize = this.db.pragma('page_size', { simple: true });

    return {
      filename: this.config.filename,
      pageCount,
      pageSize,
      sizeBytes: (pageCount as number) * (pageSize as number),
      isInitialized: this.isInitialized,
    };
  }

  /**
   * Close database
   */
  close(): void {
    if (this.db) {
      this.db.close();
      this.db = null;
      this.isInitialized = false;
      this.emit('closed');
    }
  }

  isConnected(): boolean {
    return this.isInitialized && this.db !== null;
  }
}
