import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetOrdersUseCase getOrdersUseCase;

  ProfileCubit({required this.getOrdersUseCase}) : super(const ProfileInitial());

  Future<void> loadProfile(String userId) async {
    emit(const ProfileLoading());
    final result = await getOrdersUseCase(userId);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (orders) => emit(ProfileLoaded(orders: orders)),
    );
  }
}
