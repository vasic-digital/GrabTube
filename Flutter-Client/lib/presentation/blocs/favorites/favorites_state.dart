import 'package:equatable/equatable.dart';
import '../../../domain/entities/download.dart';

/// Base class for Favorites states
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is created
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// State when favorites are being loaded
class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// State when favorites are loaded successfully
class FavoritesLoaded extends FavoritesState {
  const FavoritesLoaded({
    required this.favorites,
    required this.favoriteIds,
  });

  final List<Download> favorites;
  final Set<String> favoriteIds;

  @override
  List<Object?> get props => [favorites, favoriteIds];

  /// Check if a download is in favorites
  bool isFavorite(String downloadId) => favoriteIds.contains(downloadId);
}

/// State when favorites operation fails
class FavoritesFailure extends FavoritesState {
  const FavoritesFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

/// State when a favorite is being added
class FavoriteAdding extends FavoritesState {
  const FavoriteAdding(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// State when a favorite is successfully added
class FavoriteAdded extends FavoritesState {
  const FavoriteAdded(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// State when a favorite is being removed
class FavoriteRemoving extends FavoritesState {
  const FavoriteRemoving(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// State when a favorite is successfully removed
class FavoriteRemoved extends FavoritesState {
  const FavoriteRemoved(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// State when checking favorite status
class FavoriteStatusChecked extends FavoritesState {
  const FavoriteStatusChecked({
    required this.downloadId,
    required this.isFavorite,
  });

  final String downloadId;
  final bool isFavorite;

  @override
  List<Object?> get props => [downloadId, isFavorite];
}

/// State when exporting favorites
class FavoritesExporting extends FavoritesState {
  const FavoritesExporting();
}

/// State when favorites are exported successfully
class FavoritesExported extends FavoritesState {
  const FavoritesExported(this.exportData);

  final String exportData;

  @override
  List<Object?> get props => [exportData];
}

/// State when importing favorites
class FavoritesImporting extends FavoritesState {
  const FavoritesImporting();
}

/// State when favorites are imported successfully
class FavoritesImported extends FavoritesState {
  const FavoritesImported(this.importedCount);

  final int importedCount;

  @override
  List<Object?> get props => [importedCount];
}

/// State when favorite IDs are loaded
class FavoriteIdsLoaded extends FavoritesState {
  const FavoriteIdsLoaded(this.favoriteIds);

  final List<String> favoriteIds;

  @override
  List<Object?> get props => [favoriteIds];
}
