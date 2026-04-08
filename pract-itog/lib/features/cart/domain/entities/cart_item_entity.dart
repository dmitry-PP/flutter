import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/game_entity.dart';

class CartItemEntity extends Equatable {
  final String gameId;
  final GameEntity game;
  final int quantity;

  const CartItemEntity({
    required this.gameId,
    required this.game,
    required this.quantity,
  });

  double get totalPrice => game.price * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      gameId: gameId,
      game: game,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [gameId, quantity];
}
