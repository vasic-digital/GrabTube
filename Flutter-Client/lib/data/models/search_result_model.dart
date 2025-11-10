import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/search_result.dart';
import 'download_model.dart';

part 'search_result_model.g.dart';

@JsonSerializable()
class SearchResultModel {
  SearchResultModel({
    required this.downloads,
    required this.totalCount,
    this.page = 1,
    this.pageSize = 20,
    this.hasMore = false,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) =>
      _$SearchResultModelFromJson(json);

  final List<DownloadModel> downloads;

  @JsonKey(name: 'total_count')
  final int totalCount;

  final int page;

  @JsonKey(name: 'page_size')
  final int pageSize;

  @JsonKey(name: 'has_more')
  final bool hasMore;

  Map<String, dynamic> toJson() => _$SearchResultModelToJson(this);

  /// Convert to domain entity
  SearchResult toEntity() {
    return SearchResult(
      downloads: downloads.map((model) => model.toEntity()).toList(),
      totalCount: totalCount,
      page: page,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  /// Create from domain entity
  factory SearchResultModel.fromEntity(SearchResult entity) {
    return SearchResultModel(
      downloads: entity.downloads.map((e) => DownloadModel.fromEntity(e)).toList(),
      totalCount: entity.totalCount,
      page: entity.page,
      pageSize: entity.pageSize,
      hasMore: entity.hasMore,
    );
  }
}
