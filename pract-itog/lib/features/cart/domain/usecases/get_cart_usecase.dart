import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase extends UseCase<List<CartItemEntity>, String> {
  final CartRepository repository;
  GetCartUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartItemEntity>>> call(String userId) {
    return repository.getCart(userId);
  }
}
