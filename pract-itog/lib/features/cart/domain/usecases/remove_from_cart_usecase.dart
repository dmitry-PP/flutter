import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase extends UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;
  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartParams params) {
    return repository.removeFromCart(params.userId, params.gameId);
  }
}

class RemoveFromCartParams extends Equatable {
  final String userId;
  final String gameId;
  const RemoveFromCartParams({required this.userId, required this.gameId});

  @override
  List<Object?> get props => [userId, gameId];
}
