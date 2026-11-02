import { useState, useCallback } from 'react';

export const useServerStatus = () => {
  const [status, setStatus] = useState<any>({ status: 'stopped' });
  const [loading, setLoading] = useState(false);

  const checkStatus = useCallback(async () => {
    try {
      const result = await window.electron.getServerStatus();
      setStatus(result);
      return result;
    } catch (error) {
      console.error('Error checking status:', error);
      return null;
    }
  }, []);

  const startServer = useCallback(async (config: any) => {
    setLoading(true);
    try {
      const result = await window.electron.startServer(config);
      if (result.success) {
        await checkStatus();
      }
      return result;
    } finally {
      setLoading(false);
    }
  }, [checkStatus]);

  const stopServer = useCallback(async () => {
    setLoading(true);
    try {
      const result = await window.electron.stopServer();
      if (result.success) {
        await checkStatus();
      }
      return result;
    } finally {
      setLoading(false);
    }
  }, [checkStatus]);

  return { status, loading, checkStatus, startServer, stopServer };
};
