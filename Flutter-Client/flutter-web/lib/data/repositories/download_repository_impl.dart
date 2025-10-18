import 'package:injectable/injectable.dart';
import '../../domain/entities/download.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_api_client.dart';
import '../datasources/download_websocket_client.dart';
import '../models/download_model.dart';

/// Implementation of DownloadRepository using HTTP API and WebSocket
@LazySingleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadApiClient _apiClient;
  final DownloadWebSocketClient _wsClient;

  DownloadRepositoryImpl(this._apiClient, this._wsClient) {
    // Connect to WebSocket on creation
    _wsClient.connect();
  }

  @override
  Future<List<Download>> getActiveDownloads() async {
    try {
      final models = await _apiClient.getQueue();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get active downloads: $e');
    }
  }

  @override
  Future<List<Download>> getCompletedDownloads() async {
    try {
      final models = await _apiClient.getCompleted();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get completed downloads: $e');
    }
  }

  @override
  Future<List<Download>> getPendingDownloads() async {
    try {
      final models = await _apiClient.getPending();
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pending downloads: $e');
    }
  }

  @override
  Future<Download?> getDownloadById(String id) async {
    try {
      // Try to find in all queues
      final queues = await Future.wait([
        getActiveDownloads(),
        getCompletedDownloads(),
        getPendingDownloads(),
      ]);

      for (final queue in queues) {
        final download = queue.where((d) => d.id == id).firstOrNull;
        if (download != null) return download;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get download by ID: $e');
    }
  }

  @override
  Future<Download> addDownload({
    required String url,
    required String quality,
    required String format,
    String? folder,
    bool autoStart = true,
  }) async {
    try {
      final request = AddDownloadRequest(
        url: url,
        quality: quality,
        format: format,
        folder: folder,
        autoStart: autoStart,
      );

      final response = await _apiClient.addDownload(request);

      if (response.status == 'error' || response.download == null) {
        throw Exception(response.error ?? 'Failed to add download');
      }

      return response.download!.toEntity();
    } catch (e) {
      throw Exception('Failed to add download: $e');
    }
  }

  @override
  Future<void> startDownload(String id) async {
    try {
      await _apiClient.startDownload(id);
    } catch (e) {
      throw Exception('Failed to start download: $e');
    }
  }

  @override
  Future<void> cancelDownload(String id) async {
    try {
      await _apiClient.cancelDownload(id);
    } catch (e) {
      throw Exception('Failed to cancel download: $e');
    }
  }

  @override
  Future<void> deleteDownload(String id) async {
    try {
      await _apiClient.deleteDownload(id);
    } catch (e) {
      throw Exception('Failed to delete download: $e');
    }
  }

  @override
  Future<void> clearCompleted() async {
    try {
      await _apiClient.clearCompleted();
    } catch (e) {
      throw Exception('Failed to clear completed: $e');
    }
  }

  @override
  Stream<Download> watchDownloadUpdates() {
    return _wsClient.updates.map((model) => model.toEntity());
  }

  @override
  Stream<Download> watchDownloadAdditions() {
    return _wsClient.additions.map((model) => model.toEntity());
  }

  @override
  Stream<String> watchDownloadDeletions() {
    return _wsClient.deletions;
  }

  @override
  Stream<void> watchClearedEvents() {
    return _wsClient.cleared;
  }

  /// Check WebSocket connection status
  bool get isConnected => _wsClient.isConnected;

  /// Get WebSocket connection status stream
  Stream<bool> get connectionStatus => _wsClient.connectionStatus;

  /// Dispose resources
  void dispose() {
    _wsClient.dispose();
  }
}
