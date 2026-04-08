import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/game_entity.dart';

class GameModel extends GameEntity {
  const GameModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.genre,
    required super.rating,
    required super.imageUrl,
    required super.screenshots,
    required super.publisher,
    required super.releaseDate,
    required super.isNew,
    required super.isFeatured,
  });

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      genre: data['genre'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String? ?? '',
      screenshots: List<String>.from(data['screenshots'] as List? ?? []),
      publisher: data['publisher'] as String? ?? '',
      releaseDate: (data['releaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isNew: data['isNew'] as bool? ?? false,
      isFeatured: data['isFeatured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'genre': genre,
      'rating': rating,
      'imageUrl': imageUrl,
      'screenshots': screenshots,
      'publisher': publisher,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'isNew': isNew,
      'isFeatured': isFeatured,
    };
  }
}
