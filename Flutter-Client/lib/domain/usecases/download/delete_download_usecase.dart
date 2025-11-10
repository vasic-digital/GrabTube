import 'package:dartz/dartz.dart';
import '../../repositories/download_repository.dart';

/// Use case for deleting downloads
class DeleteDownloadUseCase {
  final DownloadRepository _repository;

  DeleteDownloadUseCase(this._repository);

  Future<Either<String, void>> call({
    required List<String> ids,
    String where = 'queue',
  }) async {
    try {
      if (ids.isEmpty) {
        return const Left('No download IDs provided');
      }

      await _repository.deleteDownload(ids: ids, where: where);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete downloads: ${e.toString()}');
    }
  }
}
