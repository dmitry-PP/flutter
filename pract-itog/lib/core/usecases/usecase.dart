import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

class NoParams {
  const NoParams();
}
