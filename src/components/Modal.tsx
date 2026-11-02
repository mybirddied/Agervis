import React, { ReactNode } from 'react'
import { X } from 'lucide-react'
import DOMPurify from 'isomorphic-dompurify'

interface ModalProps {
  isOpen: boolean
  title: string
  children: ReactNode
  onClose: () => void
  actions?: Array<{ label: string; onClick: () => void; variant?: 'primary' | 'danger' | 'secondary' }>
}

// Helper to sanitize modal titles
const sanitizeTitle = (text: string) => DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })

export function Modal({ isOpen, title, children, onClose, actions }: ModalProps) {
  if (!isOpen) return null

  return (
    <div className="fixed inset-0 bg-black/50 dark:bg-black/70 flex items-center justify-center z-50">
      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 shadow-xl max-w-md w-full mx-4">
        <div className="flex items-center justify-between p-6 border-b border-gray-200 dark:border-gray-800">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">{sanitizeTitle(title)}</h2>
          <button
            onClick={onClose}
            className="p-1 hover:bg-gray-100 dark:hover:bg-gray-800 rounded transition-colors"
            aria-label="Close modal"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6">{children}</div>

        {actions && (
          <div className="border-t border-gray-200 dark:border-gray-800 p-6 flex gap-2 justify-end">
            {actions.map((action, i) => (
              <button
                key={i}
                onClick={action.onClick}
                className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                  action.variant === 'danger'
                    ? 'bg-red-600 hover:bg-red-700 text-white'
                    : action.variant === 'secondary'
                      ? 'bg-gray-200 dark:bg-gray-800 text-gray-900 dark:text-white hover:bg-gray-300 dark:hover:bg-gray-700'
                      : 'bg-blue-600 hover:bg-blue-700 text-white'
                }`}
              >
                {sanitizeTitle(action.label)}
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

export function useModal() {
  const [isOpen, setIsOpen] = React.useState(false)
  const open = React.useCallback(() => setIsOpen(true), [])
  const close = React.useCallback(() => setIsOpen(false), [])
  return { isOpen, open, close }
}
