import React from 'react'
import { useStore } from '../../store/dashboard'
import { BarChart3, Users, TrendingUp, Settings, Zap, MessageCircle, Activity, LayoutGrid } from 'lucide-react'

const tabs: Array<{ id: any; label: string; icon: any }> = [
  { id: 'overview', label: 'Overview', icon: LayoutGrid },
  { id: 'players', label: 'Players', icon: Users },
  { id: 'economy', label: 'Economy', icon: TrendingUp },
  { id: 'admin', label: 'Admin', icon: Zap },
  { id: 'logs', label: 'Logs', icon: Activity },
  { id: 'settings', label: 'Settings', icon: Settings },
  { id: 'chat', label: 'Chat', icon: MessageCircle },
  { id: 'analytics', label: 'Analytics', icon: BarChart3 },
]

export default function Sidebar() {
  const { activeTab, setActiveTab } = useStore()

  return (
    <div className="w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-800 flex flex-col">
      <div className="p-6 border-b border-gray-200 dark:border-gray-800">
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Agervis</h1>
        <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">Admin Dashboard</p>
      </div>

      <nav className="flex-1 overflow-y-auto p-4 space-y-2">
        {tabs.map((tab) => {
          const Icon = tab.icon
          const isActive = activeTab === tab.id
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-colors ${
                isActive
                  ? 'bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400'
                  : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800'
              }`}
            >
              <Icon className="w-5 h-5" />
              <span>{tab.label}</span>
            </button>
          )
        })}
      </nav>

      <div className="p-4 border-t border-gray-200 dark:border-gray-800">
        <p className="text-xs text-gray-500 dark:text-gray-400">Version 1.0.0</p>
      </div>
    </div>
  )
}
