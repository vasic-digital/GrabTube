import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/jdownloader_instance.dart';

void main() {
  group('JDownloaderInstance Entity Tests', () {
    test('should create JDownloaderInstance with all fields', () {
      final instance = JDownloaderInstance(
        id: '1',
        name: 'My JDownloader',
        deviceId: 'device123',
        status: JDownloaderStatus.online,
        host: '192.168.1.100',
        port: 3129,
        downloadSpeed: 2048000, // 2 MB/s
        uploadSpeed: 102400, // 100 KB/s
        activeDownloads: 3,
        totalDownloads: 10,
        freeSpace: 1073741824, // 1 GB
        totalSpace: 2147483648, // 2 GB
        version: '2.0.1',
      );

      expect(instance.id, '1');
      expect(instance.name, 'My JDownloader');
      expect(instance.deviceId, 'device123');
      expect(instance.status, JDownloaderStatus.online);
      expect(instance.host, '192.168.1.100');
      expect(instance.port, 3129);
      expect(instance.downloadSpeed, 2048000);
      expect(instance.uploadSpeed, 102400);
      expect(instance.activeDownloads, 3);
      expect(instance.totalDownloads, 10);
      expect(instance.freeSpace, 1073741824);
      expect(instance.totalSpace, 2147483648);
      expect(instance.version, '2.0.1');
    });

    test('should return correct status checks', () {
      final online = JDownloaderInstance(
        id: '1',
        name: 'test',
        deviceId: 'device1',
        status: JDownloaderStatus.online,
      );

      expect(online.isOnline, true);
      expect(online.isDownloading, false);
      expect(online.hasError, false);
      expect(online.isPaused, false);

      final downloading = JDownloaderInstance(
        id: '2',
        name: 'test',
        deviceId: 'device2',
        status: JDownloaderStatus.downloading,
      );

      expect(downloading.isOnline, true);
      expect(downloading.isDownloading, true);
      expect(downloading.hasError, false);

      final paused = JDownloaderInstance(
        id: '3',
        name: 'test',
        deviceId: 'device3',
        status: JDownloaderStatus.paused,
      );

      expect(paused.isOnline, true);
      expect(paused.isPaused, true);

      final error = JDownloaderInstance(
        id: '4',
        name: 'test',
        deviceId: 'device4',
        status: JDownloaderStatus.error,
      );

      expect(error.isOnline, false);
      expect(error.hasError, true);

      final offline = JDownloaderInstance(
        id: '5',
        name: 'test',
        deviceId: 'device5',
        status: JDownloaderStatus.offline,
      );

      expect(offline.isOnline, false);
    });

    test('should format speeds correctly', () {
      final instance = JDownloaderInstance(
        id: '1',
        name: 'test',
        deviceId: 'device1',
        status: JDownloaderStatus.online,
        downloadSpeed: 1536000, // 1.5 MB/s
        uploadSpeed: 51200, // 50 KB/s
      );

      expect(instance.downloadSpeedFormatted, '1.5 MB/s');
      expect(instance.uploadSpeedFormatted, '50.0 KB/s');
    });

    test('should format storage correctly', () {
      final instance = JDownloaderInstance(
        id: '1',
        name: 'test',
        deviceId: 'device1',
        status: JDownloaderStatus.online,
        freeSpace: 536870912, // 512 MB
        totalSpace: 1073741824, // 1 GB
      );

      expect(instance.freeSpaceFormatted, '512.0 MB');
      expect(instance.totalSpaceFormatted, '1.0 GB');
      expect(instance.usedSpacePercentage, 50.0);
    });

    test('should create copy with updated fields', () {
      final original = JDownloaderInstance(
        id: '1',
        name: 'Original',
        deviceId: 'device1',
        status: JDownloaderStatus.offline,
        downloadSpeed: 0,
      );

      final updated = original.copyWith(
        name: 'Updated',
        status: JDownloaderStatus.online,
        downloadSpeed: 1024000,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Updated');
      expect(updated.status, JDownloaderStatus.online);
      expect(updated.downloadSpeed, 1024000);
      expect(updated.deviceId, original.deviceId); // Unchanged
    });

    test('should support equatable comparison', () {
      final instance1 = JDownloaderInstance(
        id: '1',
        name: 'test',
        deviceId: 'device1',
        status: JDownloaderStatus.online,
        downloadSpeed: 1024000,
      );

      final instance2 = JDownloaderInstance(
        id: '1',
        name: 'test',
        deviceId: 'device1',
        status: JDownloaderStatus.online,
        downloadSpeed: 1024000,
      );

      final instance3 = JDownloaderInstance(
        id: '1',
        name: 'test',
        deviceId: 'device1',
        status: JDownloaderStatus.online,
        downloadSpeed: 2048000, // Different speed
      );

      expect(instance1, equals(instance2));
      expect(instance1, isNot(equals(instance3)));
    });

    test('should handle null values gracefully', () {
      final instance = JDownloaderInstance(
        id: '1',
        name: 'test',
        deviceId: 'device1',
        status: JDownloaderStatus.online,
      );

      expect(instance.downloadSpeedFormatted, '0 B/s');
      expect(instance.uploadSpeedFormatted, '0 B/s');
      expect(instance.freeSpaceFormatted, 'Unknown');
      expect(instance.totalSpaceFormatted, 'Unknown');
      expect(instance.usedSpacePercentage, 0.0);
    });
  });
}