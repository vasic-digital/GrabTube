import '../entities/qr_scan_result.dart';

/// Repository interface for QR code scanning operations
abstract class QrScannerRepository {
  /// Scan QR code from camera
  Future<QRScanResult> scanFromCamera();

  /// Scan QR code from image file
  Future<QRScanResult> scanFromImage(String imagePath);

  /// Validate if scanned value is a valid download URL
  Future<bool> validateUrl(String url);

  /// Extract URL from QR code raw value
  Future<String?> extractUrl(String rawValue);

  /// Get scan history
  Future<List<QRScanResult>> getScanHistory();

  /// Save scan result to history
  Future<void> saveScanResult(QRScanResult result);

  /// Clear scan history
  Future<void> clearScanHistory();

  /// Delete specific scan result from history
  Future<void> deleteScanResult(String scanId);

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission();

  /// Request camera permission
  Future<bool> requestCameraPermission();
}
