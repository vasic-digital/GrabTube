import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/download.dart';
import '../../domain/entities/sync_result.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/favorites/sync_favorites_usecase.dart';
import '../../core/services/favorites_sync_service.dart';
import '../models/download_model.dart';

/// Implementation of FavoritesRepository using API client and Hive
@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(
    this._dio,
    this._favoritesBox,
    this._syncService,
  );

  final Dio _dio;
  final Box<String> _favoritesBox;
  final FavoritesSyncService _syncService;

  final _favoritesController = StreamController<List<Download>>.broadcast();

  @override
  Stream<List<Download>> get favoritesUpdates => _favoritesController.stream;

  @override
  Future<List<Download>> getFavorites() async {
    try {
      final favoriteIds = await getFavoriteIds();
      if (favoriteIds.isEmpty) {
        return [];
      }

      // Fetch download details for each favorite ID
      final downloads = <Download>[];
      for (final id in favoriteIds) {
        try {
          final response = await _dio.get<Map<String, dynamic>>('/downloads/$id');
          if (response.data != null) {
            final model = DownloadModel.fromJson(response.data!);
            downloads.add(model.toEntity());
          }
        } catch (e) {
          // Skip downloads that can't be fetched
          continue;
        }
      }

      _favoritesController.add(downloads);
      return downloads;
    } catch (e) {
      throw Exception('Failed to get favorites: ${e.toString()}');
    }
  }

  @override
  Future<void> addFavorite(String downloadId) async {
    try {
      if (!await isFavorite(downloadId)) {
        await _favoritesBox.put(downloadId, downloadId);
        await _notifyFavoritesChanged();
      }
    } catch (e) {
      throw Exception('Failed to add favorite: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFavorite(String downloadId) async {
    try {
      await _favoritesBox.delete(downloadId);
      await _notifyFavoritesChanged();
    } catch (e) {
      throw Exception('Failed to remove favorite: ${e.toString()}');
    }
  }

  @override
  Future<void> toggleFavorite(String downloadId) async {
    try {
      if (await isFavorite(downloadId)) {
        await removeFavorite(downloadId);
      } else {
        await addFavorite(downloadId);
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite: ${e.toString()}');
    }
  }

  @override
  Future<bool> isFavorite(String downloadId) async {
    try {
      return _favoritesBox.containsKey(downloadId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getFavoriteIds() async {
    try {
      return _favoritesBox.values.toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await _favoritesBox.clear();
      await _notifyFavoritesChanged();
    } catch (e) {
      throw Exception('Failed to clear favorites: ${e.toString()}');
    }
  }

  @override
  Future<String> exportFavorites() async {
    try {
      final favorites = await getFavorites();
      final models = favorites.map((e) => DownloadModel.fromEntity(e)).toList();
      final jsonList = models.map((m) => m.toJson()).toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert({
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'count': jsonList.length,
        'favorites': jsonList,
      });

      // Return the JSON string - caller will handle file writing
      return jsonString;
    } catch (e) {
      throw Exception('Failed to export favorites: ${e.toString()}');
    }
  }

  @override
  Future<void> importFavorites(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      final favoritesList = jsonData['favorites'] as List<dynamic>;
      final models = favoritesList
          .map((json) => DownloadModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Add each favorite ID
      for (final model in models) {
        await addFavorite(model.id);
      }

      await _notifyFavoritesChanged();
    } catch (e) {
      throw Exception('Failed to import favorites: ${e.toString()}');
    }
  }

  @override
  Future<SyncResult> syncFavorites() async {
    try {
      final favorites = await getFavorites();
      final serverUrl = await _dio.options.baseUrl;
      final result = await _syncService.syncFavorites(
        serverUrl: serverUrl,
        localFavorites: favorites,
      );
      await _notifyFavoritesChanged();
      return result;
    } catch (e) {
      throw Exception('Failed to sync favorites: ${e.toString()}');
    }
  }

  Future<void> _notifyFavoritesChanged() async {
    try {
      final favorites = await getFavorites();
      _favoritesController.add(favorites);
    } catch (e) {
      // Silently fail - this is just for notifications
    }
  }

  @disposeMethod
  void dispose() {
    _favoritesController.close();
  }
}
