import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/data/datasources/catalog_remote_datasource.dart';
import '../../../catalog/domain/entities/game_entity.dart';
import 'wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  final FirebaseFirestore _firestore;
  final CatalogRemoteDataSource _catalogDataSource;

  WishlistCubit({
    required FirebaseFirestore firestore,
    required CatalogRemoteDataSource catalogDataSource,
  })  : _firestore = firestore,
        _catalogDataSource = catalogDataSource,
        super(const WishlistInitial());

  CollectionReference _wishlistRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('wishlist');

  Future<void> loadWishlist(String userId) async {
    emit(const WishlistLoading());
    try {
      final snapshot = await _wishlistRef(userId).get();
      final games = <GameEntity>[];
      for (final doc in snapshot.docs) {
        try {
          final game = await _catalogDataSource.getGameById(doc.id);
          games.add(game);
        } catch (_) {}
      }
      emit(WishlistLoaded(games));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> toggleWishlist(String userId, GameEntity game) async {
    if (state is! WishlistLoaded) {
      await loadWishlist(userId);
    }
    
    final current = state;
    if (current is! WishlistLoaded) return;

    final inWishlist = current.contains(game.id);
    if (inWishlist) {
      await _wishlistRef(userId).doc(game.id).delete();
      emit(WishlistLoaded(
        current.games.where((g) => g.id != game.id).toList(),
      ));
    } else {
      await _wishlistRef(userId).doc(game.id).set({
        'addedAt': FieldValue.serverTimestamp(),
      });
      emit(WishlistLoaded([...current.games, game]));
    }
  }
}
