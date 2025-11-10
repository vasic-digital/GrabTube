import 'package:dartz/dartz.dart';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for getting a schedule by ID
class GetScheduleByIdUseCase {
  final ScheduleRepository _repository;

  GetScheduleByIdUseCase(this._repository);

  Future<Either<String, Schedule>> call(String scheduleId) async {
    try {
      if (scheduleId.isEmpty) {
        return const Left('Schedule ID cannot be empty');
      }

      final schedule = await _repository.getScheduleById(scheduleId);

      if (schedule == null) {
        return Left('Schedule not found: $scheduleId');
      }

      return Right(schedule);
    } catch (e) {
      return Left('Failed to get schedule: ${e.toString()}');
    }
  }
}
