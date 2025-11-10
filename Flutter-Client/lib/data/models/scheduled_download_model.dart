import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/scheduled_download.dart';

part 'scheduled_download_model.g.dart';

@JsonSerializable()
class ScheduledDownloadModel {
  ScheduledDownloadModel({
    required this.id,
    required this.scheduleId,
    required this.downloadId,
    required this.scheduledAt,
    this.executedAt,
    this.isExecuted = false,
    this.isSuccessful = false,
    this.errorMessage,
    this.result,
  });

  factory ScheduledDownloadModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduledDownloadModelFromJson(json);

  final String id;

  @JsonKey(name: 'schedule_id')
  final String scheduleId;

  @JsonKey(name: 'download_id')
  final String downloadId;

  @JsonKey(name: 'scheduled_at')
  final String scheduledAt;

  @JsonKey(name: 'executed_at')
  final String? executedAt;

  @JsonKey(name: 'is_executed')
  final bool isExecuted;

  @JsonKey(name: 'is_successful')
  final bool isSuccessful;

  @JsonKey(name: 'error_message')
  final String? errorMessage;

  final Map<String, dynamic>? result;

  Map<String, dynamic> toJson() => _$ScheduledDownloadModelToJson(this);

  /// Convert to domain entity
  ScheduledDownload toEntity() {
    return ScheduledDownload(
      id: id,
      scheduleId: scheduleId,
      downloadId: downloadId,
      scheduledAt: DateTime.parse(scheduledAt),
      executedAt: executedAt != null ? DateTime.parse(executedAt!) : null,
      isExecuted: isExecuted,
      isSuccessful: isSuccessful,
      errorMessage: errorMessage,
      result: result,
    );
  }

  /// Create from domain entity
  factory ScheduledDownloadModel.fromEntity(ScheduledDownload entity) {
    return ScheduledDownloadModel(
      id: entity.id,
      scheduleId: entity.scheduleId,
      downloadId: entity.downloadId,
      scheduledAt: entity.scheduledAt.toIso8601String(),
      executedAt: entity.executedAt?.toIso8601String(),
      isExecuted: entity.isExecuted,
      isSuccessful: entity.isSuccessful,
      errorMessage: entity.errorMessage,
      result: entity.result,
    );
  }
}
