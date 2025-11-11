import '../entities/download.dart';
import '../usecases/favorites/sync_favorites_usecase.dart';

/// Repository interface for favorites operations
abstract class FavoritesRepository {
  /// Get all favorite downloads
  Future<List<Download>> getFavorites();

  /// Add download to favorites
  Future<void> addFavorite(String downloadId);

  /// Remove download from favorites
  Future<void> removeFavorite(String downloadId);

  /// Toggle favorite status of a download
  Future<void> toggleFavorite(String downloadId);

  /// Check if download is in favorites
  Future<bool> isFavorite(String downloadId);

  /// Get favorite IDs
  Future<List<String>> getFavoriteIds();

  /// Clear all favorites
  Future<void> clearFavorites();

  /// Export favorites to file
  Future<String> exportFavorites();

  /// Import favorites from file
  Future<void> importFavorites(String filePath);

  /// Sync favorites across devices
  Future<SyncResult> syncFavorites();

  /// Stream of favorites updates
  Stream<List<Download>> get favoritesUpdates;
}
