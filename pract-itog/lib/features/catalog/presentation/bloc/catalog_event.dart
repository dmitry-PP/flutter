import 'package:equatable/equatable.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();
  @override
  List<Object?> get props => [];
}

class CatalogLoadGames extends CatalogEvent {
  final String? genre;
  final String? sortBy;
  const CatalogLoadGames({this.genre, this.sortBy});
  @override
  List<Object?> get props => [genre, sortBy];
}

class CatalogLoadFeatured extends CatalogEvent {
  const CatalogLoadFeatured();
}

class CatalogSearchGames extends CatalogEvent {
  final String query;
  const CatalogSearchGames(this.query);
  @override
  List<Object?> get props => [query];
}

class CatalogClearSearch extends CatalogEvent {
  const CatalogClearSearch();
}
