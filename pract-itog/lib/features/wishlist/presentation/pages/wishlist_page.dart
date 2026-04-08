import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../catalog/presentation/widgets/game_card.dart';
import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    final s = context.read<AuthBloc>().state;
    if (s is AuthAuthenticated) {
      context.read<WishlistCubit>().loadWishlist(s.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Список чтения',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          if (state is WishlistLoading) return const ShimmerGameGrid(count: 4);
          if (state is WishlistLoaded && state.games.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.bookmark_border_rounded,
              title: 'Список пока пуст',
              subtitle: 'Добавляйте книги, чтобы вернуться к ним позже',
            );
          }
          if (state is WishlistLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.42,
              ),
              itemCount: state.games.length,
              itemBuilder: (context, index) => ProductCard(
                product: state.games[index],
                onTap: () => context.push('/product/${state.games[index].id}'),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
