import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_featured_games_usecase.dart';
import '../../domain/usecases/get_games_usecase.dart';
import '../../domain/usecases/search_games_usecase.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetGamesUseCase getGamesUseCase;
  final GetFeaturedGamesUseCase getFeaturedGamesUseCase;
  final SearchGamesUseCase searchGamesUseCase;

  CatalogBloc({
    required this.getGamesUseCase,
    required this.getFeaturedGamesUseCase,
    required this.searchGamesUseCase,
  }) : super(const CatalogInitial()) {
    on<CatalogLoadGames>(_onLoadGames);
    on<CatalogLoadFeatured>(_onLoadFeatured);
    on<CatalogSearchGames>(_onSearch);
    on<CatalogClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadGames(
    CatalogLoadGames event,
    Emitter<CatalogState> emit,
  ) async {
    emit(const CatalogLoading());
    final gamesResult = await getGamesUseCase(
      GetGamesParams(genre: event.genre, sortBy: event.sortBy),
    );
    final featuredResult = await getFeaturedGamesUseCase(const NoParams());
    gamesResult.fold(
      (failure) => emit(CatalogError(failure.message)),
      (games) => featuredResult.fold(
        (_) => emit(CatalogLoaded(games: games)),
        (featured) =>
            emit(CatalogLoaded(games: games, featuredGames: featured)),
      ),
    );
  }

  Future<void> _onLoadFeatured(
    CatalogLoadFeatured event,
    Emitter<CatalogState> emit,
  ) async {
    final result = await getFeaturedGamesUseCase(const NoParams());
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (games) {
        final current = state;
        if (current is CatalogLoaded) {
          emit(CatalogLoaded(games: current.games, featuredGames: games));
        }
      },
    );
  }

  Future<void> _onSearch(
    CatalogSearchGames event,
    Emitter<CatalogState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const CatalogLoadGames());
      return;
    }
    emit(const CatalogLoading());
    final result = await searchGamesUseCase(event.query);
    result.fold(
      (failure) => emit(CatalogError(failure.message)),
      (games) => emit(CatalogSearchResult(results: games, query: event.query)),
    );
  }

  void _onClearSearch(
    CatalogClearSearch event,
    Emitter<CatalogState> emit,
  ) {
    add(const CatalogLoadGames());
  }
}
