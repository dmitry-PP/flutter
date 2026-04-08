import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders(String userId);
}
