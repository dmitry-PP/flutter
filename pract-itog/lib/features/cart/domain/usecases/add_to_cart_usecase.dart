import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../catalog/domain/entities/game_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase extends UseCase<void, AddToCartParams> {
  final CartRepository repository;
  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToCartParams params) {
    return repository.addToCart(params.userId, params.game);
  }
}

class AddToCartParams extends Equatable {
  final String userId;
  final GameEntity game;
  const AddToCartParams({required this.userId, required this.game});

  @override
  List<Object?> get props => [userId, game];
}
