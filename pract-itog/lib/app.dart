import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/catalog/presentation/bloc/catalog_bloc.dart';
import 'features/catalog/presentation/cubit/filter_cubit.dart';
import 'features/catalog/presentation/pages/game_detail_page.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/profile/presentation/pages/orders_page.dart';
import 'features/splash/splash_page.dart';
import 'features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'features/wishlist/presentation/pages/wishlist_page.dart';
import 'injection_container.dart';
import 'main_navigation_page.dart';

class BookNestApp extends StatelessWidget {
  const BookNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<CatalogBloc>(create: (_) => sl<CatalogBloc>()),
        BlocProvider<FilterCubit>(create: (_) => sl<FilterCubit>()),
        BlocProvider<CartBloc>(create: (_) => sl<CartBloc>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        BlocProvider<WishlistCubit>(create: (_) => sl<WishlistCubit>()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/email-verification',
          builder: (_, __) => const EmailVerificationPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, __) => const MainNavigationPage(currentIndex: 0),
        ),
        GoRoute(
          path: '/wishlist-tab',
          builder: (_, __) => const MainNavigationPage(currentIndex: 1),
        ),
        GoRoute(
          path: '/cart',
          builder: (_, __) => const MainNavigationPage(currentIndex: 2),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const MainNavigationPage(currentIndex: 3),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (_, state) =>
              GameDetailPage(gameId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/profile/orders',
          builder: (_, __) => const OrdersPage(),
        ),
        GoRoute(
          path: '/wishlist',
          builder: (_, __) => const WishlistPage(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          _router.go('/login');
        } else if (state is AuthAuthenticated) {
          context.read<WishlistCubit>().loadWishlist(state.user.id);
          context.read<CartBloc>().add(CartLoad(state.user.id));
        }
      },
      child: MaterialApp.router(
        title: 'BookNest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
