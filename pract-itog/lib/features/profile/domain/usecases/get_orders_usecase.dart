import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/profile_repository.dart';

class GetOrdersUseCase extends UseCase<List<OrderEntity>, String> {
  final ProfileRepository repository;
  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(String userId) {
    return repository.getOrders(userId);
  }
}
