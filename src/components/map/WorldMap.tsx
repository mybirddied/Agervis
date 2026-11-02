import React, { useEffect, useRef, useState } from 'react'
import { ZoomIn, ZoomOut } from 'lucide-react'
import DOMPurify from 'isomorphic-dompurify'

interface Player {
  id: string
  name: string
  x: number
  y: number
  heat: number
}

interface WorldMapState {
  players: Player[]
  zoom: number
  panX: number
  panY: number
}

// Helper to sanitize player names for canvas display
const sanitizeName = (text: string) => DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })

export default function WorldMap() {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const animationRef = useRef<number>()
  const [zoom, setZoom] = useState(1)
  const stateRef = useRef<WorldMapState>({
    players: [
      { id: '1', name: 'Marlo', x: 120, y: 340, heat: 85 },
      { id: '2', name: 'Citizen', x: 240, y: 180, heat: 5 },
      { id: '3', name: 'Officer Pike', x: 300, y: 250, heat: 0 },
    ],
    zoom: 1,
    panX: 0,
    panY: 0,
  })

  const drawFrame = (canvas: HTMLCanvasElement, ctx: CanvasRenderingContext2D, state: WorldMapState) => {
    const { players, zoom, panX, panY } = state

    // Clear canvas
    ctx.fillStyle = '#1f2937'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    // Save context for transformations
    ctx.save()
    ctx.translate(canvas.width / 2, canvas.height / 2)
    ctx.scale(zoom, zoom)
    ctx.translate(-canvas.width / 2 + panX, -canvas.height / 2 + panY)

    // Draw grid (optimized for zoom)
    const gridSize = 50 / zoom
    ctx.strokeStyle = '#374151'
    ctx.lineWidth = 1 / zoom
    const startX = Math.floor(-panX / gridSize) * gridSize
    const startY = Math.floor(-panY / gridSize) * gridSize

    for (let i = startX; i < canvas.width / zoom + panX; i += gridSize) {
      ctx.beginPath()
      ctx.moveTo(i, -panY)
      ctx.lineTo(i, canvas.height / zoom - panY)
      ctx.stroke()
    }
    for (let i = startY; i < canvas.height / zoom + panY; i += gridSize) {
      ctx.beginPath()
      ctx.moveTo(-panX, i)
      ctx.lineTo(canvas.width / zoom - panX, i)
      ctx.stroke()
    }

    // Draw heatmap overlays (batch for performance)
    players.forEach((player) => {
      if (player.heat > 0) {
        const intensity = Math.min(player.heat / 100, 1)
        ctx.fillStyle = `rgba(239, 68, 68, ${intensity * 0.15})`
        ctx.beginPath()
        ctx.arc(player.x, player.y, 30 + player.heat / 2, 0, Math.PI * 2)
        ctx.fill()
      }
    })

    // Draw players (sorted by heat for visual priority)
    const sortedPlayers = [...players].sort((a, b) => a.heat - b.heat)
    sortedPlayers.forEach((player) => {
      // Draw player marker
      const color = player.heat > 50 ? '#ef4444' : player.heat > 20 ? '#f59e0b' : '#10b981'
      ctx.fillStyle = color
      ctx.beginPath()
      ctx.arc(player.x, player.y, 8, 0, Math.PI * 2)
      ctx.fill()

      // Draw outer glow for high-heat players
      if (player.heat > 50) {
        ctx.strokeStyle = `rgba(239, 68, 68, 0.3)`
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.arc(player.x, player.y, 15, 0, Math.PI * 2)
        ctx.stroke()
      }

      // Draw label (optimized for zoom) - sanitize player name
      ctx.fillStyle = '#f9fafb'
      ctx.font = `${12 / zoom}px sans-serif`
      ctx.textAlign = 'center'
      ctx.fillText(sanitizeName(player.name), player.x, player.y - 20)
    })

    ctx.restore()
  }

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    const ctx = canvas.getContext('2d')
    if (!ctx) return

    // Set canvas size with device pixel ratio for sharpness
    const dpr = window.devicePixelRatio || 1
    canvas.width = canvas.offsetWidth * dpr
    canvas.height = canvas.offsetHeight * dpr
    ctx.scale(dpr, dpr)

    const animate = () => {
      drawFrame(canvas, ctx, stateRef.current)
      animationRef.current = requestAnimationFrame(animate)
    }

    animationRef.current = requestAnimationFrame(animate)

    // Handle window resize
    const handleResize = () => {
      canvas.width = canvas.offsetWidth * dpr
      canvas.height = canvas.offsetHeight * dpr
      ctx.scale(dpr, dpr)
    }

    window.addEventListener('resize', handleResize)

    return () => {
      if (animationRef.current) cancelAnimationFrame(animationRef.current)
      window.removeEventListener('resize', handleResize)
    }
  }, [])

  const handleZoom = (direction: 'in' | 'out') => {
    setZoom((prev) => {
      const newZoom = direction === 'in' ? Math.min(prev * 1.2, 4) : Math.max(prev / 1.2, 0.5)
      stateRef.current.zoom = newZoom
      return newZoom
    })
  }

  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 overflow-hidden">
      <div className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-800">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">World Map (Zoom: {zoom.toFixed(1)}x)</h3>
        <div className="flex items-center gap-2">
          <button
            onClick={() => handleZoom('in')}
            className="p-2 hover:bg-gray-200 dark:hover:bg-gray-800 rounded transition-colors"
            title="Zoom In"
          >
            <ZoomIn className="w-4 h-4" />
          </button>
          <button
            onClick={() => handleZoom('out')}
            className="p-2 hover:bg-gray-200 dark:hover:bg-gray-800 rounded transition-colors"
            title="Zoom Out"
          >
            <ZoomOut className="w-4 h-4" />
          </button>
        </div>
      </div>
      <canvas ref={canvasRef} className="w-full h-96 bg-gray-900 cursor-grab active:cursor-grabbing" />
      <div className="p-2 text-xs text-gray-500 dark:text-gray-400 border-t border-gray-200 dark:border-gray-800">
        Players: {stateRef.current.players.length} | Use scroll wheel to zoom or click zoom buttons
      </div>
    </div>
  )
}
