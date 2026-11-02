import { spawn, ChildProcess } from 'child_process';
import * as net from 'net';
import * as dns from 'dns';
import { promisify } from 'util';
import { exec } from 'child_process';
import * as path from 'path';
import * as fs from 'fs';

const execAsync = promisify(exec);

export interface ServerStatus {
  status: 'running' | 'stopped' | 'error';
  port?: number;
  pid?: number;
  error?: string;
  uptime?: number;
}

export class ServerProcess {
  private process: ChildProcess | null = null;
  private startTime: number | null = null;
  private config: any = null;
  private statusCheckInterval: NodeJS.Timeout | null = null;

  async start(config: any): Promise<{ success: boolean; error?: string; pid?: number }> {
    try {
      if (this.process) {
        return { success: false, error: 'Server is already running' };
      }

      const portAvailable = await this.checkPortAvailability(config.port);
      if (!portAvailable.available) {
        return { success: false, error: `Port ${config.port} is already in use` };
      }

      this.config = config;
      this.process = spawn('node', ['dist/server.js'], {
        env: {
          ...process.env,
          PORT: String(config.port),
          API_KEY: config.apiKey,
          BASE_URL: config.baseUrl,
          SERVER_NAME: config.serverName,
          MAX_PLAYERS: String(config.maxPlayers),
        },
      });

      this.startTime = Date.now();

      this.process.on('error', (error) => {
        console.error('Server process error:', error);
        this.process = null;
        this.startTime = null;
      });

      this.process.on('exit', () => {
        this.process = null;
        this.startTime = null;
      });

      return { success: true, pid: this.process.pid };
    } catch (error) {
      return { success: false, error: String(error) };
    }
  }

  async stop(): Promise<{ success: boolean; error?: string }> {
    try {
      if (!this.process) {
        return { success: false, error: 'Server is not running' };
      }

      return new Promise((resolve) => {
        if (this.process) {
          this.process.kill();
          setTimeout(() => {
            if (this.process) {
              this.process.kill('SIGKILL');
            }
            this.process = null;
            this.startTime = null;
            resolve({ success: true });
          }, 1000);
        } else {
          resolve({ success: true });
        }
      });
    } catch (error) {
      return { success: false, error: String(error) };
    }
  }

  getStatus(): ServerStatus {
    if (!this.process) {
      return { status: 'stopped' };
    }

    return {
      status: 'running',
      port: this.config?.port,
      pid: this.process.pid,
      uptime: this.startTime ? Date.now() - this.startTime : undefined,
    };
  }

  async checkPortAvailability(port: number): Promise<{ available: boolean }> {
    return new Promise((resolve) => {
      const server = net.createServer();
      server.once('error', () => {
        resolve({ available: false });
      });
      server.once('listening', () => {
        server.close();
        resolve({ available: true });
      });
      server.listen(port);
    });
  }

  async findAvailablePort(basePort: number): Promise<{ port: number }> {
    let port = basePort;
    while (port < basePort + 100) {
      const result = await this.checkPortAvailability(port);
      if (result.available) {
        return { port };
      }
      port++;
    }
    return { port: basePort };
  }

  async testNetwork(config: any): Promise<{ reachable: boolean; error?: string }> {
    try {
      const url = new URL(config.baseUrl);
      const hostname = url.hostname;

      return new Promise((resolve) => {
        dns.lookup(hostname, (err) => {
          if (err) {
            resolve({ reachable: false, error: `Cannot resolve hostname: ${hostname}` });
          } else {
            resolve({ reachable: true });
          }
        });
      });
    } catch (error) {
      return { reachable: false, error: String(error) };
    }
  }

  async checkFirewall(port: number): Promise<{ isBlocked: boolean; message?: string }> {
    try {
      if (process.platform === 'win32') {
        try {
          await execAsync(
            `netsh advfirewall firewall show rule name="Agervis Port ${port}" dir=in`,
          );
          return { isBlocked: false, message: 'Port is open in firewall' };
        } catch {
          return {
            isBlocked: true,
            message: `Port ${port} may be blocked by Windows Firewall. Run this command as Administrator: netsh advfirewall firewall add rule name="Agervis Port ${port}" dir=in action=allow protocol=tcp localport=${port}`,
          };
        }
      }

      if (process.platform === 'darwin') {
        return {
          isBlocked: false,
          message: 'On macOS, you may need to allow the app through the firewall in System Preferences > Security & Privacy',
        };
      }

      if (process.platform === 'linux') {
        try {
          await execAsync(`sudo ufw status | grep ${port}`);
          return { isBlocked: false, message: 'Port is open in firewall' };
        } catch {
          return {
            isBlocked: true,
            message: `Port ${port} may be blocked. Run: sudo ufw allow ${port}/tcp`,
          };
        }
      }

      return { isBlocked: false };
    } catch (error) {
      return { isBlocked: false, message: `Unable to check firewall: ${String(error)}` };
    }
  }
}
