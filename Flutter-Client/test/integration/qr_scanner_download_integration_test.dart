import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:grabtube/core/di/injection.dart';
import 'package:grabtube/domain/entities/qr_scan_result.dart';
import 'package:grabtube/domain/repositories/qr_scanner_repository.dart';
import 'package:grabtube/domain/repositories/download_repository.dart';
import 'package:grabtube/domain/usecases/scan_qr_code_usecase.dart';
import 'package:grabtube/presentation/blocs/download/download_bloc.dart';
import 'package:grabtube/presentation/blocs/download/download_event.dart';
import 'package:grabtube/presentation/blocs/download/download_state.dart';
import 'package:grabtube/presentation/blocs/qr_scanner/qr_scanner_bloc.dart';
import 'package:grabtube/presentation/blocs/qr_scanner/qr_scanner_event.dart';
import 'package:grabtube/presentation/blocs/qr_scanner/qr_scanner_state.dart';
import 'package:grabtube/presentation/pages/home_page.dart';
import 'package:grabtube/presentation/widgets/add_download_dialog.dart';
import 'package:grabtube/presentation/widgets/adaptive_qr_scanner.dart';

class MockQRScannerRepository extends Mock implements QRScannerRepository {}

class MockDownloadRepository extends Mock implements DownloadRepository {}

