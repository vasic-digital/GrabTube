import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../network/api_client.dart';
import '../network/socket_client.dart';
import '../network/python_service_client.dart';
import '../network/native_python_bridge.dart';
import '../network/jdownloader_api_client.dart';
import '../../domain/repositories/download_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/repositories/jdownloader_repository.dart';
import '../../data/repositories/download_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/repositories/jdownloader_repository_impl.dart';

final getIt = GetIt.instance;

/// Configure dependency injection
Future<void> configureDependencies() async {
  // Register third-party dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerSingleton<Connectivity>(Connectivity());

  // Register Dio instances
  getIt.registerSingleton<Dio>(
    Dio(
      BaseOptions(
        baseUrl: sharedPreferences.getString('server_url') ?? 'http://localhost:8080',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
    instanceName: 'main',
  );

  getIt.registerSingleton<Dio>(
    Dio(
      BaseOptions(
        baseUrl: 'https://api.jdownloader.org',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ),
    instanceName: 'jdownloader',
  );

  // Register services
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>(instanceName: 'main')));
  getIt.registerLazySingleton<JDownloaderApiClient>(() => JDownloaderApiClient(getIt<Dio>(instanceName: 'jdownloader')));
  getIt.registerLazySingleton<SocketClient>(() => SocketClient(sharedPreferences));
  getIt.registerLazySingleton<PythonServiceClient>(() => PythonServiceClient());
  getIt.registerLazySingleton<NativePythonBridge>(() => NativePythonBridge());

  // Register repositories
  getIt.registerLazySingleton<DownloadRepository>(
    () => DownloadRepositoryImpl(
      getIt<ApiClient>(),
      getIt<SocketClient>(),
      sharedPreferences,
    ),
  );
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      getIt<DownloadRepository>(),
      sharedPreferences,
    ),
  );
  getIt.registerLazySingleton<JDownloaderRepository>(
    () => JDownloaderRepositoryImpl(
      getIt<JDownloaderApiClient>(),
      sharedPreferences,
    ),
  );
}
