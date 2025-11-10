import 'package:dartz/dartz.dart';
import '../../entities/search_parameters.dart';
import '../../repositories/search_repository.dart';

/// Use case for getting search history
class GetSearchHistoryUseCase {
  final SearchRepository _repository;

  GetSearchHistoryUseCase(this._repository);

  Future<Either<String, List<SearchParameters>>> call() async {
    try {
      final history = await _repository.getSearchHistory();
      return Right(history);
    } catch (e) {
      return Left('Failed to get search history: ${e.toString()}');
    }
  }
}
