import 'package:dartz/dartz.dart';
import '../../repositories/favorites_repository.dart';

/// Use case for adding download to favorites
class AddFavoriteUseCase {
  final FavoritesRepository _repository;

  AddFavoriteUseCase(this._repository);

  Future<Either<String, void>> call(String downloadId) async {
    try {
      if (downloadId.isEmpty) {
        return const Left('Download ID cannot be empty');
      }

      await _repository.addFavorite(downloadId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add favorite: ${e.toString()}');
    }
  }
}
