import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../cubit/filter_cubit.dart';
import '../widgets/game_card.dart';
import '../../domain/entities/game_entity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogBloc>().add(const CatalogLoadGames());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CatalogBloc, CatalogState>(
        builder: (context, state) {
          if (state is CatalogLoading) {
            return const ShimmerGameGrid();
          }
          if (state is CatalogError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Ошибка загрузки',
              subtitle: state.message,
              actionLabel: 'Повторить',
              onAction: () =>
                  context.read<CatalogBloc>().add(const CatalogLoadGames()),
            );
          }
          if (state is CatalogLoaded) {
            return _buildContent(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(CatalogLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async =>
          context.read<CatalogBloc>().add(const CatalogLoadGames()),
      child: CustomScrollView(
        slivers: [
          _buildHeaderSliver(),
          SliverToBoxAdapter(child: _buildGenreChips()),
          if (state.featuredGames.isNotEmpty)
            SliverToBoxAdapter(child: _buildFeatured(state)),
          SliverToBoxAdapter(child: _buildAllHeader(state.games.length)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.42,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ProductCard(
                  product: state.games[index],
                  onTap: () =>
                      context.push('/product/${state.games[index].id}'),
                ),
                childCount: state.games.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  SliverAppBar _buildHeaderSliver() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      backgroundColor: AppColors.primary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded, color: Colors.white),
          onPressed: () => _showFilterSheet(context),
        ),
        BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            final count = state is CartLoaded ? state.items.length : 0;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () => context.go('/cart'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BookNest',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 1),
            Text(
              'Книги, которые хочется дочитать',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.accent.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: _buildSearchBar(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Поиск книг, авторов…',
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textHint,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CatalogBloc>().add(const CatalogClearSearch());
                    setState(() {});
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isNotEmpty) {
            context.read<CatalogBloc>().add(CatalogSearchGames(value));
          } else {
            context.read<CatalogBloc>().add(const CatalogClearSearch());
          }
        },
      ),
    );
  }

  Widget _buildFeatured(CatalogLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Рекомендуем',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.featuredGames.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = state.featuredGames[index];
                return SizedBox(
                  width: 280,
                  child: _FeaturedProductTile(
                    product: product,
                    onTap: () => context.push('/product/${product.id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
      child: Row(
        children: [
          Text(
            'Каталог',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const Spacer(),
          Text(
            '$count позиций',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filterState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Жанры',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: FilterCubit.genres.map((genre) {
                  final selected = filterState.selectedGenre == genre;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () {
                        context.read<FilterCubit>().selectGenre(genre);
                        final filter = context.read<FilterCubit>().state;
                        context.read<CatalogBloc>().add(
                              CatalogLoadGames(
                                genre: filter.selectedGenre == genre
                                    ? null
                                    : genre,
                                sortBy: filterState.sortBy,
                              ),
                            );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color:
                              selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.divider,
                            width: 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyFilters() {
    final filter = context.read<FilterCubit>().state;
    context.read<CatalogBloc>().add(
          CatalogLoadGames(genre: filter.selectedGenre, sortBy: filter.sortBy),
        );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
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

class _FeaturedProductTile extends StatelessWidget {
  final GameEntity product;
  final VoidCallback onTap;

  const _FeaturedProductTile({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(20)),
                child: SizedBox(
                  width: 140,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.imageUrl.startsWith('local:')
                          ? _LocalFeaturedArt(product: product)
                          : CachedNetworkImage(
                              imageUrl: product.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) =>
                                  _LocalFeaturedArt(product: product),
                            ),
                      if (product.isNew)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          product.genre,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        product.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.publisher,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.starColor,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    product.rating.toStringAsFixed(1),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.formattedPrice,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Подробнее',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalFeaturedArt extends StatelessWidget {
  final GameEntity product;
  const _LocalFeaturedArt({required this.product});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.accent,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _iconForGenre(product.genre),
          size: 52,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }

  IconData _iconForGenre(String genre) {
    final g = genre.toLowerCase();
    if (g.contains('фантаст')) return Icons.rocket_launch_rounded;
    if (g.contains('фэнтез')) return Icons.auto_stories_rounded;
    if (g.contains('класс')) return Icons.menu_book_rounded;
    if (g.contains('детектив')) return Icons.manage_search_rounded;
    if (g.contains('бизнес')) return Icons.business_center_rounded;
    if (g.contains('само')) return Icons.psychology_alt_rounded;
    if (g.contains('детям')) return Icons.child_care_rounded;
    return Icons.local_library_rounded;
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
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Фильтры и сортировка',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Text('Жанр', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FilterCubit.genres.map((genre) {
                  final selected = filter.selectedGenre == genre;
                  return FilterChip(
                    label: Text(genre),
                    selected: selected,
                    onSelected: (_) {
                      context.read<FilterCubit>().selectGenre(genre);
                    },
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
