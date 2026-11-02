import React, { useState, useEffect } from 'react';

interface ElectronContextType {
  config: any | null;
  setConfig: (config: any) => void;
  isConfigured: boolean;
}

export const ElectronContext = React.createContext<ElectronContextType | undefined>(undefined);

export const ElectronProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [config, setConfig] = useState<any>(null);

  useEffect(() => {
    loadConfig();
  }, []);

  const loadConfig = async () => {
    try {
      const result = await window.electron.getConfig();
      if (result && result.apiKey) {
        setConfig(result);
      }
    } catch (error) {
      console.error('Error loading config:', error);
    }
  };

  return (
    <ElectronContext.Provider value={{ config, setConfig, isConfigured: !!config?.apiKey }}>
      {children}
    </ElectronContext.Provider>
  );
};

export const useElectron = () => {
  const context = React.useContext(ElectronContext);
  if (!context) {
    throw new Error('useElectron must be used within ElectronProvider');
  }
  return context;
};
