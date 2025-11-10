import 'package:dartz/dartz.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for deleting a schedule
class DeleteScheduleUseCase {
  final ScheduleRepository _repository;

  DeleteScheduleUseCase(this._repository);

  Future<Either<String, void>> call(String scheduleId) async {
    try {
      if (scheduleId.isEmpty) {
        return const Left('Schedule ID cannot be empty');
      }

      await _repository.deleteSchedule(scheduleId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete schedule: ${e.toString()}');
    }
  }
}
