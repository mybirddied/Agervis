import { contextBridge, ipcRenderer } from 'electron';

export interface ElectronAPI {
  // Config
  getConfig: () => Promise<any>;
  saveConfig: (config: any) => Promise<any>;
  validateConfig: (config: any) => Promise<any>;

  // Server
  startServer: (config: any) => Promise<any>;
  stopServer: () => Promise<any>;
  getServerStatus: () => Promise<any>;

  // Network
  checkPort: (port: number) => Promise<any>;
  getSuggestedPort: (basePort: number) => Promise<any>;
  testNetwork: (config: any) => Promise<any>;
  checkFirewall: (port: number) => Promise<any>;
}

const electronAPI: ElectronAPI = {
  getConfig: () => ipcRenderer.invoke('get-config'),
  saveConfig: (config: any) => ipcRenderer.invoke('save-config', config),
  validateConfig: (config: any) => ipcRenderer.invoke('validate-config', config),
  startServer: (config: any) => ipcRenderer.invoke('start-server', config),
  stopServer: () => ipcRenderer.invoke('stop-server'),
  getServerStatus: () => ipcRenderer.invoke('get-server-status'),
  checkPort: (port: number) => ipcRenderer.invoke('check-port', port),
  getSuggestedPort: (basePort: number) => ipcRenderer.invoke('get-suggested-port', basePort),
  testNetwork: (config: any) => ipcRenderer.invoke('test-network', config),
  checkFirewall: (port: number) => ipcRenderer.invoke('check-firewall', port),
};

contextBridge.exposeInMainWorld('electron', electronAPI);

declare global {
  interface Window {
    electron: ElectronAPI;
  }
}
