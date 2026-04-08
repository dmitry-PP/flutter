import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/domain/usecases/verify_email_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'features/catalog/data/repositories/catalog_repository_impl.dart';
import 'features/catalog/domain/repositories/catalog_repository.dart';
import 'features/catalog/domain/usecases/get_featured_games_usecase.dart';
import 'features/catalog/domain/usecases/get_games_usecase.dart';
import 'features/catalog/domain/usecases/search_games_usecase.dart';
import 'features/catalog/presentation/bloc/catalog_bloc.dart';
import 'features/catalog/presentation/cubit/filter_cubit.dart';

import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/repositories/cart_repository.dart';
import 'features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'features/cart/domain/usecases/checkout_usecase.dart';
import 'features/cart/domain/usecases/get_cart_usecase.dart';
import 'features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';

import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_orders_usecase.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

import 'features/wishlist/presentation/cubit/wishlist_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => SendEmailVerificationUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      resetPasswordUseCase: sl(),
      sendEmailVerificationUseCase: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl<CatalogRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetGamesUseCase(sl<CatalogRepository>()));
  sl.registerLazySingleton(
    () => GetFeaturedGamesUseCase(sl<CatalogRepository>()),
  );
  sl.registerLazySingleton(() => SearchGamesUseCase(sl<CatalogRepository>()));
  sl.registerFactory(
    () => CatalogBloc(
      getGamesUseCase: sl(),
      getFeaturedGamesUseCase: sl(),
      searchGamesUseCase: sl(),
    ),
  );
  sl.registerFactory(() => FilterCubit());

  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      catalogDataSource: sl<CatalogRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => CheckoutUseCase(sl<CartRepository>()));
  sl.registerFactory(
    () => CartBloc(
      getCartUseCase: sl(),
      addToCartUseCase: sl(),
      removeFromCartUseCase: sl(),
      checkoutUseCase: sl(),
      cartRepository: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetOrdersUseCase(sl<ProfileRepository>()));
  sl.registerFactory(
    () => ProfileCubit(getOrdersUseCase: sl()),
  );

  sl.registerFactory(
    () => WishlistCubit(
      firestore: sl<FirebaseFirestore>(),
      catalogDataSource: sl<CatalogRemoteDataSource>(),
    ),
  );
}
