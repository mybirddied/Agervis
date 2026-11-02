import React, { ReactNode, ErrorInfo } from 'react'
import DOMPurify from 'isomorphic-dompurify'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
}

// Helper to sanitize error messages
const sanitizeError = (text: string) => DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })

export class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div className="min-h-screen bg-red-50 dark:bg-red-900/20 flex items-center justify-center p-4">
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-red-200 dark:border-red-800 p-6 max-w-md">
              <h2 className="text-lg font-semibold text-red-900 dark:text-red-100 mb-2">Something went wrong</h2>
              <p className="text-sm text-red-700 dark:text-red-200 mb-4">{sanitizeError(this.state.error?.message || 'Unknown error')}</p>
              <button
                onClick={() => window.location.reload()}
                className="px-4 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition-colors"
              >
                Reload Dashboard
              </button>
            </div>
          </div>
        )
      )
    }

    return this.props.children
  }
}
