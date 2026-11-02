// WebSocket hook for real-time dashboard updates
import { useEffect, useRef, useState } from 'react'

export interface WebSocketMessage {
  type: string
  payload: any
}

export function useWebSocket(url: string = 'ws://localhost:3000/ws/dashboard') {
  const [connected, setConnected] = useState(false)
  const [lastMessage, setLastMessage] = useState<WebSocketMessage | null>(null)
  const wsRef = useRef<WebSocket | null>(null)
  const reconnectTimeoutRef = useRef<number | null>(null)
  const reconnectAttemptsRef = useRef(0)

  useEffect(() => {
    const connect = () => {
      try {
        const authToken = localStorage.getItem('auth_token')
        if (!authToken) {
          console.error('No auth token available')
          return
        }

        const wsUrl = `${url}?token=${encodeURIComponent(authToken)}`
        const ws = new WebSocket(wsUrl)
        wsRef.current = ws

        ws.onopen = () => {
          setConnected(true)
          reconnectAttemptsRef.current = 0
        }

      ws.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data) as WebSocketMessage
          setLastMessage(message)
        } catch (e) {
          console.error('Failed to parse WebSocket message:', e)
        }
      }

      ws.onerror = (error) => {
        console.error('WebSocket error:', error)
        setConnected(false)
      }

      ws.onclose = () => {
        setConnected(false)
        reconnectAttemptsRef.current++

        if (reconnectAttemptsRef.current < 10) {
          const delay = Math.min(1000 * Math.pow(2, reconnectAttemptsRef.current), 30000)
          reconnectTimeoutRef.current = window.setTimeout(() => {
            connect()
          }, delay)
        }
      }
    } catch (e) {
      console.error('Failed to create WebSocket:', e)
      setConnected(false)
    }
  }

  connect()

  return () => {
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current)
    }
    if (wsRef.current) {
      wsRef.current.close()
    }
  }
}, [url])

  const send = (message: WebSocketMessage) => {
    if (wsRef.current?.readyState === WebSocket.OPEN) {
      wsRef.current.send(JSON.stringify(message))
    }
  }

  return { connected, lastMessage, send }
}
