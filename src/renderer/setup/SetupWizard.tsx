import React, { useState, useEffect } from 'react';
import { AlertCircle, CheckCircle2, ArrowRight, Loader } from 'lucide-react';

interface SetupWizardProps {
  onComplete: (config: any) => void;
}

export const SetupWizard: React.FC<SetupWizardProps> = ({ onComplete }) => {
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(true);
  const [config, setConfig] = useState<any>(null);
  const [errors, setErrors] = useState<string[]>([]);

  useEffect(() => {
    loadExistingConfig();
  }, []);

  const loadExistingConfig = async () => {
    try {
      const existingConfig = await window.electron.getConfig();
      setConfig(existingConfig || {});
      setLoading(false);
    } catch (error) {
      console.error('Error loading config:', error);
      setConfig({});
      setLoading(false);
    }
  };

  const handleApiKeySubmit = async (apiKey: string, baseUrl: string) => {
    const newConfig = { ...config, apiKey, baseUrl };
    setConfig(newConfig);
    setStep(2);
  };

  const handleServerConfigSubmit = async (serverConfig: any) => {
    const newConfig = { ...config, ...serverConfig };

    try {
      const validation = await window.electron.validateConfig(newConfig);
      if (!validation.valid) {
        setErrors(validation.errors || []);
        return;
      }

      const saved = await window.electron.saveConfig(newConfig);
      if (saved.success) {
        onComplete(newConfig);
      } else {
        setErrors([saved.error || 'Failed to save configuration']);
      }
    } catch (error) {
      setErrors([`Error saving configuration: ${String(error)}`]);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <div className="text-center">
          <Loader className="w-8 h-8 animate-spin text-blue-600 mx-auto mb-4" />
          <p className="text-gray-600">Loading configuration...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-xl p-8 max-w-md w-full">
        {/* Progress indicator */}
        <div className="flex items-center gap-2 mb-8">
          <div
            className={`w-10 h-10 rounded-full flex items-center justify-center font-medium ${
              step >= 1 ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
            }`}
          >
            1
          </div>
          <div className={`flex-1 h-1 ${step >= 2 ? 'bg-blue-600' : 'bg-gray-200'}`} />
          <div
            className={`w-10 h-10 rounded-full flex items-center justify-center font-medium ${
              step >= 2 ? 'bg-blue-600 text-white' : 'bg-gray-200 text-gray-600'
            }`}
          >
            2
          </div>
        </div>

        {/* Step titles */}
        <div className="text-sm text-gray-500 mb-6">
          {step === 1 ? 'Step 1 of 2: API Configuration' : 'Step 2 of 2: Server Configuration'}
        </div>

        {/* Error display */}
        {errors.length > 0 && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
            {errors.map((error, idx) => (
              <div key={idx} className="flex items-start gap-2 text-sm text-red-700 mb-2">
                <AlertCircle className="w-4 h-4 mt-0.5 flex-shrink-0" />
                <span>{error}</span>
              </div>
            ))}
          </div>
        )}

        {/* Step content */}
        {step === 1 && (
          <ApiKeyFormStandalone
            onNext={handleApiKeySubmit}
            initialApiKey={config.apiKey || ''}
            initialBaseUrl={config.baseUrl || 'http://localhost:8000'}
          />
        )}

        {step === 2 && (
          <ServerConfigStandalone
            onNext={handleServerConfigSubmit}
            initialPort={config.port || 3000}
            initialServerName={config.serverName || 'Agervis Server'}
            initialMaxPlayers={config.maxPlayers || 100}
          />
        )}

        {/* Navigation */}
        {step === 2 && (
          <button
            onClick={() => setStep(1)}
            className="w-full mt-6 bg-gray-200 hover:bg-gray-300 text-gray-700 font-medium py-2 rounded-lg transition-colors"
          >
            Back
          </button>
        )}
      </div>
    </div>
  );
};

