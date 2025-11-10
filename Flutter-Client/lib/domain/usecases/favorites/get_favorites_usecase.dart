import 'package:dartz/dartz.dart';
import '../../entities/download.dart';
import '../../repositories/favorites_repository.dart';

/// Use case for getting all favorites
class GetFavoritesUseCase {
  final FavoritesRepository _repository;

  GetFavoritesUseCase(this._repository);

  Future<Either<String, List<Download>>> call() async {
    try {
      final favorites = await _repository.getFavorites();
      return Right(favorites);
    } catch (e) {
      return Left('Failed to get favorites: ${e.toString()}');
    }
  }
}
