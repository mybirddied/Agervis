// Map Editor Store - Zustand store for state management
import { create } from 'zustand';
import type { Room, Tile, LayerType, MapEditorState } from '../../shared/types/map-editor';

interface MapEditorStore extends MapEditorState {
  setCurrentRoom: (room: Room | null) => void;
  setSelectedLayer: (layer: LayerType) => void;
  setSelectedTile: (tile: Tile | null) => void;
  setZoom: (zoom: number) => void;
  setPan: (panX: number, panY: number) => void;
  pushHistory: (room: Room) => void;
  undo: () => boolean;
  redo: () => boolean;
  clearHistory: () => void;
}

export const useMapEditorStore = create<MapEditorStore>((set, get) => ({
  currentRoom: null,
  selectedLayer: 'objects',
  selectedTile: null,
  history: [],
  historyIndex: -1,
  zoom: 1,
  panX: 0,
  panY: 0,

  setCurrentRoom: (room) => set({ currentRoom: room }),

  setSelectedLayer: (layer) => set({ selectedLayer: layer }),

  setSelectedTile: (tile) => set({ selectedTile: tile }),

  setZoom: (zoom) => set({ zoom }),

  setPan: (panX, panY) => set({ panX, panY }),

  pushHistory: (room) =>
    set((state) => {
      const newHistory = state.history.slice(0, state.historyIndex + 1);
      newHistory.push(JSON.parse(JSON.stringify(room)));

      return {
        history: newHistory.slice(-50), // Keep last 50 states
        historyIndex: newHistory.length - 1,
      };
    }),

  undo: () => {
    const state = get();
    if (state.historyIndex > 0) {
      set({ historyIndex: state.historyIndex - 1 });
      return true;
    }
    return false;
  },

  redo: () => {
    const state = get();
    if (state.historyIndex < state.history.length - 1) {
      set({ historyIndex: state.historyIndex + 1 });
      return true;
    }
    return false;
  },

  clearHistory: () =>
    set({
      history: [],
      historyIndex: -1,
    }),
}));

export default useMapEditorStore;
