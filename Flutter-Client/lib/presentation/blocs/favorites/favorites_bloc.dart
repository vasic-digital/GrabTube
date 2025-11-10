import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/download.dart';
import '../../../domain/usecases/favorites/get_favorites_usecase.dart';
import '../../../domain/usecases/favorites/add_favorite_usecase.dart';
import '../../../domain/usecases/favorites/remove_favorite_usecase.dart';
import '../../../domain/usecases/favorites/toggle_favorite_usecase.dart';
import '../../../domain/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// BLoC for managing favorites functionality
@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(
    this._getFavoritesUseCase,
    this._addFavoriteUseCase,
    this._removeFavoriteUseCase,
    this._toggleFavoriteUseCase,
    this._repository,
  ) : super(const FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddFavoriteEvent>(_onAddFavorite);
    on<RemoveFavoriteEvent>(_onRemoveFavorite);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<CheckFavoriteStatusEvent>(_onCheckFavoriteStatus);
    on<ClearFavoritesEvent>(_onClearFavorites);
    on<ExportFavoritesEvent>(_onExportFavorites);
    on<ImportFavoritesEvent>(_onImportFavorites);
    on<GetFavoriteIdsEvent>(_onGetFavoriteIds);
    on<FavoritesUpdatedEvent>(_onFavoritesUpdated);

    // Subscribe to favorites updates stream
    _favoritesSubscription = _repository.favoritesUpdates.listen((favorites) {
      add(const FavoritesUpdatedEvent());
    });
  }

  final GetFavoritesUseCase _getFavoritesUseCase;
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final FavoritesRepository _repository;

  StreamSubscription<List<Download>>? _favoritesSubscription;

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());

    final result = await _getFavoritesUseCase();

    result.fold(
      (error) => emit(FavoritesFailure(error)),
      (favorites) async {
        final favoriteIds = await _repository.getFavoriteIds();
        emit(FavoritesLoaded(
          favorites: favorites,
          favoriteIds: favoriteIds.toSet(),
        ));
      },
    );
  }

  Future<void> _onAddFavorite(
    AddFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoriteAdding(event.downloadId));

    final result = await _addFavoriteUseCase(event.downloadId);

    result.fold(
      (error) => emit(FavoritesFailure(error)),
      (_) {
        emit(FavoriteAdded(event.downloadId));
        add(const LoadFavoritesEvent());
      },
    );
  }

  Future<void> _onRemoveFavorite(
    RemoveFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoriteRemoving(event.downloadId));

    final result = await _removeFavoriteUseCase(event.downloadId);

    result.fold(
      (error) => emit(FavoritesFailure(error)),
      (_) {
        emit(FavoriteRemoved(event.downloadId));
        add(const LoadFavoritesEvent());
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _toggleFavoriteUseCase(event.downloadId);

    result.fold(
      (error) => emit(FavoritesFailure(error)),
      (_) => add(const LoadFavoritesEvent()),
    );
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatusEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await _repository.isFavorite(event.downloadId);
      emit(FavoriteStatusChecked(
        downloadId: event.downloadId,
        isFavorite: isFavorite,
      ));
    } catch (e) {
      emit(FavoritesFailure('Failed to check favorite status: ${e.toString()}'));
    }
  }

  Future<void> _onClearFavorites(
    ClearFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _repository.clearFavorites();
      emit(const FavoritesLoaded(favorites: [], favoriteIds: {}));
    } catch (e) {
      emit(FavoritesFailure('Failed to clear favorites: ${e.toString()}'));
    }
  }

  Future<void> _onExportFavorites(
    ExportFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesExporting());

    try {
      final exportData = await _repository.exportFavorites();
      emit(FavoritesExported(exportData));
    } catch (e) {
      emit(FavoritesFailure('Failed to export favorites: ${e.toString()}'));
    }
  }

  Future<void> _onImportFavorites(
    ImportFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesImporting());

    try {
      await _repository.importFavorites(event.filePath);

      final favorites = await _repository.getFavorites();
      emit(FavoritesImported(favorites.length));

      // Reload favorites after import
      add(const LoadFavoritesEvent());
    } catch (e) {
      emit(FavoritesFailure('Failed to import favorites: ${e.toString()}'));
    }
  }

  Future<void> _onGetFavoriteIds(
    GetFavoriteIdsEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final favoriteIds = await _repository.getFavoriteIds();
      emit(FavoriteIdsLoaded(favoriteIds));
    } catch (e) {
      emit(FavoritesFailure('Failed to get favorite IDs: ${e.toString()}'));
    }
  }

  Future<void> _onFavoritesUpdated(
    FavoritesUpdatedEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    // Reload favorites when stream notifies of updates
    add(const LoadFavoritesEvent());
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
