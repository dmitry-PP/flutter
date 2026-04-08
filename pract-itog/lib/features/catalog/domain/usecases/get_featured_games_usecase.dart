import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/game_entity.dart';
import '../repositories/catalog_repository.dart';

class GetFeaturedGamesUseCase extends UseCase<List<GameEntity>, NoParams> {
  final CatalogRepository repository;
  GetFeaturedGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<GameEntity>>> call(NoParams params) {
    return repository.getFeaturedGames();
  }
}
