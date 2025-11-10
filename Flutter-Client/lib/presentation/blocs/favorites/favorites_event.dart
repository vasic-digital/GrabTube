import 'package:equatable/equatable.dart';

/// Base class for Favorites events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all favorites
class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();
}

/// Event to add a download to favorites
class AddFavoriteEvent extends FavoritesEvent {
  const AddFavoriteEvent(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// Event to remove a download from favorites
class RemoveFavoriteEvent extends FavoritesEvent {
  const RemoveFavoriteEvent(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// Event to toggle favorite status
class ToggleFavoriteEvent extends FavoritesEvent {
  const ToggleFavoriteEvent(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// Event to check if a download is favorited
class CheckFavoriteStatusEvent extends FavoritesEvent {
  const CheckFavoriteStatusEvent(this.downloadId);

  final String downloadId;

  @override
  List<Object?> get props => [downloadId];
}

/// Event to clear all favorites
class ClearFavoritesEvent extends FavoritesEvent {
  const ClearFavoritesEvent();
}

/// Event to export favorites to file
class ExportFavoritesEvent extends FavoritesEvent {
  const ExportFavoritesEvent();
}

/// Event to import favorites from file
class ImportFavoritesEvent extends FavoritesEvent {
  const ImportFavoritesEvent(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

/// Event to get list of favorite IDs
class GetFavoriteIdsEvent extends FavoritesEvent {
  const GetFavoriteIdsEvent();
}

/// Event when favorites are updated from stream
class FavoritesUpdatedEvent extends FavoritesEvent {
  const FavoritesUpdatedEvent();
}
