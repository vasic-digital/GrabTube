import 'package:dartz/dartz.dart';
import '../../repositories/qr_scanner_repository.dart';

/// Use case for validating QR code URL
class ValidateQRUrlUseCase {
  final QRScannerRepository _repository;

  ValidateQRUrlUseCase(this._repository);

  Future<Either<String, bool>> call(String url) async {
    try {
      if (url.isEmpty) {
        return const Left('URL cannot be empty');
      }

      final isValid = await _repository.validateUrl(url);
      return Right(isValid);
    } catch (e) {
      return Left('Failed to validate URL: ${e.toString()}');
    }
  }
}
