import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../entities/download_schedule.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for getting all schedules
@injectable
class GetSchedulesUseCase {
  GetSchedulesUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Either<String, List<DownloadSchedule>>> call() async {
    try {
      final schedules = await _repository.getSchedules();
      return Right(schedules);
    } catch (e) {
      return Left('Failed to get schedules: ${e.toString()}');
    }
  }
}
