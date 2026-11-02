import React, { useRef, useEffect } from 'react'
import { useStore } from '../../store/dashboard'
import { useWebSocket } from '../../hooks/useWebSocket'
import { useKeyboardShortcuts } from '../../hooks/useKeyboardShortcuts'
import Header from './Header'
import Sidebar from './Sidebar'
import Overview from '../tabs/Overview'
import Players from '../tabs/Players'
import Economy from '../tabs/Economy'
import Admin from '../tabs/Admin'
import Logs from '../tabs/Logs'
import Settings from '../tabs/Settings'
import Chat from '../tabs/Chat'
import Analytics from '../tabs/Analytics'
import Console from '../console/Console'
import './Layout.css'

export default function Layout() {
  const { activeTab, setActiveTab } = useStore()
  const { connected } = useWebSocket()
  const consoleInputRef = useRef<HTMLInputElement>(null)

  const tabMap = ['overview', 'players', 'economy', 'admin', 'logs', 'settings', 'chat', 'analytics']

  // Setup keyboard shortcuts
  useKeyboardShortcuts([
    {
      key: '/',
      callback: () => {
        consoleInputRef.current?.focus()
      },
    },
    {
      key: 't',
      ctrlKey: true,
      callback: () => {
        const toggleButton = document.querySelector('button[aria-label="Toggle theme"]') as HTMLButtonElement
        toggleButton?.click()
      },
    },
    ...tabMap.map((tab, index) => ({
      key: String(index + 1),
      callback: () => setActiveTab(tab as any),
    })),
    {
      key: 'Escape',
      callback: () => {
        consoleInputRef.current?.blur()
      },
    },
  ])

  const renderTab = () => {
    switch (activeTab) {
      case 'overview':
        return <Overview />
      case 'players':
        return <Players />
      case 'economy':
        return <Economy />
      case 'admin':
        return <Admin />
      case 'logs':
        return <Logs />
      case 'settings':
        return <Settings />
      case 'chat':
        return <Chat />
      case 'analytics':
        return <Analytics />
      default:
        return <Overview />
    }
  }

  return (
    <div className="flex h-screen bg-gray-50 dark:bg-gray-950">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header connected={connected} />
        <main className="flex-1 overflow-auto">
          <div className="container mx-auto p-6 space-y-6">
            {renderTab()}
          </div>
        </main>
        <Console ref={consoleInputRef} />
      </div>
    </div>
  )
}
