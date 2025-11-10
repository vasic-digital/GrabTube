import 'package:dartz/dartz.dart';
import '../../entities/download.dart';
import '../../repositories/download_repository.dart';

/// Use case for getting downloads
class GetDownloadsUseCase {
  final DownloadRepository _repository;

  GetDownloadsUseCase(this._repository);

  Future<Either<String, List<Download>>> call({String? filter}) async {
    try {
      List<Download> downloads;

      switch (filter) {
        case 'queue':
          downloads = await _repository.getQueue();
          break;
        case 'completed':
          downloads = await _repository.getCompleted();
          break;
        case 'pending':
          downloads = await _repository.getPending();
          break;
        default:
          downloads = await _repository.getDownloads();
      }

      return Right(downloads);
    } catch (e) {
      return Left('Failed to get downloads: ${e.toString()}');
    }
  }
}
