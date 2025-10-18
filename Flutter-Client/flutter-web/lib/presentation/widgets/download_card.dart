import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/download.dart';

/// Widget to display a single download item
class DownloadCard extends StatelessWidget {
  final Download download;
  final VoidCallback? onStart;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const DownloadCard({
    super.key,
    required this.download,
    this.onStart,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    download.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildActions(context),
              ],
            ),

            const SizedBox(height: 8),

            // URL
            Text(
              download.url,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Progress bar (if downloading)
            if (download.isActive) ...[
              LinearProgressIndicator(
                value: download.progress,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Status and details
            Row(
              children: [
                _buildStatusChip(context),
                const Spacer(),
                if (download.isActive) ...[
                  Text(
                    _formatSpeed(download.speed),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
                Text(
                  '${download.quality} • ${download.format.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),

            // Error message (if any)
            if (download.hasError && download.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        download.error!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build action buttons based on download status
  Widget _buildActions(BuildContext context) {
    if (download.isPending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onStart != null)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: onStart,
              tooltip: 'Start Download',
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
        ],
      );
    }

    if (download.isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCancel != null)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: onCancel,
              tooltip: 'Cancel',
            ),
        ],
      );
    }

    if (download.isCompleted || download.hasError || download.isCanceled) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// Build status chip
  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (download.status) {
      case DownloadStatus.pending:
        backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
        textColor = Theme.of(context).colorScheme.onSecondaryContainer;
        icon = Icons.pending;
        label = 'Pending';
        break;
      case DownloadStatus.downloading:
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        icon = Icons.download;
        label = '${download.formattedProgress}';
        break;
      case DownloadStatus.completed:
        backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
        textColor = Theme.of(context).colorScheme.onTertiaryContainer;
        icon = Icons.check_circle;
        label = 'Completed';
        break;
      case DownloadStatus.error:
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        textColor = Theme.of(context).colorScheme.onErrorContainer;
        icon = Icons.error;
        label = 'Error';
        break;
      case DownloadStatus.canceled:
        backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        textColor = Theme.of(context).colorScheme.onSurface;
        icon = Icons.cancel;
        label = 'Canceled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  /// Format download speed
  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond == 0) return '0 B/s';

    const units = ['B/s', 'KB/s', 'MB/s', 'GB/s'];
    int unitIndex = 0;
    double speed = bytesPerSecond.toDouble();

    while (speed >= 1024 && unitIndex < units.length - 1) {
      speed /= 1024;
      unitIndex++;
    }

    return '${speed.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}
