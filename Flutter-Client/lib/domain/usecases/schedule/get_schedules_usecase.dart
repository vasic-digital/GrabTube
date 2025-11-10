import 'package:dartz/dartz.dart';
import '../../entities/schedule.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for getting all schedules
class GetSchedulesUseCase {
  final ScheduleRepository _repository;

  GetSchedulesUseCase(this._repository);

  Future<Either<String, List<Schedule>>> call({bool activeOnly = false}) async {
    try {
      final schedules = activeOnly
          ? await _repository.getActiveSchedules()
          : await _repository.getAllSchedules();
      return Right(schedules);
    } catch (e) {
      return Left('Failed to get schedules: ${e.toString()}');
    }
  }
}
