import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/speed_data_point.dart';

part 'speed_data_point_model.g.dart';

@JsonSerializable()
class SpeedDataPointModel {
  SpeedDataPointModel({
    required this.timestamp,
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  factory SpeedDataPointModel.fromJson(Map<String, dynamic> json) =>
      _$SpeedDataPointModelFromJson(json);

  final int timestamp;

  @JsonKey(name: 'download_speed')
  final double downloadSpeed;

  @JsonKey(name: 'upload_speed')
  final double uploadSpeed;

  Map<String, dynamic> toJson() => _$SpeedDataPointModelToJson(this);

  /// Convert to domain entity
  SpeedDataPoint toEntity() {
    return SpeedDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
    );
  }

  /// Create from domain entity
  factory SpeedDataPointModel.fromEntity(SpeedDataPoint entity) {
    return SpeedDataPointModel(
      timestamp: entity.timestamp.millisecondsSinceEpoch,
      downloadSpeed: entity.downloadSpeed,
      uploadSpeed: entity.uploadSpeed,
    );
  }
}
