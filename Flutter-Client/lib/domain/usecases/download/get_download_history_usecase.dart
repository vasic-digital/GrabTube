import 'package:dartz/dartz.dart';
import '../../entities/download.dart';
import '../../repositories/download_repository.dart';

/// Use case for getting download history
class GetDownloadHistoryUseCase {
  final DownloadRepository _repository;

  GetDownloadHistoryUseCase(this._repository);

  Future<Either<String, List<Download>>> call() async {
    try {
      final history = await _repository.getHistory();
      return Right(history);
    } catch (e) {
      return Left('Failed to get download history: ${e.toString()}');
    }
  }
}
