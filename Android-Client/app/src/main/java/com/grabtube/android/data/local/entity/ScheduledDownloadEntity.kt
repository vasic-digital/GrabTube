package com.grabtube.android.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.grabtube.android.domain.model.ScheduledDownload
import java.time.Instant

/**
 * Database entity for ScheduledDownload
 */
@Entity(tableName = "scheduled_downloads")
data class ScheduledDownloadEntity(
    @PrimaryKey
    val id: String,
    val scheduleId: String,
    val downloadId: String,
    val scheduledAt: Long, // timestamp
    val executedAt: Long?, // timestamp
    val isExecuted: Boolean,
    val isSuccessful: Boolean,
    val errorMessage: String?,
    val result: String? // JSON string
) {
    fun toDomain(): ScheduledDownload {
        return ScheduledDownload(
            id = id,
            scheduleId = scheduleId,
            downloadId = downloadId,
            scheduledAt = Instant.ofEpochSecond(scheduledAt),
            executedAt = executedAt?.let { Instant.ofEpochSecond(it) },
            isExecuted = isExecuted,
            isSuccessful = isSuccessful,
            errorMessage = errorMessage,
            result = result?.let { parseResult(it) }
        )
    }

    private fun parseResult(json: String): Map<String, Any> {
        // Simple JSON parsing - in real app use Gson or similar
        return try {
            json.removeSurfix("}").removePrefix("{").split(",").associate {
                val (key, value) = it.split(":")
                key.removeSurfix("\"").removePrefix("\"") to value.removeSurfix("\"").removePrefix("\"")
            }
        } catch (e: Exception) {
            emptyMap()
        }
    }

    companion object {
        fun fromDomain(scheduledDownload: ScheduledDownload): ScheduledDownloadEntity {
            return ScheduledDownloadEntity(
                id = scheduledDownload.id,
                scheduleId = scheduledDownload.scheduleId,
                downloadId = scheduledDownload.downloadId,
                scheduledAt = scheduledDownload.scheduledAt.epochSecond,
                executedAt = scheduledDownload.executedAt?.epochSecond,
                isExecuted = scheduledDownload.isExecuted,
                isSuccessful = scheduledDownload.isSuccessful,
                errorMessage = scheduledDownload.errorMessage,
                result = scheduledDownload.result?.let { serializeResult(it) }
            )
        }

        private fun serializeResult(result: Map<String, Any>): String {
            // Simple JSON serialization - in real app use Gson or similar
            return result.entries.joinToString(",", "{", "}") { (key, value) ->
                "\"$key\":\"$value\""
            }
        }
    }
}