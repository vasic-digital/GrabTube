import 'package:dartz/dartz.dart';
import '../../repositories/jdownloader_repository.dart';

/// Use case for adding download to JDownloader
class AddJDownloaderDownloadUseCase {
  final JDownloaderRepository _repository;

  AddJDownloaderDownloadUseCase(this._repository);

  Future<Either<String, void>> call({
    required String instanceId,
    required String url,
    String? destinationFolder,
    String? packageName,
  }) async {
    try {
      if (instanceId.isEmpty) {
        return const Left('Instance ID cannot be empty');
      }

      if (url.isEmpty) {
        return const Left('URL cannot be empty');
      }

      await _repository.addDownload(
        instanceId: instanceId,
        url: url,
        destinationFolder: destinationFolder,
        packageName: packageName,
      );

      return const Right(null);
    } catch (e) {
      return Left('Failed to add download to JDownloader: ${e.toString()}');
    }
  }
}
