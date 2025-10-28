import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/qr_scan_result.dart';

void main() {
  group('QRScanResult', () {
    test('should create QRScanResult with valid properties', () {
      // Arrange
      const rawValue = 'https://youtube.com/watch?v=test123';
      const extractedUrl = 'https://youtube.com/watch?v=test123';
      final scannedAt = DateTime.now();
      const isValidUrl = true;

      // Act
      final result = QRScanResult(
        rawValue: rawValue,
        extractedUrl: extractedUrl,
        scannedAt: scannedAt,
        isValidUrl: isValidUrl,
      );

      // Assert
      expect(result.rawValue, equals(rawValue));
      expect(result.extractedUrl, equals(extractedUrl));
      expect(result.scannedAt, equals(scannedAt));
      expect(result.isValidUrl, equals(isValidUrl));
    });

    test('should create QRScanResult with null extractedUrl', () {
      // Arrange
      const rawValue = 'Some text without URL';
      final scannedAt = DateTime.now();
      const isValidUrl = false;

      // Act
      final result = QRScanResult(
        rawValue: rawValue,
        extractedUrl: null,
        scannedAt: scannedAt,
        isValidUrl: isValidUrl,
      );

      // Assert
      expect(result.rawValue, equals(rawValue));
      expect(result.extractedUrl, isNull);
      expect(result.scannedAt, equals(scannedAt));
      expect(result.isValidUrl, equals(isValidUrl));
    });

    test('should copy QRScanResult with new values', () {
      // Arrange
      final originalResult = QRScanResult(
        rawValue: 'original',
        extractedUrl: 'original_url',
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      // Act
      final copiedResult = originalResult.copyWith(
        rawValue: 'modified',
        isValidUrl: false,
      );

      // Assert
      expect(copiedResult.rawValue, equals('modified'));
      expect(copiedResult.extractedUrl, equals('original_url')); // unchanged
      expect(copiedResult.scannedAt, equals(DateTime(2023, 1, 1))); // unchanged
      expect(copiedResult.isValidUrl, equals(false));
    });

    test('should compare QRScanResult objects correctly', () {
      // Arrange
      final result1 = QRScanResult(
        rawValue: 'test',
        extractedUrl: 'test_url',
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      final result2 = QRScanResult(
        rawValue: 'test',
        extractedUrl: 'test_url',
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      final result3 = QRScanResult(
        rawValue: 'different',
        extractedUrl: 'test_url',
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      // Assert
      expect(result1, equals(result2));
      expect(result1, isNot(equals(result3)));
    });

    test('should have correct props list', () {
      // Arrange
      final result = QRScanResult(
        rawValue: 'test',
        extractedUrl: 'test_url',
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      // Act
      final props = result.props;

      // Assert
      expect(props, contains('test'));
      expect(props, contains('test_url'));
      expect(props, contains(DateTime(2023, 1, 1)));
      expect(props, contains(true));
      expect(props.length, equals(4));
    });
  });
}