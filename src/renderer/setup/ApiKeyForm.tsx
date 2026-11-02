import React, { useState, useEffect } from 'react';
import { AlertCircle, CheckCircle2, Loader } from 'lucide-react';

interface ApiKeyFormProps {
  onNext: (apiKey: string, baseUrl: string) => void;
  initialApiKey?: string;
  initialBaseUrl?: string;
}

export const ApiKeyForm: React.FC<ApiKeyFormProps> = ({
  onNext,
  initialApiKey = '',
  initialBaseUrl = 'http://localhost:8000',
}) => {
  const [apiKey, setApiKey] = useState(initialApiKey);
  const [baseUrl, setBaseUrl] = useState(initialBaseUrl);
  const [errors, setErrors] = useState<string[]>([]);
  const [testing, setTesting] = useState(false);

  const validateForm = (): boolean => {
    const newErrors: string[] = [];

    if (!apiKey.trim()) {
      newErrors.push('API key is required');
    }

    if (!baseUrl.trim()) {
      newErrors.push('Base URL is required');
    } else {
      try {
        new URL(baseUrl);
      } catch {
        newErrors.push('Base URL must be a valid URL (e.g., http://localhost:8000)');
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
        setErrors([...errors, `Connection failed: ${result.error || 'Unable to reach server'}`]);
      } else {
        setErrors([]);
        onNext(apiKey, baseUrl);
      }
    } catch (error) {
      setErrors([...errors, `Error testing connection: ${String(error)}`]);
    } finally {
      setTesting(false);
    }
  };

  return (
    <div className="w-full max-w-md mx-auto">
      <h2 className="text-2xl font-bold mb-6 text-gray-900">API Configuration</h2>

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
          <p className="text-xs text-gray-500 mt-1">
            Find your API key at https://console.anthropic.com/account/keys
          </p>
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
          <p className="text-xs text-gray-500 mt-1">
            The URL where your Agervis server will be hosted
          </p>
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
          onClick={handleTestConnection}
          disabled={testing}
          className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-blue-400 text-white font-medium py-2 rounded-lg transition-colors flex items-center justify-center gap-2"
        >
          {testing ? (
            <>
              <Loader className="w-4 h-4 animate-spin" />
              Testing Connection...
            </>
          ) : (
            'Test & Continue'
          )}
        </button>
      </div>
    </div>
  );
};
