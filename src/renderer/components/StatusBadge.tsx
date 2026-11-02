import React from 'react';
import { AlertCircle, CheckCircle2, Loader } from 'lucide-react';

interface StatusBadgeProps {
  status: 'running' | 'stopped' | 'error' | 'starting';
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const statusConfig = {
    running: { color: 'bg-green-100 text-green-800', label: 'Running', icon: CheckCircle2 },
    stopped: { color: 'bg-gray-100 text-gray-800', label: 'Stopped', icon: null },
    error: { color: 'bg-red-100 text-red-800', label: 'Error', icon: AlertCircle },
    starting: { color: 'bg-blue-100 text-blue-800', label: 'Starting', icon: Loader },
  };

  const config = statusConfig[status];
  const Icon = config.icon;

  return (
    <div className={`inline-flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${config.color}`}>
      {Icon && <Icon className="w-4 h-4" />}
      {config.label}
    </div>
  );
};
