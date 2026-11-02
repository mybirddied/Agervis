import { app, Menu, Tray } from 'electron';
import * as path from 'path';

export class TrayManager {
  private tray: Tray | null = null;
  private mainWindow: any;

  constructor(mainWindow: any) {
    this.mainWindow = mainWindow;
    this.createTray();
  }

  private createTray() {
    const iconPath = path.join(__dirname, '../assets/icon.png');
    this.tray = new Tray(iconPath);

    const contextMenu = Menu.buildFromTemplate([
      {
        label: 'Show',
        click: () => {
          if (this.mainWindow) {
            this.mainWindow.show();
            this.mainWindow.focus();
          }
        },
      },
      {
        label: 'Status: Starting...',
        click: () => {
          if (this.mainWindow) {
            this.mainWindow.show();
            this.mainWindow.focus();
          }
        },
        id: 'status',
      },
      { type: 'separator' },
      {
        label: 'Start Server',
        click: () => {
          if (this.mainWindow) {
            this.mainWindow.webContents.send('tray-action', 'start-server');
          }
        },
        id: 'start-server',
      },
      {
        label: 'Stop Server',
        click: () => {
          if (this.mainWindow) {
            this.mainWindow.webContents.send('tray-action', 'stop-server');
          }
        },
        id: 'stop-server',
      },
      { type: 'separator' },
      {
        label: 'Quit',
        click: () => {
          app.quit();
        },
      },
    ]);

    this.tray.setContextMenu(contextMenu);

    this.tray.on('click', () => {
      if (this.mainWindow) {
        if (this.mainWindow.isVisible()) {
          this.mainWindow.hide();
        } else {
          this.mainWindow.show();
          this.mainWindow.focus();
        }
      }
    });
  }

  updateStatus(status: 'running' | 'stopped' | 'error') {
    if (!this.tray) return;

    const menu = this.tray.getContextMenu();
    if (!menu) return;

    const statusItem = menu.getItemById('status');
    if (statusItem) {
      statusItem.label = `Status: ${status.charAt(0).toUpperCase() + status.slice(1)}`;
    }

    this.tray.setContextMenu(menu);
  }

  destroy() {
    if (this.tray) {
      this.tray.destroy();
      this.tray = null;
    }
  }
}
