import '../../../catalog/domain/entities/game_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.gameId,
    required super.game,
    required super.quantity,
  });

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      gameId: entity.gameId,
      game: entity.game,
      quantity: entity.quantity,
    );
  }

  factory CartItemModel.fromGame(GameEntity game, {int quantity = 1}) {
    return CartItemModel(gameId: game.id, game: game, quantity: quantity);
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'quantity': quantity,
      'price': game.price,
      'title': game.title,
      'imageUrl': game.imageUrl,
    };
  }
}
