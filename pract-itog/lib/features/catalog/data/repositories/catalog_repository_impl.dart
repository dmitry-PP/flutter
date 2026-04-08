import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource dataSource;
  CatalogRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<GameEntity>>> getGames({
    String? genre,
    String? sortBy,
  }) async {
    try {
      final games = await dataSource.getGames(genre: genre, sortBy: sortBy);
      return Right(games);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameEntity>>> getFeaturedGames() async {
    try {
      final games = await dataSource.getFeaturedGames();
      return Right(games);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<GameEntity>>> searchGames(String query) async {
    try {
      final games = await dataSource.searchGames(query);
      return Right(games);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GameEntity>> getGameById(String id) async {
    try {
      final game = await dataSource.getGameById(id);
      return Right(game);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
