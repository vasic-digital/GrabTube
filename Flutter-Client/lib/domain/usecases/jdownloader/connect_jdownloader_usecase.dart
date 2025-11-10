import 'package:dartz/dartz.dart';
import '../../entities/jdownloader_instance.dart';
import '../../repositories/jdownloader_repository.dart';

/// Use case for connecting to JDownloader instance
class ConnectJDownloaderUseCase {
  final JDownloaderRepository _repository;

  ConnectJDownloaderUseCase(this._repository);

  Future<Either<String, JDownloaderInstance>> call(String instanceId) async {
    try {
      if (instanceId.isEmpty) {
        return const Left('Instance ID cannot be empty');
      }

      final instance = await _repository.connectInstance(instanceId);
      return Right(instance);
    } catch (e) {
      return Left('Failed to connect to JDownloader: ${e.toString()}');
    }
  }
}
