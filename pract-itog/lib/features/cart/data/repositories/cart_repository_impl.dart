import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../catalog/domain/entities/game_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource dataSource;
  CartRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCart(String userId) async {
    try {
      final items = await dataSource.getCart(userId);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(
    String userId,
    GameEntity game,
  ) async {
    try {
      await dataSource.addToCart(userId, game);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(
    String userId,
    String gameId,
  ) async {
    try {
      await dataSource.removeFromCart(userId, gameId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateQuantity(
    String userId,
    String gameId,
    int quantity,
  ) async {
    try {
      await dataSource.updateQuantity(userId, gameId, quantity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> checkout(
    String userId,
    List<CartItemEntity> items,
  ) async {
    try {
      await dataSource.checkout(userId, items);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart(String userId) async {
    try {
      await dataSource.clearCart(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
