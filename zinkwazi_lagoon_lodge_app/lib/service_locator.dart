import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'repositories/items_repo.dart';
import 'repositories/order_repo.dart';
import 'services/navigation.dart';
import 'services/network_info.dart';
import 'services/notification.dart';
import 'services/remote_item_src.dart';
import 'services/remote_order_src.dart';
import 'view_models/item_vm.dart';
import 'view_models/order_vm.dart';

import 'services/local_data_src.dart';

final sl = GetIt.instance;

void initInjector() {

  // View Models
  sl.registerFactory(() => ItemViewModel(navigationService: sl(), itemRepository: sl()));
  sl.registerFactory(() => OrderViewModel(navigationService: sl(), orderRepository: sl(), notificationService: sl()));


  // Repositories
    sl.registerLazySingleton<ItemRepository>(
          () => ItemRepository(sl(), sl()));
    sl.registerLazySingleton<OrderRepository>(
          () => OrderRepository(sl(), sl(), sl()));
//  sl.registerLazySingleton<AuthRepositoryContract>(
//          () => AuthRepository(
//        remoteAuthSource: sl(),
//        localDataSource: sl(),
//        networkInfo: sl(),
//      ));

  // Services
  sl.registerLazySingleton<LocalDataSourceContract>(() => LocalDataSource());
  sl.registerLazySingleton<NetworkInfoContract>(() => NetworkInfo(sl())); // mobile only
  sl.registerLazySingleton<NavigationServiceContract>(() => NavigationService());
  sl.registerLazySingleton<NotificationService>(() => NotificationService(sl())); // mobile only
  sl.registerLazySingleton<RemoteItemSourceContract>(() => RemoteItemSource(sl()));
  sl.registerLazySingleton<RemoteOrderSourceContract>(() => RemoteOrderSource(sl()));


  // External
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton(() => Client());
  sl.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  //  sl.registerLazySingleton<FlutterSecureStorage>(() => FlutterSecureStorage());


}