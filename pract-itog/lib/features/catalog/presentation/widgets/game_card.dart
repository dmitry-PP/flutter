import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../../wishlist/presentation/cubit/wishlist_state.dart';
import '../../domain/entities/game_entity.dart';

class ProductCard extends StatelessWidget {
  final GameEntity product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final userId = _getUserId(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'product_image_${product.id}',
                        child: product.imageUrl.startsWith('local:')
                            ? _LocalProductArt(
                                title: product.title,
                                genre: product.genre,
                              )
                            : CachedNetworkImage(
                                imageUrl: product.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: AppColors.shimmerBase,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => _LocalProductArt(
                                  title: product.title,
                                  genre: product.genre,
                                ),
                              ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Row(
                          children: [
                            if (product.isNew)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'НОВИНКА',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: BlocBuilder<WishlistCubit, WishlistState>(
                          builder: (context, state) {
                            final inWishlist = state is WishlistLoaded &&
                                state.contains(product.id);
                            return IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.divider),
                                ),
                                child: Icon(
                                  inWishlist
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: inWishlist
                                      ? AppColors.primaryDark
                                      : AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                              onPressed: () {
                                if (userId.isEmpty) {
                                  AppSnackBar.showInfo(
                                    context,
                                    'Войдите, чтобы добавить в список',
                                  );
                                  return;
                                }
                                context
                                    .read<WishlistCubit>()
                                    .toggleWishlist(userId, product);
                                AppSnackBar.showInfo(
                                  context,
                                  !inWishlist
                                      ? 'Добавлено в список'
                                      : 'Удалено из списка',
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.publisher.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          product.genre,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.formattedPrice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryDark,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.starColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          BlocBuilder<CartBloc, CartState>(
                            builder: (context, cartState) {
                              final inCart = cartState is CartLoaded &&
                                  cartState.containsGame(product.id);
                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  if (userId.isEmpty) {
                                    AppSnackBar.showError(
                                      context,
                                      'Войдите, чтобы купить',
                                    );
                                    return;
                                  }
                                  if (inCart) {
                                    context.go('/cart');
                                    return;
                                  }
                                  context.read<CartBloc>().add(
                                        CartAddGame(
                                            userId: userId, game: product),
                                      );
                                  NotificationService.instance
                                      .showCartNotification(product.title);
                                  AppSnackBar.showSuccess(
                                    context,
                                    'Добавлено в корзину',
                                  );
                                },
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: inCart
                                        ? AppColors.primary
                                        : AppColors.accent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    inCart
                                        ? Icons.check_rounded
                                        : Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              );
                            },
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

  String _getUserId(BuildContext context) {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.id : '';
  }
}

class _LocalProductArt extends StatelessWidget {
  final String title;
  final String genre;

  const _LocalProductArt({
    required this.title,
    required this.genre,
  });

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
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Icon(
              _iconForGenre(genre),
              size: 64,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          ),
        ],
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
