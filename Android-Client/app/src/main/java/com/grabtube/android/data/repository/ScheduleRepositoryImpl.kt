package com.grabtube.android.data.repository

import com.grabtube.android.data.local.dao.ScheduleDao
import com.grabtube.android.data.local.entity.ScheduleEntity
import com.grabtube.android.data.local.entity.ScheduledDownloadEntity
import com.grabtube.android.domain.model.Schedule
import com.grabtube.android.domain.model.ScheduledDownload
import com.grabtube.android.domain.repository.ScheduleRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ScheduleRepositoryImpl @Inject constructor(
    private val scheduleDao: ScheduleDao
) : ScheduleRepository {

    override fun observeSchedules(): Flow<List<Schedule>> {
        return scheduleDao.observeAll().map { entities ->
            entities.map { it.toDomain() }
        }
    }

    override fun observeActiveSchedules(): Flow<List<Schedule>> {
        return scheduleDao.observeActive().map { entities ->
            entities.map { it.toDomain() }
        }
    }

    override fun observeSchedule(id: String): Flow<Schedule?> {
        return scheduleDao.observeById(id).map { entity ->
            entity?.toDomain()
        }
    }

    override suspend fun getAllSchedules(): List<Schedule> {
        return scheduleDao.getAll().map { it.toDomain() }
    }

    override suspend fun getScheduleById(id: String): Schedule? {
        return scheduleDao.getById(id)?.toDomain()
    }

    override suspend fun createSchedule(schedule: Schedule): Schedule {
        val entity = ScheduleEntity.fromDomain(schedule)
        scheduleDao.insert(entity)
        return schedule
    }

    override suspend fun updateSchedule(schedule: Schedule): Schedule {
        val entity = ScheduleEntity.fromDomain(schedule)
        scheduleDao.update(entity)
        return schedule
    }

    override suspend fun deleteSchedule(id: String) {
        scheduleDao.deleteById(id)
    }

    override suspend fun toggleSchedule(id: String, isActive: Boolean) {
        scheduleDao.updateActiveStatus(id, isActive)
    }

    override suspend fun getSchedulesToExecute(currentTime: Instant): List<Schedule> {
        val timeWindow = java.time.Duration.ofMinutes(5) // Check 5 minutes ahead
        val fromTime = currentTime.minus(timeWindow).epochSecond
        val toTime = currentTime.plus(timeWindow).epochSecond

        val entities = scheduleDao.getSchedulesToExecute(fromTime, toTime)
        val schedules = entities.map { it.toDomain() }

        // Filter schedules that should actually execute now
        return schedules.filter { it.shouldExecuteNow(currentTime) }
    }

    override suspend fun markScheduleExecuted(id: String, executedAt: Instant) {
        scheduleDao.updateExecutionInfo(id, executedAt.epochSecond)
    }

    override suspend fun getScheduledDownloads(scheduleId: String): List<ScheduledDownload> {
        return scheduleDao.getScheduledDownloads(scheduleId).map { it.toDomain() }
    }

    override suspend fun createScheduledDownload(scheduledDownload: ScheduledDownload): ScheduledDownload {
        val entity = ScheduledDownloadEntity.fromDomain(scheduledDownload)
        scheduleDao.insertScheduledDownload(entity)
        return scheduledDownload
    }

    override suspend fun updateScheduledDownload(scheduledDownload: ScheduledDownload): ScheduledDownload {
        val entity = ScheduledDownloadEntity.fromDomain(scheduledDownload)
        scheduleDao.updateScheduledDownload(entity)
        return scheduledDownload
    }

    override suspend fun getNextExecutionTimes(): Map<String, Instant?> {
        val schedules = getAllSchedules()
        return schedules.associate { schedule ->
            schedule.id to if (schedule.isActive && !schedule.isExpired()) {
                schedule.calculateNextExecution()
            } else {
                null
            }
        }
    }

    override suspend fun cleanupOldScheduledDownloads(olderThan: Instant) {
        scheduleDao.deleteOldScheduledDownloads(olderThan.epochSecond)
    }
}