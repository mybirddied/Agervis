import React from 'react'

export default function Overview() {
  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card title="Total Players" value="12" subtitle="Online now" />
        <Card title="Server CPU" value="35.2%" subtitle="Normal usage" />
        <Card title="Total Money" value="$125,439" subtitle="Clean: $87,230" />
        <Card title="AI Tokens Today" value="45,230" subtitle="Under limit" />
      </div>
      <Card title="Recent Admin Actions" content={<RecentActions />} />
    </div>
  )
}

function Card({ title, value, subtitle, content }: any) {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
      {value && (
        <>
          <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400">{title}</h3>
          <p className="text-3xl font-bold text-gray-900 dark:text-white mt-2">{value}</p>
          {subtitle && <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">{subtitle}</p>}
        </>
      )}
      {content && (
        <>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">{title}</h3>
          {content}
        </>
      )}
    </div>
  )
}

function RecentActions() {
  const actions = [
    { id: 1, admin: 'Admin1', action: 'Kicked player', target: 'Marlo', time: '2 minutes ago' },
    { id: 2, admin: 'Admin2', action: 'Banned player', target: 'Spammer42', time: '15 minutes ago' },
    { id: 3, admin: 'Admin1', action: 'Teleported player', target: 'Citizen', time: '1 hour ago' },
  ]

  return (
    <div className="space-y-2">
      {actions.map((action) => (
        <div key={action.id} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded">
          <div>
            <p className="font-medium text-gray-900 dark:text-white">{action.action}</p>
            <p className="text-sm text-gray-500 dark:text-gray-400">{action.admin} → {action.target}</p>
          </div>
          <span className="text-sm text-gray-500 dark:text-gray-400">{action.time}</span>
        </div>
      ))}
    </div>
  )
}
