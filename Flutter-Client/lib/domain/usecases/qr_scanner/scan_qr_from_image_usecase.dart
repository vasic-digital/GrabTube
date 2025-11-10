import 'package:dartz/dartz.dart';
import '../../entities/qr_scan_result.dart';
import '../../repositories/qr_scanner_repository.dart';

/// Use case for scanning QR codes from image file
class ScanQRFromImageUseCase {
  final QRScannerRepository _repository;

  ScanQRFromImageUseCase(this._repository);

  Future<Either<String, QRScanResult>> call(String imagePath) async {
    try {
      if (imagePath.isEmpty) {
        return const Left('Image path cannot be empty');
      }

      final result = await _repository.scanFromImage(imagePath);

      return result.fold(
        (error) => Left(error),
        (scanResult) async {
          await _repository.saveScanResult(scanResult);
          return Right(scanResult);
        },
      );
    } catch (e) {
      return Left('Failed to scan QR from image: ${e.toString()}');
    }
  }
}
