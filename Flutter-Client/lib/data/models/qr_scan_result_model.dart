import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/qr_scan_result.dart';

part 'qr_scan_result_model.g.dart';

@JsonSerializable()
class QRScanResultModel {
  QRScanResultModel({
    required this.rawValue,
    required this.scannedAt,
    required this.isValidUrl,
    this.extractedUrl,
  });

  factory QRScanResultModel.fromJson(Map<String, dynamic> json) =>
      _$QRScanResultModelFromJson(json);

  @JsonKey(name: 'raw_value')
  final String rawValue;

  @JsonKey(name: 'extracted_url')
  final String? extractedUrl;

  @JsonKey(name: 'scanned_at')
  final String scannedAt;

  @JsonKey(name: 'is_valid_url')
  final bool isValidUrl;

  Map<String, dynamic> toJson() => _$QRScanResultModelToJson(this);

  /// Convert to domain entity
  QRScanResult toEntity() {
    return QRScanResult(
      rawValue: rawValue,
      extractedUrl: extractedUrl,
      scannedAt: DateTime.parse(scannedAt),
      isValidUrl: isValidUrl,
    );
  }

  /// Create from domain entity
  factory QRScanResultModel.fromEntity(QRScanResult entity) {
    return QRScanResultModel(
      rawValue: entity.rawValue,
      extractedUrl: entity.extractedUrl,
      scannedAt: entity.scannedAt.toIso8601String(),
      isValidUrl: entity.isValidUrl,
    );
  }
}
