import 'package:injectable/injectable.dart';

import '../network/python_service_client.dart';
import '../network/native_python_bridge.dart';
import '../network/jdownloader_api_client.dart';
import '../../data/repositories/qr_scanner_repository_impl.dart';

/// Module for service dependencies
@module
abstract class ServiceModule {
  @singleton
  PythonServiceClient get pythonServiceClient;

  @singleton
  NativePythonBridge get nativePythonBridge;

  @singleton
  JDownloaderApiClient get jdownloaderApiClient;

  @singleton
  QRScannerRepositoryImpl get qrScannerRepository;
}