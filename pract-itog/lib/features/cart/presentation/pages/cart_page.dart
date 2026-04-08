import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
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
    _loadCart();
  }

  void _loadCart() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CartBloc>().add(CartLoad(authState.user.id));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String get _userId {
    final s = context.read<AuthBloc>().state;
    return s is AuthAuthenticated ? s.user.id : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            AppSnackBar.showError(context, state.message);
          } else if (state is CartCheckedOut) {
            final formatted = NumberFormat.currency(
              locale: 'ru_RU',
              symbol: '₽',
              decimalDigits: 0,
            ).format(state.total);
            AppSnackBar.showSuccess(
              context,
              'Заказ оформлен на $formatted! Спасибо за покупку.',
            );
            NotificationService.instance.showOrderNotification(formatted);
            context.read<ProfileCubit>().loadProfile(_userId);
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const ShimmerList(count: 3);
          }
          if (state is CartLoaded && state.items.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.shopping_bag_outlined,
              title: 'Ваша корзина пуста',
              subtitle: 'Добавьте книги из каталога',
            );
          }
          if (state is CartLoaded) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: _buildCart(state),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCart(CartLoaded state) {
    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 0,
    );
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return Dismissible(
                key: Key(item.gameId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 28),
                ),
                onDismissed: (_) {
                  context.read<CartBloc>().add(
                        CartRemoveGame(userId: _userId, gameId: item.gameId),
                      );
                  AppSnackBar.showInfo(
                      context, '${item.game.title} удалена из корзины');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                        ),
                        child: Hero(
                          tag: 'product_image_${item.game.id}',
                          child: item.game.imageUrl.startsWith('local:')
                              ? _CartLocalImage(
                                  title: item.game.title,
                                  genre: item.game.genre,
                                )
                              : CachedNetworkImage(
                                  imageUrl: item.game.imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => _CartLocalImage(
                                    title: item.game.title,
                                    genre: item.game.genre,
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.game.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.game.publisher,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatter.format(item.game.price),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildQuantityControl(item.gameId, item.quantity),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _buildCheckoutBar(state, formatter),
      ],
    );
  }

  Widget _buildQuantityControl(String gameId, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: AppColors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: quantity > 1
                ? () => context.read<CartBloc>().add(
                      CartUpdateQuantity(
                        userId: _userId,
                        gameId: gameId,
                        quantity: quantity - 1,
                      ),
                    )
                : null,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            color: AppColors.primary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => context.read<CartBloc>().add(
                  CartUpdateQuantity(
                    userId: _userId,
                    gameId: gameId,
                    quantity: quantity + 1,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(CartLoaded state, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ИТОГО',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    formatter.format(state.total),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: PrimaryButton(
                text: 'ОФОРМИТЬ',
                icon: Icons.check_circle_outline,
                onPressed: () => _showCheckoutDialog(state, formatter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(CartLoaded state, NumberFormat formatter) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Оформление заказа',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(
          'Подтвердить заказ на сумму ${formatter.format(state.total)}?\n\n'
          'Товаров в корзине: ${state.items.length}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ОТМЕНА',
                style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartBloc>().add(CartCheckout(_userId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('ПОДТВЕРДИТЬ',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _CartLocalImage extends StatelessWidget {
  final String title;
  final String genre;

  const _CartLocalImage({
    required this.title,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: DecoratedBox(
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
        child: Icon(
          _iconForGenre(genre),
          color: Colors.white.withValues(alpha: 0.95),
          size: 34,
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
