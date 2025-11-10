import 'package:dartz/dartz.dart';
import '../../repositories/favorites_repository.dart';

/// Use case for toggling favorite status
class ToggleFavoriteUseCase {
  final FavoritesRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  Future<Either<String, bool>> call(String downloadId) async {
    try {
      if (downloadId.isEmpty) {
        return const Left('Download ID cannot be empty');
      }

      await _repository.toggleFavorite(downloadId);
      final isFavorite = await _repository.isFavorite(downloadId);
      return Right(isFavorite);
    } catch (e) {
      return Left('Failed to toggle favorite: ${e.toString()}');
    }
  }
}
