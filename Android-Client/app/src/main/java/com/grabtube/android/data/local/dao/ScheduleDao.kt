package com.grabtube.android.data.local.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.grabtube.android.data.local.entity.ScheduleEntity
import com.grabtube.android.data.local.entity.ScheduledDownloadEntity
import kotlinx.coroutines.flow.Flow

/**
 * Data Access Object for schedule operations
 */
@Dao
interface ScheduleDao {
    @Query("SELECT * FROM schedules ORDER BY createdAt DESC")
    fun observeAll(): Flow<List<ScheduleEntity>>

    @Query("SELECT * FROM schedules WHERE isActive = 1 ORDER BY createdAt DESC")
    fun observeActive(): Flow<List<ScheduleEntity>>

    @Query("SELECT * FROM schedules WHERE id = :id")
    fun observeById(id: String): Flow<ScheduleEntity?>

    @Query("SELECT * FROM schedules ORDER BY createdAt DESC")
    suspend fun getAll(): List<ScheduleEntity>

    @Query("SELECT * FROM schedules WHERE id = :id")
    suspend fun getById(id: String): ScheduleEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(schedule: ScheduleEntity)

    @Update
    suspend fun update(schedule: ScheduleEntity)

    @Query("DELETE FROM schedules WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("UPDATE schedules SET isActive = :isActive WHERE id = :id")
    suspend fun updateActiveStatus(id: String, isActive: Boolean)

    @Query("""
        SELECT * FROM schedules
        WHERE isActive = 1
        AND (nextExecutionAt IS NULL OR nextExecutionAt <= :toTime)
        ORDER BY nextExecutionAt ASC
    """)
    suspend fun getSchedulesToExecute(fromTime: Long, toTime: Long): List<ScheduleEntity>

    @Query("""
        UPDATE schedules
        SET lastExecutedAt = :executedAt,
            executionCount = executionCount + 1,
            nextExecutionAt = NULL
        WHERE id = :id
    """)
    suspend fun updateExecutionInfo(id: String, executedAt: Long)

    @Query("SELECT * FROM scheduled_downloads WHERE scheduleId = :scheduleId ORDER BY scheduledAt DESC")
    suspend fun getScheduledDownloads(scheduleId: String): List<ScheduledDownloadEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertScheduledDownload(scheduledDownload: ScheduledDownloadEntity)

    @Update
    suspend fun updateScheduledDownload(scheduledDownload: ScheduledDownloadEntity)

    @Query("DELETE FROM scheduled_downloads WHERE executedAt < :olderThan AND isExecuted = 1")
    suspend fun deleteOldScheduledDownloads(olderThan: Long)

    @Query("""
        SELECT
            (SELECT COUNT(*) FROM schedules) as totalSchedules,
            (SELECT COUNT(*) FROM schedules WHERE isActive = 1) as activeSchedules,
            (SELECT COUNT(*) FROM scheduled_downloads) as totalExecutions,
            (SELECT COUNT(*) FROM scheduled_downloads WHERE isSuccessful = 1) as successfulExecutions
    """)
    suspend fun getExecutionStats(): Map<String, Any>
}