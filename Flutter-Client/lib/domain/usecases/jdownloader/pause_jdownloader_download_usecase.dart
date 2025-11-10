import 'package:dartz/dartz.dart';
import '../../repositories/jdownloader_repository.dart';

/// Use case for pausing JDownloader download
class PauseJDownloaderDownloadUseCase {
  final JDownloaderRepository _repository;

  PauseJDownloaderDownloadUseCase(this._repository);

  Future<Either<String, void>> call({
    required String instanceId,
    required String downloadId,
  }) async {
    try {
      if (instanceId.isEmpty) {
        return const Left('Instance ID cannot be empty');
      }

      if (downloadId.isEmpty) {
        return const Left('Download ID cannot be empty');
      }

      await _repository.pauseDownload(
        instanceId: instanceId,
        downloadId: downloadId,
      );

      return const Right(null);
    } catch (e) {
      return Left('Failed to pause JDownloader download: ${e.toString()}');
    }
  }
}
