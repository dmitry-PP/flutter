import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class CheckoutUseCase extends UseCase<void, CheckoutParams> {
  final CartRepository repository;
  CheckoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CheckoutParams params) {
    return repository.checkout(params.userId, params.items);
  }
}

class CheckoutParams extends Equatable {
  final String userId;
  final List<CartItemEntity> items;
  const CheckoutParams({required this.userId, required this.items});

  @override
  List<Object?> get props => [userId, items];
}
