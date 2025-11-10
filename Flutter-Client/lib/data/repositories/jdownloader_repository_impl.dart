import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/jdownloader_instance.dart';
import '../../domain/entities/speed_data_point.dart';
import '../../domain/repositories/jdownloader_repository.dart';
import '../models/jdownloader_instance_model.dart';
import '../models/speed_data_point_model.dart';

/// Implementation of JDownloaderRepository using API client and Hive
@LazySingleton(as: JDownloaderRepository)
class JDownloaderRepositoryImpl implements JDownloaderRepository {
  JDownloaderRepositoryImpl(
    this._dio,
    this._instancesBox,
    this._speedDataBox,
  );

  final Dio _dio;
  final Box<JDownloaderInstanceModel> _instancesBox;
  final Box<SpeedDataPointModel> _speedDataBox;

  final _instanceController = StreamController<JDownloaderInstance>.broadcast();
  final _speedController = StreamController<SpeedDataPoint>.broadcast();

  @override
  Stream<JDownloaderInstance> get instanceUpdates => _instanceController.stream;

  @override
  Stream<SpeedDataPoint> get speedUpdates => _speedController.stream;

  @override
  Future<List<JDownloaderInstance>> getInstances() async {
    try {
      final models = _instancesBox.values.toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get instances: ${e.toString()}');
    }
  }

  @override
  Future<JDownloaderInstance?> getInstanceById(String instanceId) async {
    try {
      final model = _instancesBox.get(instanceId);
      return model?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<JDownloaderInstance> addInstance({
    required String name,
    required String deviceId,
    String? host,
    int? port,
    String? username,
    String? password,
  }) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final instance = JDownloaderInstance(
        id: id,
        name: name,
        deviceId: deviceId,
        status: JDownloaderStatus.offline,
        host: host,
        port: port,
      );

      final model = JDownloaderInstanceModel.fromEntity(instance);
      await _instancesBox.put(id, model);
      _instanceController.add(instance);

      return instance;
    } catch (e) {
      throw Exception('Failed to add instance: ${e.toString()}');
    }
  }

