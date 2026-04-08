import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/game_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartLoad extends CartEvent {
  final String userId;
  const CartLoad(this.userId);
  @override
  List<Object?> get props => [userId];
}

class CartAddGame extends CartEvent {
  final String userId;
  final GameEntity game;
  const CartAddGame({required this.userId, required this.game});
  @override
  List<Object?> get props => [userId, game];
}

class CartRemoveGame extends CartEvent {
  final String userId;
  final String gameId;
  const CartRemoveGame({required this.userId, required this.gameId});
  @override
  List<Object?> get props => [userId, gameId];
}

class CartUpdateQuantity extends CartEvent {
  final String userId;
  final String gameId;
  final int quantity;
  const CartUpdateQuantity({
    required this.userId,
    required this.gameId,
    required this.quantity,
  });
  @override
  List<Object?> get props => [userId, gameId, quantity];
}

class CartCheckout extends CartEvent {
  final String userId;
  const CartCheckout(this.userId);
  @override
  List<Object?> get props => [userId];
}
