import 'package:equatable/equatable.dart';
import '../../domain/entities/game_entity.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();
  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  final List<GameEntity> games;
  final List<GameEntity> featuredGames;
  const CatalogLoaded({required this.games, this.featuredGames = const []});
  @override
  List<Object?> get props => [games, featuredGames];
}

class CatalogSearchResult extends CatalogState {
  final List<GameEntity> results;
  final String query;
  const CatalogSearchResult({required this.results, required this.query});
  @override
  List<Object?> get props => [results, query];
}

class CatalogError extends CatalogState {
  final String message;
  const CatalogError(this.message);
  @override
  List<Object?> get props => [message];
}
