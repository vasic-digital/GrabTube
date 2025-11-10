import 'package:equatable/equatable.dart';

/// QR scan result entity representing a scanned QR code
class QRScanResult extends Equatable {
  const QRScanResult({
    required this.rawValue,
    required this.scannedAt,
    required this.isValidUrl,
    this.extractedUrl,
  });

  /// The raw scanned value from the QR code
  final String rawValue;

  /// Extracted URL if the QR code contains a valid download URL
  final String? extractedUrl;

  /// When the QR code was scanned
  final DateTime scannedAt;

  /// Whether the scanned value is a valid URL for downloading
  final bool isValidUrl;

  /// Create a copy with updated fields
  QRScanResult copyWith({
    String? rawValue,
    String? extractedUrl,
    DateTime? scannedAt,
    bool? isValidUrl,
  }) {
    return QRScanResult(
      rawValue: rawValue ?? this.rawValue,
      extractedUrl: extractedUrl ?? this.extractedUrl,
      scannedAt: scannedAt ?? this.scannedAt,
      isValidUrl: isValidUrl ?? this.isValidUrl,
    );
  }

  /// Check if the QR code contains a valid URL
  bool get hasValidUrl => isValidUrl && extractedUrl != null;

  /// Get a user-friendly description of the scan result
  String get description {
    if (hasValidUrl) {
      return 'Valid download URL';
    } else if (extractedUrl != null) {
      return 'URL detected but not valid for downloading';
    } else {
      return 'No URL found in QR code';
    }
  }

  @override
  List<Object?> get props => [
        rawValue,
        extractedUrl,
        scannedAt,
        isValidUrl,
      ];
}
