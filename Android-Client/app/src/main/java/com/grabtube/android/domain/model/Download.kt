package com.grabtube.android.domain.model

import java.time.Instant

/**
 * Domain model representing a download item
 */
data class Download(
    val id: String,
    val url: String,
    val title: String,
    val thumbnail: String?,
    val status: DownloadStatus,
    val progress: Float = 0f,
    val speed: Long = 0L, // bytes per second
    val eta: Long? = null, // seconds remaining
    val downloadedBytes: Long = 0L,
    val totalBytes: Long? = null,
    val quality: String,
    val format: String,
    val folder: String?,
    val errorMessage: String? = null,
    val addedAt: Instant,
    val startedAt: Instant? = null,
    val completedAt: Instant? = null,
    val outputPath: String? = null,
    val autoStart: Boolean = true
)

enum class DownloadStatus {
    PENDING,
    EXTRACTING_INFO,
    DOWNLOADING,
    PROCESSING,
    COMPLETED,
    FAILED,
    CANCELED,
    PAUSED;

    fun isActive(): Boolean = this in listOf(EXTRACTING_INFO, DOWNLOADING, PROCESSING)
    fun isFinished(): Boolean = this in listOf(COMPLETED, FAILED, CANCELED)
    fun canRetry(): Boolean = this in listOf(FAILED, CANCELED)
    fun canCancel(): Boolean = this in listOf(PENDING, EXTRACTING_INFO, DOWNLOADING, PROCESSING, PAUSED)
    fun canPause(): Boolean = this == DOWNLOADING
    fun canResume(): Boolean = this == PAUSED
}
