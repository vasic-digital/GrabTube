package com.grabtube.android.data.service

import com.grabtube.android.domain.model.DownloadRequest
import com.grabtube.android.domain.model.Schedule
import com.grabtube.android.domain.model.ScheduledDownload
import com.grabtube.android.domain.repository.DownloadRepository
import com.grabtube.android.domain.repository.ScheduleExecutionService
import com.grabtube.android.domain.repository.ScheduleRepository
import com.grabtube.android.domain.repository.ScheduleRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import timber.log.Timber
import java.time.Instant
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ScheduleExecutionServiceImpl @Inject constructor(
    private val scheduleRepository: ScheduleRepository,
    private val downloadRepository: DownloadRepository
) : ScheduleExecutionService {

    private val scope = CoroutineScope(Dispatchers.IO + Job())
    private var executionJob: Job? = null
    private val checkInterval = 60000L // Check every minute

    override suspend fun start() {
        if (executionJob?.isActive == true) return

        Timber.d("Starting schedule execution service")
        executionJob = scope.launch {
            while (isActive) {
                try {
                    checkAndExecuteSchedules()
                } catch (e: Exception) {
                    Timber.e(e, "Error in schedule execution service")
                }
                delay(checkInterval)
            }
        }
    }

    override suspend fun stop() {
        Timber.d("Stopping schedule execution service")
        executionJob?.cancel()
        executionJob = null
    }

    override suspend fun checkAndExecuteSchedules() {
        val schedulesToExecute = scheduleRepository.getSchedulesToExecute()

        for (schedule in schedulesToExecute) {
            executeSchedule(schedule)
        }
    }

    override suspend fun executeScheduleNow(scheduleId: String) {
        val schedule = scheduleRepository.getScheduleById(scheduleId)
        if (schedule != null) {
            executeSchedule(schedule, force = true)
        }
    }

    private suspend fun executeSchedule(schedule: Schedule, force: Boolean = false) {
        try {
            Timber.d("Executing schedule: ${schedule.name}")

            // Create download request based on schedule type
            val downloadRequest = createDownloadRequest(schedule)

            if (downloadRequest != null) {
                // Add download
                val downloadResult = downloadRepository.addDownload(downloadRequest)

                downloadResult.fold(
                    { download ->
                        // Create scheduled download record
                        val scheduledDownload = ScheduledDownload(
                            id = UUID.randomUUID().toString(),
                            scheduleId = schedule.id,
                            downloadId = download.id,
                            scheduledAt = Instant.now(),
                            isExecuted = true,
                            isSuccessful = true
                        )

                        scheduleRepository.createScheduledDownload(scheduledDownload)

                        // Mark schedule as executed
                        scheduleRepository.markScheduleExecuted(schedule.id)

                        Timber.d("Schedule executed successfully: ${schedule.name}")
                    },
                    { error ->
                        // Create failed scheduled download record
                        val scheduledDownload = ScheduledDownload(
                            id = UUID.randomUUID().toString(),
                            scheduleId = schedule.id,
                            downloadId = "", // No download created
                            scheduledAt = Instant.now(),
                            executedAt = Instant.now(),
                            isExecuted = true,
                            isSuccessful = false,
                            errorMessage = error.toString()
                        )

                        scheduleRepository.createScheduledDownload(scheduledDownload)

                        Timber.e("Failed to execute schedule ${schedule.name}: $error")
                    }
                )
            }
        } catch (e: Exception) {
            // Create error record
            val scheduledDownload = ScheduledDownload(
                id = UUID.randomUUID().toString(),
                scheduleId = schedule.id,
                downloadId = "",
                scheduledAt = Instant.now(),
                executedAt = Instant.now(),
                isExecuted = true,
                isSuccessful = false,
                errorMessage = e.message
            )

            scheduleRepository.createScheduledDownload(scheduledDownload)

            Timber.e(e, "Error executing schedule: ${schedule.name}")
        }
    }

    private fun createDownloadRequest(schedule: Schedule): DownloadRequest? {
        return when (schedule.type) {
            ScheduleType.ONE_TIME, ScheduleType.RECURRING -> {
                // These would need URL and other details stored in metadata
                val url = schedule.metadata?.get("url") as? String
                val quality = schedule.metadata?.get("quality") as? String ?: "best"
                val format = schedule.metadata?.get("format") as? String ?: "mp4"
                val folder = schedule.metadata?.get("folder") as? String

                if (url != null) {
                    DownloadRequest(
                        url = url,
                        quality = quality,
                        format = format,
                        folder = folder,
                        autoStart = true
                    )
                } else null
            }

            ScheduleType.PERIODIC -> {
                // Similar to recurring but with different timing
                val url = schedule.metadata?.get("url") as? String
                val quality = schedule.metadata?.get("quality") as? String ?: "best"
                val format = schedule.metadata?.get("format") as? String ?: "mp4"
                val folder = schedule.metadata?.get("folder") as? String

                if (url != null) {
                    DownloadRequest(
                        url = url,
                        quality = quality,
                        format = format,
                        folder = folder,
                        autoStart = true
                    )
                } else null
            }

            ScheduleType.COLLECTION -> {
                // For video collections (playlists, channels, etc.)
                val collectionUrl = schedule.metadata?.get("collectionUrl") as? String
                val quality = schedule.metadata?.get("quality") as? String ?: "best"
                val format = schedule.metadata?.get("format") as? String ?: "mp4"
                val folder = schedule.metadata?.get("folder") as? String

                if (collectionUrl != null) {
                    DownloadRequest(
                        url = collectionUrl,
                        quality = quality,
                        format = format,
                        folder = folder,
                        autoStart = true
                    )
                } else null
            }
        }
    }

    override suspend fun getExecutionStats(): Map<String, Any> {
        return try {
            // Get stats from repository - simplified implementation
            val schedules = scheduleRepository.getAllSchedules()
            val totalSchedules = schedules.size
            val activeSchedules = schedules.count { it.isActive }

            // This would need to be implemented properly in the DAO
            mapOf(
                "totalSchedules" to totalSchedules,
                "activeSchedules" to activeSchedules,
                "totalExecutions" to 0, // Placeholder
                "successfulExecutions" to 0 // Placeholder
            )
        } catch (e: Exception) {
            Timber.e(e, "Error getting execution stats")
            emptyMap()
        }
    }
}