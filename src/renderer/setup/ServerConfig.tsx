import React, { useState } from 'react';
import { AlertCircle } from 'lucide-react';

interface ServerConfigProps {
  onNext: (config: any) => void;
  initialPort?: number;
  initialServerName?: string;
  initialMaxPlayers?: number;
}

export const ServerConfig: React.FC<ServerConfigProps> = ({
  onNext,
  initialPort = 3000,
  initialServerName = 'Agervis Server',
  initialMaxPlayers = 100,
}) => {
  const [port, setPort] = useState(initialPort);
  const [serverName, setServerName] = useState(initialServerName);
  const [maxPlayers, setMaxPlayers] = useState(initialMaxPlayers);
  const [errors, setErrors] = useState<string[]>([]);
  const [checking, setChecking] = useState(false);

  const validateForm = (): boolean => {
    const newErrors: string[] = [];

    if (!port || port < 1 || port > 65535) {
      newErrors.push('Port must be between 1 and 65535');
    }

    if (!serverName.trim() || serverName.length < 1 || serverName.length > 50) {
      newErrors.push('Server name must be between 1 and 50 characters');
    }

    if (!maxPlayers || maxPlayers < 1 || maxPlayers > 10000) {
      newErrors.push('Max players must be between 1 and 10000');
    }

    setErrors(newErrors);
    return newErrors.length === 0;
  };

  const handleCheck = async () => {
    if (!validateForm()) return;

    setChecking(true);
    try {
      const portCheck = await window.electron.checkPort(port);
      if (!portCheck.available) {
        const suggested = await window.electron.getSuggestedPort(port);
        setErrors([
          `Port ${port} is already in use. Try port ${suggested.port} instead?`,
        ]);
      } else {
        setErrors([]);
        onNext({ port, serverName, maxPlayers });
      }
    } catch (error) {
      setErrors([`Error checking port: ${String(error)}`]);
    } finally {
      setChecking(false);
    }
  };

  return (
    <div className="w-full max-w-md mx-auto">
      <h2 className="text-2xl font-bold mb-6 text-gray-900">Server Configuration</h2>

      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Server Port</label>
          <input
            type="number"
            value={port}
            onChange={(e) => setPort(parseInt(e.target.value) || 3000)}
            placeholder="3000"
            min="1"
            max="65535"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <p className="text-xs text-gray-500 mt-1">The port your server will listen on</p>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Server Name</label>
          <input
            type="text"
            value={serverName}
            onChange={(e) => setServerName(e.target.value)}
            placeholder="Agervis Server"
            maxLength={50}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <p className="text-xs text-gray-500 mt-1">
            {serverName.length}/50 characters
          </p>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Max Players</label>
          <input
            type="number"
            value={maxPlayers}
            onChange={(e) => setMaxPlayers(parseInt(e.target.value) || 100)}
            placeholder="100"
            min="1"
            max="10000"
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <p className="text-xs text-gray-500 mt-1">Maximum concurrent players</p>
        </div>

        {errors.length > 0 && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            {errors.map((error, idx) => (
              <div key={idx} className="flex items-start gap-2 text-sm text-red-700">
                <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
                <span>{error}</span>
              </div>
            ))}
          </div>
        )}

        <button
          onClick={handleCheck}
          disabled={checking}
          className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-medium py-2 rounded-lg transition-colors"
        >
          {checking ? 'Checking...' : 'Continue'}
        </button>
      </div>
    </div>
  );
};
