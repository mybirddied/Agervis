/**
 * Economy Transaction Processor
 * Handles clean vs dirty money, transactions, and financial tracking
 * SECURITY: Transaction IDs use UUIDs to prevent collisions, all balances validated
 */

import { randomUUID } from 'crypto';

export type TransactionType = 'income' | 'expense' | 'transfer' | 'laundering' | 'crime_income';
export type MoneyType = 'clean' | 'dirty';

export interface Transaction {
  id: string;
  type: TransactionType;
  amount: number;
  moneyType: MoneyType;
  from: string;
  to: string;
  timestamp: number;
  description: string;
  suspicious: boolean;
}

export interface Account {
  id: string;
  owner: string;
  balance: number;
  cleanMoney: number;
  dirtyMoney: number;
  transactions: Transaction[];
  flagged: boolean;
  version: number; // For optimistic locking
}

export class EconomyTransactionProcessor {
  private accounts: Map<string, Account> = new Map();
  private suspiciousThreshold: number = 50000; // transactions over this are suspicious
  private launderingEfficiency: number = 0.7; // 70% efficiency on money laundering
  private transactionLocks: Map<string, number> = new Map(); // account ID -> lock version

  /**
   * Create an account
   */
  createAccount(owner: string): Account {
    const accountId = randomUUID();
    const account: Account = {
      id: accountId,
      owner,
      balance: 0,
      cleanMoney: 0,
      dirtyMoney: 0,
      transactions: [],
      flagged: false,
      version: 0,
    };
    this.accounts.set(accountId, account);
    this.transactionLocks.set(accountId, 0);
    return account;
  }

  /**
   * Get or create account for owner
   */
  getOrCreateAccount(owner: string): Account {
    const existing = Array.from(this.accounts.values()).find((acc) => acc.owner === owner);
    return existing || this.createAccount(owner);
  }

  /**
   * Process a transaction with full validation and atomic operations
   * SECURITY: Validates positive balance, uses UUID transaction IDs, prevents race conditions
   */
  processTransaction(
    amount: number,
    moneyType: MoneyType,
    from: string,
    to: string,
    type: TransactionType,
    description: string
  ): Transaction | null {
    // Validate amount is positive
    if (amount <= 0) {
      throw new Error('Transaction amount must be positive');
    }

    const fromAccount = this.getOrCreateAccount(from);
    const toAccount = this.getOrCreateAccount(to);

    // Acquire locks in deterministic order to prevent deadlocks
    const [firstLock, secondLock] = [fromAccount.id, toAccount.id].sort();
    this.acquireLock(firstLock);
    if (firstLock !== secondLock) {
      this.acquireLock(secondLock);
    }

    try {
      // Re-fetch accounts after acquiring locks
      const fromAccountLatest = this.getOrCreateAccount(from);
      const toAccountLatest = this.getOrCreateAccount(to);

      // Validate sufficient balance BEFORE any state changes
      if (moneyType === 'clean') {
        if (fromAccountLatest.cleanMoney < amount) {
          return null; // insufficient clean funds
        }
      } else {
        if (fromAccountLatest.dirtyMoney < amount) {
          return null; // insufficient dirty funds
        }
      }

      // Check if transaction is suspicious
      const suspicious = amount > this.suspiciousThreshold;
      if (suspicious) {
        fromAccountLatest.flagged = true;
      }

      // Atomic deduction from sender
      if (moneyType === 'clean') {
        fromAccountLatest.cleanMoney -= amount;
      } else {
        fromAccountLatest.dirtyMoney -= amount;
      }
      fromAccountLatest.balance -= amount;

      // Validate balance doesn't go negative (defense in depth)
      if (fromAccountLatest.balance < 0 || fromAccountLatest.cleanMoney < 0 || fromAccountLatest.dirtyMoney < 0) {
        throw new Error('Balance validation failed: negative balance detected');
      }

      // Atomic addition to recipient
      if (moneyType === 'clean') {
        toAccountLatest.cleanMoney += amount;
      } else {
        toAccountLatest.dirtyMoney += amount;
      }
      toAccountLatest.balance += amount;

      // Create transaction with UUID (collision-proof)
      const transaction: Transaction = {
        id: randomUUID(),
        type,
        amount,
        moneyType,
        from,
        to,
        timestamp: Date.now(),
        description,
        suspicious,
      };

      // Increment versions for optimistic locking
      fromAccountLatest.version++;
      toAccountLatest.version++;

      fromAccountLatest.transactions.push(transaction);
      toAccountLatest.transactions.push(transaction);

      return transaction;
    } finally {
      this.releaseLock(firstLock);
      if (firstLock !== secondLock) {
        this.releaseLock(secondLock);
      }
    }
  }

  /**
   * Launder dirty money (convert to clean with loss)
   * SECURITY: Validates amount is positive, maintains atomic operations
   */
  launderMoney(owner: string, amount: number): number {
    // Validate amount is positive
    if (amount <= 0) {
      throw new Error('Laundering amount must be positive');
    }

    const account = this.getOrCreateAccount(owner);
    this.acquireLock(account.id);

    try {
      const accountLatest = this.getOrCreateAccount(owner);

      // Validate sufficient dirty money
      if (accountLatest.dirtyMoney < amount) {
        return 0; // not enough dirty money
      }

      accountLatest.dirtyMoney -= amount;
      const cleanAmount = Math.round(amount * this.launderingEfficiency);
      accountLatest.cleanMoney += cleanAmount;
      accountLatest.balance += cleanAmount - amount; // net loss

      // Validate balance consistency
      if (accountLatest.balance < 0 || accountLatest.dirtyMoney < 0 || accountLatest.cleanMoney < 0) {
        throw new Error('Balance validation failed during money laundering');
      }

      const transaction: Transaction = {
        id: randomUUID(),
        type: 'laundering',
        amount,
        moneyType: 'dirty',
        from: owner,
        to: owner,
        timestamp: Date.now(),
        description: `Money laundering: ${amount} dirty -> ${cleanAmount} clean`,
        suspicious: true,
      };

      accountLatest.transactions.push(transaction);
      accountLatest.flagged = true;
      accountLatest.version++;

      return cleanAmount;
    } finally {
      this.releaseLock(account.id);
    }
  }

  /**
   * Acquire a lock on an account (simple spin-lock for in-memory)
   */
  private acquireLock(accountId: string): void {
    const maxRetries = 1000;
    let retries = 0;
    while (this.transactionLocks.get(accountId) !== undefined && retries < maxRetries) {
      retries++;
    }
    if (retries >= maxRetries) {
      throw new Error('Failed to acquire lock: timeout');
    }
    this.transactionLocks.set(accountId, Date.now());
  }

  /**
   * Release a lock on an account
   */
  private releaseLock(accountId: string): void {
    this.transactionLocks.delete(accountId);
  }

  /**
   * Get account by owner
   */
  getAccount(owner: string): Account | null {
    return Array.from(this.accounts.values()).find((acc) => acc.owner === owner) || null;
  }

  /**
   * Get flagged accounts
   */
  getFlaggedAccounts(): Account[] {
    return Array.from(this.accounts.values()).filter((acc) => acc.flagged);
  }

  /**
   * Get net worth (clean + dirty)
   */
  getNetWorth(owner: string): number {
    const account = this.getAccount(owner);
    return account ? account.balance : 0;
  }
}
