import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../repositories/schedule_repository.dart';

/// Use case for deleting a schedule
@injectable
class DeleteScheduleUseCase {
  DeleteScheduleUseCase(this._repository);

  final ScheduleRepository _repository;

  Future<Either<String, void>> call(String id) async {
    try {
      await _repository.deleteSchedule(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete schedule: ${e.toString()}');
    }
  }
}
