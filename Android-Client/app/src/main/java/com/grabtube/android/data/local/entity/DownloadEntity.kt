package com.grabtube.android.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.model.DownloadStatus
import java.time.Instant

@Entity(tableName = "downloads")
data class DownloadEntity(
    @PrimaryKey
    val id: String,
    val url: String,
    val title: String,
    val thumbnail: String?,
    val status: String,
    val progress: Float,
    val speed: Long,
    val eta: Long?,
    val downloadedBytes: Long,
    val totalBytes: Long?,
    val quality: String,
    val format: String,
    val folder: String?,
    val errorMessage: String?,
    val addedAt: Long,
    val startedAt: Long?,
    val completedAt: Long?,
    val outputPath: String?,
    val autoStart: Boolean,
    val isFavorite: Boolean = false
)

fun DownloadEntity.toDomain(): Download {
    return Download(
        id = id,
        url = url,
        title = title,
        thumbnail = thumbnail,
        status = DownloadStatus.valueOf(status),
        progress = progress,
        speed = speed,
        eta = eta,
        downloadedBytes = downloadedBytes,
        totalBytes = totalBytes,
        quality = quality,
        format = format,
        folder = folder,
        errorMessage = errorMessage,
        addedAt = Instant.ofEpochSecond(addedAt),
        startedAt = startedAt?.let { Instant.ofEpochSecond(it) },
        completedAt = completedAt?.let { Instant.ofEpochSecond(it) },
        outputPath = outputPath,
        autoStart = autoStart,
        isFavorite = isFavorite
    )
}

fun Download.toEntity(): DownloadEntity {
    return DownloadEntity(
        id = id,
        url = url,
        title = title,
        thumbnail = thumbnail,
        status = status.name,
        progress = progress,
        speed = speed,
        eta = eta,
        downloadedBytes = downloadedBytes,
        totalBytes = totalBytes,
        quality = quality,
        format = format,
        folder = folder,
        errorMessage = errorMessage,
        addedAt = addedAt.epochSecond,
        startedAt = startedAt?.epochSecond,
        completedAt = completedAt?.epochSecond,
        outputPath = outputPath,
        autoStart = autoStart,
        isFavorite = isFavorite
    )
}
