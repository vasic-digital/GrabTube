import 'package:dartz/dartz.dart';
import '../../entities/download.dart';
import '../../repositories/download_repository.dart';

/// Use case for adding a new download
class AddDownloadUseCase {
  final DownloadRepository _repository;

  AddDownloadUseCase(this._repository);

  Future<Either<String, Download>> call({
    required String url,
    String? quality,
    String? format,
    String? folder,
    bool? autoStart,
  }) async {
    try {
      if (url.isEmpty) {
        return const Left('URL cannot be empty');
      }

      final download = await _repository.addDownload(
        url: url,
        quality: quality,
        format: format,
        folder: folder,
        autoStart: autoStart,
      );

      return Right(download);
    } catch (e) {
      return Left('Failed to add download: ${e.toString()}');
    }
  }
}
