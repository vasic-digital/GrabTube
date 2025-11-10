import 'package:equatable/equatable.dart';
import '../../../domain/entities/search_parameters.dart';

/// Base class for Search events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Event to perform a search with given parameters
class PerformSearchEvent extends SearchEvent {
  const PerformSearchEvent(this.parameters);

  final SearchParameters parameters;

  @override
  List<Object?> get props => [parameters];
}

/// Event to update search parameters
class UpdateSearchParametersEvent extends SearchEvent {
  const UpdateSearchParametersEvent(this.parameters);

  final SearchParameters parameters;

  @override
  List<Object?> get props => [parameters];
}

/// Event to load search history
class LoadSearchHistoryEvent extends SearchEvent {
  const LoadSearchHistoryEvent();
}

/// Event to clear search history
class ClearSearchHistoryEvent extends SearchEvent {
  const ClearSearchHistoryEvent();
}

/// Event to delete a specific search from history
class DeleteSearchHistoryEvent extends SearchEvent {
  const DeleteSearchHistoryEvent(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Event to get suggested searches based on query
class GetSuggestedSearchesEvent extends SearchEvent {
  const GetSuggestedSearchesEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to apply a filter from history
class ApplyHistorySearchEvent extends SearchEvent {
  const ApplyHistorySearchEvent(this.parameters);

  final SearchParameters parameters;

  @override
  List<Object?> get props => [parameters];
}

/// Event to reset search to initial state
class ResetSearchEvent extends SearchEvent {
  const ResetSearchEvent();
}

/// Event to load more search results (pagination)
class LoadMoreSearchResultsEvent extends SearchEvent {
  const LoadMoreSearchResultsEvent();
}
