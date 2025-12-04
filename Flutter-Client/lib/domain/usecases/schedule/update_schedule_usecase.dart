import 'package:dartz/dartz.dart';
import '../../entities/download_schedule.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for updating an existing schedule
class UpdateScheduleUseCase {
  final ScheduleRepository _repository;

  UpdateScheduleUseCase(this._repository);

  Future<Either<String, DownloadSchedule>> call(DownloadSchedule schedule) async {
    try {
      await _repository.updateSchedule(schedule);
      return Right(schedule);
    } catch (e) {
      return Left('Failed to update schedule: ${e.toString()}');
    }
  }
}
