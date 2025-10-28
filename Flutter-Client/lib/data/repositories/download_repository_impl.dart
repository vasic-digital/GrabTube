import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/network/socket_client.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/download.dart';
import '../../domain/entities/video_info.dart';
import '../../domain/repositories/download_repository.dart';
import '../models/download_model.dart';

@Singleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  DownloadRepositoryImpl(this._apiClient, this._socketClient, this._prefs);

  final ApiClient _apiClient;
  final SocketClient _socketClient;
  final SharedPreferences _prefs;

  static const String _favoritesKey = 'favorite_download_ids';

  @override
  Future<Download> addDownload({
    required String url,
    String? quality,
    String? format,
    String? folder,
    bool? autoStart,
  }) async {
    try {
      AppLogger.info('Adding download: $url');
      final response = await _apiClient.addDownload(
        url: url,
        quality: quality,
        format: format,
        folder: folder,
        autoStart: autoStart,
      );

      // Parse the response to get download info
      final downloadData = response['download'] as Map<String, dynamic>?;
      if (downloadData != null) {
        final model = DownloadModel.fromJson(downloadData);
        return model.toEntity();
      }

      throw Exception('Invalid response format');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add download', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Download>> getDownloads() async {
    try {
      AppLogger.info('Fetching all downloads');
      final response = await _apiClient.getDownloads();
      final downloads = <Download>[];

      // Parse queue
      if (response['queue'] != null) {
        final queueList = response['queue'] as List;
        downloads.addAll(
          queueList
              .map((e) => DownloadModel.fromJson(e as Map<String, dynamic>))
              .map((model) => model.toEntity()),
        );
      }

      // Parse done
      if (response['done'] != null) {
        final doneList = response['done'] as List;
        downloads.addAll(
          doneList
              .map((e) => DownloadModel.fromJson(e as Map<String, dynamic>))
              .map((model) => model.toEntity()),
        );
      }

      return downloads;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch downloads', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Download>> getQueue() async {
    try {
      AppLogger.info('Fetching download queue');
      final models = await _apiClient.getQueue();
      return models.map((model) => model.toEntity()).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch queue', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Download>> getCompleted() async {
    try {
      AppLogger.info('Fetching completed downloads');
      final models = await _apiClient.getCompleted();
      return models.map((model) => model.toEntity()).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch completed downloads', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Download>> getPending() async {
    try {
      AppLogger.info('Fetching pending downloads');
      final models = await _apiClient.getPending();
      return models.map((model) => model.toEntity()).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch pending downloads', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteDownload({
    required List<String> ids,
    String where = 'queue',
  }) async {
    try {
      AppLogger.info('Deleting downloads: $ids from $where');
      await _apiClient.deleteDownload(ids: ids, where: where);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete downloads', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> startDownload({required List<String> ids}) async {
    try {
      AppLogger.info('Starting downloads: $ids');
      await _apiClient.startDownload(ids: ids);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start downloads', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Download>> getHistory() async {
    try {
      AppLogger.info('Fetching download history');
      final models = await _apiClient.getHistory();
      return models.map((model) => model.toEntity()).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch history', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> redownload({
    required String url,
    String? quality,
    String? format,
    String? folder,
    bool? autoStart,
  }) async {
    try {
      AppLogger.info('Re-downloading from history: $url');
      await _apiClient.redownload(
        url: url,
        quality: quality,
        format: format,
        folder: folder,
        autoStart: autoStart,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to redownload', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> clearCompleted() async {
    try {
      AppLogger.info('Clearing completed downloads');
      await _apiClient.clearCompleted();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear completed downloads', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<VideoInfo> getVideoInfo({required String url}) async {
    try {
      AppLogger.info('Fetching video info for: $url');
      final response = await _apiClient.getVideoInfo(url: url);

      // Parse video info
      return VideoInfo(
        id: response['id'] as String? ?? '',
        title: response['title'] as String? ?? 'Unknown',
        url: url,
        thumbnail: response['thumbnail'] as String?,
        duration: response['duration'] as int?,
        uploader: response['uploader'] as String?,
        description: response['description'] as String?,
        viewCount: response['view_count'] as int?,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch video info', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      AppLogger.info('Checking server health');
      final response = await _apiClient.checkHealth();
      return response['status'] == 'ok';
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check server health', e, stackTrace);
      return false;
    }
  }

  @override
  Stream<Download> get downloadUpdates =>
      _socketClient.downloadUpdated.map((model) => model.toEntity());

  @override
  Stream<Download> get newDownloads =>
      _socketClient.downloadAdded.map((model) => model.toEntity());

  @override
  Stream<Download> get completedDownloads =>
      _socketClient.downloadCompleted.map((model) => model.toEntity());

  @override
  Stream<String> get canceledDownloads => _socketClient.downloadCanceled;

  @override
  Stream<bool> get connectionStatus => _socketClient.connectionStatus;

  @override
  Future<void> toggleFavorite(String downloadId) async {
    try {
      final isFav = await isFavorite(downloadId);
      if (isFav) {
        await _removeFromFavorites(downloadId);
      } else {
        await _addToFavorites(downloadId);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle favorite', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> isFavorite(String downloadId) async {
    try {
      final favoriteIds = await _getFavoriteIds();
      return favoriteIds.contains(downloadId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check favorite status', e, stackTrace);
      return false;
    }
  }

  Future<List<String>> _getFavoriteIds() async {
    try {
      return _prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      AppLogger.error('Failed to get favorite IDs', e);
      return [];
    }
  }

  Future<void> _addToFavorites(String downloadId) async {
    try {
      final favoriteIds = await _getFavoriteIds();
      if (!favoriteIds.contains(downloadId)) {
        favoriteIds.add(downloadId);
        await _prefs.setStringList(_favoritesKey, favoriteIds);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add to favorites', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _removeFromFavorites(String downloadId) async {
    try {
      final favoriteIds = await _getFavoriteIds();
      favoriteIds.remove(downloadId);
      await _prefs.setStringList(_favoritesKey, favoriteIds);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to remove from favorites', e, stackTrace);
      rethrow;
    }
  }
}
