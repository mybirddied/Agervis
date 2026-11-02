import React from 'react'
import { BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'

export default function Economy() {
  const transactionData = [
    { hour: '0h', trades: 120, jobs: 200, crimes: 45 },
    { hour: '4h', trades: 180, jobs: 240, crimes: 52 },
    { hour: '8h', trades: 320, jobs: 280, crimes: 78 },
    { hour: '12h', trades: 280, jobs: 320, crimes: 95 },
    { hour: '16h', trades: 410, jobs: 380, crimes: 120 },
    { hour: '20h', trades: 520, jobs: 420, crimes: 145 },
  ]

  const moneyDistribution = [
    { name: 'Clean Money', value: 87230, fill: '#10b981' },
    { name: 'Dirty Money', value: 38209, fill: '#ef4444' },
  ]

  const recentTransactions = [
    { id: 1, from: 'Marlo', to: 'Moth', amount: 500, type: 'trade', time: '5 min ago' },
    { id: 2, from: 'System', to: 'Citizen', amount: 250, type: 'job_pay', time: '15 min ago' },
    { id: 3, from: 'Officer Pike', to: 'Evidence', amount: 1000, type: 'crime', time: '1 hour ago' },
  ]

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card title="Total Money" value="$125,439" />
        <Card title="Clean Money" value="$87,230" />
        <Card title="Dirty Money" value="$38,209" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Transaction Types Over Time</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={transactionData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
              <XAxis dataKey="hour" stroke="#9ca3af" />
              <YAxis stroke="#9ca3af" />
              <Tooltip contentStyle={{ backgroundColor: '#1f2937', border: '1px solid #374151', borderRadius: '8px' }} />
              <Legend />
              <Bar dataKey="trades" stackId="a" fill="#3b82f6" />
              <Bar dataKey="jobs" stackId="a" fill="#10b981" />
              <Bar dataKey="crimes" stackId="a" fill="#ef4444" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Money Distribution</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie data={moneyDistribution} cx="50%" cy="50%" labelLine={false} label={({ name, value }) => `${name}: $${value.toLocaleString()}`} outerRadius={80} fill="#8884d8" dataKey="value">
                {moneyDistribution.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.fill} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => `$${value.toLocaleString()}`} contentStyle={{ backgroundColor: '#1f2937', border: '1px solid #374151', borderRadius: '8px' }} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Recent Transactions</h3>
        <div className="space-y-2">
          {recentTransactions.map((tx) => (
            <div key={tx.id} className="flex items-center justify-between p-3 bg-gray-50 dark:bg-gray-800 rounded">
              <div>
                <p className="font-medium text-gray-900 dark:text-white">{tx.from} → {tx.to}</p>
                <p className="text-sm text-gray-500 dark:text-gray-400">{tx.type}</p>
              </div>
              <div className="text-right">
                <p className="font-semibold text-gray-900 dark:text-white">${tx.amount}</p>
                <p className="text-sm text-gray-500 dark:text-gray-400">{tx.time}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

function Card({ title, value }: any) {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
      <h3 className="text-sm font-medium text-gray-600 dark:text-gray-400">{title}</h3>
      <p className="text-3xl font-bold text-gray-900 dark:text-white mt-2">{value}</p>
    </div>
  )
}
