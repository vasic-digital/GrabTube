package com.grabtube.android.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.grabtube.android.domain.model.Schedule
import com.grabtube.android.domain.model.RecurrencePattern
import com.grabtube.android.domain.model.ScheduleType
import com.grabtube.android.domain.model.TimeUnit
import com.grabtube.android.domain.model.WeekDay
import java.time.Instant

/**
 * Database entity for Schedule
 */
@Entity(tableName = "schedules")
data class ScheduleEntity(
    @PrimaryKey
    val id: String,
    val name: String,
    val description: String,
    val type: String, // ScheduleType.name
    val startDate: Long?, // timestamp
    val startTime: Long?, // timestamp
    val recurrencePattern: String?, // RecurrencePattern.name
    val weekDays: String?, // JSON string of WeekDay names
    val dayOfMonth: Int?,
    val interval: Int?,
    val timeUnit: String?, // TimeUnit.name
    val endDate: Long?, // timestamp
    val maxExecutions: Int?,
    val isActive: Boolean,
    val createdAt: Long, // timestamp
    val lastExecutedAt: Long?, // timestamp
    val nextExecutionAt: Long?, // timestamp
    val executionCount: Int,
    val metadata: String? // JSON string
) {
    fun toDomain(): Schedule {
        return Schedule(
            id = id,
            name = name,
            description = description,
            type = ScheduleType.valueOf(type),
            startDate = startDate?.let { Instant.ofEpochSecond(it) },
            startTime = startTime?.let { Instant.ofEpochSecond(it) },
            recurrencePattern = recurrencePattern?.let { RecurrencePattern.valueOf(it) },
            weekDays = weekDays?.split(",")?.map { WeekDay.valueOf(it) },
            dayOfMonth = dayOfMonth,
            interval = interval,
            timeUnit = timeUnit?.let { TimeUnit.valueOf(it) },
            endDate = endDate?.let { Instant.ofEpochSecond(it) },
            maxExecutions = maxExecutions,
            isActive = isActive,
            createdAt = Instant.ofEpochSecond(createdAt),
            lastExecutedAt = lastExecutedAt?.let { Instant.ofEpochSecond(it) },
            nextExecutionAt = nextExecutionAt?.let { Instant.ofEpochSecond(it) },
            executionCount = executionCount,
            metadata = metadata?.let { parseMetadata(it) }
        )
    }

    private fun parseMetadata(json: String): Map<String, Any> {
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
        fun fromDomain(schedule: Schedule): ScheduleEntity {
            return ScheduleEntity(
                id = schedule.id,
                name = schedule.name,
                description = schedule.description,
                type = schedule.type.name,
                startDate = schedule.startDate?.epochSecond,
                startTime = schedule.startTime?.epochSecond,
                recurrencePattern = schedule.recurrencePattern?.name,
                weekDays = schedule.weekDays?.joinToString(",") { it.name },
                dayOfMonth = schedule.dayOfMonth,
                interval = schedule.interval,
                timeUnit = schedule.timeUnit?.name,
                endDate = schedule.endDate?.epochSecond,
                maxExecutions = schedule.maxExecutions,
                isActive = schedule.isActive,
                createdAt = schedule.createdAt.epochSecond,
                lastExecutedAt = schedule.lastExecutedAt?.epochSecond,
                nextExecutionAt = schedule.nextExecutionAt?.epochSecond,
                executionCount = schedule.executionCount,
                metadata = schedule.metadata?.let { serializeMetadata(it) }
            )
        }

        private fun serializeMetadata(metadata: Map<String, Any>): String {
            // Simple JSON serialization - in real app use Gson or similar
            return metadata.entries.joinToString(",", "{", "}") { (key, value) ->
                "\"$key\":\"$value\""
            }
        }
    }
}