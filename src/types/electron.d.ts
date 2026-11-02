// Type definitions for Electron IPC API
declare global {
  interface Window {
    electron: {
      // Config operations
      getConfig: () => Promise<any>;
      saveConfig: (config: any) => Promise<{ success: boolean; error?: string }>;
      validateConfig: (config: any) => Promise<{ valid: boolean; errors?: string[] }>;

      // Server control
      startServer: (config: any) => Promise<{ success: boolean; error?: string; pid?: number }>;
      stopServer: () => Promise<{ success: boolean; error?: string }>;
      getServerStatus: () => Promise<{
        status: 'running' | 'stopped' | 'error';
        port?: number;
        pid?: number;
        error?: string;
        uptime?: number;
      }>;

      // Network operations
      checkPort: (port: number) => Promise<{ available: boolean }>;
      getSuggestedPort: (basePort: number) => Promise<{ port: number }>;
      testNetwork: (config: any) => Promise<{ reachable: boolean; error?: string }>;
      checkFirewall: (port: number) => Promise<{ isBlocked: boolean; message?: string }>;
    };
  }
}

export {};
