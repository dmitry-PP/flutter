import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../cubit/filter_cubit.dart';
import '../widgets/game_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    context.read<CatalogBloc>().add(const CatalogLoadGames());
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filter = context.read<FilterCubit>().state;
    context.read<CatalogBloc>().add(
          CatalogLoadGames(genre: filter.selectedGenre, sortBy: filter.sortBy),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('КАТАЛОГ КНИГ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildSearchBar(),
            _buildActiveFilters(),
            Expanded(child: _buildGameList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Поиск по названию, автору...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textHint),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                    context.read<CatalogBloc>().add(const CatalogClearSearch());
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty) {
            context.read<CatalogBloc>().add(CatalogSearchGames(value));
          } else {
            _applyFilters();
          }
        },
      ),
    );
  }

  Widget _buildActiveFilters() {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filter) {
        final hasFilters =
            filter.selectedGenre != null || filter.sortBy != 'default';
        if (!hasFilters) return const SizedBox(height: 8);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              if (filter.selectedGenre != null)
                Chip(
                  label: Text(filter.selectedGenre!),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    context
                        .read<FilterCubit>()
                        .selectGenre(filter.selectedGenre);
                    _applyFilters();
                  },
                ),
              if (filter.sortBy != 'default') ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    FilterCubit.sortOptions.firstWhere(
                        (o) => o['value'] == filter.sortBy)['label']!,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () {
                    context.read<FilterCubit>().selectSort('default');
                    _applyFilters();
                  },
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<FilterCubit>().reset();
                  _applyFilters();
                },
                child: const Text('Сбросить'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameList() {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state is CatalogLoading) return const ShimmerGameGrid();
        if (state is CatalogError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Ошибка загрузки',
            subtitle: state.message,
            actionLabel: 'Повторить',
            onAction: _applyFilters,
          );
        }

        List games = [];
        if (state is CatalogLoaded) games = state.games;
        if (state is CatalogSearchResult) games = state.results;

        if (games.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.search_off,
            title: 'Ничего не найдено',
            subtitle: 'Попробуйте изменить фильтры или запрос поиска',
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => _applyFilters(),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.42,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) => ProductCard(
              product: games[index],
              onTap: () => context.push('/product/${games[index].id}'),
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<FilterCubit>(),
        child: _FilterSheet(onApply: _applyFilters),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final VoidCallback onApply;
  const _FilterSheet({required this.onApply});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filter) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Фильтры',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Text('Жанр', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FilterCubit.genres.map((genre) {
                  return FilterChip(
                    label: Text(genre),
                    selected: filter.selectedGenre == genre,
                    onSelected: (_) =>
                        context.read<FilterCubit>().selectGenre(genre),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Сортировка',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...FilterCubit.sortOptions.map(
                (opt) {
                  final selected = filter.sortBy == opt['value'];
                  return InkWell(
                    onTap: () =>
                        context.read<FilterCubit>().selectSort(opt['value']!),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textHint,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            opt['label']!,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onApply();
                  },
                  child: const Text('Применить'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
