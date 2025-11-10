import 'package:dartz/dartz.dart';
import '../../repositories/download_repository.dart';

/// Use case for starting pending downloads
class StartDownloadUseCase {
  final DownloadRepository _repository;

  StartDownloadUseCase(this._repository);

  Future<Either<String, void>> call({required List<String> ids}) async {
    try {
      if (ids.isEmpty) {
        return const Left('No download IDs provided');
      }

      await _repository.startDownload(ids: ids);
      return const Right(null);
    } catch (e) {
      return Left('Failed to start downloads: ${e.toString()}');
    }
  }
}
