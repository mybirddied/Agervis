/**
 * NPC Schedule System
 * Manages daily routines and location changes for NPCs
 */

export interface ScheduleEntry {
  startTime: number; // minutes from midnight (0-1439)
  endTime: number;
  location: string;
  action: string;
  importance: 'critical' | 'important' | 'routine';
}

export interface DailySchedule {
  npcId: string;
  day: number;
  entries: ScheduleEntry[];
}

export class ScheduleSystem {
  private schedules: Map<string, DailySchedule[]> = new Map();
  private currentGameTime: number = 0; // minutes

  /**
   * Create a basic schedule for an NPC
   */
  createBasicSchedule(npcId: string, role: string): ScheduleEntry[] {
    const schedules: Record<string, ScheduleEntry[]> = {
      shopkeeper: [
        { startTime: 360, endTime: 540, location: 'home', action: 'morning_routine', importance: 'routine' },
        { startTime: 540, endTime: 1080, location: 'shop', action: 'work', importance: 'critical' },
        { startTime: 1080, endTime: 1140, location: 'restaurant', action: 'lunch', importance: 'routine' },
        { startTime: 1140, endTime: 1380, location: 'shop', action: 'work', importance: 'critical' },
        { startTime: 1380, endTime: 1440, location: 'home', action: 'evening_routine', importance: 'routine' },
      ],
      employee: [
        { startTime: 420, endTime: 540, location: 'home', action: 'morning_routine', importance: 'routine' },
        { startTime: 540, endTime: 1080, location: 'workplace', action: 'work', importance: 'critical' },
        { startTime: 1080, endTime: 1140, location: 'restaurant', action: 'lunch', importance: 'routine' },
        { startTime: 1140, endTime: 1320, location: 'workplace', action: 'work', importance: 'critical' },
        { startTime: 1320, endTime: 1440, location: 'home', action: 'evening_routine', importance: 'routine' },
      ],
      civilian: [
        { startTime: 480, endTime: 600, location: 'home', action: 'morning_routine', importance: 'routine' },
        { startTime: 600, endTime: 1200, location: 'city', action: 'roaming', importance: 'routine' },
        { startTime: 1200, endTime: 1260, location: 'restaurant', action: 'lunch', importance: 'routine' },
        { startTime: 1260, endTime: 1380, location: 'city', action: 'roaming', importance: 'routine' },
        { startTime: 1380, endTime: 1440, location: 'home', action: 'evening_routine', importance: 'routine' },
      ],
    };

    return schedules[role] || schedules['civilian'];
  }

  /**
   * Get current schedule entry for NPC
   */
  getCurrentScheduleEntry(npcId: string, gameTime: number): ScheduleEntry | null {
    const daySchedules = this.schedules.get(npcId) || [];
    const dayIndex = Math.floor(gameTime / 1440);
    const daySchedule = daySchedules[dayIndex];

    if (!daySchedule) return null;

    const timeInDay = gameTime % 1440;
    return daySchedule.entries.find(
      (entry) => timeInDay >= entry.startTime && timeInDay < entry.endTime
    ) || null;
  }

  /**
   * Get next scheduled action
   */
  getNextScheduledAction(npcId: string, gameTime: number): ScheduleEntry | null {
    const daySchedules = this.schedules.get(npcId) || [];
    const dayIndex = Math.floor(gameTime / 1440);
    const daySchedule = daySchedules[dayIndex];

    if (!daySchedule) return null;

    const timeInDay = gameTime % 1440;
    return daySchedule.entries.find((entry) => entry.startTime > timeInDay) || null;
  }

  /**
   * Update game time
   */
  updateGameTime(deltaMinutes: number): void {
    this.currentGameTime += deltaMinutes;
  }

  /**
   * Get current game time in day (0-1439)
   */
  getCurrentTimeInDay(): number {
    return this.currentGameTime % 1440;
  }

  /**
   * Get current day
   */
  getCurrentDay(): number {
    return Math.floor(this.currentGameTime / 1440);
  }
}
