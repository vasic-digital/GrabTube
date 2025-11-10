import 'package:dartz/dartz.dart';
import '../../repositories/jdownloader_repository.dart';

/// Use case for resuming JDownloader download
class ResumeJDownloaderDownloadUseCase {
  final JDownloaderRepository _repository;

  ResumeJDownloaderDownloadUseCase(this._repository);

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

      await _repository.resumeDownload(
        instanceId: instanceId,
        downloadId: downloadId,
      );

      return const Right(null);
    } catch (e) {
      return Left('Failed to resume JDownloader download: ${e.toString()}');
    }
  }
}
