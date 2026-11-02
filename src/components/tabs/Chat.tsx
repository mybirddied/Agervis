import React from 'react'
import DOMPurify from 'isomorphic-dompurify'

// Helper to sanitize chat messages and player names
const sanitizeChat = (text: string) => DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })

export default function Chat() {
  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Chat Monitor</h2>

      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Live Chat Feed</h3>
        <div className="space-y-3 max-h-96 overflow-y-auto">
          {[
            { player: 'Marlo', npc: 'Moth', message: 'Got anything for me?', sentiment: 'neutral' },
            { player: 'Citizen', npc: 'Officer Pike', message: 'Is everything okay?', sentiment: 'positive' },
            { player: 'Player123', msg: 'fuck this shit', flagged: true, sentiment: 'negative' },
          ].map((chat, i) => (
            <div key={i} className={`p-3 rounded-lg ${
              chat.flagged ? 'bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800' :
              'bg-gray-50 dark:bg-gray-800'
            }`}>
              <div className="flex items-center justify-between mb-1">
                <span className="font-medium text-gray-900 dark:text-white">{sanitizeChat(chat.player || 'Player')}</span>
                {chat.npc && <span className="text-sm text-gray-500 dark:text-gray-400">→ {sanitizeChat(chat.npc)}</span>}
              </div>
              <p className="text-sm text-gray-700 dark:text-gray-300">{sanitizeChat(chat.message || chat.msg || '')}</p>
              {chat.flagged && <p className="text-xs text-red-600 dark:text-red-400 mt-2">Flagged for review</p>}
            </div>
          ))}
        </div>
      </div>

      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Moderation Tools</h3>
        <div className="space-y-2">
          <button className="w-full px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors">Review Flagged Messages</button>
          <button className="w-full px-4 py-2 bg-yellow-600 hover:bg-yellow-700 text-white rounded-lg font-medium transition-colors">Mute Player</button>
          <button className="w-full px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition-colors">Ban Player</button>
        </div>
      </div>
    </div>
  )
}
