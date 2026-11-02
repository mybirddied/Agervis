import React, { useState, useRef, useEffect, forwardRef } from 'react'
import { Send } from 'lucide-react'
import DOMPurify from 'isomorphic-dompurify'
import { parseCommandWithAI } from '../../services/commandParser'

// Helper to sanitize command output, removing all HTML tags
const sanitizeOutput = (text: string) => DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })

const Console = forwardRef<HTMLInputElement>((props, ref) => {
  const [input, setInput] = useState('')
  const [history, setHistory] = useState<string[]>([])
  const [historyIndex, setHistoryIndex] = useState(-1)
  const [output, setOutput] = useState<Array<{ type: 'command' | 'result' | 'error'; text: string }>>([])
  const [isProcessing, setIsProcessing] = useState(false)
  const outputRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLInputElement>(null)

  // Merge forwarded ref with local ref
  useEffect(() => {
    if (ref && 'current' in ref) {
      ref.current = inputRef.current
    }
  }, [ref])

  useEffect(() => {
    if (outputRef.current) {
      outputRef.current.scrollTop = outputRef.current.scrollHeight
    }
  }, [output])

  const handleCommand = async (cmd: string) => {
    if (!cmd.trim()) return

    setIsProcessing(true)
    setHistory([...history, cmd])
    setHistoryIndex(-1)
    setOutput((prev) => [...prev, { type: 'command', text: `> ${cmd}` }])

    try {
      // Parse and execute command with AI fallback
      const result = await parseCommandWithAI(cmd)
      setOutput((prev) => [...prev, { type: result.success ? 'result' : 'error', text: result.message }])
    } catch (error) {
      setOutput((prev) => [...prev, { type: 'error', text: `Error processing command: ${error instanceof Error ? error.message : 'Unknown error'}` }])
    } finally {
      setIsProcessing(false)
      setInput('')
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !isProcessing) {
      handleCommand(input)
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      const newIndex = historyIndex === -1 ? history.length - 1 : Math.max(0, historyIndex - 1)
      setHistoryIndex(newIndex)
      setInput(history[newIndex] || '')
    } else if (e.key === 'ArrowDown') {
      e.preventDefault()
      const newIndex = historyIndex === -1 ? -1 : Math.min(history.length - 1, historyIndex + 1)
      setHistoryIndex(newIndex)
      setInput(newIndex === -1 ? '' : history[newIndex])
    }
  }

  return (
    <div className="border-t border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-900">
      <div className="max-w-6xl mx-auto flex flex-col h-64">
        <div ref={outputRef} className="flex-1 overflow-y-auto p-4 space-y-1 font-mono text-sm">
          {output.length === 0 ? (
            <div className="space-y-1 text-gray-500 dark:text-gray-400 text-xs">
              <p>Type a command. Try: kick player marlo, broadcast hello world, show players</p>
              <p>Shortcuts: Press / to focus console, Ctrl+T to toggle theme, 1-8 for tabs, Esc to unfocus</p>
            </div>
          ) : (
            output.map((line, i) => (
              <div
                key={i}
                className={
                  line.type === 'command'
                    ? 'text-blue-600 dark:text-blue-400'
                    : line.type === 'error'
                      ? 'text-red-600 dark:text-red-400'
                      : 'text-green-600 dark:text-green-400'
                }
              >
                {sanitizeOutput(line.text)}
              </div>
            ))
          )}
        </div>

        <div className="border-t border-gray-200 dark:border-gray-800 p-4 flex items-center gap-2">
          <span className="text-gray-500 dark:text-gray-400 font-mono text-sm">></span>
          <input
            ref={inputRef}
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type command... (press / to focus, Esc to unfocus)"
            className="flex-1 bg-transparent text-gray-900 dark:text-white font-mono text-sm outline-none disabled:opacity-50"
            disabled={isProcessing}
          />
          <button
            onClick={() => handleCommand(input)}
            className="p-2 hover:bg-gray-200 dark:hover:bg-gray-800 rounded transition-colors disabled:opacity-50"
            disabled={isProcessing}
            title={isProcessing ? 'Processing...' : 'Send command'}
          >
            {isProcessing ? <div className="w-4 h-4 border-2 border-gray-400 border-t-gray-600 rounded-full animate-spin" /> : <Send className="w-4 h-4" />}
          </button>
        </div>
      </div>
    </div>
  )
})

Console.displayName = 'Console'

export default Console
