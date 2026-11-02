import React from 'react'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'

export default function Analytics() {
  const performanceData = [
    { time: '0h', cpu: 20, memory: 15, bandwidth: 12 },
    { time: '4h', cpu: 28, memory: 22, bandwidth: 18 },
    { time: '8h', cpu: 35, memory: 30, bandwidth: 25 },
    { time: '12h', cpu: 42, memory: 38, bandwidth: 32 },
    { time: '16h', cpu: 38, memory: 35, bandwidth: 28 },
    { time: '20h', cpu: 32, memory: 25, bandwidth: 20 },
  ]

  const playerActivityData = [
    { hour: '0h', players: 5 },
    { hour: '1h', players: 8 },
    { hour: '2h', players: 12 },
    { hour: '3h', players: 15 },
    { hour: '4h', players: 18 },
    { hour: '5h', players: 14 },
    { hour: '6h', players: 10 },
    { hour: '7h', players: 12 },
  ]

  const tokenUsageData = [
    { name: 'Server Key', value: 12450, fill: '#3b82f6' },
    { name: 'BYOK Total', value: 32780, fill: '#10b981' },
  ]

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Analytics</h2>

      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Performance Metrics Over Time</h3>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={performanceData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
            <XAxis dataKey="time" stroke="#9ca3af" />
            <YAxis stroke="#9ca3af" />
            <Tooltip contentStyle={{ backgroundColor: '#1f2937', border: '1px solid #374151', borderRadius: '8px' }} />
            <Legend />
            <Line type="monotone" dataKey="cpu" stroke="#3b82f6" strokeWidth={2} name="CPU %" />
            <Line type="monotone" dataKey="memory" stroke="#10b981" strokeWidth={2} name="Memory %" />
            <Line type="monotone" dataKey="bandwidth" stroke="#f59e0b" strokeWidth={2} name="Bandwidth %" />
          </LineChart>
        </ResponsiveContainer>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Player Activity Trend</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={playerActivityData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
              <XAxis dataKey="hour" stroke="#9ca3af" />
              <YAxis stroke="#9ca3af" />
              <Tooltip contentStyle={{ backgroundColor: '#1f2937', border: '1px solid #374151', borderRadius: '8px' }} />
              <Bar dataKey="players" fill="#3b82f6" radius={[8, 8, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">AI Token Usage Breakdown</h3>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie data={tokenUsageData} cx="50%" cy="50%" labelLine={false} label={({ name, value }) => `${name}: ${value.toLocaleString()}`} outerRadius={80} fill="#8884d8" dataKey="value">
                {tokenUsageData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.fill} />
                ))}
              </Pie>
              <Tooltip formatter={(value) => value.toLocaleString()} contentStyle={{ backgroundColor: '#1f2937', border: '1px solid #374151', borderRadius: '8px' }} />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <MetricCard label="Current CPU Usage" value="35.2%" percentage={35.2} color="bg-blue-600" />
        <MetricCard label="Current Memory" value="512MB / 2GB" percentage={25.6} color="bg-green-600" />
        <MetricCard label="Current Bandwidth" value="2.4 Mbps" percentage={45} color="bg-yellow-600" />
      </div>
    </div>
  )
}

function MetricCard({ label, value, percentage, color }: { label: string; value: string; percentage: number; color: string }) {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
      <p className="text-sm text-gray-600 dark:text-gray-400 mb-2">{label}</p>
      <p className="text-2xl font-bold text-gray-900 dark:text-white mb-3">{value}</p>
      <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
        <div className={`${color} h-2 rounded-full transition-all`} style={{ width: `${percentage}%` }}></div>
      </div>
    </div>
  )
}
