import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

@module
abstract class DioModule {
  @singleton
  Dio dio(SharedPreferences prefs) {
    final baseUrl = prefs.getString(AppConstants.prefKeyServerUrl) ??
        AppConstants.defaultServerUrl;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (AppConstants.isDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => AppLogger.debug('[DIO] $obj'),
        ),
      );
    }

    // Add error handling interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          AppLogger.error(
            'API Error: ${error.message}',
            error,
            error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );

    AppLogger.info('Dio initialized with base URL: $baseUrl');
    return dio;
  }
}
