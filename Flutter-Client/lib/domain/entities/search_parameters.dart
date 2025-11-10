import 'package:equatable/equatable.dart';

/// Search parameters entity for filtering and sorting downloads
class SearchParameters extends Equatable {
  const SearchParameters({
    this.query,
    this.favoritesOnly = false,
    this.status,
    this.quality,
    this.format,
    this.extractor,
    this.uploader,
    this.minDuration,
    this.maxDuration,
    this.minViews,
    this.maxViews,
    this.minLikes,
    this.maxLikes,
    this.dateFrom,
    this.dateTo,
    this.sortBy = 'title',
    this.sortOrder = 'asc',
    this.page = 1,
    this.pageSize = 20,
  });

  /// Search query text
  final String? query;

  /// Filter to show only favorites
  final bool favoritesOnly;

  /// Filter by download status (e.g., ['completed', 'downloading'])
  final List<String>? status;

  /// Filter by quality (e.g., ['1080p', '720p'])
  final List<String>? quality;

  /// Filter by format (e.g., ['mp4', 'webm'])
  final List<String>? format;

  /// Filter by extractor/platform (e.g., ['youtube', 'vimeo'])
  final List<String>? extractor;

  /// Filter by uploader/channel name
  final List<String>? uploader;

  /// Minimum video duration in seconds
  final int? minDuration;

  /// Maximum video duration in seconds
  final int? maxDuration;

  /// Minimum view count
  final int? minViews;

  /// Maximum view count
  final int? maxViews;

  /// Minimum like count
  final int? minLikes;

  /// Maximum like count
  final int? maxLikes;

  /// Filter by date from (inclusive)
  final DateTime? dateFrom;

  /// Filter by date to (inclusive)
  final DateTime? dateTo;

  /// Field to sort by (e.g., 'title', 'date', 'duration')
  final String sortBy;

  /// Sort order ('asc' or 'desc')
  final String sortOrder;

  /// Page number for pagination (1-indexed)
  final int page;

  /// Number of items per page
  final int pageSize;

  /// Create a copy with updated fields
  SearchParameters copyWith({
    String? query,
    bool? favoritesOnly,
    List<String>? status,
    List<String>? quality,
    List<String>? format,
    List<String>? extractor,
    List<String>? uploader,
    int? minDuration,
    int? maxDuration,
    int? minViews,
    int? maxViews,
    int? minLikes,
    int? maxLikes,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? pageSize,
  }) {
    return SearchParameters(
      query: query ?? this.query,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      status: status ?? this.status,
      quality: quality ?? this.quality,
      format: format ?? this.format,
      extractor: extractor ?? this.extractor,
      uploader: uploader ?? this.uploader,
      minDuration: minDuration ?? this.minDuration,
      maxDuration: maxDuration ?? this.maxDuration,
      minViews: minViews ?? this.minViews,
      maxViews: maxViews ?? this.maxViews,
      minLikes: minLikes ?? this.minLikes,
      maxLikes: maxLikes ?? this.maxLikes,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Check if any filters are active
  bool get hasFilters =>
      query != null ||
      favoritesOnly ||
      status != null ||
      quality != null ||
      format != null ||
      extractor != null ||
      uploader != null ||
      minDuration != null ||
      maxDuration != null ||
      minViews != null ||
      maxViews != null ||
      minLikes != null ||
      maxLikes != null ||
      dateFrom != null ||
      dateTo != null;

  /// Check if pagination is active
  bool get isPaginated => page > 1 || pageSize != 20;

  /// Check if descending sort order
  bool get isDescending => sortOrder == 'desc';

  /// Check if ascending sort order
  bool get isAscending => sortOrder == 'asc';

  @override
  List<Object?> get props => [
        query,
        favoritesOnly,
        status,
        quality,
        format,
        extractor,
        uploader,
        minDuration,
        maxDuration,
        minViews,
        maxViews,
        minLikes,
        maxLikes,
        dateFrom,
        dateTo,
        sortBy,
        sortOrder,
        page,
        pageSize,
      ];
}
