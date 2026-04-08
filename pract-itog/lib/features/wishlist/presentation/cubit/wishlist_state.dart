import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/game_entity.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();
  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {
  const WishlistInitial();
}

class WishlistLoading extends WishlistState {
  const WishlistLoading();
}

class WishlistLoaded extends WishlistState {
  final List<GameEntity> games;
  const WishlistLoaded(this.games);

  bool contains(String gameId) => games.any((g) => g.id == gameId);

  @override
  List<Object?> get props => [games];
}

class WishlistError extends WishlistState {
  final String message;
  const WishlistError(this.message);
  @override
  List<Object?> get props => [message];
}
