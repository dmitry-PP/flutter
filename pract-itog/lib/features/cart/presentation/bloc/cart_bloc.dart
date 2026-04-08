import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/checkout_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final CheckoutUseCase checkoutUseCase;
  final CartRepository cartRepository;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.removeFromCartUseCase,
    required this.checkoutUseCase,
    required this.cartRepository,
  }) : super(const CartInitial()) {
    on<CartLoad>(_onLoad);
    on<CartAddGame>(_onAdd);
    on<CartRemoveGame>(_onRemove);
    on<CartUpdateQuantity>(_onUpdateQuantity);
    on<CartCheckout>(_onCheckout);
  }

  Future<void> _onLoad(CartLoad event, Emitter<CartState> emit) async {
    emit(const CartLoading());
    final result = await getCartUseCase(event.userId);
    result.fold(
      (f) => emit(CartError(f.message)),
      (items) => emit(CartLoaded(items)),
    );
  }

  Future<void> _onAdd(CartAddGame event, Emitter<CartState> emit) async {
    final result = await addToCartUseCase(
      AddToCartParams(userId: event.userId, game: event.game),
    );
    result.fold(
      (f) => emit(CartError(f.message)),
      (_) => add(CartLoad(event.userId)),
    );
  }

  Future<void> _onRemove(CartRemoveGame event, Emitter<CartState> emit) async {
    final result = await removeFromCartUseCase(
      RemoveFromCartParams(userId: event.userId, gameId: event.gameId),
    );
    result.fold(
      (f) => emit(CartError(f.message)),
      (_) => add(CartLoad(event.userId)),
    );
  }

  Future<void> _onUpdateQuantity(
    CartUpdateQuantity event,
    Emitter<CartState> emit,
  ) async {
    final result = await cartRepository.updateQuantity(
      event.userId,
      event.gameId,
      event.quantity,
    );
    result.fold(
      (f) => emit(CartError(f.message)),
      (_) => add(CartLoad(event.userId)),
    );
  }

  Future<void> _onCheckout(
    CartCheckout event,
    Emitter<CartState> emit,
  ) async {
    final current = state;
    if (current is! CartLoaded || current.items.isEmpty) return;
    final total = current.total;
    emit(const CartLoading());
    final result = await checkoutUseCase(
      CheckoutParams(userId: event.userId, items: current.items),
    );
    result.fold(
      (f) => emit(CartError(f.message)),
      (_) => emit(CartCheckedOut(total)),
    );
  }
}
