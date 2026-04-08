import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/game_entity.dart';
import '../repositories/catalog_repository.dart';

class SearchGamesUseCase extends UseCase<List<GameEntity>, String> {
  final CatalogRepository repository;
  SearchGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<GameEntity>>> call(String query) {
    return repository.searchGames(query);
  }
}
