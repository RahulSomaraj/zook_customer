import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../app/app_router.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/send_otp.dart';
import '../../features/auth/domain/usecases/verify_otp.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/product/data/datasources/category_remote_data_source.dart';
import '../../features/product/data/datasources/product_remote_data_source.dart';
import '../../features/product/data/repositories/category_repository_impl.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/category_repository.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import '../../features/wishlist/data/repositories/wishlist_repository_impl.dart';
import '../../features/wishlist/domain/repositories/wishlist_repository.dart';
import '../../features/wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../features/address/data/datasources/address_remote_data_source.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/address/presentation/cubit/address_cubit.dart';

/// Global service locator.
final GetIt sl = GetIt.instance;

/// Registers every dependency. Call once in main() before runApp().
Future<void> initDependencies() async {
  // ---- External ----
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  // Dio attaches the auth bearer token via the local auth store (resolved
  // lazily, so registration order with AuthLocalDataSource doesn't matter).
  // On a 401 it clears the session and routes to the sign-in page.
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      tokenProvider: () => sl<AuthLocalDataSource>().accessToken,
      onUnauthorized: () {
        sl<AuthLocalDataSource>().clear();
        AppRouter.router.go(AppRoute.login.path);
      },
    ),
  );

  // ---- Auth feature ----
  // Data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  // Domain
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  // Presentation
  sl.registerFactory(
    () => AuthBloc(sendOtp: sl(), verifyOtp: sl(), logout: sl()),
  );

  // ---- Product / catalog (live API) ----
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  // Categories (live API)
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );

  // ---- Wishlist (live API) ----
  sl.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(remoteDataSource: sl()),
  );

  // ---- Address (live API) ----
  sl.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerFactory<AddressCubit>(() => AddressCubit(repository: sl()));

  // ---- Cart (live API) ----
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: sl()),
  );

  // ---- Cart & Wishlist (global singletons, shared across the app) ----
  sl.registerLazySingleton<CartCubit>(() => CartCubit(repository: sl()));
  sl.registerLazySingleton<WishlistCubit>(
    () => WishlistCubit(repository: sl()),
  );
}
