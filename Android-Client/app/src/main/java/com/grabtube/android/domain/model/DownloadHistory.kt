package com.grabtube.android.domain.model

import java.time.Instant

/**
 * Domain model for download history entry
 */
data class DownloadHistory(
    val id: String,
    val url: String,
    val title: String,
    val thumbnail: String?,
    val quality: String,
    val format: String,
    val folder: String?,
    val status: DownloadStatus,
    val completedAt: Instant,
    val duration: Long?, // download duration in seconds
    val fileSize: Long? = null
)
