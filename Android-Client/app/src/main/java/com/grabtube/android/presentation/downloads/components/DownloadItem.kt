package com.grabtube.android.presentation.downloads.components

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import com.grabtube.android.domain.model.Download
import com.grabtube.android.domain.model.DownloadStatus

@Composable
fun DownloadItem(
    download: Download,
    onCancel: () -> Unit,
    onRetry: () -> Unit,
    onDelete: () -> Unit,
    onStart: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Thumbnail
                download.thumbnail?.let { thumbnailUrl ->
                    AsyncImage(
                        model = thumbnailUrl,
                        contentDescription = "Thumbnail",
                        modifier = Modifier
                            .size(80.dp)
                            .clip(MaterialTheme.shapes.small),
                        contentScale = ContentScale.Crop
                    )
                }

                Column(
                    modifier = Modifier.weight(1f),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        text = download.title,
                        style = MaterialTheme.typography.titleMedium,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        StatusChip(status = download.status)
                        Text(
                            text = "${download.quality} • ${download.format}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    if (download.status.isActive()) {
                        DownloadProgress(download)
                    }

                    if (download.status == DownloadStatus.FAILED && download.errorMessage != null) {
                        Text(
                            text = download.errorMessage,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.error,
                            maxLines = 2,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
            }

            // Action buttons
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp),
                horizontalArrangement = Arrangement.End,
                verticalAlignment = Alignment.CenterVertically
            ) {
                when {
                    download.status.canCancel() -> {
                        TextButton(onClick = onCancel) {
                            Icon(Icons.Default.Cancel, contentDescription = null)
                            Spacer(Modifier.width(4.dp))
                            Text("Cancel")
                        }
                    }
                    download.status.canRetry() -> {
                        TextButton(onClick = onRetry) {
                            Icon(Icons.Default.Refresh, contentDescription = null)
                            Spacer(Modifier.width(4.dp))
                            Text("Retry")
                        }
                    }
                    download.status == DownloadStatus.PENDING -> {
                        TextButton(onClick = onStart) {
                            Icon(Icons.Default.PlayArrow, contentDescription = null)
                            Spacer(Modifier.width(4.dp))
                            Text("Start")
                        }
                    }
                }

                if (download.status.isFinished()) {
                    TextButton(onClick = onDelete) {
                        Icon(Icons.Default.Delete, contentDescription = null)
                        Spacer(Modifier.width(4.dp))
                        Text("Delete")
                    }
                }
            }
        }
    }
}

@Composable
private fun StatusChip(status: DownloadStatus) {
    val (text, color) = when (status) {
        DownloadStatus.PENDING -> "Pending" to MaterialTheme.colorScheme.secondary
        DownloadStatus.EXTRACTING_INFO -> "Preparing" to MaterialTheme.colorScheme.primary
        DownloadStatus.DOWNLOADING -> "Downloading" to MaterialTheme.colorScheme.primary
        DownloadStatus.PROCESSING -> "Processing" to MaterialTheme.colorScheme.primary
        DownloadStatus.COMPLETED -> "Completed" to MaterialTheme.colorScheme.tertiary
        DownloadStatus.FAILED -> "Failed" to MaterialTheme.colorScheme.error
        DownloadStatus.CANCELED -> "Canceled" to MaterialTheme.colorScheme.outline
        DownloadStatus.PAUSED -> "Paused" to MaterialTheme.colorScheme.secondary
    }

    SuggestionChip(
        onClick = {},
        label = { Text(text, style = MaterialTheme.typography.labelSmall) },
        colors = SuggestionChipDefaults.suggestionChipColors(containerColor = color.copy(alpha = 0.2f))
    )
}

@Composable
private fun DownloadProgress(download: Download) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        LinearProgressIndicator(
            progress = { download.progress },
            modifier = Modifier.fillMaxWidth()
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "${(download.progress * 100).toInt()}%",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            download.speed.let { speed ->
                if (speed > 0) {
                    Text(
                        text = formatSpeed(speed),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
}

private fun formatSpeed(bytesPerSecond: Long): String {
    return when {
        bytesPerSecond >= 1_000_000 -> String.format("%.1f MB/s", bytesPerSecond / 1_000_000.0)
        bytesPerSecond >= 1_000 -> String.format("%.1f KB/s", bytesPerSecond / 1_000.0)
        else -> "$bytesPerSecond B/s"
    }
}
