import 'package:dartz/dartz.dart';
import '../../repositories/jdownloader_repository.dart';

/// Use case for disconnecting from JDownloader instance
class DisconnectJDownloaderUseCase {
  final JDownloaderRepository _repository;

  DisconnectJDownloaderUseCase(this._repository);

  Future<Either<String, void>> call(String instanceId) async {
    try {
      if (instanceId.isEmpty) {
        return const Left('Instance ID cannot be empty');
      }

      await _repository.disconnectInstance(instanceId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to disconnect from JDownloader: ${e.toString()}');
    }
  }
}
