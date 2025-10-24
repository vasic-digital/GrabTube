import 'package:injectable/injectable.dart';

import '../network/python_service_client.dart';
import '../network/native_python_bridge.dart';

/// Module for service dependencies
@module
abstract class ServiceModule {
  @singleton
  PythonServiceClient get pythonServiceClient;

  @singleton
  NativePythonBridge get nativePythonBridge;
}