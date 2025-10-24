package com.grabtube.android.domain.model

import java.time.Instant

/**
 * Types of schedules supported
 */
enum class ScheduleType {
    ONE_TIME,      // Execute once at specific date/time
    RECURRING,     // Execute repeatedly (daily, weekly, monthly)
    PERIODIC,      // Execute every X time units
    COLLECTION     // For downloading video collections periodically
}

/**
 * Recurrence patterns for recurring schedules
 */
enum class RecurrencePattern {
    DAILY,
    WEEKLY,
    MONTHLY,
    YEARLY
}

/**
 * Days of the week for weekly recurrence
 */
enum class WeekDay {
    MONDAY,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY,
    SUNDAY
}

/**
 * Time units for periodic schedules
 */
enum class TimeUnit {
    MINUTES,
    HOURS,
    DAYS,
    WEEKS,
    MONTHS
}

/**
 * Domain model representing a scheduling configuration
 */
data class Schedule(
    val id: String,
    val name: String,
    val description: String = "",
    val type: ScheduleType,
    val startDate: Instant? = null,        // For one-time schedules
    val startTime: Instant? = null,        // Time of day to execute
    val recurrencePattern: RecurrencePattern? = null,
    val weekDays: List<WeekDay>? = null,   // For weekly recurrence
    val dayOfMonth: Int? = null,           // For monthly recurrence (1-31)
    val interval: Int? = null,             // For periodic schedules (every X units)
    val timeUnit: TimeUnit? = null,        // Unit for periodic schedules
    val endDate: Instant? = null,          // When to stop recurring
    val maxExecutions: Int? = null,        // Maximum number of executions
    val isActive: Boolean = true,
    val createdAt: Instant,
    val lastExecutedAt: Instant? = null,
    val nextExecutionAt: Instant? = null,
    val executionCount: Int = 0,
    val metadata: Map<String, Any>? = null // Additional configuration
) {
    /**
     * Calculate next execution time
     */
    fun calculateNextExecution(from: Instant = Instant.now()): Instant? {
        return when (type) {
            ScheduleType.ONE_TIME -> calculateOneTimeNextExecution(from)
            ScheduleType.RECURRING -> calculateRecurringNextExecution(from)
            ScheduleType.PERIODIC -> calculatePeriodicNextExecution(from)
            ScheduleType.COLLECTION -> calculatePeriodicNextExecution(from)
        }
    }

    private fun calculateOneTimeNextExecution(from: Instant): Instant? {
        return if (startDate != null && startTime != null) {
            // Combine date and time
            val dateTime = startDate.atZone(java.time.ZoneId.systemDefault())
                .withHour(startTime.atZone(java.time.ZoneId.systemDefault()).hour)
                .withMinute(startTime.atZone(java.time.ZoneId.systemDefault()).minute)
                .withSecond(0)
                .withNano(0)
                .toInstant()

            if (dateTime.isAfter(from)) dateTime else null
        } else null
    }

    private fun calculateRecurringNextExecution(from: Instant): Instant? {
        if (recurrencePattern == null || startTime == null) return null

        return when (recurrencePattern!!) {
            RecurrencePattern.DAILY -> calculateDailyNextExecution(from)
            RecurrencePattern.WEEKLY -> calculateWeeklyNextExecution(from)
            RecurrencePattern.MONTHLY -> calculateMonthlyNextExecution(from)
            RecurrencePattern.YEARLY -> calculateYearlyNextExecution(from)
        }
    }

    private fun calculateDailyNextExecution(from: Instant): Instant {
        val fromZdt = from.atZone(java.time.ZoneId.systemDefault())
        val timeZdt = startTime!!.atZone(java.time.ZoneId.systemDefault())

        val today = fromZdt.toLocalDate()
        val executionTime = today.atTime(timeZdt.toLocalTime())

        return if (executionTime.isAfter(fromZdt)) {
            executionTime.toInstant()
        } else {
            // Tomorrow
            val tomorrow = today.plusDays(1)
            tomorrow.atTime(timeZdt.toLocalTime()).toInstant()
        }
    }

    private fun calculateWeeklyNextExecution(from: Instant): Instant? {
        if (weekDays.isNullOrEmpty()) return null

        val fromZdt = from.atZone(java.time.ZoneId.systemDefault())
        val timeZdt = startTime!!.atZone(java.time.ZoneId.systemDefault())

        val currentDayOfWeek = fromZdt.dayOfWeek
        val sortedWeekDays = weekDays.sortedBy { it.ordinal }

        // Find next weekday in the list
        val nextWeekDay = sortedWeekDays.firstOrNull { it.ordinal >= currentDayOfWeek.ordinal }
            ?: sortedWeekDays.first()

        val daysToAdd = nextWeekDay.ordinal - currentDayOfWeek.ordinal
        val targetDate = fromZdt.toLocalDate().plusDays(
            if (daysToAdd < 0) daysToAdd + 7L else daysToAdd.toLong()
        )

        val executionTime = targetDate.atTime(timeZdt.toLocalTime())

        // If the execution time has passed today, move to next occurrence
        return if (executionTime.isBefore(fromZdt) ||
                   (executionTime.isEqual(fromZdt) && nextWeekDay == WeekDay.values()[currentDayOfWeek.ordinal])) {
            val nextTargetDate = targetDate.plusDays(7)
            nextTargetDate.atTime(timeZdt.toLocalTime()).toInstant()
        } else {
            executionTime.toInstant()
        }
    }

    private fun calculateMonthlyNextExecution(from: Instant): Instant? {
        val dayOfMonth = dayOfMonth ?: return null
        val fromZdt = from.atZone(java.time.ZoneId.systemDefault())
        val timeZdt = startTime!!.atZone(java.time.ZoneId.systemDefault())

        val currentMonth = fromZdt.toLocalDate()
        val targetDate = try {
            currentMonth.withDayOfMonth(dayOfMonth)
        } catch (e: Exception) {
            // Invalid day for this month, use last day
            currentMonth.withDayOfMonth(currentMonth.lengthOfMonth())
        }

        val executionTime = targetDate.atTime(timeZdt.toLocalTime())

        return if (executionTime.isAfter(fromZdt)) {
            executionTime.toInstant()
        } else {
            // Next month
            val nextMonth = currentMonth.plusMonths(1)
            val nextTargetDate = try {
                nextMonth.withDayOfMonth(dayOfMonth)
            } catch (e: Exception) {
                nextMonth.withDayOfMonth(nextMonth.lengthOfMonth())
            }
            nextTargetDate.atTime(timeZdt.toLocalTime()).toInstant()
        }
    }

    private fun calculateYearlyNextExecution(from: Instant): Instant {
        val fromZdt = from.atZone(java.time.ZoneId.systemDefault())
        val timeZdt = startTime!!.atZone(java.time.ZoneId.systemDefault())

        val currentYear = fromZdt.year
        val targetDate = java.time.LocalDate.of(currentYear, timeZdt.month, timeZdt.dayOfMonth)
        val executionTime = targetDate.atTime(timeZdt.toLocalTime())

        return if (executionTime.isAfter(fromZdt)) {
            executionTime.toInstant()
        } else {
            // Next year
            val nextYear = currentYear + 1
            val nextTargetDate = java.time.LocalDate.of(nextYear, timeZdt.month, timeZdt.dayOfMonth)
            nextTargetDate.atTime(timeZdt.toLocalTime()).toInstant()
        }
    }

    private fun calculatePeriodicNextExecution(from: Instant): Instant? {
        val interval = interval ?: return null
        val timeUnit = timeUnit ?: return null

        val duration = when (timeUnit) {
            TimeUnit.MINUTES -> java.time.Duration.ofMinutes(interval.toLong())
            TimeUnit.HOURS -> java.time.Duration.ofHours(interval.toLong())
            TimeUnit.DAYS -> java.time.Duration.ofDays(interval.toLong())
            TimeUnit.WEEKS -> java.time.Duration.ofDays(interval.toLong() * 7)
            TimeUnit.MONTHS -> java.time.Duration.ofDays(interval.toLong() * 30) // Approximation
        }

        val lastExecution = lastExecutedAt ?: createdAt
        val nextExecution = lastExecution.plus(duration)

        return if (nextExecution.isAfter(from)) nextExecution else from.plus(duration)
    }

    /**
     * Check if schedule should execute now
     */
    fun shouldExecuteNow(currentTime: Instant = Instant.now()): Boolean {
        val nextExecution = calculateNextExecution(currentTime) ?: return false

        // Allow 1 minute tolerance for execution
        val tolerance = java.time.Duration.ofMinutes(1)
        return java.time.Duration.between(currentTime, nextExecution).abs() <= tolerance
    }

    /**
     * Check if schedule is expired
     */
    fun isExpired(currentTime: Instant = Instant.now()): Boolean {
        if (endDate != null && endDate!!.isBefore(currentTime)) return true
        if (maxExecutions != null && executionCount >= maxExecutions!!) return true

        return false
    }

    companion object {
        /**
         * Create a one-time schedule
         */
        fun oneTime(
            id: String,
            name: String,
            executeAt: Instant,
            description: String = "",
            metadata: Map<String, Any>? = null
        ) = Schedule(
            id = id,
            name = name,
            description = description,
            type = ScheduleType.ONE_TIME,
            startDate = executeAt.truncatedTo(java.time.temporal.ChronoUnit.DAYS),
            startTime = executeAt,
            isActive = true,
            createdAt = Instant.now(),
            metadata = metadata
        )

        /**
         * Create a daily recurring schedule
         */
        fun daily(
            id: String,
            name: String,
            startTime: Instant,
            endDate: Instant? = null,
            maxExecutions: Int? = null,
            description: String = "",
            metadata: Map<String, Any>? = null
        ) = Schedule(
            id = id,
            name = name,
            description = description,
            type = ScheduleType.RECURRING,
            recurrencePattern = RecurrencePattern.DAILY,
            startTime = startTime,
            endDate = endDate,
            maxExecutions = maxExecutions,
            isActive = true,
            createdAt = Instant.now(),
            metadata = metadata
        )

        /**
         * Create a weekly recurring schedule
         */
        fun weekly(
            id: String,
            name: String,
            startTime: Instant,
            weekDays: List<WeekDay>,
            endDate: Instant? = null,
            maxExecutions: Int? = null,
            description: String = "",
            metadata: Map<String, Any>? = null
        ) = Schedule(
            id = id,
            name = name,
            description = description,
            type = ScheduleType.RECURRING,
            recurrencePattern = RecurrencePattern.WEEKLY,
            startTime = startTime,
            weekDays = weekDays,
            endDate = endDate,
            maxExecutions = maxExecutions,
            isActive = true,
            createdAt = Instant.now(),
            metadata = metadata
        )

        /**
         * Create a periodic schedule
         */
        fun periodic(
            id: String,
            name: String,
            interval: Int,
            timeUnit: TimeUnit,
            startDate: Instant? = null,
            endDate: Instant? = null,
            maxExecutions: Int? = null,
            description: String = "",
            metadata: Map<String, Any>? = null
        ) = Schedule(
            id = id,
            name = name,
            description = description,
            type = ScheduleType.PERIODIC,
            interval = interval,
            timeUnit = timeUnit,
            startDate = startDate,
            endDate = endDate,
            maxExecutions = maxExecutions,
            isActive = true,
            createdAt = Instant.now(),
            metadata = metadata
        )

        /**
         * Create a collection schedule for downloading video collections
         */
        fun collection(
            id: String,
            name: String,
            interval: Int,
            timeUnit: TimeUnit,
            collectionUrl: String,
            startDate: Instant? = null,
            endDate: Instant? = null,
            maxExecutions: Int? = null,
            description: String = "",
            metadata: Map<String, Any>? = null
        ) = Schedule(
            id = id,
            name = name,
            description = description,
            type = ScheduleType.COLLECTION,
            interval = interval,
            timeUnit = timeUnit,
            startDate = startDate,
            endDate = endDate,
            maxExecutions = maxExecutions,
            isActive = true,
            createdAt = Instant.now(),
            metadata = (metadata ?: emptyMap()) + ("collectionUrl" to collectionUrl)
        )
    }
}