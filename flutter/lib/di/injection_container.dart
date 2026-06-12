import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/network/network_info.dart';
import '../core/network/api_client.dart';
import '../core/network/dio_client.dart';
import '../core/storage/app_local_storage.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/chat/data/datasources/chat_remote_datasource.dart';
import '../features/chat/data/repositories/chat_repository_impl.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/documents/data/datasources/document_remote_datasource.dart';
import '../features/documents/data/repositories/document_repository_impl.dart';
import '../features/documents/domain/repositories/document_repository.dart';
import '../features/settings/data/datasources/settings_remote_datasource.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/domain/repositories/settings_repository.dart';

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

  sl.registerLazySingleton<DioClient>(() => DioClient(
        getAccessToken: () => sl<AppLocalStorage>().getString('access_token'),
        onTokenRefresh: null,
        onUnauthorized: null,
      ));

  _registerAuth();
  _registerSettings();
  _registerChat();
  _registerDocuments();

  sl<DioClient>().onTokenRefresh = () async {
    final refreshToken =
        await sl<AppLocalStorage>().getSecureString('refresh_token');
    if (refreshToken == null) return null;
    try {
      final response = await sl<DioClient>().post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
        requiresAuth: false,
      );
      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;
      await sl<AppLocalStorage>().setString('access_token', newAccessToken);
      await sl<AppLocalStorage>()
          .setSecureString('refresh_token', newRefreshToken);
      return newAccessToken;
    } catch (_) {
      return null;
    }
  };
  sl<DioClient>().onUnauthorized = () {
    sl<AppLocalStorage>().remove('access_token');
    sl<AppLocalStorage>().removeSecure('refresh_token');
  };
}

void _registerAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localStorage: sl<AppLocalStorage>(),
      dioClient: sl<DioClient>(),
    ),
  );
}

void _registerSettings() {
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSource(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: sl<SettingsRemoteDataSource>(),
    ),
  );
}

void _registerChat() {
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl<ChatRemoteDataSource>(),
      localStorage: sl<AppLocalStorage>(),
    ),
  );
}

void _registerDocuments() {
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSource(client: sl<DioClient>()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(
      remoteDataSource: sl<DocumentRemoteDataSource>(),
    ),
  );
}
