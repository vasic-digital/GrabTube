import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:grabtube/domain/entities/qr_scan_result.dart';
import 'package:grabtube/domain/repositories/qr_scanner_repository.dart';
import 'package:grabtube/presentation/blocs/qr_scanner/qr_scanner_bloc.dart';
import 'package:grabtube/presentation/blocs/qr_scanner/qr_scanner_event.dart';
import 'package:grabtube/presentation/blocs/qr_scanner/qr_scanner_state.dart';

class MockQRScannerRepository extends Mock implements QRScannerRepository {}

void main() {
  group('QRScannerBloc', () {
    late QRScannerBloc bloc;
    late MockQRScannerRepository mockRepository;

    setUp(() {
      mockRepository = MockQRScannerRepository();
      bloc = QRScannerBloc(mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be QRScannerInitial', () {
      expect(bloc.state, equals(QRScannerInitial()));
    });

    group('ScanQRCodeRequested', () {
      test('should emit loading and success when permission is granted and scan succeeds', () async {
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

        // Assert later
        final expectedStates = [
          QRScannerLoading(),
          QRScannerScanning(),
          QRScannerSuccess(
            const QRScanResult(
              rawValue: 'https://youtube.com/watch?v=test',
              extractedUrl: 'https://youtube.com/watch?v=test',
              scannedAt: DateTime(2023, 1, 1),
              isValidUrl: true,
            ),
          ),
        ];

        // Act
        bloc.add(const ScanQRCodeRequested());

        // Assert
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
        verify(() => mockRepository.hasCameraPermission()).called(1);
        verify(() => mockRepository.scanQRCode()).called(1);
        verifyNever(() => mockRepository.requestCameraPermission());
      });

      test('should emit permission required when permission is not granted', () async {
        // Arrange
        when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => false);

        // Assert later
        final expectedStates = [
          QRScannerLoading(),
          QRScannerPermissionRequired(),
        ];

        // Act
        bloc.add(const ScanQRCodeRequested());

        // Assert
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
        verify(() => mockRepository.hasCameraPermission()).called(1);
        verifyNever(() => mockRepository.scanQRCode());
        verifyNever(() => mockRepository.requestCameraPermission());
      });

      test('should emit error when scanning fails', () async {
        // Arrange
        when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => true);
        when(() => mockRepository.scanQRCode()).thenAnswer((_) async => const Left('Scanning failed'));

        // Assert later
        final expectedStates = [
          QRScannerLoading(),
          QRScannerScanning(),
          const QRScannerError('Scanning failed'),
        ];

        // Act
        bloc.add(const ScanQRCodeRequested());

        // Assert
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
        verify(() => mockRepository.hasCameraPermission()).called(1);
        verify(() => mockRepository.scanQRCode()).called(1);
        verifyNever(() => mockRepository.requestCameraPermission());
      });
    });

    group('CameraPermissionRequested', () {
      test('should emit loading and success when permission is granted', () async {
        // Arrange
        when(() => mockRepository.requestCameraPermission()).thenAnswer((_) async => const Right(null));
        when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => true);
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

        // Assert later
        final expectedStates = [
          QRScannerLoading(),
          QRScannerScanning(),
          QRScannerSuccess(
            const QRScanResult(
              rawValue: 'https://example.com/video',
              extractedUrl: 'https://example.com/video',
              scannedAt: DateTime(2023, 1, 1),
              isValidUrl: true,
            ),
          ),
        ];

        // Act
        bloc.add(const CameraPermissionRequested());

        // Assert
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
        verify(() => mockRepository.requestCameraPermission()).called(1);
        verify(() => mockRepository.hasCameraPermission()).called(1);
        verify(() => mockRepository.scanQRCode()).called(1);
      });

      test('should emit error when permission request fails', () async {
        // Arrange
        when(() => mockRepository.requestCameraPermission()).thenAnswer((_) async => const Left('Permission denied'));

        // Assert later
        final expectedStates = [
          QRScannerLoading(),
          const QRScannerError('Permission denied'),
        ];

        // Act
        bloc.add(const CameraPermissionRequested());

        // Assert
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
        verify(() => mockRepository.requestCameraPermission()).called(1);
        verifyNever(() => mockRepository.hasCameraPermission());
        verifyNever(() => mockRepository.scanQRCode());
      });
    });

    group('QRScannerReset', () {
      test('should emit QRScannerInitial', () async {
        // Arrange
        when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => false);

        // First, get to a different state
        bloc.add(const ScanQRCodeRequested());
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert later
        final expectedStates = [
          QRScannerInitial(),
        ];

        // Act
        bloc.add(const QRScannerReset());

        // Assert
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
      });
    });

    group('multiple events', () {
      test('should handle multiple scan requests correctly', () async {
        // Arrange
        when(() => mockRepository.hasCameraPermission()).thenAnswer((_) async => true);
        when(() => mockRepository.scanQRCode()).thenAnswer(
          (_) async => Right(
            const QRScanResult(
              rawValue: 'https://test.com/video1',
              extractedUrl: 'https://test.com/video1',
              scannedAt: DateTime(2023, 1, 1),
              isValidUrl: true,
            ),
          ),
        );

        // Act
        bloc.add(const ScanQRCodeRequested());
        bloc.add(const ScanQRCodeRequested());

        // Assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            QRScannerLoading(),
            QRScannerScanning(),
            QRScannerSuccess(
              const QRScanResult(
                rawValue: 'https://test.com/video1',
                extractedUrl: 'https://test.com/video1',
                scannedAt: DateTime(2023, 1, 1),
                isValidUrl: true,
              ),
            ),
            QRScannerLoading(),
            QRScannerScanning(),
            QRScannerSuccess(
              const QRScanResult(
                rawValue: 'https://test.com/video1',
                extractedUrl: 'https://test.com/video1',
                scannedAt: DateTime(2023, 1, 1),
                isValidUrl: true,
              ),
            ),
          ]),
        );
      });
    });
  });
}