import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../network/api_client.dart';
import '../network/socket_client.dart';
import '../network/python_service_client.dart';
import '../network/native_python_bridge.dart';
import '../network/jdownloader_api_client.dart';

// Domain - Repositories
import '../../domain/repositories/download_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/repositories/jdownloader_repository.dart';
import '../../domain/repositories/qr_scanner_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/schedule_repository.dart';

// Data - Repository Implementations
import '../../data/repositories/download_repository_impl.dart';
import '../../data/repositories/search_repository_impl.dart';
import '../../data/repositories/jdownloader_repository_impl.dart';
import '../../data/repositories/qr_scanner_repository_impl.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../data/repositories/schedule_repository_impl.dart';

// Data - Models (for Hive boxes)
import '../../data/models/qr_scan_result_model.dart';
import '../../data/models/schedule_model.dart';
import '../../data/models/scheduled_download_model.dart';
import '../../data/models/jdownloader_instance_model.dart';
import '../../data/models/speed_data_point_model.dart';
import '../../data/models/search_parameters_model.dart';

// Domain - Use Cases - Download
import '../../domain/usecases/download/add_download_usecase.dart';
import '../../domain/usecases/download/delete_download_usecase.dart';
import '../../domain/usecases/download/get_download_history_usecase.dart';
import '../../domain/usecases/download/get_downloads_usecase.dart';
import '../../domain/usecases/download/start_download_usecase.dart';

// Domain - Use Cases - QR Scanner
import '../../domain/usecases/scan_qr_code_usecase.dart';
import '../../domain/usecases/qr_scanner/scan_qr_from_image_usecase.dart';
import '../../domain/usecases/qr_scanner/validate_qr_url_usecase.dart';

// Domain - Use Cases - Search
import '../../domain/usecases/search/search_downloads_usecase.dart';
import '../../domain/usecases/search/get_search_history_usecase.dart';
import '../../domain/usecases/search/clear_search_history_usecase.dart';

// Domain - Use Cases - Favorites
import '../../domain/usecases/favorites/add_favorite_usecase.dart';
import '../../domain/usecases/favorites/remove_favorite_usecase.dart';
import '../../domain/usecases/favorites/get_favorites_usecase.dart';
import '../../domain/usecases/favorites/toggle_favorite_usecase.dart';

// Domain - Use Cases - Schedule
import '../../domain/usecases/schedule/create_schedule_usecase.dart';
import '../../domain/usecases/schedule/update_schedule_usecase.dart';
import '../../domain/usecases/schedule/delete_schedule_usecase.dart';
import '../../domain/usecases/schedule/get_schedules_usecase.dart';
import '../../domain/usecases/schedule/get_schedule_by_id_usecase.dart';

// Domain - Use Cases - JDownloader
import '../../domain/usecases/jdownloader/connect_jdownloader_usecase.dart';
import '../../domain/usecases/jdownloader/disconnect_jdownloader_usecase.dart';
import '../../domain/usecases/jdownloader/add_jdownloader_download_usecase.dart';
import '../../domain/usecases/jdownloader/get_jdownloader_downloads_usecase.dart';
import '../../domain/usecases/jdownloader/pause_jdownloader_download_usecase.dart';
import '../../domain/usecases/jdownloader/resume_jdownloader_download_usecase.dart';

