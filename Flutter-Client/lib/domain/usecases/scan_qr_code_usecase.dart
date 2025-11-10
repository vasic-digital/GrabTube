import 'package:dartz/dartz.dart';
import '../entities/qr_scan_result.dart';
import '../repositories/qr_scanner_repository.dart';

/// Use case for scanning QR codes from camera
class ScanQRCodeUseCase {
  final QRScannerRepository _repository;

  ScanQRCodeUseCase(this._repository);

  Future<Either<String, QRScanResult>> call() async {
    try {
      // Check if camera permission is granted
      final hasPermission = await _repository.hasCameraPermission();

      if (!hasPermission) {
        // Request permission if not granted
        final permissionResult = await _repository.requestCameraPermission();

        // Check if permission request failed
        if (permissionResult.isLeft()) {
          return permissionResult.fold(
            (error) => Left(error),
            (_) => Left('Permission denied'),
          );
        }
      }

      // Scan QR code
      final result = await _repository.scanQRCode();

      return result.fold(
        (error) => Left(error),
        (scanResult) async {
          // Save to history
          await _repository.saveScanResult(scanResult);
          return Right(scanResult);
        },
      );
    } catch (e) {
      return Left('Failed to scan QR code: ${e.toString()}');
    }
  }
}
