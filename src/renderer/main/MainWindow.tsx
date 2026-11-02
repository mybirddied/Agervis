import React, { useState, useEffect } from 'react';
import { SetupWizard } from '../setup/SetupWizard';
import { ServerControls } from './ServerControls';

export const MainWindow: React.FC = () => {
  const [config, setConfig] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadConfig();
  }, []);

  const loadConfig = async () => {
    try {
      const result = await window.electron.getConfig();
      if (result && result.apiKey) {
        setConfig(result);
      } else {
        setConfig(null);
      }
    } catch (error) {
      console.error('Error loading config:', error);
      setConfig(null);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <div className="text-center">
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!config) {
    return <SetupWizard onComplete={(cfg) => setConfig(cfg)} />;
  }

  return <ServerControls config={config} />;
};
