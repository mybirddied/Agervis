/**
 * Authentication Middleware
 * Verifies auth tokens for protected routes
 */

import { Request, Response, NextFunction } from 'express';
import { AuthManager } from '../auth/auth-manager';

export interface AuthenticatedRequest extends Request {
  admin?: {
    id: string;
    username: string;
    role: 'admin' | 'viewer';
  };
}

export function createAuthMiddleware(authManager: AuthManager) {
  return async (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        res.status(401).json({ error: 'Authentication required' });
        return;
      }

      const admin = await authManager.validateToken(token);

      if (!admin) {
        res.status(401).json({ error: 'Invalid or expired token' });
        return;
      }

      req.admin = {
        id: admin.id,
        username: admin.username,
        role: admin.role,
      };

      next();
    } catch (error) {
      console.error('Auth middleware error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
}

export function requireRole(role: 'admin' | 'viewer') {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    if (!req.admin) {
      res.status(401).json({ error: 'Authentication required' });
      return;
    }

    if (role === 'admin' && req.admin.role !== 'admin') {
      res.status(403).json({ error: 'Admin privileges required' });
      return;
    }

    next();
  };
}
