import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/qr_scan_result.dart';
import '../../domain/repositories/qr_scanner_repository.dart';
import '../models/qr_scan_result_model.dart';

/// Implementation of QRScannerRepository using mobile_scanner and Hive
@LazySingleton(as: QRScannerRepository)
class QRScannerRepositoryImpl implements QRScannerRepository {
  QRScannerRepositoryImpl(this._scanHistoryBox);

  final Box<QRScanResultModel> _scanHistoryBox;
  final _imagePicker = ImagePicker();

  static const _urlPattern = r'^https?://';
  static const _youtubePatterns = [
    r'youtube\.com',
    r'youtu\.be',
    r'youtube-nocookie\.com',
  ];

  @override
  Future<Either<String, QRScanResult>> scanQRCode() async {
    try {
      // Check permission first
      final hasPermission = await hasCameraPermission();
      if (!hasPermission) {
        final permissionResult = await requestCameraPermission();
        if (permissionResult.isLeft()) {
          return permissionResult.fold(
            (error) => Left(error),
            (_) => const Left('Camera permission denied'),
          );
        }
      }

      // Note: Actual scanning requires UI integration
      // This implementation provides the data layer foundation
      // The presentation layer will handle MobileScannerController
      return const Left(
        'QR scanning requires UI integration. Use MobileScannerController in presentation layer.',
      );
    } catch (e) {
      return Left('Failed to scan QR code: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, QRScanResult>> scanFromImage(String imagePath) async {
    try {
      // Note: Image scanning with mobile_scanner requires platform-specific implementation
      // This would typically use MobileScannerController.analyzeImage()
      // For now, return placeholder
      return const Left(
        'Image scanning requires platform-specific implementation',
      );
    } catch (e) {
      return Left('Failed to scan from image: ${e.toString()}');
    }
  }

  @override
  Future<bool> validateUrl(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null) return false;

      // Check if URL matches expected patterns
      final isHttp = RegExp(_urlPattern, caseSensitive: false).hasMatch(url);
      if (!isHttp) return false;

      // Check if it's a supported video platform
      final isSupportedPlatform = _youtubePatterns.any(
        (pattern) => RegExp(pattern, caseSensitive: false).hasMatch(url),
      );

      return isSupportedPlatform;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> extractUrl(String rawValue) async {
    try {
      // If raw value is already a URL, return it
      if (await validateUrl(rawValue)) {
        return rawValue;
      }

      // Try to extract URL from text (common in QR codes)
      final urlRegex = RegExp(
        r'https?://[^\s]+',
        caseSensitive: false,
      );

      final match = urlRegex.firstMatch(rawValue);
      if (match != null) {
        final extractedUrl = match.group(0);
        if (extractedUrl != null && await validateUrl(extractedUrl)) {
          return extractedUrl;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<QRScanResult>> getScanHistory() async {
    try {
      final models = _scanHistoryBox.values.toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveScanResult(QRScanResult result) async {
    try {
      final model = QRScanResultModel.fromEntity(result);
      final key = result.scannedAt.millisecondsSinceEpoch.toString();
      await _scanHistoryBox.put(key, model);
    } catch (e) {
      throw Exception('Failed to save scan result: ${e.toString()}');
    }
  }

  @override
  Future<void> clearScanHistory() async {
    try {
      await _scanHistoryBox.clear();
    } catch (e) {
      throw Exception('Failed to clear scan history: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteScanResult(String scanId) async {
    try {
      await _scanHistoryBox.delete(scanId);
    } catch (e) {
      throw Exception('Failed to delete scan result: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<String, void>> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();

      if (status.isGranted) {
        return const Right(null);
      } else if (status.isDenied) {
        return const Left('Camera permission denied');
      } else if (status.isPermanentlyDenied) {
        return const Left(
          'Camera permission permanently denied. Please enable it in settings.',
        );
      } else {
        return const Left('Camera permission request failed');
      }
    } catch (e) {
      return Left('Failed to request camera permission: ${e.toString()}');
    }
  }
}
