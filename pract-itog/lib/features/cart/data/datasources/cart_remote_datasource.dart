import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../catalog/domain/entities/game_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../catalog/data/datasources/catalog_remote_datasource.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemEntity>> getCart(String userId);
  Future<void> addToCart(String userId, GameEntity game);
  Future<void> removeFromCart(String userId, String gameId);
  Future<void> updateQuantity(String userId, String gameId, int quantity);
  Future<void> checkout(String userId, List<CartItemEntity> items);
  Future<void> clearCart(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CatalogRemoteDataSource _catalogDataSource;

  // Локальное хранилище для корзины (на случай проблем с Firestore)
  static final Map<String, List<Map<String, dynamic>>> _localCarts = {};

  CartRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required CatalogRemoteDataSource catalogDataSource,
  })  : _firestore = firestore,
        _catalogDataSource = catalogDataSource;

  CollectionReference _cartRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('cart');

  @override
  Future<List<CartItemEntity>> getCart(String userId) async {
    try {
      final snapshot = await _cartRef(userId).get();
      final items = <CartItemEntity>[];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final gameId = data['gameId'] as String;
        final quantity = data['quantity'] as int? ?? 1;
        try {
          final game = await _catalogDataSource.getGameById(gameId);
          items.add(
              CartItemModel(gameId: gameId, game: game, quantity: quantity));
        } catch (_) {}
      }
      return items;
    } catch (e) {
      debugPrint('Firestore error (getCart), using local: $e');
      final localData = _localCarts[userId] ?? [];
      final items = <CartItemEntity>[];
      for (final data in localData) {
        final gameId = data['gameId'] as String;
        final quantity = data['quantity'] as int? ?? 1;
        try {
          final game = await _catalogDataSource.getGameById(gameId);
          items.add(
              CartItemModel(gameId: gameId, game: game, quantity: quantity));
        } catch (_) {}
      }
      return items;
    }
  }

  @override
  Future<void> addToCart(String userId, GameEntity game) async {
    try {
      final doc = _cartRef(userId).doc(game.id);
      final existing = await doc.get();
      if (existing.exists) {
        final qty =
            (existing.data() as Map<String, dynamic>)['quantity'] as int? ?? 1;
        await doc.update({'quantity': qty + 1});
      } else {
        await doc.set({
          'gameId': game.id,
          'quantity': 1,
          'addedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Firestore error (addToCart), using local: $e');
      final cart = _localCarts[userId] ?? [];
      final existingIndex =
          cart.indexWhere((item) => item['gameId'] == game.id);
      if (existingIndex != -1) {
        cart[existingIndex]['quantity'] =
            (cart[existingIndex]['quantity'] as int) + 1;
      } else {
        cart.add({
          'gameId': game.id,
          'quantity': 1,
        });
      }
      _localCarts[userId] = cart;
    }
  }

  @override
  Future<void> removeFromCart(String userId, String gameId) async {
    try {
      await _cartRef(userId).doc(gameId).delete();
    } catch (e) {
      debugPrint('Firestore error (removeFromCart), using local: $e');
      final cart = _localCarts[userId] ?? [];
      cart.removeWhere((item) => item['gameId'] == gameId);
      _localCarts[userId] = cart;
    }
  }

  @override
  Future<void> updateQuantity(
    String userId,
    String gameId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCart(userId, gameId);
      return;
    }
    try {
      await _cartRef(userId).doc(gameId).update({'quantity': quantity});
    } catch (e) {
      debugPrint('Firestore error (updateQuantity), using local: $e');
      final cart = _localCarts[userId] ?? [];
      final index = cart.indexWhere((item) => item['gameId'] == gameId);
      if (index != -1) {
        cart[index]['quantity'] = quantity;
      }
      _localCarts[userId] = cart;
    }
  }

  @override
  Future<void> checkout(String userId, List<CartItemEntity> items) async {
    final total = items.fold<double>(0, (acc, i) => acc + i.totalPrice);
    try {
      final orderRef =
          _firestore.collection('users').doc(userId).collection('orders').doc();
      await orderRef.set({
        'id': orderRef.id,
        'games': items
            .map((i) => {
                  'gameId': i.gameId,
                  'title': i.game.title,
                  'price': i.game.price,
                  'quantity': i.quantity,
                  'imageUrl': i.game.imageUrl,
                })
            .toList(),
        'total': total,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
    } catch (e) {
      debugPrint('Firestore error (checkout): $e');
      // Для демо просто очистим локальную корзину
    }
    await clearCart(userId);
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      final snapshot = await _cartRef(userId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore error (clearCart), using local: $e');
    }
    _localCarts[userId] = [];
  }
}
