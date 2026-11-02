// Core dashboard types
export type TabType = 'overview' | 'players' | 'economy' | 'admin' | 'logs' | 'settings' | 'chat' | 'analytics'

export interface Player {
  id: string
  name: string
  level: number
  x: number
  y: number
  heat: number
  money: number
  online: boolean
  joinedAt: number
}

export interface NPC {
  id: string
  name: string
  x: number
  y: number
  mood: string
  role: string
}

export interface WorldPosition {
  x: number
  y: number
  zone: string
  roomId: string
}

export interface ServerStatus {
  online: boolean
  playerCount: number
  maxPlayers: number
  uptime: number
  cpu: number
  memory: number
  bandwidth: number
  fps: number
}

export interface AITokenUsage {
  total: number
  serverKey: number
  byok: number
  limit: number
  daily: number
  dailyLimit: number
}

export interface ChatMessage {
  id: string
  playerId: string
  playerName: string
  npcId?: string
  npcName?: string
  message: string
  timestamp: number
  isNPC: boolean
  moderated: boolean
}

export interface EconomyTransaction {
  id: string
  from: string
  to: string
  amount: number
  type: 'trade' | 'job_pay' | 'crime' | 'gift' | 'tax'
  timestamp: number
  clean: boolean
}

export interface Evidence {
  id: string
  type: 'blood' | 'dna' | 'fingerprint' | 'witness'
  location: WorldPosition
  linkedToPlayer?: string
  strength: number
  timestamp: number
}

export interface AdminLog {
  id: string
  adminId: string
  action: string
  targetId?: string
  details: string
  timestamp: number
}
