import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_item_entity.dart';
import '../../../catalog/domain/entities/game_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCart(String userId);
  Future<Either<Failure, void>> addToCart(String userId, GameEntity game);
  Future<Either<Failure, void>> removeFromCart(String userId, String gameId);
  Future<Either<Failure, void>> updateQuantity(
    String userId,
    String gameId,
    int quantity,
  );
  Future<Either<Failure, void>> checkout(
    String userId,
    List<CartItemEntity> items,
  );
  Future<Either<Failure, void>> clearCart(String userId);
}
