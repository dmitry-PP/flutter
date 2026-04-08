import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {
  const CartInitial();
}

class CartLoading extends CartState {
  const CartLoading();
}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  const CartLoaded(this.items);

  double get total =>
      items.fold(0, (acc, item) => acc + item.totalPrice);

  bool containsGame(String gameId) => items.any((i) => i.gameId == gameId);

  @override
  List<Object?> get props => [items];
}

class CartCheckedOut extends CartState {
  final double total;
  const CartCheckedOut(this.total);
  @override
  List<Object?> get props => [total];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}
