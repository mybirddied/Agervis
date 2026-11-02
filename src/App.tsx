import React, { useState, useEffect } from 'react'
import { Moon, Sun } from 'lucide-react'
import { useStore } from './store/dashboard'
import { useWebSocket } from './hooks/useWebSocket'
import { ErrorBoundary } from './components/ErrorBoundary'
import Layout from './components/layout/Layout'
import { Login } from './components/auth/Login'
import './styles/index.css'

export default function App() {
  const [theme, setTheme] = useState<'light' | 'dark'>('dark')
  const [authToken, setAuthToken] = useState<string | null>(null)
  const [isAuthChecked, setIsAuthChecked] = useState(false)
  const { connected } = useWebSocket()

  useEffect(() => {
    const token = localStorage.getItem('auth_token')
    setAuthToken(token)
    setIsAuthChecked(true)
  }, [])

  useEffect(() => {
    const root = document.documentElement
    if (theme === 'dark') {
      root.classList.add('dark')
    } else {
      root.classList.remove('dark')
    }
  }, [theme])

  const toggleTheme = () => {
    setTheme(theme === 'dark' ? 'light' : 'dark')
  }

  const handleLogin = (token: string) => {
    setAuthToken(token)
  }

  const handleLogout = () => {
    localStorage.removeItem('auth_token')
    setAuthToken(null)
  }

  if (!isAuthChecked) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-900">
        <div className="text-gray-400">Loading...</div>
      </div>
    )
  }

  if (!authToken) {
    return <Login onLogin={handleLogin} />
  }

  return (
    <ErrorBoundary>
      <div className={`${theme === 'dark' ? 'dark' : ''}`}>
        <div className="min-h-screen bg-gray-50 dark:bg-gray-950 text-gray-900 dark:text-gray-50 transition-colors">
          {/* Theme toggle */}
          <div className="fixed top-4 right-4 z-50">
            <button
              onClick={toggleTheme}
              className="p-2 rounded-lg bg-gray-200 dark:bg-gray-800 hover:bg-gray-300 dark:hover:bg-gray-700 transition-colors"
              aria-label="Toggle theme"
            >
              {theme === 'dark' ? (
                <Sun className="w-5 h-5" />
              ) : (
                <Moon className="w-5 h-5" />
              )}
            </button>
          </div>

          {/* Connection status */}
          <div className="fixed top-4 left-4 z-50">
            <div className={`flex items-center gap-2 px-3 py-1 rounded-full text-sm font-medium ${
              connected
                ? 'bg-green-100 dark:bg-green-900 text-green-800 dark:text-green-100'
                : 'bg-red-100 dark:bg-red-900 text-red-800 dark:text-red-100'
            }`}>
              <div className={`w-2 h-2 rounded-full ${connected ? 'bg-green-600' : 'bg-red-600'}`} />
              {connected ? 'Connected' : 'Disconnected'}
            </div>
          </div>

          <Layout />
        </div>
      </div>
    </ErrorBoundary>
  )
}
