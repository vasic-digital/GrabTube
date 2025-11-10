import '../entities/search_parameters.dart';
import '../entities/search_result.dart';

/// Repository interface for search operations
abstract class SearchRepository {
  /// Search downloads with given parameters
  Future<SearchResult> searchDownloads(SearchParameters parameters);

  /// Get search history
  Future<List<SearchParameters>> getSearchHistory();

  /// Save search parameters to history
  Future<void> saveSearchHistory(SearchParameters parameters);

  /// Clear search history
  Future<void> clearSearchHistory();

  /// Delete specific search from history
  Future<void> deleteSearchHistory(int index);

  /// Get suggested searches based on history
  Future<List<String>> getSuggestedSearches(String query);
}
