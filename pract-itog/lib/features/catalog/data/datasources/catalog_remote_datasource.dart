import '../models/game_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<GameModel>> getGames({String? genre, String? sortBy});
  Future<List<GameModel>> getFeaturedGames();
  Future<List<GameModel>> searchGames(String query);
  Future<GameModel> getGameById(String id);
  Future<void> seedGamesIfNeeded();
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl();

  List<GameModel> get _localGames => _sampleGames().map((data) {
        return GameModel(
          id: data['id'] as String,
          title: data['title'] as String,
          description: data['description'] as String,
          price: (data['price'] as num).toDouble(),
          genre: data['genre'] as String,
          rating: (data['rating'] as num).toDouble(),
          imageUrl: data['imageUrl'] as String,
          screenshots: List<String>.from(data['screenshots'] as List),
          publisher: data['publisher'] as String,
          releaseDate: data['releaseDate'] as DateTime,
          isNew: data['isNew'] as bool,
          isFeatured: data['isFeatured'] as bool,
        );
      }).toList();

  @override
  Future<List<GameModel>> getGames({String? genre, String? sortBy}) async {
    var games = _localGames;

    if (genre != null && genre.isNotEmpty) {
      games = games.where((g) => g.genre == genre).toList();
    }

    switch (sortBy) {
      case 'price_asc':
        games.sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        games.sort((a, b) => b.price.compareTo(a.price));
      case 'rating':
        games.sort((a, b) => b.rating.compareTo(a.rating));
      case 'newest':
        games.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
      default:
        games.sort((a, b) => b.isFeatured ? 1 : -1);
    }
    return games;
  }

  @override
  Future<List<GameModel>> getFeaturedGames() async {
    return _localGames.where((g) => g.isFeatured).take(5).toList();
  }

  @override
  Future<List<GameModel>> searchGames(String query) async {
    final lower = query.toLowerCase();
    return _localGames
        .where(
          (g) =>
              g.title.toLowerCase().contains(lower) ||
              g.genre.toLowerCase().contains(lower) ||
              g.publisher.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Future<GameModel> getGameById(String id) async {
    final game = _localGames.firstWhere(
      (g) => g.id == id,
      orElse: () => throw Exception('Книга не найдена'),
    );
    return game;
  }

  @override
  Future<void> seedGamesIfNeeded() async {}

  List<Map<String, dynamic>> _sampleGames() {
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'title': 'Дюна',
        'description':
            'Эпическая сага о власти, вере и выживании на планете Арракис. '
                'Пол Атрейдес оказывается в центре борьбы за меланж — ресурс, '
                'который меняет судьбы империй.',
        'price': 990.0,
        'genre': 'Фантастика',
        'rating': 4.8,
        'imageUrl': 'https://covers.openlibrary.org/b/isbn/0441172717-L.jpg',
        'screenshots': [
          'https://covers.openlibrary.org/b/isbn/0441172717-L.jpg',
          'https://covers.openlibrary.org/b/isbn/0441172717-M.jpg',
        ],
        'publisher': 'Фрэнк Герберт',
        'releaseDate': now.subtract(const Duration(days: 30)),
        'isNew': false,
        'isFeatured': true,
      },
      {
        'id': '2',
        'title': 'Гарри Поттер и философский камень',
        'description':
            'Первая книга о мальчике-волшебнике: Хогвартс, тайны, дружба '
                'и приключения, которые меняют жизнь навсегда.',
        'price': 790.0,
        'genre': 'Фэнтези',
        'rating': 4.9,
        'imageUrl': 'https://covers.openlibrary.org/b/isbn/0747532699-L.jpg',
        'screenshots': [
          'https://covers.openlibrary.org/b/isbn/0747532699-L.jpg',
          'https://covers.openlibrary.org/b/isbn/0747532699-M.jpg',
        ],
        'publisher': 'Дж. К. Роулинг',
        'releaseDate': now.subtract(const Duration(days: 12)),
        'isNew': true,
        'isFeatured': true,
      },
      {
        'id': '3',
        'title': '1984',
        'description': 'Роман-предупреждение о тотальном контроле, '
            'манипуляции правдой и цене свободы.',
        'price': 520.0,
        'genre': 'Классика',
        'rating': 4.7,
        'imageUrl': 'https://covers.openlibrary.org/b/isbn/0451524934-L.jpg',
        'screenshots': [
          'https://covers.openlibrary.org/b/isbn/0451524934-L.jpg',
          'https://covers.openlibrary.org/b/isbn/0451524934-M.jpg',
        ],
        'publisher': 'Джордж Оруэлл',
        'releaseDate': now.subtract(const Duration(days: 90)),
        'isNew': true,
        'isFeatured': true,
      },
      {
        'id': '4',
        'title': 'Шерлок Холмс: Собрание рассказов',
        'description':
            'Классические расследования, остроумие и наблюдательность. '
                'Истории, которые сделали Холмса легендой.',
        'price': 690.0,
        'genre': 'Детектив',
        'rating': 4.8,
        'imageUrl': 'https://covers.openlibrary.org/b/isbn/9780141034379-L.jpg',
        'screenshots': [
          'https://covers.openlibrary.org/b/isbn/9780141034379-L.jpg',
          'https://covers.openlibrary.org/b/isbn/9780141034379-M.jpg',
        ],
        'publisher': 'Артур Конан Дойл',
        'releaseDate': now.subtract(const Duration(days: 20)),
        'isNew': true,
        'isFeatured': true,
      },
      {
        'id': '5',
        'title': 'Думай медленно… решай быстро',
        'description':
            'Как работают два режима мышления и почему мы ошибаемся, '
                'даже когда уверены в своей правоте.',
        'price': 890.0,
        'genre': 'Саморазвитие',
        'rating': 4.6,
        'imageUrl': 'https://covers.openlibrary.org/b/isbn/0374533555-L.jpg',
        'screenshots': [
          'https://covers.openlibrary.org/b/isbn/0374533555-L.jpg',
          'https://covers.openlibrary.org/b/isbn/0374533555-M.jpg',
        ],
        'publisher': 'Даниэль Канеман',
        'releaseDate': now.subtract(const Duration(days: 65)),
        'isNew': false,
        'isFeatured': false,
      },
      {
        'id': '6',
        'title': 'Нулевой пациент',
        'description': 'Напряжённый триллер о первых часах катастрофы и '
            'людях, которые пытаются остановить цепную реакцию событий.',
        'price': 640.0,
        'genre': 'Фантастика',
        'rating': 4.5,
        'imageUrl': 'https://covers.openlibrary.org/b/isbn/0316033094-L.jpg',
        'screenshots': [
          'https://covers.openlibrary.org/b/isbn/0316033094-L.jpg',
          'https://covers.openlibrary.org/b/isbn/0316033094-M.jpg',
        ],
        'publisher': 'Джонатан Мэйберри',
        'releaseDate': now.subtract(const Duration(days: 120)),
        'isNew': false,
        'isFeatured': false,
      },
    ];
  }
}
