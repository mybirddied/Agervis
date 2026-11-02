import React, { useState, useEffect } from 'react';
import { Play, Square, RefreshCw, AlertCircle, CheckCircle2, Wifi, Shield } from 'lucide-react';

interface ServerControlsProps {
  config: any;
}

export const ServerControls: React.FC<ServerControlsProps> = ({ config }) => {
  const [status, setStatus] = useState<any>({ status: 'stopped' });
  const [loading, setLoading] = useState(false);
  const [statusCheckInterval, setStatusCheckInterval] = useState<NodeJS.Timeout | null>(null);
  const [networkStatus, setNetworkStatus] = useState<any>(null);
  const [firewallStatus, setFirewallStatus] = useState<any>(null);

  useEffect(() => {
    checkStatus();
    const interval = setInterval(checkStatus, 2000);
    setStatusCheckInterval(interval);

    return () => {
      if (interval) clearInterval(interval);
    };
  }, []);

  useEffect(() => {
    checkNetworkStatus();
    checkFirewall();
  }, [config]);

  const checkStatus = async () => {
    try {
      const result = await window.electron.getServerStatus();
      setStatus(result);
    } catch (error) {
      console.error('Error checking status:', error);
    }
  };

  const checkNetworkStatus = async () => {
    try {
      const result = await window.electron.testNetwork(config);
      setNetworkStatus(result);
    } catch (error) {
      console.error('Error checking network:', error);
    }
  };

  const checkFirewall = async () => {
    try {
      const result = await window.electron.checkFirewall(config.port);
      setFirewallStatus(result);
    } catch (error) {
      console.error('Error checking firewall:', error);
    }
  };

  const handleStart = async () => {
    setLoading(true);
    try {
      const result = await window.electron.startServer(config);
      if (result.success) {
        await checkStatus();
      }
    } catch (error) {
      console.error('Error starting server:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleStop = async () => {
    setLoading(true);
    try {
      const result = await window.electron.stopServer();
      if (result.success) {
        await checkStatus();
      }
    } catch (error) {
      console.error('Error stopping server:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'running':
        return 'bg-green-50 border-green-200';
      case 'stopped':
        return 'bg-gray-50 border-gray-200';
      case 'error':
        return 'bg-red-50 border-red-200';
      default:
        return 'bg-gray-50 border-gray-200';
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'running':
        return <span className="inline-block w-2 h-2 bg-green-500 rounded-full mr-2" />;
      case 'stopped':
        return <span className="inline-block w-2 h-2 bg-gray-400 rounded-full mr-2" />;
      case 'error':
        return <span className="inline-block w-2 h-2 bg-red-500 rounded-full mr-2" />;
      default:
        return null;
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Agervis Server</h1>
        <p className="text-gray-600">{config.serverName}</p>
      </div>

      {/* Status Card */}
      <div className={`border rounded-lg p-6 mb-6 ${getStatusColor(status.status)}`}>
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center">
            {getStatusBadge(status.status)}
            <span className="text-lg font-semibold text-gray-900 capitalize">
              {status.status}
            </span>
          </div>
          {status.uptime && (
            <span className="text-sm text-gray-600">
              Uptime: {Math.floor(status.uptime / 1000)}s
            </span>
          )}
        </div>

        <div className="grid grid-cols-2 gap-4 text-sm mb-4">
          <div>
            <p className="text-gray-600">Server Name</p>
            <p className="font-medium text-gray-900">{config.serverName}</p>
          </div>
          <div>
            <p className="text-gray-600">Port</p>
            <p className="font-medium text-gray-900">{config.port}</p>
          </div>
          <div>
            <p className="text-gray-600">Max Players</p>
            <p className="font-medium text-gray-900">{config.maxPlayers}</p>
          </div>
          {status.pid && (
            <div>
              <p className="text-gray-600">Process ID</p>
              <p className="font-medium text-gray-900">{status.pid}</p>
            </div>
          )}
        </div>

        {/* Control Buttons */}
        <div className="flex gap-3">
          <button
            onClick={handleStart}
            disabled={loading || status.status === 'running'}
            className="flex-1 bg-green-600 hover:bg-green-700 disabled:bg-gray-300 text-white font-medium py-2 rounded-lg transition-colors flex items-center justify-center gap-2"
          >
            <Play className="w-4 h-4" />
            Start Server
          </button>
          <button
            onClick={handleStop}
            disabled={loading || status.status === 'stopped'}
            className="flex-1 bg-red-600 hover:bg-red-700 disabled:bg-gray-300 text-white font-medium py-2 rounded-lg transition-colors flex items-center justify-center gap-2"
          >
            <Square className="w-4 h-4" />
            Stop Server
          </button>
          <button
            onClick={() => {
              checkStatus();
              checkNetworkStatus();
              checkFirewall();
            }}
            disabled={loading}
            className="bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 text-white font-medium py-2 px-4 rounded-lg transition-colors flex items-center justify-center gap-2"
          >
            <RefreshCw className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Network Status */}
      {networkStatus && (
        <div className={`border rounded-lg p-4 mb-4 flex items-start gap-3 ${networkStatus.reachable ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
          <Wifi className={`w-5 h-5 mt-0.5 flex-shrink-0 ${networkStatus.reachable ? 'text-green-600' : 'text-red-600'}`} />
          <div>
            <p className={`font-medium ${networkStatus.reachable ? 'text-green-900' : 'text-red-900'}`}>
              {networkStatus.reachable ? 'Network Reachable' : 'Network Unreachable'}
            </p>
            {networkStatus.error && (
              <p className={`text-sm ${networkStatus.reachable ? 'text-green-700' : 'text-red-700'}`}>
                {networkStatus.error}
              </p>
            )}
          </div>
        </div>
      )}

      {/* Firewall Status */}
      {firewallStatus && (
        <div
          className={`border rounded-lg p-4 flex items-start gap-3 ${
            firewallStatus.isBlocked ? 'bg-yellow-50 border-yellow-200' : 'bg-green-50 border-green-200'
          }`}
        >
          <Shield
            className={`w-5 h-5 mt-0.5 flex-shrink-0 ${
              firewallStatus.isBlocked ? 'text-yellow-600' : 'text-green-600'
            }`}
          />
          <div>
            <p
              className={`font-medium ${
                firewallStatus.isBlocked ? 'text-yellow-900' : 'text-green-900'
              }`}
            >
              {firewallStatus.isBlocked ? 'Firewall May Block Server' : 'Firewall OK'}
            </p>
            {firewallStatus.message && (
              <p
                className={`text-sm ${
                  firewallStatus.isBlocked ? 'text-yellow-700' : 'text-green-700'
                }`}
              >
                {firewallStatus.message}
              </p>
            )}
          </div>
        </div>
      )}
    </div>
  );
};
