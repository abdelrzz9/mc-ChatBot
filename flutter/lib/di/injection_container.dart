import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/network/network_info.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_client.dart';
import '../core/storage/app_local_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<AppLocalStorage>(
    () => AppLocalStorage(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: sl<Connectivity>(),
      connectionChecker: sl<InternetConnection>(),
    ),
  );

  sl.registerLazySingleton(
    () => ApiClient(networkInfo: sl<NetworkInfo>()),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(),
  );
}
