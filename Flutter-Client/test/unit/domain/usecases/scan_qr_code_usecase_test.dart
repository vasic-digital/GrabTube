import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:grabtube/domain/entities/qr_scan_result.dart';
import 'package:grabtube/domain/repositories/qr_scanner_repository.dart';
import 'package:grabtube/domain/usecases/scan_qr_code_usecase.dart';

class MockQRScannerRepository extends Mock implements QRScannerRepository {}

void main() {
  group('ScanQRCodeUseCase', () {
    late ScanQRCodeUseCase useCase;
    late MockQRScannerRepository mockRepository;

    setUp(() {
      mockRepository = MockQRScannerRepository();
      useCase = ScanQRCodeUseCase(mockRepository);
    });

    test('should return QR scan result when permission is granted', () async {
      // Arrange
      when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => true);
      when(() => mockRepository.scanQRCode()).thenAnswer(
        (_) async => Right(
          QRScanResult(
            rawValue: 'https://youtube.com/watch?v=test',
            extractedUrl: 'https://youtube.com/watch?v=test',
            scannedAt: DateTime(2023, 1, 1),
            isValidUrl: true,
          ),
        ),
      );

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Right<String, QRScanResult>>());
      result.fold(
        (error) => fail('Expected success but got error: $error'),
        (scanResult) {
          expect(scanResult.rawValue, equals('https://youtube.com/watch?v=test'));
          expect(scanResult.extractedUrl, equals('https://youtube.com/watch?v=test'));
          expect(scanResult.isValidUrl, equals(true));
        },
      );
      verify(() => mockRepository.hasCameraPermission()).called(1);
      verify(() => mockRepository.scanQRCode()).called(1);
      verifyNever(() => mockRepository.requestCameraPermission());
    });

    test('should request permission and scan when permission is not granted', () async {
      // Arrange
      when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => false);
      when(() => mockRepository.requestCameraPermission()).thenAnswer((_) async => const Right(null));
      when(() => mockRepository.scanQRCode()).thenAnswer(
        (_) async => Right(
          QRScanResult(
            rawValue: 'https://example.com/video',
            extractedUrl: 'https://example.com/video',
            scannedAt: DateTime(2023, 1, 1),
            isValidUrl: true,
          ),
        ),
      );

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Right<String, QRScanResult>>());
      result.fold(
        (error) => fail('Expected success but got error: $error'),
        (scanResult) {
          expect(scanResult.rawValue, equals('https://example.com/video'));
          expect(scanResult.extractedUrl, equals('https://example.com/video'));
          expect(scanResult.isValidUrl, equals(true));
        },
      );
      verify(() => mockRepository.hasCameraPermission()).called(1);
      verify(() => mockRepository.requestCameraPermission()).called(1);
      verify(() => mockRepository.scanQRCode()).called(1);
    });

    test('should return error when permission request fails', () async {
      // Arrange
      when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => false);
      when(() => mockRepository.requestCameraPermission()).thenAnswer((_) async => Left('Permission denied'));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Left<String, QRScanResult>>());
      result.fold(
        (error) => expect(error, equals('Permission denied')),
        (_) => fail('Expected error but got success'),
      );
      verify(() => mockRepository.hasCameraPermission()).called(1);
      verify(() => mockRepository.requestCameraPermission()).called(1);
      verifyNever(() => mockRepository.scanQRCode());
    });

    test('should return error when scanning fails', () async {
      // Arrange
      when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => true);
      when(() => mockRepository.scanQRCode()).thenAnswer((_) async => Left('Scanning failed'));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Left<String, QRScanResult>>());
      result.fold(
        (error) => expect(error, equals('Scanning failed')),
        (_) => fail('Expected error but got success'),
      );
      verify(() => mockRepository.hasCameraPermission()).called(1);
      verify(() => mockRepository.scanQRCode()).called(1);
      verifyNever(() => mockRepository.requestCameraPermission());
    });

    test('should return error when permission request returns null', () async {
      // Arrange
      when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => false);
      when(() => mockRepository.requestCameraPermission()).thenAnswer((_) async => Left('Permission denied'));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Left<String, QRScanResult>>());
      result.fold(
        (error) => expect(error, equals('Permission denied')),
        (_) => fail('Expected error but got success'),
      );
      verify(() => mockRepository.hasCameraPermission()).called(1);
      verify(() => mockRepository.requestCameraPermission()).called(1);
      verifyNever(() => mockRepository.scanQRCode());
    });
  });
}