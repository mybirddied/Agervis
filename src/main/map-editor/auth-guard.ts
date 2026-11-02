/**
 * Map Editor Authentication Guard
 * Protects map editor routes with authentication
 */

import { Request, Response, NextFunction } from 'express';
import { AuthManager } from '../../auth/auth-manager';

export function createMapEditorAuthGuard(authManager: AuthManager) {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const token = req.headers.authorization?.replace('Bearer ', '') ||
                    req.query.token as string;

      if (!token) {
        res.status(401).json({ error: 'Authentication required for map editor' });
        return;
      }

      const admin = await authManager.validateToken(token);

      if (!admin) {
        res.status(401).json({ error: 'Invalid or expired token' });
        return;
      }

      if (admin.role !== 'admin') {
        res.status(403).json({ error: 'Admin privileges required for map editor' });
        return;
      }

      next();
    } catch (error) {
      console.error('Map editor auth error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
}
