// ExportDialog.tsx - Export options and format selection
import React, { useState } from 'react';
import { Download, FileJson, FileImage } from 'lucide-react';
import GodotExporter from '../../main/map-editor/export/godot-exporter';
import JSONExporter from '../../main/map-editor/export/json-exporter';
import PNGExporter from '../../main/map-editor/export/png-exporter';
import type { Room, Tile, ExportOptions } from '../../shared/types/map-editor';

interface ExportDialogProps {
  room: Room;
  tileLibrary: Tile[];
  onClose: () => void;
}

export default function ExportDialog({ room, tileLibrary, onClose }: ExportDialogProps) {
  const [exportFormat, setExportFormat] = useState<'godot' | 'json' | 'png'>('json');
  const [includeCollision, setIncludeCollision] = useState(true);
  const [includeLighting, setIncludeLighting] = useState(true);
  const [exporting, setExporting] = useState(false);

  const handleExport = async () => {
    setExporting(true);

    try {
      const options: ExportOptions = {
        format: exportFormat,
        includeCollision,
        includeLighting,
      };

      let content = '';
      let filename = `${room.id}`;
      let mimeType = 'text/plain';

      switch (exportFormat) {
        case 'godot': {
          const exporter = new GodotExporter();
          content = exporter.exportToGodot(room);
          filename += exporter.getFileExtension();
          mimeType = 'text/plain';
          break;
        }

        case 'json': {
          const exporter = new JSONExporter();
          content = exporter.exportToJSON(room, options);
          filename += exporter.getFileExtension();
          mimeType = 'application/json';
          break;
        }

        case 'png': {
          const exporter = new PNGExporter();
          const tileImages = new Map<string, HTMLImageElement>();

          // Convert tile library to image map
          tileLibrary.forEach((tile) => {
            const img = new Image();
            img.src = tile.imageUrl;
            tileImages.set(tile.id, img);
          });

          const dataUrl = await exporter.exportToPNG(room, tileImages);
          exporter.downloadPNG(dataUrl, `${filename}.png`);
          onClose();
          return;
        }
      }

      // Download file
      const blob = new Blob([content], { type: mimeType });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);

      onClose();
    } catch (error) {
      console.error('Export error:', error);
      alert('Failed to export room');
    } finally {
      setExporting(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-gray-800 rounded-lg p-6 max-w-sm w-full mx-4 border border-gray-700">
        <h2 className="text-xl font-bold mb-4 text-white">Export Room</h2>

        {/* Format Selection */}
        <div className="mb-4">
          <label className="block text-sm font-semibold mb-2 text-gray-300">Export Format</label>
          <div className="space-y-2">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="radio"
                name="format"
                value="json"
                checked={exportFormat === 'json'}
                onChange={(e) => setExportFormat(e.target.value as 'json')}
                className="w-4 h-4"
              />
              <FileJson size={16} />
              <span>JSON (Portable)</span>
            </label>

            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="radio"
                name="format"
                value="godot"
                checked={exportFormat === 'godot'}
                onChange={(e) => setExportFormat(e.target.value as 'godot')}
                className="w-4 h-4"
              />
              <span>Godot (TSCN)</span>
            </label>

            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="radio"
                name="format"
                value="png"
                checked={exportFormat === 'png'}
                onChange={(e) => setExportFormat(e.target.value as 'png')}
                className="w-4 h-4"
              />
              <FileImage size={16} />
              <span>PNG (Preview)</span>
            </label>
          </div>
        </div>

        {/* Export Options */}
        {exportFormat !== 'png' && (
          <div className="mb-4 space-y-2">
            <label className="flex items-center gap-2 cursor-pointer text-sm">
              <input
                type="checkbox"
                checked={includeCollision}
                onChange={(e) => setIncludeCollision(e.target.checked)}
                className="w-4 h-4"
              />
              <span>Include Collision Layer</span>
            </label>

            <label className="flex items-center gap-2 cursor-pointer text-sm">
              <input
                type="checkbox"
                checked={includeLighting}
                onChange={(e) => setIncludeLighting(e.target.checked)}
                className="w-4 h-4"
              />
              <span>Include Lighting Data</span>
            </label>
          </div>
        )}

        {/* Format Info */}
        <div className="mb-4 p-3 bg-gray-700 rounded text-sm text-gray-300">
          {exportFormat === 'json' && 'Portable JSON format for import into other tools.'}
          {exportFormat === 'godot' && 'Godot TSCN format for direct integration into your Godot project.'}
          {exportFormat === 'png' && 'PNG preview image of your room layout with grid overlay.'}
        </div>

        {/* Action Buttons */}
        <div className="flex gap-2">
          <button
            onClick={onClose}
            className="flex-1 px-4 py-2 bg-gray-700 hover:bg-gray-600 rounded font-medium transition-colors"
          >
            Cancel
          </button>
          <button
            onClick={handleExport}
            disabled={exporting}
            className="flex-1 px-4 py-2 bg-blue-600 hover:bg-blue-500 disabled:bg-blue-800 rounded font-medium transition-colors flex items-center justify-center gap-2"
          >
            <Download size={16} />
            {exporting ? 'Exporting...' : 'Export'}
          </button>
        </div>
      </div>
    </div>
  );
}
