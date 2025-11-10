import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/search_parameters.dart';

part 'search_parameters_model.g.dart';

@JsonSerializable()
class SearchParametersModel {
  SearchParametersModel({
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

  factory SearchParametersModel.fromJson(Map<String, dynamic> json) =>
      _$SearchParametersModelFromJson(json);

  final String? query;

  @JsonKey(name: 'favorites_only')
  final bool favoritesOnly;

  final List<String>? status;
  final List<String>? quality;
  final List<String>? format;
  final List<String>? extractor;
  final List<String>? uploader;

  @JsonKey(name: 'min_duration')
  final int? minDuration;

  @JsonKey(name: 'max_duration')
  final int? maxDuration;

  @JsonKey(name: 'min_views')
  final int? minViews;

  @JsonKey(name: 'max_views')
  final int? maxViews;

  @JsonKey(name: 'min_likes')
  final int? minLikes;

  @JsonKey(name: 'max_likes')
  final int? maxLikes;

  @JsonKey(name: 'date_from')
  final String? dateFrom;

  @JsonKey(name: 'date_to')
  final String? dateTo;

  @JsonKey(name: 'sort_by')
  final String sortBy;

  @JsonKey(name: 'sort_order')
  final String sortOrder;

  final int page;

  @JsonKey(name: 'page_size')
  final int pageSize;

  Map<String, dynamic> toJson() => _$SearchParametersModelToJson(this);

  /// Convert to domain entity
  SearchParameters toEntity() {
    return SearchParameters(
      query: query,
      favoritesOnly: favoritesOnly,
      status: status,
      quality: quality,
      format: format,
      extractor: extractor,
      uploader: uploader,
      minDuration: minDuration,
      maxDuration: maxDuration,
      minViews: minViews,
      maxViews: maxViews,
      minLikes: minLikes,
      maxLikes: maxLikes,
      dateFrom: dateFrom != null ? DateTime.parse(dateFrom!) : null,
      dateTo: dateTo != null ? DateTime.parse(dateTo!) : null,
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Create from domain entity
  factory SearchParametersModel.fromEntity(SearchParameters entity) {
    return SearchParametersModel(
      query: entity.query,
      favoritesOnly: entity.favoritesOnly,
      status: entity.status,
      quality: entity.quality,
      format: entity.format,
      extractor: entity.extractor,
      uploader: entity.uploader,
      minDuration: entity.minDuration,
      maxDuration: entity.maxDuration,
      minViews: entity.minViews,
      maxViews: entity.maxViews,
      minLikes: entity.minLikes,
      maxLikes: entity.maxLikes,
      dateFrom: entity.dateFrom?.toIso8601String(),
      dateTo: entity.dateTo?.toIso8601String(),
      sortBy: entity.sortBy,
      sortOrder: entity.sortOrder,
      page: entity.page,
      pageSize: entity.pageSize,
    );
  }
}
