import 'package:dartz/dartz.dart';
import '../../repositories/favorites_repository.dart';

/// Use case for removing download from favorites
class RemoveFavoriteUseCase {
  final FavoritesRepository _repository;

  RemoveFavoriteUseCase(this._repository);

  Future<Either<String, void>> call(String downloadId) async {
    try {
      if (downloadId.isEmpty) {
        return const Left('Download ID cannot be empty');
      }

      await _repository.removeFavorite(downloadId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to remove favorite: ${e.toString()}');
    }
  }
}
