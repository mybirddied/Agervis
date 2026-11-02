import React from 'react'
import DOMPurify from 'isomorphic-dompurify'

// Helper to sanitize player names and status
const sanitizePlayer = (text: string) => DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })

export default function Players() {
  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Player Management</h2>
        <input
          type="text"
          placeholder="Search players..."
          className="px-4 py-2 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 text-gray-900 dark:text-white"
        />
      </div>

      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50 dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
            <tr>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900 dark:text-white">Name</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900 dark:text-white">Heat</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900 dark:text-white">Position</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900 dark:text-white">Money</th>
              <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900 dark:text-white">Status</th>
              <th className="px-6 py-3 text-right text-sm font-semibold text-gray-900 dark:text-white">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
            {[
              { id: 1, name: 'Marlo', heat: 85, x: 120, y: 340, money: 5000, status: 'online' },
              { id: 2, name: 'Citizen', heat: 5, x: 240, y: 180, money: 2000, status: 'online' },
              { id: 3, name: 'Officer Pike', heat: 0, x: 300, y: 250, money: 1500, status: 'online' },
            ].map((player) => (
              <tr key={player.id} className="hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                <td className="px-6 py-4 text-sm font-medium text-gray-900 dark:text-white">{sanitizePlayer(player.name)}</td>
                <td className="px-6 py-4 text-sm text-gray-600 dark:text-gray-400">
                  <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                    player.heat > 50 ? 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400' :
                    player.heat > 20 ? 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400' :
                    'bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400'
                  }`}>
                    {player.heat}
                  </span>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600 dark:text-gray-400">({player.x}, {player.y})</td>
                <td className="px-6 py-4 text-sm font-medium text-gray-900 dark:text-white">${player.money}</td>
                <td className="px-6 py-4 text-sm">
                  <span className="flex items-center gap-2">
                    <span className="w-2 h-2 rounded-full bg-green-500" />
                    <span className="text-gray-600 dark:text-gray-400">{sanitizePlayer(player.status)}</span>
                  </span>
                </td>
                <td className="px-6 py-4 text-right">
                  <button className="text-sm font-medium text-blue-600 dark:text-blue-400 hover:underline">Kick</button>
                  <span className="mx-2 text-gray-300 dark:text-gray-700">|</span>
                  <button className="text-sm font-medium text-blue-600 dark:text-blue-400 hover:underline">Ban</button>
                  <span className="mx-2 text-gray-300 dark:text-gray-700">|</span>
                  <button className="text-sm font-medium text-blue-600 dark:text-blue-400 hover:underline">Teleport</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
