/**
 * Authentication API Routes
 * Express routes for admin authentication
 */

import { Router, Request, Response } from 'express';
import { AuthManager } from '../auth/auth-manager';

export function createAuthRoutes(authManager: AuthManager): Router {
  const router = Router();

  // Login endpoint
  router.post('/login', async (req: Request, res: Response) => {
    try {
      const { username, password } = req.body;

      if (!username || !password) {
        res.status(400).json({ error: 'Username and password required' });
        return;
      }

      const token = await authManager.authenticate(username, password);

      if (!token) {
        res.status(401).json({ error: 'Invalid credentials' });
        return;
      }

      res.json({ token });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  // Logout endpoint
  router.post('/logout', async (req: Request, res: Response) => {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        res.status(400).json({ error: 'Token required' });
        return;
      }

      await authManager.revokeToken(token);
      res.json({ success: true });
    } catch (error) {
      console.error('Logout error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  // Verify token endpoint
  router.get('/verify', async (req: Request, res: Response) => {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        res.status(401).json({ error: 'No token provided' });
        return;
      }

      const admin = await authManager.validateToken(token);

      if (!admin) {
        res.status(401).json({ error: 'Invalid or expired token' });
        return;
      }

      res.json({
        id: admin.id,
        username: admin.username,
        role: admin.role,
      });
    } catch (error) {
      console.error('Verify error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  return router;
}
