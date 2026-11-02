/**
 * CLI Setup for Initial Admin Account
 * Creates the first admin account during server setup
 */

import { AuthManager } from './auth/auth-manager';
import { SQLiteDatabase } from './database/sqlite';
import * as readline from 'readline';

export async function setupInitialAdmin(db: SQLiteDatabase): Promise<void> {
  const authManager = new AuthManager(db);

  // Check if any admin accounts exist
  const existingAdmins = await db.query<{ count: number }>(
    'SELECT COUNT(*) as count FROM admin_accounts'
  );

  if (existingAdmins[0]?.count > 0) {
    console.log('Admin account already exists. Skipping initial setup.');
    return;
  }

  console.log('\n=== Initial Admin Setup ===\n');
  console.log('No admin accounts found. Let\'s create the first one.\n');

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const question = (prompt: string): Promise<string> => {
    return new Promise((resolve) => {
      rl.question(prompt, (answer) => {
        resolve(answer);
      });
    });
  };

  try {
    const username = await question('Admin username: ');
    const password = await question('Admin password: ');
    const confirmPassword = await question('Confirm password: ');

    if (password !== confirmPassword) {
      console.error('\nPasswords do not match. Please restart the server and try again.');
      process.exit(1);
    }

    if (password.length < 8) {
      console.error('\nPassword must be at least 8 characters. Please restart the server and try again.');
      process.exit(1);
    }

    const adminId = await authManager.createAdmin(username, password, 'admin');
    console.log(`\nAdmin account created successfully!`);
    console.log(`Username: ${username}`);
    console.log(`Admin ID: ${adminId}\n`);
  } catch (error) {
    console.error('Failed to create admin account:', error);
    process.exit(1);
  } finally {
    rl.close();
  }
}
