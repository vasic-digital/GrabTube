import 'package:equatable/equatable.dart';
import 'package:grabtube/domain/entities/download.dart';

/// Search result entity containing downloads and pagination info
class SearchResult extends Equatable {
  const SearchResult({
    required this.downloads,
    required this.totalCount,
    this.page = 1,
    this.pageSize = 20,
    this.hasMore = false,
  });

  /// List of downloads matching the search criteria
  final List<Download> downloads;

  /// Total number of downloads matching the search (before pagination)
  final int totalCount;

  /// Current page number (1-indexed)
  final int page;

  /// Number of items per page
  final int pageSize;

  /// Whether there are more pages available
  final bool hasMore;

  /// Create a copy with updated fields
  SearchResult copyWith({
    List<Download>? downloads,
    int? totalCount,
    int? page,
    int? pageSize,
    bool? hasMore,
  }) {
    return SearchResult(
      downloads: downloads ?? this.downloads,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Check if the result is empty
  bool get isEmpty => downloads.isEmpty;

  /// Check if the result has items
  bool get isNotEmpty => downloads.isNotEmpty;

  /// Get the number of results in current page
  int get count => downloads.length;

  /// Calculate total number of pages
  int get totalPages => totalCount == 0 ? 0 : (totalCount / pageSize).ceil();

  /// Check if this is the first page
  bool get isFirstPage => page <= 1;

  /// Check if this is the last page
  bool get isLastPage => !hasMore;

  @override
  List<Object?> get props => [
        downloads,
        totalCount,
        page,
        pageSize,
        hasMore,
      ];
}
