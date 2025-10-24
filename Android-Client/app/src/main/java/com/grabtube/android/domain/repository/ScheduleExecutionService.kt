package com.grabtube.android.domain.repository

/**
 * Service for managing schedule execution
 */
interface ScheduleExecutionService {
    /**
     * Start the schedule execution service
     */
    suspend fun start()

    /**
     * Stop the schedule execution service
     */
    suspend fun stop()

    /**
     * Check and execute due schedules
     */
    suspend fun checkAndExecuteSchedules()

    /**
     * Force execute a specific schedule
     */
    suspend fun executeScheduleNow(scheduleId: String)

    /**
     * Get execution statistics
     */
    suspend fun getExecutionStats(): Map<String, Any>
}