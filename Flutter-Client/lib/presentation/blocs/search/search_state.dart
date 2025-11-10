import 'package:equatable/equatable.dart';
import '../../../domain/entities/search_parameters.dart';
import '../../../domain/entities/search_result.dart';

/// Base class for Search states
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is created
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// State when search is in progress
class SearchLoading extends SearchState {
  const SearchLoading();
}

/// State when search completes successfully
class SearchSuccess extends SearchState {
  const SearchSuccess({
    required this.result,
    required this.parameters,
  });

  final SearchResult result;
  final SearchParameters parameters;

  @override
  List<Object?> get props => [result, parameters];
}

/// State when search fails
class SearchFailure extends SearchState {
  const SearchFailure(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

/// State when search history is loaded
class SearchHistoryLoaded extends SearchState {
  const SearchHistoryLoaded(this.history);

  final List<SearchParameters> history;

  @override
  List<Object?> get props => [history];
}

/// State when search history is being loaded
class SearchHistoryLoading extends SearchState {
  const SearchHistoryLoading();
}

/// State when search suggestions are available
class SearchSuggestionsLoaded extends SearchState {
  const SearchSuggestionsLoaded(this.suggestions);

  final List<String> suggestions;

  @override
  List<Object?> get props => [suggestions];
}

/// State when search parameters have been updated
class SearchParametersUpdated extends SearchState {
  const SearchParametersUpdated(this.parameters);

  final SearchParameters parameters;

  @override
  List<Object?> get props => [parameters];
}

/// State when loading more results (pagination)
class SearchLoadingMore extends SearchState {
  const SearchLoadingMore({
    required this.currentResult,
    required this.parameters,
  });

  final SearchResult currentResult;
  final SearchParameters parameters;

  @override
  List<Object?> get props => [currentResult, parameters];
}

/// State with combined results after pagination
class SearchMoreResultsLoaded extends SearchState {
  const SearchMoreResultsLoaded({
    required this.result,
    required this.parameters,
  });

  final SearchResult result;
  final SearchParameters parameters;

  @override
  List<Object?> get props => [result, parameters];
}
