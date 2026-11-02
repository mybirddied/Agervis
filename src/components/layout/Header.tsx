import React from 'react'
import { Server, AlertCircle } from 'lucide-react'
import { useStore } from '../../store/dashboard'

interface HeaderProps {
  connected: boolean
}

export default function Header({ connected }: HeaderProps) {
  const { serverStatus } = useStore()

  return (
    <div className="bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 px-6 py-4">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2">
            <Server className="w-5 h-5 text-gray-600 dark:text-gray-400" />
            <div>
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Server Status</h2>
              <p className="text-sm text-gray-500 dark:text-gray-400">Agervis Game Server</p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-6">
          <div className="grid grid-cols-4 gap-4 text-center">
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Players</p>
              <p className="text-xl font-bold text-gray-900 dark:text-white">
                {serverStatus.playerCount}/{serverStatus.maxPlayers}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">CPU</p>
              <p className="text-xl font-bold text-gray-900 dark:text-white">{serverStatus.cpu.toFixed(1)}%</p>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Memory</p>
              <p className="text-xl font-bold text-gray-900 dark:text-white">{serverStatus.memory}MB</p>
            </div>
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Uptime</p>
              <p className="text-xl font-bold text-gray-900 dark:text-white">{formatUptime(serverStatus.uptime)}</p>
            </div>
          </div>

          <div className={`flex items-center gap-2 px-4 py-2 rounded-lg ${
            connected
              ? 'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'
              : 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400'
          }`}>
            {connected ? (
              <>
                <div className="w-2 h-2 rounded-full bg-green-600 animate-pulse" />
                <span className="text-sm font-medium">Connected</span>
              </>
            ) : (
              <>
                <AlertCircle className="w-4 h-4" />
                <span className="text-sm font-medium">Disconnected</span>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function formatUptime(seconds: number): string {
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  if (hours > 0) {
    return `${hours}h ${minutes}m`
  }
  return `${minutes}m`
}
