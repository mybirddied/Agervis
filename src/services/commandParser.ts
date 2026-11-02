export async function parseCommandWithAI(command: string): Promise<{ success: boolean; message: string }> {
  try {
    // First attempt basic regex parsing for common commands
    const basicResult = parseCommandBasic(command)
    if (basicResult) return basicResult

    // Fall back to Claude Haiku for complex natural language parsing
    const response = await fetch('/api/console/parse', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ command }),
    })

    if (!response.ok) {
      throw new Error('Failed to parse command with AI')
    }

    const data = await response.json()
    return data
  } catch (error) {
    return { success: false, message: `Error processing command: ${error instanceof Error ? error.message : 'Unknown error'}` }
  }
}

function parseCommandBasic(cmd: string): { success: boolean; message: string } | null {
  const lower = cmd.toLowerCase().trim()

  // Kick command
  if (lower.startsWith('kick')) {
    const match = cmd.match(/kick\s+(?:player\s+)?(\w+)/i)
    if (match) return { success: true, message: `Kicked player "${match[1]}"` }
  }

  // Ban command
  if (lower.startsWith('ban')) {
    const match = cmd.match(/ban\s+(?:player\s+)?(\w+)(?:\s+for\s+(\d+)\s+days)?/i)
    if (match) {
      const days = match[2] || '7'
      return { success: true, message: `Banned player "${match[1]}" for ${days} days` }
    }
  }

  // Broadcast command
  if (lower.startsWith('broadcast')) {
    const msg = cmd.substring(10).trim()
    if (msg) return { success: true, message: `Broadcast: "${msg}" sent to all players` }
  }

  // Show players command
  if (lower.startsWith('show players')) {
    return { success: true, message: 'Found 3 players: Marlo (heat: 85), Citizen (heat: 5), Officer Pike (heat: 0)' }
  }

  // Help command
  if (lower.startsWith('help')) {
    return {
      success: true,
      message: `Commands: kick, ban, broadcast, show players, teleport, restart, shutdown, give money, reset heat, spawn event`,
    }
  }

  // Teleport command
  if (lower.startsWith('teleport')) {
    const match = cmd.match(/teleport\s+(?:player\s+)?(\w+)\s+to\s+([\d.]+)[,\s]+([\d.]+)/i)
    if (match) return { success: true, message: `Teleported player "${match[1]}" to (${match[2]}, ${match[3]})` }
  }

  // Restart command
  if (lower.startsWith('restart')) {
    return { success: true, message: 'Server restart initiated. Restarting in 30 seconds.' }
  }

  // Shutdown command
  if (lower.startsWith('shutdown')) {
    return { success: true, message: 'Emergency shutdown initiated. All players will be disconnected.' }
  }

  // Give money command
  if (lower.startsWith('give money')) {
    const match = cmd.match(/give\s+money\s+(?:to\s+)?(\w+)\s+(\d+)/i)
    if (match) return { success: true, message: `Gave $${match[2]} to player "${match[1]}"` }
  }

  // Reset heat command
  if (lower.startsWith('reset heat')) {
    const match = cmd.match(/reset\s+heat\s+(?:for\s+)?(\w+)/i)
    if (match) return { success: true, message: `Reset heat for player "${match[1]}" to 0` }
  }

  // Spawn event command
  if (lower.startsWith('spawn event')) {
    const match = cmd.match(/spawn\s+event\s+(\w+)/i)
    if (match) return { success: true, message: `Spawned event: ${match[1]}` }
  }

  return null
}
