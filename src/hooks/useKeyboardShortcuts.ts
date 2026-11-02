import { useEffect } from 'react'

interface ShortcutConfig {
  key: string
  ctrlKey?: boolean
  shiftKey?: boolean
  altKey?: boolean
  callback: () => void
}

export function useKeyboardShortcuts(shortcuts: ShortcutConfig[]) {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      for (const shortcut of shortcuts) {
        const keyMatch = e.key.toLowerCase() === shortcut.key.toLowerCase()
        const ctrlMatch = (shortcut.ctrlKey || false) === (e.ctrlKey || e.metaKey)
        const shiftMatch = (shortcut.shiftKey || false) === e.shiftKey
        const altMatch = (shortcut.altKey || false) === e.altKey

        if (keyMatch && ctrlMatch && shiftMatch && altMatch) {
          e.preventDefault()
          shortcut.callback()
        }
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [shortcuts])
}

export const DEFAULT_SHORTCUTS = {
  TOGGLE_CONSOLE: { key: '/', callback: () => {} },
  TOGGLE_THEME: { key: 't', ctrlKey: true, callback: () => {} },
  TAB_1: { key: '1', callback: () => {} },
  TAB_2: { key: '2', callback: () => {} },
  TAB_3: { key: '3', callback: () => {} },
  TAB_4: { key: '4', callback: () => {} },
  TAB_5: { key: '5', callback: () => {} },
  TAB_6: { key: '6', callback: () => {} },
  TAB_7: { key: '7', callback: () => {} },
  TAB_8: { key: '8', callback: () => {} },
  ESCAPE: { key: 'Escape', callback: () => {} },
}
