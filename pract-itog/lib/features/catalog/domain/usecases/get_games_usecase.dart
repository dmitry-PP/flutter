import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/game_entity.dart';
import '../repositories/catalog_repository.dart';

class GetGamesUseCase extends UseCase<List<GameEntity>, GetGamesParams> {
  final CatalogRepository repository;
  GetGamesUseCase(this.repository);

  @override
  Future<Either<Failure, List<GameEntity>>> call(GetGamesParams params) {
    return repository.getGames(genre: params.genre, sortBy: params.sortBy);
  }
}

class GetGamesParams extends Equatable {
  final String? genre;
  final String? sortBy;
  const GetGamesParams({this.genre, this.sortBy});

  @override
  List<Object?> get props => [genre, sortBy];
}
