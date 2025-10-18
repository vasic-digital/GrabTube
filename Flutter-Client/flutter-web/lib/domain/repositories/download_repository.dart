import '../entities/download.dart';

/// Repository interface for download operations
///
/// This interface defines the contract for download data operations.
/// Implementations can use HTTP API, WebSocket, local storage, etc.
abstract class DownloadRepository {
  /// Get all active downloads (downloading status)
  Future<List<Download>> getActiveDownloads();

  /// Get all completed downloads
  Future<List<Download>> getCompletedDownloads();

  /// Get all pending downloads (not started yet)
  Future<List<Download>> getPendingDownloads();

  /// Get download by ID
  Future<Download?> getDownloadById(String id);

  /// Add a new download
  ///
  /// Parameters:
  /// - [url]: Video URL
  /// - [quality]: Selected quality (e.g., "1080", "best")
  /// - [format]: Selected format (e.g., "mp4", "webm")
  /// - [folder]: Optional custom folder
  /// - [autoStart]: Whether to start download immediately
  Future<Download> addDownload({
    required String url,
    required String quality,
    required String format,
    String? folder,
    bool autoStart = true,
  });

  /// Start a pending download
  Future<void> startDownload(String id);

  /// Cancel an active download
  Future<void> cancelDownload(String id);

  /// Delete a download from history
  Future<void> deleteDownload(String id);

  /// Clear all completed downloads
  Future<void> clearCompleted();

  /// Stream of download updates via WebSocket
  Stream<Download> watchDownloadUpdates();

  /// Stream of download additions
  Stream<Download> watchDownloadAdditions();

  /// Stream of download deletions
  Stream<String> watchDownloadDeletions();

  /// Stream of cleared events
  Stream<void> watchClearedEvents();
}
