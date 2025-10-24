import '../entities/download.dart';
import '../entities/video_info.dart';

/// Repository interface for download operations
abstract class DownloadRepository {
  /// Add a new download
  Future<Download> addDownload({
    required String url,
    String? quality,
    String? format,
    String? folder,
    bool? autoStart,
  });

  /// Get all downloads
  Future<List<Download>> getDownloads();

  /// Get queue downloads
  Future<List<Download>> getQueue();

  /// Get completed downloads
  Future<List<Download>> getCompleted();

  /// Get pending downloads
  Future<List<Download>> getPending();

  /// Delete downloads
  Future<void> deleteDownload({
    required List<String> ids,
    String where = 'queue',
  });

  /// Start downloads
  Future<void> startDownload({required List<String> ids});

  /// Get download history
  Future<List<Download>> getHistory();

  /// Re-download from history
  Future<void> redownload({
    required String url,
    String? quality,
    String? format,
    String? folder,
    bool? autoStart,
  });

  /// Clear completed downloads
  Future<void> clearCompleted();

  /// Get video information
  Future<VideoInfo> getVideoInfo({required String url});

  /// Check server health
  Future<bool> checkHealth();

  /// Stream of download updates
  Stream<Download> get downloadUpdates;

  /// Stream of new downloads
  Stream<Download> get newDownloads;

  /// Stream of completed downloads
  Stream<Download> get completedDownloads;

  /// Stream of canceled download IDs
  Stream<String> get canceledDownloads;

  /// Stream of connection status
  Stream<bool> get connectionStatus;

  /// Toggle favorite status of a download
  Future<void> toggleFavorite(String downloadId);

  /// Check if download is favorite
  Future<bool> isFavorite(String downloadId);
}
