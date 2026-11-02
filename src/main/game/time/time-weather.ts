/**
 * Time/Weather Controller
 * Manages day/night cycles and weather effects
 */

export type WeatherType = 'clear' | 'rainy' | 'stormy' | 'foggy' | 'snowy';

export interface WeatherCondition {
  type: WeatherType;
  intensity: number; // 0-100
  temperature: number; // -50 to 50 celsius
  visibility: number; // 0-100
  effects: Record<string, number>; // effect name -> impact
}

export interface TimeState {
  hours: number; // 0-23
  minutes: number; // 0-59
  day: number;
  season: 'spring' | 'summer' | 'fall' | 'winter';
}

export class TimeWeatherController {
  private currentTime: TimeState = {
    hours: 12,
    minutes: 0,
    day: 0,
    season: 'spring',
  };
  private weather: WeatherCondition = {
    type: 'clear',
    intensity: 0,
    temperature: 20,
    visibility: 100,
    effects: {},
  };
  private dayLengthMinutes: number = 1440; // real minutes per game day
  private weatherChangeChance: number = 0.02; // per update

  /**
   * Advance time by minutes
   */
  advanceTime(minutes: number): void {
    this.currentTime.minutes += minutes;

    while (this.currentTime.minutes >= 60) {
      this.currentTime.minutes -= 60;
      this.currentTime.hours++;

      while (this.currentTime.hours >= 24) {
        this.currentTime.hours -= 24;
        this.currentTime.day++;

        // Update season
        const dayOfYear = this.currentTime.day % 365;
        if (dayOfYear < 91) {
          this.currentTime.season = 'spring';
        } else if (dayOfYear < 182) {
          this.currentTime.season = 'summer';
        } else if (dayOfYear < 273) {
          this.currentTime.season = 'fall';
        } else {
          this.currentTime.season = 'winter';
        }
      }
    }

    // Update weather
    this.updateWeather();
  }

  /**
   * Randomly update weather
   */
  private updateWeather(): void {
    if (Math.random() > this.weatherChangeChance) return;

    const weatherTypes: WeatherType[] = ['clear', 'rainy', 'stormy', 'foggy', 'snowy'];
    const newType = weatherTypes[Math.floor(Math.random() * weatherTypes.length)];

    this.weather.type = newType;
    this.weather.intensity = Math.random() * 100;
    this.weather.temperature = 15 + Math.random() * 30 - (this.currentTime.season === 'winter' ? 15 : 0);

    // Update visibility based on weather
    if (newType === 'clear') {
      this.weather.visibility = 100;
    } else if (newType === 'rainy') {
      this.weather.visibility = 70;
    } else if (newType === 'stormy') {
      this.weather.visibility = 30;
    } else if (newType === 'foggy') {
      this.weather.visibility = 40;
    } else if (newType === 'snowy') {
      this.weather.visibility = 50;
    }

    this.updateWeatherEffects();
  }

  /**
   * Update weather effects on gameplay
   */
  private updateWeatherEffects(): void {
    this.weather.effects = {};

    switch (this.weather.type) {
      case 'rainy':
        this.weather.effects['slip_chance'] = 10;
        this.weather.effects['speed_reduction'] = 15;
        break;
      case 'stormy':
        this.weather.effects['slip_chance'] = 30;
        this.weather.effects['speed_reduction'] = 30;
        this.weather.effects['damage_reduction'] = 10;
        break;
      case 'foggy':
        this.weather.effects['visibility_reduction'] = 40;
        this.weather.effects['detection_reduction'] = 20;
        break;
      case 'snowy':
        this.weather.effects['slip_chance'] = 20;
        this.weather.effects['speed_reduction'] = 25;
        this.weather.effects['temperature_damage'] = 5;
        break;
    }
  }

  /**
   * Get current time
   */
  getTime(): TimeState {
    return { ...this.currentTime };
  }

  /**
   * Get current weather
   */
  getWeather(): WeatherCondition {
    return { ...this.weather };
  }

  /**
   * Check if it's night time (19:00 - 06:00)
   */
  isNight(): boolean {
    return this.currentTime.hours >= 19 || this.currentTime.hours < 6;
  }

  /**
   * Get time of day description
   */
  getTimeOfDay(): string {
    if (this.currentTime.hours < 6) return 'night';
    if (this.currentTime.hours < 12) return 'morning';
    if (this.currentTime.hours < 17) return 'afternoon';
    if (this.currentTime.hours < 21) return 'evening';
    return 'night';
  }

  /**
   * Set time manually
   */
  setTime(hours: number, minutes: number): void {
    this.currentTime.hours = Math.max(0, Math.min(23, hours));
    this.currentTime.minutes = Math.max(0, Math.min(59, minutes));
  }
}
