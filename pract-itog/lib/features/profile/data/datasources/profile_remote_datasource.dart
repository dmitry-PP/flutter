import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<OrderModel>> getOrders(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  ProfileRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map(OrderModel.fromFirestore).toList();
    } catch (e) {
      debugPrint('Firestore error (orders): $e');
      return []; // Возвращаем пустой список при ошибке доступа
    }
  }
}
