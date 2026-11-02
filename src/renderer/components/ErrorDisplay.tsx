import React from 'react';
import { AlertCircle } from 'lucide-react';

interface ErrorDisplayProps {
  errors: string[];
  onDismiss?: (index: number) => void;
}

export const ErrorDisplay: React.FC<ErrorDisplayProps> = ({ errors, onDismiss }) => {
  if (errors.length === 0) return null;

  return (
    <div className="bg-red-50 border border-red-200 rounded-lg p-4 space-y-2">
      {errors.map((error, idx) => (
        <div key={idx} className="flex items-start gap-3">
          <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="text-sm text-red-700">{error}</p>
          </div>
          {onDismiss && (
            <button
              onClick={() => onDismiss(idx)}
              className="text-red-500 hover:text-red-700 text-lg leading-none"
            >
              ×
            </button>
          )}
        </div>
      ))}
    </div>
  );
};
