import '../entities/jdownloader_instance.dart';
import '../entities/speed_data_point.dart';

/// Repository interface for JDownloader integration operations
abstract class JDownloaderRepository {
  /// Get all JDownloader instances
  Future<List<JDownloaderInstance>> getInstances();

  /// Get instance by ID
  Future<JDownloaderInstance?> getInstanceById(String instanceId);

  /// Add a new JDownloader instance
  Future<JDownloaderInstance> addInstance({
    required String name,
    required String deviceId,
    String? host,
    int? port,
    String? username,
    String? password,
  });

  /// Update instance details
  Future<JDownloaderInstance> updateInstance(JDownloaderInstance instance);

  /// Delete instance
  Future<void> deleteInstance(String instanceId);

  /// Connect to a JDownloader instance
  Future<JDownloaderInstance> connectInstance(String instanceId);

  /// Disconnect from a JDownloader instance
  Future<void> disconnectInstance(String instanceId);

  /// Pause downloads on an instance
  Future<void> pauseInstance(String instanceId);

  /// Resume downloads on an instance
  Future<void> resumeInstance(String instanceId);

  /// Add download to JDownloader instance
  Future<void> addDownload({
    required String instanceId,
    required String url,
    String? destinationFolder,
    String? packageName,
  });

  /// Get downloads from JDownloader instance
  Future<List<dynamic>> getDownloads(String instanceId);

  /// Pause specific download on JDownloader
  Future<void> pauseDownload({
    required String instanceId,
    required String downloadId,
  });

  /// Resume specific download on JDownloader
  Future<void> resumeDownload({
    required String instanceId,
    required String downloadId,
  });

  /// Remove download from JDownloader
  Future<void> removeDownload({
    required String instanceId,
    required String downloadId,
  });

  /// Get speed history for an instance
  Future<List<SpeedDataPoint>> getSpeedHistory(
    String instanceId, {
    int limit = 100,
  });

  /// Check instance connection status
  Future<bool> checkConnection(String instanceId);

  /// Stream of instance updates
  Stream<JDownloaderInstance> get instanceUpdates;

  /// Stream of speed data updates
  Stream<SpeedDataPoint> get speedUpdates;
}