// Simplified standalone components for use within the wizard
const ApiKeyFormStandalone: React.FC<any> = ({
  onNext,
  initialApiKey,
  initialBaseUrl,
}) => {
  const [apiKey, setApiKey] = useState(initialApiKey);
  const [baseUrl, setBaseUrl] = useState(initialBaseUrl);
  const [errors, setErrors] = useState<string[]>([]);
  const [testing, setTesting] = useState(false);

  const validateForm = (): boolean => {
    const newErrors: string[] = [];
    if (!apiKey.trim()) newErrors.push('API key is required');
    if (!baseUrl.trim()) newErrors.push('Base URL is required');
    else {
      try {
        new URL(baseUrl);
      } catch {
        newErrors.push('Base URL must be a valid URL');
      }
    }
    setErrors(newErrors);
    return newErrors.length === 0;
  };

  const handleTestConnection = async () => {
    if (!validateForm()) return;
    setTesting(true);
    try {
      const result = await window.electron.testNetwork({ baseUrl });
      if (!result.reachable) {
        setErrors([`Connection failed: ${result.error || 'Unable to reach server'}`]);
      } else {
        setErrors([]);
        onNext(apiKey, baseUrl);
      }
    } catch (error) {
      setErrors([`Error testing connection: ${String(error)}`]);
    } finally {
      setTesting(false);
    }
  };

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">API Key</label>
        <input
          type="password"
          value={apiKey}
          onChange={(e) => setApiKey(e.target.value)}
          placeholder="Enter your Anthropic API key"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">Base URL</label>
        <input
          type="text"
          value={baseUrl}
          onChange={(e) => setBaseUrl(e.target.value)}
          placeholder="http://localhost:8000"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      {errors.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3">
          {errors.map((err, i) => (
            <div key={i} className="text-sm text-red-700">{err}</div>
          ))}
        </div>
      )}
      <button
        onClick={handleTestConnection}
        disabled={testing}
        className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-medium py-2 rounded-lg transition-colors flex items-center justify-center gap-2"
      >
        {testing ? <>Testing...</> : <>Test & Continue</>}
      </button>
    </div>
  );
};

const ServerConfigStandalone: React.FC<any> = ({
  onNext,
  initialPort,
  initialServerName,
  initialMaxPlayers,
}) => {
  const [port, setPort] = useState(initialPort);
  const [serverName, setServerName] = useState(initialServerName);
  const [maxPlayers, setMaxPlayers] = useState(initialMaxPlayers);
  const [errors, setErrors] = useState<string[]>([]);
  const [checking, setChecking] = useState(false);

  const validateForm = (): boolean => {
    const newErrors: string[] = [];
    if (!port || port < 1 || port > 65535) newErrors.push('Port must be 1-65535');
    if (!serverName.trim()) newErrors.push('Server name is required');
    if (!maxPlayers || maxPlayers < 1) newErrors.push('Max players must be at least 1');
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
        setErrors([`Port ${port} in use. Try ${suggested.port}?`]);
      } else {
        onNext({ port, serverName, maxPlayers });
      }
    } catch (error) {
      setErrors([`Error: ${String(error)}`]);
    } finally {
      setChecking(false);
    }
  };

  return (
    <div className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">Server Port</label>
        <input
          type="number"
          value={port}
          onChange={(e) => setPort(parseInt(e.target.value) || 3000)}
          min="1"
          max="65535"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">Server Name</label>
        <input
          type="text"
          value={serverName}
          onChange={(e) => setServerName(e.target.value)}
          maxLength={50}
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">Max Players</label>
        <input
          type="number"
          value={maxPlayers}
          onChange={(e) => setMaxPlayers(parseInt(e.target.value) || 100)}
          min="1"
          max="10000"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
        />
      </div>
      {errors.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-3">
          {errors.map((err, i) => (
            <div key={i} className="text-sm text-red-700">{err}</div>
          ))}
        </div>
      )}
      <button
        onClick={handleCheck}
        disabled={checking}
        className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-medium py-2 rounded-lg transition-colors"
      >
        {checking ? 'Checking...' : 'Save Configuration'}
      </button>
    </div>
  );
};
