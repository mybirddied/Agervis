import { app, BrowserWindow, Menu, ipcMain } from 'electron';
import { isDev } from './dev-utils';
import { TrayManager } from './tray/tray-manager';
import { ConfigManager } from './config-manager';
import { ServerProcess } from './server-process';
import * as path from 'path';

let mainWindow: BrowserWindow | null = null;
let trayManager: TrayManager | null = null;
let serverProcess: ServerProcess | null = null;
const configManager = new ConfigManager();

const createWindow = () => {
  mainWindow = new BrowserWindow({
    width: 1024,
    height: 768,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
    },
  });

  const startUrl = isDev
    ? 'http://localhost:5173'
    : `file://${path.join(__dirname, '../dist/index.html')}`;

  mainWindow.loadURL(startUrl);

  if (isDev) {
    mainWindow.webContents.openDevTools();
  }

  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  mainWindow.on('minimize', () => {
    if (trayManager) {
      mainWindow?.hide();
    }
  });

  return mainWindow;
};

app.on('ready', () => {
  createWindow();
  trayManager = new TrayManager(mainWindow);
  serverProcess = new ServerProcess();
  setupIpcHandlers();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  } else if (mainWindow.isVisible()) {
    mainWindow.focus();
  } else {
    mainWindow.show();
  }
});

const setupIpcHandlers = () => {
  // Config handlers
  ipcMain.handle('get-config', async () => {
    return configManager.loadConfig();
  });

  ipcMain.handle('save-config', async (_event, config) => {
    return configManager.saveConfig(config);
  });

  ipcMain.handle('validate-config', async (_event, config) => {
    return configManager.validateConfig(config);
  });

  // Server handlers
  ipcMain.handle('start-server', async (_event, config) => {
    if (!serverProcess) return { success: false, error: 'Server process not initialized' };
    return serverProcess.start(config);
  });

  ipcMain.handle('stop-server', async () => {
    if (!serverProcess) return { success: false, error: 'Server process not initialized' };
    return serverProcess.stop();
  });

  ipcMain.handle('get-server-status', async () => {
    if (!serverProcess) return { status: 'error' };
    return serverProcess.getStatus();
  });

  // Port handlers
  ipcMain.handle('check-port', async (_event, port: number) => {
    if (!serverProcess) return { available: false };
    return serverProcess.checkPortAvailability(port);
  });

  ipcMain.handle('get-suggested-port', async (_event, basePort: number) => {
    if (!serverProcess) return { port: 3000 };
    return serverProcess.findAvailablePort(basePort);
  });

  // Network handlers
  ipcMain.handle('test-network', async (_event, config) => {
    if (!serverProcess) return { reachable: false, error: 'Server process not initialized' };
    return serverProcess.testNetwork(config);
  });

  // Firewall handlers
  ipcMain.handle('check-firewall', async (_event, port: number) => {
    if (!serverProcess) return { isBlocked: false };
    return serverProcess.checkFirewall(port);
  });
};

export { mainWindow };