// Presentation - BLoCs
import '../../presentation/blocs/download/download_bloc.dart';
import '../../presentation/blocs/qr_scanner/qr_scanner_bloc.dart';
import '../../presentation/blocs/search/search_bloc.dart';
import '../../presentation/blocs/favorites/favorites_bloc.dart';
import '../../presentation/blocs/schedule/schedule_bloc.dart';
import '../../presentation/blocs/jdownloader/jdownloader_bloc.dart';

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
        baseUrl: sharedPreferences.getString('server_url') ?? 'http://localhost:8081',
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

  // Open Hive boxes (these will be used by repositories)
  // Note: Hive.initFlutter() is called in main.dart before this function
  final scanHistoryBox = await Hive.openBox<QRScanResultModel>('scan_history');
  final searchHistoryBox = await Hive.openBox<SearchParametersModel>('search_history');
  final favoritesBox = await Hive.openBox<String>('favorites');
  final schedulesBox = await Hive.openBox<ScheduleModel>('schedules');
  final scheduledDownloadsBox = await Hive.openBox<ScheduledDownloadModel>('scheduled_downloads');
  final jdownloaderInstancesBox = await Hive.openBox<JDownloaderInstanceModel>('jdownloader_instances');
  final speedDataBox = await Hive.openBox<SpeedDataPointModel>('speed_data');

  // Register Hive boxes
  getIt.registerSingleton<Box<QRScanResultModel>>(scanHistoryBox);
  getIt.registerSingleton<Box<SearchParametersModel>>(searchHistoryBox);
  getIt.registerSingleton<Box<String>>(favoritesBox);
  getIt.registerSingleton<Box<ScheduleModel>>(schedulesBox);
  getIt.registerSingleton<Box<ScheduledDownloadModel>>(scheduledDownloadsBox);
  getIt.registerSingleton<Box<JDownloaderInstanceModel>>(jdownloaderInstancesBox);
  getIt.registerSingleton<Box<SpeedDataPointModel>>(speedDataBox);

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
      getIt<Dio>(instanceName: 'main'),
      getIt<Box<SearchParametersModel>>(),
    ),
  );

  getIt.registerLazySingleton<JDownloaderRepository>(
    () => JDownloaderRepositoryImpl(
      getIt<Dio>(instanceName: 'jdownloader'),
      getIt<Box<JDownloaderInstanceModel>>(),
      getIt<Box<SpeedDataPointModel>>(),
    ),
  );

  getIt.registerLazySingleton<QRScannerRepository>(
    () => QRScannerRepositoryImpl(
      getIt<Box<QRScanResultModel>>(),
    ),
  );

  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      getIt<Dio>(instanceName: 'main'),
      getIt<Box<String>>(),
    ),
  );

  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(
      getIt<Box<ScheduleModel>>(),
      getIt<Box<ScheduledDownloadModel>>(),
    ),
  );

  // Register use cases - Download
  getIt.registerLazySingleton(() => AddDownloadUseCase(getIt<DownloadRepository>()));
  getIt.registerLazySingleton(() => DeleteDownloadUseCase(getIt<DownloadRepository>()));
  getIt.registerLazySingleton(() => GetDownloadHistoryUseCase(getIt<DownloadRepository>()));
  getIt.registerLazySingleton(() => GetDownloadsUseCase(getIt<DownloadRepository>()));
  getIt.registerLazySingleton(() => StartDownloadUseCase(getIt<DownloadRepository>()));

  // Register use cases - QR Scanner
  getIt.registerLazySingleton(() => ScanQRCodeUseCase(getIt<QRScannerRepository>()));
  getIt.registerLazySingleton(() => ScanQRFromImageUseCase(getIt<QRScannerRepository>()));
  getIt.registerLazySingleton(() => ValidateQRUrlUseCase(getIt<QRScannerRepository>()));

  // Register use cases - Search
  getIt.registerLazySingleton(() => SearchDownloadsUseCase(getIt<SearchRepository>()));
  getIt.registerLazySingleton(() => GetSearchHistoryUseCase(getIt<SearchRepository>()));
  getIt.registerLazySingleton(() => ClearSearchHistoryUseCase(getIt<SearchRepository>()));

  // Register use cases - Favorites
  getIt.registerLazySingleton(() => AddFavoriteUseCase(getIt<FavoritesRepository>()));
  getIt.registerLazySingleton(() => RemoveFavoriteUseCase(getIt<FavoritesRepository>()));
  getIt.registerLazySingleton(() => GetFavoritesUseCase(getIt<FavoritesRepository>()));
  getIt.registerLazySingleton(() => ToggleFavoriteUseCase(getIt<FavoritesRepository>()));

  // Register use cases - Schedule
  getIt.registerLazySingleton(() => CreateScheduleUseCase(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => UpdateScheduleUseCase(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => DeleteScheduleUseCase(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => GetSchedulesUseCase(getIt<ScheduleRepository>()));
  getIt.registerLazySingleton(() => GetScheduleByIdUseCase(getIt<ScheduleRepository>()));

  // Register use cases - JDownloader
  getIt.registerLazySingleton(() => ConnectJDownloaderUseCase(getIt<JDownloaderRepository>()));
  getIt.registerLazySingleton(() => DisconnectJDownloaderUseCase(getIt<JDownloaderRepository>()));
  getIt.registerLazySingleton(() => AddJDownloaderDownloadUseCase(getIt<JDownloaderRepository>()));
  getIt.registerLazySingleton(() => GetJDownloaderDownloadsUseCase(getIt<JDownloaderRepository>()));
  getIt.registerLazySingleton(() => PauseJDownloaderDownloadUseCase(getIt<JDownloaderRepository>()));
  getIt.registerLazySingleton(() => ResumeJDownloaderDownloadUseCase(getIt<JDownloaderRepository>()));

  // Register BLoCs (use factory for BLoCs to create new instances)
  getIt.registerFactory(
    () => DownloadBloc(
      getIt<DownloadRepository>(),
    ),
  );

  getIt.registerFactory(
    () => QRScannerBloc(
      getIt<ScanQRCodeUseCase>(),
      getIt<ScanQRFromImageUseCase>(),
      getIt<ValidateQRUrlUseCase>(),
      getIt<QRScannerRepository>(),
    ),
  );

  getIt.registerFactory(
    () => SearchBloc(
      getIt<SearchDownloadsUseCase>(),
      getIt<GetSearchHistoryUseCase>(),
      getIt<ClearSearchHistoryUseCase>(),
      getIt<SearchRepository>(),
    ),
  );

  getIt.registerFactory(
    () => FavoritesBloc(
      getIt<GetFavoritesUseCase>(),
      getIt<AddFavoriteUseCase>(),
      getIt<RemoveFavoriteUseCase>(),
      getIt<ToggleFavoriteUseCase>(),
      getIt<FavoritesRepository>(),
    ),
  );

  getIt.registerFactory(
    () => ScheduleBloc(
      getIt<CreateScheduleUseCase>(),
      getIt<UpdateScheduleUseCase>(),
      getIt<DeleteScheduleUseCase>(),
      getIt<GetSchedulesUseCase>(),
      getIt<GetScheduleByIdUseCase>(),
      getIt<ScheduleRepository>(),
    ),
  );

  getIt.registerFactory(
    () => JDownloaderBloc(
      getIt<ConnectJDownloaderUseCase>(),
      getIt<DisconnectJDownloaderUseCase>(),
      getIt<AddJDownloaderDownloadUseCase>(),
      getIt<GetJDownloaderDownloadsUseCase>(),
      getIt<PauseJDownloaderDownloadUseCase>(),
      getIt<ResumeJDownloaderDownloadUseCase>(),
      getIt<JDownloaderRepository>(),
    ),
  );
}