  @override
  Future<JDownloaderInstance> updateInstance(
    JDownloaderInstance instance,
  ) async {
    try {
      if (!_instancesBox.containsKey(instance.id)) {
        throw Exception('Instance not found: ${instance.id}');
      }

      final model = JDownloaderInstanceModel.fromEntity(instance);
      await _instancesBox.put(instance.id, model);
      _instanceController.add(instance);

      return instance;
    } catch (e) {
      throw Exception('Failed to update instance: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteInstance(String instanceId) async {
    try {
      await _instancesBox.delete(instanceId);

      // Clean up speed data for this instance
      final keysToDelete = <String>[];
      for (final key in _speedDataBox.keys) {
        if (key.toString().startsWith('$instanceId-')) {
          keysToDelete.add(key.toString());
        }
      }
      await _speedDataBox.deleteAll(keysToDelete);
    } catch (e) {
      throw Exception('Failed to delete instance: ${e.toString()}');
    }
  }

  @override
  Future<JDownloaderInstance> connectInstance(String instanceId) async {
    try {
      final instance = await getInstanceById(instanceId);
      if (instance == null) {
        throw Exception('Instance not found: $instanceId');
      }

      // Send connect request to backend
      final response = await _dio.post<Map<String, dynamic>>(
        '/jdownloader/connect',
        data: {
          'instance_id': instanceId,
          'device_id': instance.deviceId,
          'host': instance.host,
          'port': instance.port,
        },
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      final updatedModel = JDownloaderInstanceModel.fromJson(response.data!);
      final updatedInstance = updatedModel.toEntity();

      await updateInstance(updatedInstance);
      return updatedInstance;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to connect instance: ${e.toString()}');
    }
  }

  @override
  Future<void> disconnectInstance(String instanceId) async {
    try {
      await _dio.post(
        '/jdownloader/disconnect',
        data: {'instance_id': instanceId},
      );

      final instance = await getInstanceById(instanceId);
      if (instance != null) {
        final disconnected = JDownloaderInstance(
          id: instance.id,
          name: instance.name,
          deviceId: instance.deviceId,
          status: JDownloaderStatus.offline,
          host: instance.host,
          port: instance.port,
        );
        await updateInstance(disconnected);
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to disconnect instance: ${e.toString()}');
    }
  }

  @override
  Future<void> pauseInstance(String instanceId) async {
    try {
      await _dio.post(
        '/jdownloader/pause',
        data: {'instance_id': instanceId},
      );

      final instance = await getInstanceById(instanceId);
      if (instance != null) {
        final paused = JDownloaderInstance(
          id: instance.id,
          name: instance.name,
          deviceId: instance.deviceId,
          status: JDownloaderStatus.paused,
          host: instance.host,
          port: instance.port,
          downloadSpeed: instance.downloadSpeed,
          uploadSpeed: instance.uploadSpeed,
          activeDownloads: instance.activeDownloads,
          totalDownloads: instance.totalDownloads,
          freeSpace: instance.freeSpace,
          totalSpace: instance.totalSpace,
          version: instance.version,
          lastConnected: instance.lastConnected,
          errorMessage: instance.errorMessage,
        );
        await updateInstance(paused);
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to pause instance: ${e.toString()}');
    }
  }

  @override
  Future<void> resumeInstance(String instanceId) async {
    try {
      await _dio.post(
        '/jdownloader/resume',
        data: {'instance_id': instanceId},
      );

      final instance = await getInstanceById(instanceId);
      if (instance != null && instance.status == JDownloaderStatus.paused) {
        final resumed = JDownloaderInstance(
          id: instance.id,
          name: instance.name,
          deviceId: instance.deviceId,
          status: JDownloaderStatus.downloading,
          host: instance.host,
          port: instance.port,
          downloadSpeed: instance.downloadSpeed,
          uploadSpeed: instance.uploadSpeed,
          activeDownloads: instance.activeDownloads,
          totalDownloads: instance.totalDownloads,
          freeSpace: instance.freeSpace,
          totalSpace: instance.totalSpace,
          version: instance.version,
          lastConnected: instance.lastConnected,
          errorMessage: instance.errorMessage,
        );
        await updateInstance(resumed);
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to resume instance: ${e.toString()}');
    }
  }

  @override
  Future<void> addDownload({
    required String instanceId,
    required String url,
    String? destinationFolder,
    String? packageName,
  }) async {
    try {
      await _dio.post(
        '/jdownloader/add-download',
        data: {
          'instance_id': instanceId,
          'url': url,
          'destination_folder': destinationFolder,
          'package_name': packageName,
        },
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add download: ${e.toString()}');
    }
  }

  @override
  Future<List<dynamic>> getDownloads(String instanceId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/jdownloader/downloads',
        queryParameters: {'instance_id': instanceId},
      );

      return response.data ?? [];
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get downloads: ${e.toString()}');
    }
  }

  @override
  Future<void> pauseDownload({
    required String instanceId,
    required String downloadId,
  }) async {
    try {
      await _dio.post(
        '/jdownloader/pause-download',
        data: {
          'instance_id': instanceId,
          'download_id': downloadId,
        },
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to pause download: ${e.toString()}');
    }
  }

  @override
  Future<void> resumeDownload({
    required String instanceId,
    required String downloadId,
  }) async {
    try {
      await _dio.post(
        '/jdownloader/resume-download',
        data: {
          'instance_id': instanceId,
          'download_id': downloadId,
        },
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to resume download: ${e.toString()}');
    }
  }

  @override
  Future<void> removeDownload({
    required String instanceId,
    required String downloadId,
  }) async {
    try {
      await _dio.delete(
        '/jdownloader/download',
        data: {
          'instance_id': instanceId,
          'download_id': downloadId,
        },
      );
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to remove download: ${e.toString()}');
    }
  }

  @override
  Future<List<SpeedDataPoint>> getSpeedHistory(
    String instanceId, {
    int limit = 100,
  }) async {
    try {
      final allSpeedData = <SpeedDataPoint>[];

      for (final key in _speedDataBox.keys) {
        if (key.toString().startsWith('$instanceId-')) {
          final model = _speedDataBox.get(key);
          if (model != null) {
            allSpeedData.add(model.toEntity());
          }
        }
      }

      // Sort by timestamp descending and limit
      allSpeedData.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allSpeedData.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> checkConnection(String instanceId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/jdownloader/check-connection',
        queryParameters: {'instance_id': instanceId},
      );

      return response.data?['connected'] as bool? ?? false;
    } on DioException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Save speed data point
  Future<void> saveSpeedData(
    String instanceId,
    SpeedDataPoint dataPoint,
  ) async {
    try {
      final model = SpeedDataPointModel.fromEntity(dataPoint);
      final key = '$instanceId-${dataPoint.timestamp.millisecondsSinceEpoch}';
      await _speedDataBox.put(key, model);
      _speedController.add(dataPoint);
    } catch (e) {
      throw Exception('Failed to save speed data: ${e.toString()}');
    }
  }

  @disposeMethod
  void dispose() {
    _instanceController.close();
    _speedController.close();
  }
}
