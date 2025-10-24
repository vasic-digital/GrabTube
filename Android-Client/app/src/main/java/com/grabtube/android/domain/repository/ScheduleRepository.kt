package com.grabtube.android.domain.repository

import com.grabtube.android.domain.model.Schedule
import com.grabtube.android.domain.model.ScheduledDownload
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for schedule operations
 */
interface ScheduleRepository {
    /**
     * Observe all schedules
     */
    fun observeSchedules(): Flow<List<Schedule>>

    /**
     * Observe active schedules only
     */
    fun observeActiveSchedules(): Flow<List<Schedule>>

    /**
     * Observe a specific schedule by ID
     */
    fun observeSchedule(id: String): Flow<Schedule?>

    /**
     * Get all schedules
     */
    suspend fun getAllSchedules(): List<Schedule>

    /**
     * Get a schedule by ID
     */
    suspend fun getScheduleById(id: String): Schedule?

    /**
     * Create a new schedule
     */
    suspend fun createSchedule(schedule: Schedule): Schedule

    /**
     * Update an existing schedule
     */
    suspend fun updateSchedule(schedule: Schedule): Schedule

    /**
     * Delete a schedule
     */
    suspend fun deleteSchedule(id: String)

    /**
     * Enable/disable a schedule
     */
    suspend fun toggleSchedule(id: String, isActive: Boolean)

    /**
     * Get schedules that should execute now
     */
    suspend fun getSchedulesToExecute(currentTime: java.time.Instant = java.time.Instant.now()): List<Schedule>

    /**
     * Mark a schedule as executed
     */
    suspend fun markScheduleExecuted(id: String, executedAt: java.time.Instant = java.time.Instant.now())

    /**
     * Get scheduled downloads for a schedule
     */
    suspend fun getScheduledDownloads(scheduleId: String): List<ScheduledDownload>

    /**
     * Create a scheduled download
     */
    suspend fun createScheduledDownload(scheduledDownload: ScheduledDownload): ScheduledDownload

    /**
     * Update a scheduled download
     */
    suspend fun updateScheduledDownload(scheduledDownload: ScheduledDownload): ScheduledDownload

    /**
     * Get next execution times for all active schedules
     */
    suspend fun getNextExecutionTimes(): Map<String, java.time.Instant?>

    /**
     * Clean up old completed scheduled downloads
     */
    suspend fun cleanupOldScheduledDownloads(olderThan: java.time.Instant = java.time.Instant.now().minus(java.time.Duration.ofDays(30)))
}