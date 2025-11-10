import 'package:dartz/dartz.dart';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for creating a new schedule
class CreateScheduleUseCase {
  final ScheduleRepository _repository;

  CreateScheduleUseCase(this._repository);

  Future<Either<String, Schedule>> call(Schedule schedule) async {
    try {
      final created = await _repository.createSchedule(schedule);
      return Right(created);
    } catch (e) {
      return Left('Failed to create schedule: ${e.toString()}');
    }
  }
}
