import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'repositories/auth_repo.dart';
import 'services/local_data_src.dart';
import 'services/remote_auth_src.dart';
import 'view_models/auth_vm.dart';
import 'repositories/items_repo.dart';
import 'repositories/order_repo.dart';
import 'services/navigation.dart';
import 'services/remote_item_src.dart';
import 'services/remote_order_src.dart';
import 'view_models/item_vm.dart';
import 'view_models/order_vm.dart';
import 'view_models/user_vm.dart';

final sl = GetIt.instance;

Future<void> initInjector() async {

  // View Models
  sl.registerFactory(() => AuthViewModel(navigationService: sl(), authRepository: sl()));
  sl.registerFactory(() => ItemViewModel(navigationService: sl(), itemRepository: sl()));
  sl.registerFactory(() => OrderViewModel(navigationService: sl(), orderRepository: sl()));
  sl.registerFactory(() => UserViewModel(navigationService: sl(), authRepository: sl()));

  // Repositories
    sl.registerLazySingleton<ItemRepository>(
          () => ItemRepository(
            remoteItemSource: sl(),
            localDataSource: sl(),
          ));
    sl.registerLazySingleton<OrderRepository>(
          () => OrderRepository(
              remoteOrderSource: sl(),
              localDataSource: sl(),
          ));
   sl.registerLazySingleton<AuthRepositoryContract>(
           () => AuthRepository(
         remoteAuthSource: sl(),
         localDataSource: sl(),
       ));

  // Services
  sl.registerLazySingleton<LocalDataSourceContract>(() => LocalDataSource());
  sl.registerLazySingleton<NavigationServiceContract>(() => NavigationService());
  sl.registerLazySingleton<RemoteAuthSourceContract>(() => RemoteAuthSource(sl()));
  sl.registerLazySingleton<RemoteItemSourceContract>(() => RemoteItemSource(sl()));
  sl.registerLazySingleton<RemoteOrderSourceContract>(() => RemoteOrderSource(sl()));

  // External
  sl.registerLazySingleton(() => Client());


}