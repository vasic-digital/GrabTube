import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/download_schedule.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for creating a schedule
@injectable
class CreateScheduleUseCase {
  CreateScheduleUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Either<String, DownloadSchedule>> call(DownloadSchedule schedule) async {
    try {
      final created = await _repository.createSchedule(schedule);
      return Right(created);
    } catch (e) {
      return Left('Failed to create schedule: ${e.toString()}');
    }
  }
}
