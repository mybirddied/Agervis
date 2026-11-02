// Admin Dashboard state management
import { create } from 'zustand'

export type TabType = 'overview' | 'players' | 'economy' | 'admin' | 'logs' | 'settings' | 'chat' | 'analytics'

export interface ServerStatus {
  online: boolean
  playerCount: number
  maxPlayers: number
  uptime: number
  cpu: number
  memory: number
  bandwidth: number
}

export interface DashboardStore {
  activeTab: TabType
  setActiveTab: (tab: TabType) => void
  serverStatus: ServerStatus
  updateServerStatus: (status: Partial<ServerStatus>) => void
  theme: 'light' | 'dark'
  setTheme: (theme: 'light' | 'dark') => void
}

export const useStore = create<DashboardStore>((set) => ({
  activeTab: 'overview',
  setActiveTab: (tab) => set({ activeTab: tab }),
  serverStatus: {
    online: false,
    playerCount: 0,
    maxPlayers: 25,
    uptime: 0,
    cpu: 0,
    memory: 0,
    bandwidth: 0,
  },
  updateServerStatus: (status) =>
    set((state) => ({
      serverStatus: { ...state.serverStatus, ...status },
    })),
  theme: 'dark',
  setTheme: (theme) => set({ theme }),
}))
