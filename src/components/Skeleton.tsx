import React from 'react'

export function SkeletonCard() {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 animate-pulse">
      <div className="h-4 bg-gray-200 dark:bg-gray-800 rounded w-1/3 mb-4"></div>
      <div className="h-8 bg-gray-200 dark:bg-gray-800 rounded w-1/2"></div>
    </div>
  )
}

export function SkeletonTable() {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 space-y-3">
      {[1, 2, 3, 4, 5].map((i) => (
        <div key={i} className="h-12 bg-gray-200 dark:bg-gray-800 rounded animate-pulse"></div>
      ))}
    </div>
  )
}

export function SkeletonChart() {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6">
      <div className="h-4 bg-gray-200 dark:bg-gray-800 rounded w-1/3 mb-4 animate-pulse"></div>
      <div className="h-64 bg-gray-200 dark:bg-gray-800 rounded animate-pulse"></div>
    </div>
  )
}

export function LoadingSpinner() {
  return (
    <div className="flex items-center justify-center p-8">
      <div className="w-8 h-8 border-4 border-gray-300 dark:border-gray-600 border-t-blue-600 rounded-full animate-spin"></div>
    </div>
  )
}
