package com.grabtube.android.domain.model

/**
 * Domain model for creating a new download
 */
data class DownloadRequest(
    val url: String,
    val quality: String = "best",
    val format: String = "any",
    val folder: String? = null,
    val autoStart: Boolean = true
)
