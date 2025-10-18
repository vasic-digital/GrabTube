package com.grabtube.android.data.remote.dto

import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.model.DownloadStatus
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.time.Instant

@Serializable
data class DownloadDto(
    @SerialName("id")
    val id: String,
    @SerialName("url")
    val url: String,
    @SerialName("title")
    val title: String,
    @SerialName("thumbnail")
    val thumbnail: String? = null,
    @SerialName("status")
    val status: String,
    @SerialName("msg")
    val msg: String? = null,
    @SerialName("percent")
    val percent: String? = null,
    @SerialName("speed")
    val speed: String? = null,
    @SerialName("eta")
    val eta: String? = null,
    @SerialName("downloaded_bytes")
    val downloadedBytes: Long? = null,
    @SerialName("total_bytes")
    val totalBytes: Long? = null,
    @SerialName("quality")
    val quality: String,
    @SerialName("format")
    val format: String,
    @SerialName("folder")
    val folder: String? = null,
    @SerialName("error")
    val error: String? = null,
    @SerialName("timestamp")
    val timestamp: Long,
    @SerialName("output_path")
    val outputPath: String? = null,
    @SerialName("auto_start")
    val autoStart: Boolean = true
)

fun DownloadDto.toDomain(): Download {
    val downloadStatus = when (status.lowercase()) {
        "pending" -> DownloadStatus.PENDING
        "preparing" -> DownloadStatus.EXTRACTING_INFO
        "downloading" -> DownloadStatus.DOWNLOADING
        "processing" -> DownloadStatus.PROCESSING
        "finished" -> DownloadStatus.COMPLETED
        "error" -> DownloadStatus.FAILED
        "paused" -> DownloadStatus.PAUSED
        else -> DownloadStatus.PENDING
    }

    val progressFloat = percent?.removeSuffix("%")?.toFloatOrNull()?.div(100f) ?: 0f
    val speedLong = speed?.filter { it.isDigit() }?.toLongOrNull() ?: 0L
    val etaLong = eta?.toLongOrNull()

    return Download(
        id = id,
        url = url,
        title = title,
        thumbnail = thumbnail,
        status = downloadStatus,
        progress = progressFloat,
        speed = speedLong,
        eta = etaLong,
        downloadedBytes = downloadedBytes ?: 0L,
        totalBytes = totalBytes,
        quality = quality,
        format = format,
        folder = folder,
        errorMessage = error ?: msg?.takeIf { downloadStatus == DownloadStatus.FAILED },
        addedAt = Instant.ofEpochSecond(timestamp),
        startedAt = if (downloadStatus.isActive() || downloadStatus.isFinished()) {
            Instant.ofEpochSecond(timestamp)
        } else null,
        completedAt = if (downloadStatus == DownloadStatus.COMPLETED) {
            Instant.now()
        } else null,
        outputPath = outputPath,
        autoStart = autoStart
    )
}
