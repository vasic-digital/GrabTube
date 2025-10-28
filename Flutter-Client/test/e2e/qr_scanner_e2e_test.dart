import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:grabtube/main.dart' as app;

void main() {
  patrolTest(
    'should complete full QR scanning and download flow',
    (PatrolIntegrationTester $) async {
      // Start the app
      await $.pumpWidgetAndSettle(const app.GrabTubeApp());

      // Verify we're on the home page
      expect($('GrabTube'), findsOneWidget);
      expect($('Add Download'), findsOneWidget);
      expect($('Scan QR'), findsOneWidget);

      // Tap on QR scanner button
      await $('Scan QR').tap();
      await $.pumpAndSettle();

      // Verify QR scanner screen is opened
      expect($('Scan QR Code'), findsOneWidget);
      expect($('Align QR code within the frame'), findsOneWidget);

      // Simulate QR code scanning (in real test, this would involve camera interaction)
      // For E2E testing, we'll simulate the successful scan result
      await $.tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/mobile_scanner',
        StringCodec().encodeMessage('{"type":"barcode","value":{"rawValue":"https://youtube.com/watch?v=test123"}}'),
        (data) {},
      );

      await $.pumpAndSettle();

      // Verify download dialog is opened with scanned URL
      expect($('Add Download'), findsOneWidget);
      expect($('Video URL'), findsOneWidget);
      
      // Verify the URL field contains the scanned URL
      final urlField = $.tester.widget<TextFormField>(
        find.byKey(const Key('url_field')),
      );
      expect(urlField.controller?.text, contains('youtube.com/watch?v=test123'));

      // Select quality and format
      await $('Quality').tap();
      await $('1080p').tap();
      await $.pumpAndSettle();

      await $('Format').tap();
      await $('MP4').tap();
      await $.pumpAndSettle();

      // Enable auto-start
      await $('Auto-start download').tap();
      await $.pumpAndSettle();

      // Submit the download
      await $('Add').tap();
      await $.pumpAndSettle();

      // Verify we're back to home page and download was added
      expect($('GrabTube'), findsOneWidget);
      expect($('Download added successfully'), findsOneWidget);

      // Verify the download appears in the queue
      await $('Queue').tap();
      await $.pumpAndSettle();
      
      expect($('youtube.com/watch?v=test123'), findsOneWidget);
    },
  );

  patrolTest(
    'should handle QR scanning permission flow',
    (PatrolIntegrationTester $) async {
      // Start the app
      await $.pumpWidgetAndSettle(const app.GrabTubeApp());

      // Tap on QR scanner button
      await $('Scan QR').tap();
      await $.pumpAndSettle();

      // Simulate camera permission denied
      await $.tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/permission_handler',
        StringCodec().encodeMessage('{"permission":"camera","status":"denied"}'),
        (data) {},
      );

      await $.pumpAndSettle();

      // Verify permission required screen is shown
      expect($('Camera Permission Required'), findsOneWidget);
      expect($('Please grant camera permission to scan QR codes'), findsOneWidget);
      expect($('Grant Permission'), findsOneWidget);

      // Grant permission
      await $('Grant Permission').tap();
      await $.pumpAndSettle();

      // Verify scanner is ready
      expect($('Scan QR Code'), findsOneWidget);
    },
  );

  patrolTest(
    'should handle invalid QR code gracefully',
    (PatrolIntegrationTester $) async {
      // Start the app
      await $.pumpWidgetAndSettle(const app.GrabTubeApp());

      // Tap on QR scanner button
      await $('Scan QR').tap();
      await $.pumpAndSettle();

      // Simulate invalid QR code scan
      await $.tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/mobile_scanner',
        StringCodec().encodeMessage('{"type":"barcode","value":{"rawValue":"This is not a URL"}}'),
        (data) {},
      );

      await $.pumpAndSettle();

      // Verify error message is shown
      expect($('Error'), findsOneWidget);
      expect($('No valid URL found in QR code'), findsOneWidget);
      expect($('Retry'), findsOneWidget);

      // Go back to home page
      await $.tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        StringCodec().encodeMessage('{"method":"pop"}'),
        (data) {},
      );

      await $.pumpAndSettle();

      // Verify we're back on home page
      expect($('GrabTube'), findsOneWidget);
    },
  );

  patrolTest(
    'should integrate QR scanning with existing features',
    (PatrolIntegrationTester $) async {
      // Start the app
      await $.pumpWidgetAndSettle(const app.GrabTubeApp());

      // Test that regular add download still works
      await $('Add Download').tap();
      await $.pumpAndSettle();

      await $('Video URL').enterText('https://example.com/video');
      await $('Add').tap();
      await $.pumpAndSettle();

      expect($('Download added successfully'), findsOneWidget);

      // Now test QR scanning
      await $('Scan QR').tap();
      await $.pumpAndSettle();

      // Simulate QR scan
      await $.tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/mobile_scanner',
        StringCodec().encodeMessage('{"type":"barcode","value":{"rawValue":"https://youtube.com/watch?v=qrtest"}}'),
        (data) {},
      );

      await $.pumpAndSettle();

      // Verify QR scanned URL is in dialog
      final urlField = $.tester.widget<TextFormField>(
        find.byKey(const Key('url_field')),
      );
      expect(urlField.controller?.text, contains('youtube.com/watch?v=qrtest'));

      // Cancel this dialog
      await $('Cancel').tap();
      await $.pumpAndSettle();

      // Verify both downloads are in the queue
      await $('Queue').tap();
      await $.pumpAndSettle();
      
      expect($('example.com/video'), findsOneWidget);
      expect($('youtube.com/watch?v=qrtest'), findsOneWidget);
    },
  );

  patrolTest(
    'should handle QR scanner on web platform',
    (PatrolIntegrationTester $) async {
      // Simulate web platform
      await $.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/platform'),
        (call) async {
          if (call.method == 'defaultTargetPlatform') {
            return 'web';
          }
          return null;
        },
      );

      // Start the app
      await $.pumpWidgetAndSettle(const app.GrabTubeApp());

      // Tap on QR scanner button
      await $('Scan QR').tap();
      await $.pumpAndSettle();

      // Verify web-specific QR scanner is shown
      expect($('Scan QR Code'), findsOneWidget);
      expect($('Camera View'), findsOneWidget);
      expect($('Position QR code in front of camera and tap Scan'), findsOneWidget);
      expect($('Scan'), findsOneWidget);

      // Test web QR scanning flow
      await $('Scan').tap();
      await $.pumpAndSettle();

      // Simulate successful web QR scan
      await $.tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'js',
        StringCodec().encodeMessage('"https://web-example.com/video"'),
        (data) {},
      );

      await $.pumpAndSettle();

      // Verify download dialog is opened
      expect($('Add Download'), findsOneWidget);
      
      final urlField = $.tester.widget<TextFormField>(
        find.byKey(const Key('url_field')),
      );
      expect(urlField.controller?.text, contains('web-example.com/video'));
    },
  );
}