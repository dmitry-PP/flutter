import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('d MMMM yyyy, HH:mm', 'ru');

    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) return const ShimmerList(count: 4);
          if (state is ProfileError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Ошибка',
              subtitle: state.message,
            );
          }
          if (state is ProfileLoaded && state.orders.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Нет заказов',
              subtitle: 'Ваши будущие покупки появятся здесь',
            );
          }
          if (state is ProfileLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OrderCard(
                  order: state.orders[index],
                  formatter: formatter,
                  dateFormatter: dateFormatter,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final NumberFormat formatter;
  final DateFormat dateFormatter;

  const _OrderCard({
    required this.order,
    required this.formatter,
    required this.dateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Заказ #${order.id.substring(0, 8).toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Доставлено',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            dateFormatter.format(order.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 20),
          ...order.games.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.sports_basketball,
                      size: 16, color: AppColors.textHint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    '×${item.quantity}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatter.format(item.price * item.quantity),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Итого:', style: Theme.of(context).textTheme.titleMedium),
              Text(
                formatter.format(order.total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