void main() {
  group('QR Scanner Download Integration Tests', () {
    late MockQRScannerRepository mockQRRepository;
    late MockDownloadRepository mockDownloadRepository;
    late QRScannerBloc qrScannerBloc;
    late DownloadBloc downloadBloc;

    setUpAll(() {
      registerFallbackValue(const AddDownloadEvent(url: 'test'));
    });

    setUp(() {
      mockQRRepository = MockQRScannerRepository();
      mockDownloadRepository = MockDownloadRepository();
      qrScannerBloc = QRScannerBloc(mockQRRepository);
      downloadBloc = DownloadBloc(mockDownloadRepository);

      // Setup dependency injection
      getIt.registerSingleton<QRScannerRepository>(mockQRRepository);
      getIt.registerSingleton<DownloadRepository>(mockDownloadRepository);
    });

    tearDown(() {
      qrScannerBloc.close();
      downloadBloc.close();
      getIt.reset();
    });

    testWidgets('should scan QR code and add download successfully', (WidgetTester tester) async {
      // Arrange
      const testUrl = 'https://youtube.com/watch?v=test123';
      const qrResult = QRScanResult(
        rawValue: testUrl,
        extractedUrl: testUrl,
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      when(() => mockQRRepository.hasCameraPermission()).thenAnswer((_) async => true);
      when(() => mockQRRepository.scanQRCode()).thenAnswer((_) async => Right(qrResult));
      when(() => mockDownloadRepository.addDownload(any(), any(), any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: qrScannerBloc),
              BlocProvider.value(value: downloadBloc),
            ],
            child: const HomePage(),
          ),
        ),
      );

      // Find and tap the QR scanner button
      final qrScannerButton = find.byKey(const Key('scanQR'));
      expect(qrScannerButton, findsOneWidget);
      await tester.tap(qrScannerButton);
      await tester.pumpAndSettle();

      // Verify QR scanner is opened
      expect(find.byType(AdaptiveQRScanner), findsOneWidget);

      // Simulate successful QR scan
      qrScannerBloc.add(const ScanQRCodeRequested());
      await tester.pumpAndSettle();

      // Verify download dialog is opened with scanned URL
      expect(find.byType(AddDownloadDialog), findsOneWidget);
      
      final urlField = find.byKey(const Key('url_field'));
      expect(urlField, findsOneWidget);
      
      final urlText = tester.widget<TextFormField>(urlField).controller?.text;
      expect(urlText, equals(testUrl));

      // Submit the download
      final addButton = find.text('Add');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockQRRepository.hasCameraPermission()).called(1);
      verify(() => mockQRRepository.scanQRCode()).called(1);
      verify(() => mockDownloadRepository.addDownload(testUrl, any(), any(), any())).called(1);
    });

    testWidgets('should handle QR scan failure gracefully', (WidgetTester tester) async {
      // Arrange
      when(() => mockQRRepository.hasCameraPermission()).thenAnswer((_) async => true);
      when(() => mockQRRepository.scanQRCode()).thenAnswer((_) async => const Left('Scanning failed'));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: qrScannerBloc),
              BlocProvider.value(value: downloadBloc),
            ],
            child: const HomePage(),
          ),
        ),
      );

      // Find and tap the QR scanner button
      final qrScannerButton = find.byKey(const Key('scanQR'));
      expect(qrScannerButton, findsOneWidget);
      await tester.tap(qrScannerButton);
      await tester.pumpAndSettle();

      // Simulate QR scan failure
      qrScannerBloc.add(const ScanQRCodeRequested());
      await tester.pumpAndSettle();

      // Verify error state is shown
      expect(find.byType(QRScannerError), findsOneWidget);
      expect(find.text('Scanning failed'), findsOneWidget);

      // Assert
      verify(() => mockQRRepository.hasCameraPermission()).called(1);
      verify(() => mockQRRepository.scanQRCode()).called(1);
      verifyNever(() => mockDownloadRepository.addDownload(any(), any(), any(), any()));
    });

    testWidgets('should request camera permission when not granted', (WidgetTester tester) async {
      // Arrange
      const testUrl = 'https://youtube.com/watch?v=test123';
      const qrResult = QRScanResult(
        rawValue: testUrl,
        extractedUrl: testUrl,
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      when(() => mockQRRepository.hasCameraPermission()).thenAnswer((_) async => false);
      when(() => mockQRRepository.requestCameraPermission()).thenAnswer((_) async => const Right(null));
      when(() => mockQRRepository.scanQRCode()).thenAnswer((_) async => Right(qrResult));
      when(() => mockDownloadRepository.addDownload(any(), any(), any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: qrScannerBloc),
              BlocProvider.value(value: downloadBloc),
            ],
            child: const HomePage(),
          ),
        ),
      );

      // Find and tap the QR scanner button
      final qrScannerButton = find.byKey(const Key('scanQR'));
      expect(qrScannerButton, findsOneWidget);
      await tester.tap(qrScannerButton);
      await tester.pumpAndSettle();

      // Simulate permission request flow
      qrScannerBloc.add(const ScanQRCodeRequested());
      await tester.pumpAndSettle();

      // Verify permission required state is shown
      expect(find.byType(QRScannerPermissionRequired), findsOneWidget);

      // Grant permission
      qrScannerBloc.add(const CameraPermissionRequested());
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockQRRepository.hasCameraPermission()).called(2);
      verify(() => mockQRRepository.requestCameraPermission()).called(1);
      verify(() => mockQRRepository.scanQRCode()).called(1);
    });

    testWidgets('should handle invalid URL from QR scan', (WidgetTester tester) async {
      // Arrange
      const invalidQrResult = QRScanResult(
        rawValue: 'This is not a URL',
        extractedUrl: null,
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: false,
      );

      when(() => mockQRRepository.hasCameraPermission()).thenAnswer((_) async => true);
      when(() => mockQRRepository.scanQRCode()).thenAnswer((_) async => Right(invalidQrResult));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: qrScannerBloc),
              BlocProvider.value(value: downloadBloc),
            ],
            child: const HomePage(),
          ),
        ),
      );

      // Find and tap the QR scanner button
      final qrScannerButton = find.byKey(const Key('scanQR'));
      expect(qrScannerButton, findsOneWidget);
      await tester.tap(qrScannerButton);
      await tester.pumpAndSettle();

      // Simulate QR scan with invalid URL
      qrScannerBloc.add(const ScanQRCodeRequested());
      await tester.pumpAndSettle();

      // Verify success state but no download dialog (since URL is invalid)
      expect(find.byType(QRScannerSuccess), findsOneWidget);
      expect(find.byType(AddDownloadDialog), findsNothing);

      // Assert
      verify(() => mockQRRepository.hasCameraPermission()).called(1);
      verify(() => mockQRRepository.scanQRCode()).called(1);
      verifyNever(() => mockDownloadRepository.addDownload(any(), any(), any(), any()));
    });

    testWidgets('should integrate QR scanning with existing download flow', (WidgetTester tester) async {
      // Arrange
      const testUrl = 'https://youtube.com/watch?v=test123';
      const qrResult = QRScanResult(
        rawValue: testUrl,
        extractedUrl: testUrl,
        scannedAt: DateTime(2023, 1, 1),
        isValidUrl: true,
      );

      when(() => mockQRRepository.hasCameraPermission()).thenAnswer((_) async => true);
      when(() => mockQRRepository.scanQRCode()).thenAnswer((_) async => Right(qrResult));
      when(() => mockDownloadRepository.addDownload(any(), any(), any(), any()))
          .thenAnswer((_) async => const Right(null));

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: qrScannerBloc),
              BlocProvider.value(value: downloadBloc),
            ],
            child: const HomePage(),
          ),
        ),
      );

      // Verify both add download and QR scanner buttons are present
      expect(find.text('Add Download'), findsOneWidget);
      expect(find.text('Scan QR'), findsOneWidget);

      // Test regular add download flow still works
      final addDownloadButton = find.text('Add Download');
      await tester.tap(addDownloadButton);
      await tester.pumpAndSettle();

      expect(find.byType(AddDownloadDialog), findsOneWidget);
      
      // Close dialog
      final cancelButton = find.text('Cancel');
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Test QR scanner flow
      final qrScannerButton = find.text('Scan QR');
      await tester.tap(qrScannerButton);
      await tester.pumpAndSettle();

      // Simulate successful QR scan
      qrScannerBloc.add(const ScanQRCodeRequested());
      await tester.pumpAndSettle();

      // Verify download dialog is opened with scanned URL
      expect(find.byType(AddDownloadDialog), findsOneWidget);
      
      final urlField = find.byKey(const Key('url_field'));
      final urlText = tester.widget<TextFormField>(urlField).controller?.text;
      expect(urlText, equals(testUrl));

      // Assert
      verify(() => mockQRRepository.hasCameraPermission()).called(1);
      verify(() => mockQRRepository.scanQRCode()).called(1);
    });
  });
}