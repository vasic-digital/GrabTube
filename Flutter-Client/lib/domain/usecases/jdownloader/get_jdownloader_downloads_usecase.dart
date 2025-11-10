import 'package:dartz/dartz.dart';
import '../../repositories/jdownloader_repository.dart';

/// Use case for getting downloads from JDownloader instance
class GetJDownloaderDownloadsUseCase {
  final JDownloaderRepository _repository;

  GetJDownloaderDownloadsUseCase(this._repository);

  Future<Either<String, List<dynamic>>> call(String instanceId) async {
    try {
      if (instanceId.isEmpty) {
        return const Left('Instance ID cannot be empty');
      }

      final downloads = await _repository.getDownloads(instanceId);
      return Right(downloads);
    } catch (e) {
      return Left('Failed to get JDownloader downloads: ${e.toString()}');
    }
  }
}
