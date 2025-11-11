import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/download.dart';
import 'grabtube_progress_indicator.dart';

class DownloadListItem extends StatelessWidget {
  const DownloadListItem({
    required this.download,
    required this.onDelete,
    this.onStart,
    super.key,
  });

  final Download download;
  final VoidCallback onDelete;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Show download details
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail with shimmer loading effect
                  if (download.thumbnail != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: download.thumbnail!,
                        width: 120,
                        height: 68,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => ShimmerLoading(
                          width: 120,
                          height: 68,
                          borderRadius: 8,
                          child: const Center(
                            child: Icon(Icons.image, color: Colors.white54),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 68,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Icon(Icons.video_library),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 120,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.video_library,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          download.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(context),
                            if (download.quality != null) ...[
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(download.quality!),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ],
                        ),
                        if (download.speed != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${download.speed} ${download.eta != null ? "• ETA: ${download.eta}" : ""}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      } else if (value == 'start' && onStart != null) {
                        onStart!();
                      }
                    },
                    itemBuilder: (context) => [
                      if (onStart != null)
                        const PopupMenuItem(
                          value: 'start',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 8),
                              Text('Start'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Progress bar with smooth animations
              if (download.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Animated arrow progress indicator with pulsing effect
                    GrabTubeProgressIndicator(
                      progress: download.progress ?? 0.0,
                      size: 32,
                      isAnimating: download.status == DownloadStatus.downloading,
                    ),
                    const SizedBox(width: 12),
                    // Linear progress bar with shimmer effect and percentage
                    Expanded(
                      child: GrabTubeLinearProgress(
                        progress: download.progress ?? 0.0,
                        height: 8,
                        showPercentage: true,
                        isAnimating: download.status == DownloadStatus.downloading,
                        label: download.fileSize != null
                            ? _formatBytes(download.fileSize!)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],

              // Error message with animated entrance
              if (download.hasError && download.error != null) ...[
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
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
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (download.status) {
      case DownloadStatus.downloading:
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        icon = Icons.downloading;
        label = 'Downloading';
      case DownloadStatus.completed:
        backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
        textColor = Theme.of(context).colorScheme.onTertiaryContainer;
        icon = Icons.check_circle;
        label = 'Completed';
      case DownloadStatus.error:
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        textColor = Theme.of(context).colorScheme.onErrorContainer;
        icon = Icons.error;
        label = 'Error';
      case DownloadStatus.pending:
        backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
        textColor = Theme.of(context).colorScheme.onSecondaryContainer;
        icon = Icons.pending;
        label = 'Pending';
      case DownloadStatus.canceled:
        backgroundColor = Theme.of(context).colorScheme.surfaceVariant;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
        icon = Icons.cancel;
        label = 'Canceled';
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: textColor),
      label: Text(label, style: TextStyle(color: textColor)),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1073741824) {
      return '${(bytes / 1073741824).toStringAsFixed(2)} GB';
    } else if (bytes >= 1048576) {
      return '${(bytes / 1048576).toStringAsFixed(2)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    }
    return '$bytes B';
  }
}
