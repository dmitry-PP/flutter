import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.games,
    required super.total,
    required super.createdAt,
    required super.status,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final gamesList = (data['games'] as List? ?? [])
        .map(
          (g) => OrderItemEntity(
            gameId: g['gameId'] as String? ?? '',
            title: g['title'] as String? ?? '',
            price: (g['price'] as num?)?.toDouble() ?? 0.0,
            quantity: g['quantity'] as int? ?? 1,
            imageUrl: g['imageUrl'] as String? ?? '',
          ),
        )
        .toList();

    return OrderModel(
      id: doc.id,
      games: gamesList,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'completed',
    );
  }
}
