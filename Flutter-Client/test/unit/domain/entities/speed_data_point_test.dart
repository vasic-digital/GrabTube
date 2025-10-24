import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/speed_data_point.dart';

void main() {
  group('SpeedDataPoint Entity Tests', () {
    test('should create SpeedDataPoint with all fields', () {
      final timestamp = DateTime.now();
      final dataPoint = SpeedDataPoint(
        timestamp: timestamp,
        downloadSpeed: 2048000, // 2 MB/s
        uploadSpeed: 102400, // 100 KB/s
      );

      expect(dataPoint.timestamp, timestamp);
      expect(dataPoint.downloadSpeed, 2048000);
      expect(dataPoint.uploadSpeed, 102400);
    });

    test('should create from JSON correctly', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final json = {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'downloadSpeed': 1536000.0,
        'uploadSpeed': 768000.0,
      };

      final dataPoint = SpeedDataPoint.fromJson(json);

      expect(dataPoint.timestamp, timestamp);
      expect(dataPoint.downloadSpeed, 1536000.0);
      expect(dataPoint.uploadSpeed, 768000.0);
    });

    test('should convert to JSON correctly', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final dataPoint = SpeedDataPoint(
        timestamp: timestamp,
        downloadSpeed: 1024000.0,
        uploadSpeed: 512000.0,
      );

      final json = dataPoint.toJson();

      expect(json['timestamp'], timestamp.millisecondsSinceEpoch);
      expect(json['downloadSpeed'], 1024000.0);
      expect(json['uploadSpeed'], 512000.0);
    });

    test('should handle null values in JSON', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final json = {
        'timestamp': timestamp.millisecondsSinceEpoch,
        'downloadSpeed': null,
        'uploadSpeed': null,
      };

      final dataPoint = SpeedDataPoint.fromJson(json);

      expect(dataPoint.timestamp, timestamp);
      expect(dataPoint.downloadSpeed, 0.0);
      expect(dataPoint.uploadSpeed, 0.0);
    });

    test('should support equatable comparison', () {
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final dataPoint1 = SpeedDataPoint(
        timestamp: timestamp,
        downloadSpeed: 1024000,
        uploadSpeed: 512000,
      );

      final dataPoint2 = SpeedDataPoint(
        timestamp: timestamp,
        downloadSpeed: 1024000,
        uploadSpeed: 512000,
      );

      final dataPoint3 = SpeedDataPoint(
        timestamp: timestamp,
        downloadSpeed: 2048000, // Different speed
        uploadSpeed: 512000,
      );

      expect(dataPoint1, equals(dataPoint2));
      expect(dataPoint1, isNot(equals(dataPoint3)));
    });
  });
}