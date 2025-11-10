import 'package:dartz/dartz.dart';
import '../../repositories/search_repository.dart';

/// Use case for clearing search history
class ClearSearchHistoryUseCase {
  final SearchRepository _repository;

  ClearSearchHistoryUseCase(this._repository);

  Future<Either<String, void>> call() async {
    try {
      await _repository.clearSearchHistory();
      return const Right(null);
    } catch (e) {
      return Left('Failed to clear search history: ${e.toString()}');
    }
  }
}
