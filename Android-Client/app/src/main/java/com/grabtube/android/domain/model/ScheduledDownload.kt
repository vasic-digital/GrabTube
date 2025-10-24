package com.grabtube.android.domain.model

import java.time.Instant

/**
 * Represents a scheduled download task
 */
data class ScheduledDownload(
    val id: String,
    val scheduleId: String,
    val downloadId: String,
    val scheduledAt: Instant,
    val executedAt: Instant? = null,
    val isExecuted: Boolean = false,
    val isSuccessful: Boolean = false,
    val errorMessage: String? = null,
    val result: Map<String, Any>? = null
)