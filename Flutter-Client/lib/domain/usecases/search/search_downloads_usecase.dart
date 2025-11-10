import 'package:dartz/dartz.dart';
import '../../entities/search_parameters.dart';
import '../../entities/search_result.dart';
import '../../repositories/search_repository.dart';

/// Use case for searching downloads
class SearchDownloadsUseCase {
  final SearchRepository _repository;

  SearchDownloadsUseCase(this._repository);

  Future<Either<String, SearchResult>> call(SearchParameters parameters) async {
    try {
      final result = await _repository.searchDownloads(parameters);

      // Save search to history if query is not empty
      if (parameters.query != null && parameters.query!.isNotEmpty) {
        await _repository.saveSearchHistory(parameters);
      }

      return Right(result);
    } catch (e) {
      return Left('Failed to search downloads: ${e.toString()}');
    }
  }
}
