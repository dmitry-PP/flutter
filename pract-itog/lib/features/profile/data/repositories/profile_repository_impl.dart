import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource dataSource;
  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders(String userId) async {
    try {
      final orders = await dataSource.getOrders(userId);
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
