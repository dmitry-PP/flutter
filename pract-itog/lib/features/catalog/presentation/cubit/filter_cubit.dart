import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class FilterState extends Equatable {
  final String? selectedGenre;
  final String sortBy;

  const FilterState({this.selectedGenre, this.sortBy = 'default'});

  FilterState copyWith(
      {String? selectedGenre, String? sortBy, bool clearGenre = false}) {
    return FilterState(
      selectedGenre: clearGenre ? null : (selectedGenre ?? this.selectedGenre),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [selectedGenre, sortBy];
}

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(const FilterState());

  static const List<String> genres = [
    'Фантастика',
    'Фэнтези',
    'Классика',
    'Детектив',
    'Бизнес',
    'Саморазвитие',
    'Детям',
  ];

  static const List<Map<String, String>> sortOptions = [
    {'value': 'default', 'label': 'По умолчанию'},
    {'value': 'price_asc', 'label': 'Цена: по возрастанию'},
    {'value': 'price_desc', 'label': 'Цена: по убыванию'},
    {'value': 'rating', 'label': 'По рейтингу'},
    {'value': 'newest', 'label': 'Сначала новые'},
  ];

  void selectGenre(String? genre) {
    if (state.selectedGenre == genre) {
      emit(state.copyWith(clearGenre: true));
    } else {
      emit(state.copyWith(selectedGenre: genre));
    }
  }

  void selectSort(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
  }

  void reset() {
    emit(const FilterState());
  }
}
