import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/game_entity.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<GameEntity>>> getGames({
    String? genre,
    String? sortBy,
  });
  Future<Either<Failure, List<GameEntity>>> getFeaturedGames();
  Future<Either<Failure, List<GameEntity>>> searchGames(String query);
  Future<Either<Failure, GameEntity>> getGameById(String id);
}
