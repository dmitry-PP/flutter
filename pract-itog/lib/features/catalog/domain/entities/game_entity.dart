import 'package:equatable/equatable.dart';

class GameEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String genre;
  final double rating;
  final String imageUrl;
  final List<String> screenshots;
  final String publisher;
  final DateTime releaseDate;
  final bool isNew;
  final bool isFeatured;

  const GameEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.genre,
    required this.rating,
    required this.imageUrl,
    required this.screenshots,
    required this.publisher,
    required this.releaseDate,
    required this.isNew,
    required this.isFeatured,
  });

  String get formattedPrice => '${price.toStringAsFixed(2)} ₽';

  @override
  List<Object?> get props => [id, title, price, genre];
}
