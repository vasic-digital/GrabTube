import 'package:dartz/dartz.dart';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for updating an existing schedule
class UpdateScheduleUseCase {
  final ScheduleRepository _repository;

  UpdateScheduleUseCase(this._repository);

  Future<Either<String, Schedule>> call(Schedule schedule) async {
    try {
      final updated = await _repository.updateSchedule(schedule);
      return Right(updated);
    } catch (e) {
      return Left('Failed to update schedule: ${e.toString()}');
    }
  }
}
