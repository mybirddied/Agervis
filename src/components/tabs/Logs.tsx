import React from 'react'

export default function Logs() {
  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Logs & Monitoring</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Audit Log</h3>
          <div className="space-y-2 text-sm">
            {[
              { admin: 'Admin1', action: 'Kicked Marlo', time: '2 min' },
              { admin: 'Admin2', action: 'Banned Spammer42', time: '15 min' },
              { admin: 'Admin1', action: 'Teleported Citizen', time: '1 hour' },
            ].map((log, i) => (
              <div key={i} className="flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800 rounded">
                <span className="text-gray-900 dark:text-white">{log.admin}: {log.action}</span>
                <span className="text-gray-500 dark:text-gray-400">{log.time} ago</span>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Evidence Tracker</h3>
          <div className="space-y-2 text-sm">
            {[
              { type: 'Blood', location: 'Downtown Alley', strength: 'High' },
              { type: 'Witness', location: 'Police Station', strength: 'Medium' },
              { type: 'DNA', location: 'Crime Scene', strength: 'High' },
            ].map((evidence, i) => (
              <div key={i} className="flex items-center justify-between p-2 bg-gray-50 dark:bg-gray-800 rounded">
                <span className="text-gray-900 dark:text-white">{evidence.type} at {evidence.location}</span>
                <span className={`text-xs font-medium ${
                  evidence.strength === 'High' ? 'text-red-600' : 'text-yellow-600'
                }`}>{evidence.strength}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
