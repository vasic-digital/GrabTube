import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/download.dart';
import '../blocs/download/download_bloc.dart';
import '../blocs/download/download_event.dart';
import '../blocs/download/download_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load history when page initializes
    context.read<DownloadBloc>().add(const LoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DownloadBloc>().add(const LoadHistory());
            },
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: BlocBuilder<DownloadBloc, DownloadState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const LoadingView(message: 'Loading history...');
          }

          if (state is HistoryLoaded) {
            if (state.history.isEmpty) {
              return _buildEmptyState();
            }
            return _buildHistoryList(state.history);
          }

          if (state is DownloadError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<DownloadBloc>().add(const LoadHistory());
              },
            );
          }

          // Default: show loading
          return const LoadingView(message: 'Loading history...');
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No History Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Downloads will appear here once added',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Download> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final download = history[index];
        return _buildHistoryCard(download);
      },
    );
  }

  Widget _buildHistoryCard(Download download) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showHistoryDetails(download),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail section
            _buildThumbnail(download),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    download.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Metadata row
                  _buildMetadataRow(download),

                  if (download.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      download.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Download info chips
                  _buildInfoChips(download),

                  const SizedBox(height: 12),

                  // Action buttons
                  _buildActionButtons(download),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(Download download) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          // Thumbnail image or placeholder
          if (download.thumbnail != null)
            Image.network(
              download.thumbnail!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildThumbnailPlaceholder();
              },
            )
          else
            _buildThumbnailPlaceholder(),

          // Duration badge
          if (download.duration != null)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(download.duration!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.video_library,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(Download download) {
    final metadata = <Widget>[];

    if (download.uploader != null) {
      metadata.add(_buildMetadataItem(
        icon: Icons.person_outline,
        text: download.uploader!,
      ));
    }

    if (download.viewCount != null) {
      metadata.add(_buildMetadataItem(
        icon: Icons.visibility_outlined,
        text: _formatNumber(download.viewCount!) + ' views',
      ));
    }

    if (download.likeCount != null) {
      metadata.add(_buildMetadataItem(
        icon: Icons.thumb_up_outlined,
        text: _formatNumber(download.likeCount!),
      ));
    }

    if (metadata.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: metadata,
    );
  }

  Widget _buildMetadataItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoChips(Download download) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (download.quality != null)
          Chip(
            label: Text(download.quality!),
            avatar: const Icon(Icons.high_quality, size: 16),
            visualDensity: VisualDensity.compact,
          ),
        if (download.format != null)
          Chip(
            label: Text(download.format!),
            avatar: const Icon(Icons.video_file, size: 16),
            visualDensity: VisualDensity.compact,
          ),
        if (download.extractor != null)
          Chip(
            label: Text(download.extractor!),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildActionButtons(Download download) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _redownload(download),
            icon: const Icon(Icons.download),
            label: const Text('Re-download'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: () => _openOriginalUrl(download),
          icon: const Icon(Icons.open_in_new),
          tooltip: 'Open Original URL',
        ),
      ],
    );
  }

  void _redownload(Download download) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-download'),
        content: Text('Re-download "${download.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DownloadBloc>().add(
                    RedownloadFromHistory(
                      url: download.url,
                      quality: download.quality,
                      format: download.format,
                      folder: download.folder,
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Re-download started')),
              );
            },
            child: const Text('Re-download'),
          ),
        ],
      ),
    );
  }

  void _openOriginalUrl(Download download) {
    // TODO: Implement URL opening using url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open: ${download.webpageUrl ?? download.url}')),
    );
  }

  void _showHistoryDetails(Download download) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  download.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                if (download.description != null) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(download.description!),
                  const SizedBox(height: 16),
                ],
                _buildDetailRow('Quality', download.quality),
                _buildDetailRow('Format', download.format),
                _buildDetailRow('Uploader', download.uploader),
                if (download.viewCount != null)
                  _buildDetailRow(
                      'Views', _formatNumber(download.viewCount!)),
                if (download.likeCount != null)
                  _buildDetailRow('Likes', _formatNumber(download.likeCount!)),
                if (download.duration != null)
                  _buildDetailRow(
                      'Duration', _formatDuration(download.duration!)),
                _buildDetailRow('Extractor', download.extractor),
                _buildDetailRow('Folder', download.folder),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
