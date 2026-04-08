import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String gameId;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;

  const OrderItemEntity({
    required this.gameId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [gameId, quantity];
}

class OrderEntity extends Equatable {
  final String id;
  final List<OrderItemEntity> games;
  final double total;
  final DateTime createdAt;
  final String status;

  const OrderEntity({
    required this.id,
    required this.games,
    required this.total,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props => [id];
}
