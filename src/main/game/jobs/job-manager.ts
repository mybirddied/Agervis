/**
 * Job System Manager
 * Manages shifts, pay calculations, and performance tracking
 */

export type JobType = 'delivery' | 'construction' | 'security' | 'hacking' | 'assassination' | 'theft' | 'legitimate';

export interface JobOffer {
  id: string;
  title: string;
  type: JobType;
  employer: string;
  pay: number;
  difficulty: number; // 1-10
  risk: number; // 0-100, heat risk
  location: string;
  duration: number; // minutes
  requirements: {
    minSkill?: Record<string, number>;
    equipment?: string[];
  };
  active: boolean;
}

export interface JobShift {
  jobId: string;
  playerId: string;
  startTime: number;
  endTime: number;
  completed: boolean;
  performance: number; // 0-100
  pay: number;
}

export class JobManager {
  private jobs: Map<string, JobOffer> = new Map();
  private shifts: Map<string, JobShift> = new Map();
  private playerReputation: Map<string, number> = new Map(); // per employer

  /**
   * Create a job offer
   */
  createJobOffer(
    title: string,
    type: JobType,
    employer: string,
    pay: number,
    difficulty: number,
    risk: number,
    location: string,
    duration: number
  ): JobOffer {
    const jobId = `job_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const job: JobOffer = {
      id: jobId,
      title,
      type,
      employer,
      pay,
      difficulty,
      risk,
      location,
      duration,
      requirements: {},
      active: true,
    };
    this.jobs.set(jobId, job);
    return job;
  }

  /**
   * Accept a job and create a shift
   */
  acceptJob(jobId: string, playerId: string): JobShift | null {
    const job = this.jobs.get(jobId);
    if (!job || !job.active) return null;

    const shift: JobShift = {
      jobId,
      playerId,
      startTime: Date.now(),
      endTime: Date.now() + job.duration * 60000,
      completed: false,
      performance: 0,
      pay: job.pay,
    };

    const shiftId = `shift_${Date.now()}`;
    this.shifts.set(shiftId, shift);
    return shift;
  }

  /**
   * Complete a job
   */
  completeJob(shiftId: string, performance: number): number {
    const shift = this.shifts.get(shiftId);
    if (!shift) return 0;

    shift.completed = true;
    shift.performance = Math.max(0, Math.min(100, performance));

    // Adjust pay based on performance
    const performanceMultiplier = 0.5 + (performance / 100) * 1.5; // 0.5x to 2x
    const finalPay = Math.round(shift.pay * performanceMultiplier);

    // Update employer reputation
    const job = this.jobs.get(shift.jobId);
    if (job) {
      const currentRep = this.playerReputation.get(`${job.employer}_${shift.playerId}`) || 0;
      this.playerReputation.set(
        `${job.employer}_${shift.playerId}`,
        currentRep + (performance - 50) * 0.2
      );
    }

    return finalPay;
  }

  /**
   * Get active jobs
   */
  getActiveJobs(): JobOffer[] {
    return Array.from(this.jobs.values()).filter((job) => job.active);
  }

  /**
   * Get jobs by type
   */
  getJobsByType(type: JobType): JobOffer[] {
    return this.getActiveJobs().filter((job) => job.type === type);
  }

  /**
   * Get player's reputation with employer
   */
  getReputation(playerId: string, employer: string): number {
    return this.playerReputation.get(`${employer}_${playerId}`) || 0;
  }

  /**
   * Get available jobs for player
   */
  getAvailableJobs(playerId: string): JobOffer[] {
    return this.getActiveJobs().filter((job) => {
      const rep = this.getReputation(playerId, job.employer);
      return rep > -50; // player not blacklisted
    });
  }
}
