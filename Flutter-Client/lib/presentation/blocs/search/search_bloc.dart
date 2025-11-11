import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/search_parameters.dart';
import '../../../domain/entities/search_result.dart';
import '../../../domain/usecases/search/search_downloads_usecase.dart';
import '../../../domain/usecases/search/get_search_history_usecase.dart';
import '../../../domain/usecases/search/clear_search_history_usecase.dart';
import '../../../domain/repositories/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

/// BLoC for managing search functionality
@injectable
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this._searchDownloadsUseCase,
    this._getSearchHistoryUseCase,
    this._clearSearchHistoryUseCase,
    this._repository,
  ) : super(const SearchInitial()) {
    on<PerformSearchEvent>(_onPerformSearch);
    on<UpdateSearchParametersEvent>(_onUpdateSearchParameters);
    on<LoadSearchHistoryEvent>(_onLoadSearchHistory);
    on<ClearSearchHistoryEvent>(_onClearSearchHistory);
    on<DeleteSearchHistoryEvent>(_onDeleteSearchHistory);
    on<GetSuggestedSearchesEvent>(_onGetSuggestedSearches);
    on<ApplyHistorySearchEvent>(_onApplyHistorySearch);
    on<ResetSearchEvent>(_onResetSearch);
    on<LoadMoreSearchResultsEvent>(_onLoadMoreSearchResults);
  }

  final SearchDownloadsUseCase _searchDownloadsUseCase;
  final GetSearchHistoryUseCase _getSearchHistoryUseCase;
  final ClearSearchHistoryUseCase _clearSearchHistoryUseCase;
  final SearchRepository _repository;

  SearchParameters? _currentParameters;
  SearchResult? _currentResult;

  Future<void> _onPerformSearch(
    PerformSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoading());

    final result = await _searchDownloadsUseCase(event.parameters);

    result.fold(
      (error) => emit(SearchFailure(error)),
      (searchResult) {
        _currentParameters = event.parameters;
        _currentResult = searchResult;
        emit(SearchSuccess(
          result: searchResult,
          parameters: event.parameters,
        ));

        // Save to history
        _repository.saveSearchHistory(event.parameters);
      },
    );
  }

  Future<void> _onUpdateSearchParameters(
    UpdateSearchParametersEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentParameters = event.parameters;
    emit(SearchParametersUpdated(event.parameters));
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchHistoryLoading());

    final result = await _getSearchHistoryUseCase();

    result.fold(
      (error) => emit(SearchFailure(error)),
      (history) => emit(SearchHistoryLoaded(history)),
    );
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    final result = await _clearSearchHistoryUseCase();

    result.fold(
      (error) => emit(SearchFailure(error)),
      (_) => emit(const SearchHistoryLoaded([])),
    );
  }

  Future<void> _onDeleteSearchHistory(
    DeleteSearchHistoryEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      await _repository.deleteSearchHistory(event.index);

      // Reload history after deletion
      final historyResult = await _getSearchHistoryUseCase();
      historyResult.fold(
        (error) => emit(SearchFailure(error)),
        (history) => emit(SearchHistoryLoaded(history)),
      );
    } catch (e) {
      emit(SearchFailure('Failed to delete search history: ${e.toString()}'));
    }
  }

  Future<void> _onGetSuggestedSearches(
    GetSuggestedSearchesEvent event,
    Emitter<SearchState> emit,
  ) async {
    try {
      final suggestions = await _repository.getSuggestedSearches(event.query);
      emit(SearchSuggestionsLoaded(suggestions));
    } catch (e) {
      emit(SearchFailure('Failed to get suggestions: ${e.toString()}'));
    }
  }

  Future<void> _onApplyHistorySearch(
    ApplyHistorySearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    // Apply search from history is the same as performing a new search
    add(PerformSearchEvent(event.parameters));
  }

  Future<void> _onResetSearch(
    ResetSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    _currentParameters = null;
    _currentResult = null;
    emit(const SearchInitial());
  }

  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResultsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (_currentParameters == null || _currentResult == null) {
      return;
    }

    // Check if there are more results to load
    if (!_currentResult!.hasMore) {
      return;
    }

    emit(SearchLoadingMore(
      currentResult: _currentResult!,
      parameters: _currentParameters!,
    ));

    // Create new parameters with next page
    final nextPageParameters = SearchParameters(
      query: _currentParameters!.query,
      favoritesOnly: _currentParameters!.favoritesOnly,
      status: _currentParameters!.status,
      quality: _currentParameters!.quality,
      format: _currentParameters!.format,
      extractor: _currentParameters!.extractor,
      uploader: _currentParameters!.uploader,
      minDuration: _currentParameters!.minDuration,
      maxDuration: _currentParameters!.maxDuration,
      minViews: _currentParameters!.minViews,
      maxViews: _currentParameters!.maxViews,
      minLikes: _currentParameters!.minLikes,
      maxLikes: _currentParameters!.maxLikes,
      dateFrom: _currentParameters!.dateFrom,
      dateTo: _currentParameters!.dateTo,
      sortBy: _currentParameters!.sortBy,
      sortOrder: _currentParameters!.sortOrder,
      page: _currentParameters!.page + 1,
      pageSize: _currentParameters!.pageSize,
    );

    final result = await _searchDownloadsUseCase(nextPageParameters);

    result.fold(
      (error) => emit(SearchFailure(error)),
      (newResult) {
        // Combine results
        final combinedDownloads = [
          ..._currentResult!.downloads,
          ...newResult.downloads,
        ];

        final combinedResult = SearchResult(
          downloads: combinedDownloads,
          totalCount: newResult.totalCount,
          page: newResult.page,
          pageSize: newResult.pageSize,
          hasMore: newResult.hasMore,
        );

        _currentParameters = nextPageParameters;
        _currentResult = combinedResult;

        emit(SearchMoreResultsLoaded(
          result: combinedResult,
          parameters: nextPageParameters,
        ));
      },
    );
  }
}
