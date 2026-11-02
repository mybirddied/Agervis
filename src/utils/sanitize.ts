import DOMPurify from 'isomorphic-dompurify'

/**
 * Sanitize user-generated content by removing all HTML tags
 * Used for: player names, chat messages, error messages, command output
 */
export const sanitizeText = (text: string): string => {
  return DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })
}

/**
 * Sanitize HTML content while preserving safe formatting
 * Used for: rich text, styled messages (when needed)
 */
export const sanitizeHTML = (html: string): string => {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'br', 'p', 'span'],
    ALLOWED_ATTR: ['class'],
  })
}

/**
 * Sanitize URLs to prevent javascript: protocol attacks
 */
export const sanitizeURL = (url: string): string => {
  if (!url) return ''
  // Reject javascript: and data: protocols
  if (url.startsWith('javascript:') || url.startsWith('data:')) {
    return ''
  }
  return url
}
