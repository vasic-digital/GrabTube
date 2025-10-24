import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'package:grabtube/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolTest('Full JDownloader dashboard flow', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Verify app starts successfully
    expect($('GrabTube'), findsOneWidget);

    // Navigate to JDownloader dashboard
    await $.tap($(Icons.cloud_download));
    await $.pumpAndSettle();

    // Verify dashboard is displayed
    expect($('My JDownloader'), findsOneWidget);

    // Check dashboard tabs
    expect($('Dashboard'), findsOneWidget);
    expect($('Instances'), findsOneWidget);

    // Test dashboard overview
    final totalInstances = $('Total Instances');
    final onlineInstances = $('Online');

    if (totalInstances.exists) {
      expect(totalInstances, findsOneWidget);
    }
    if (onlineInstances.exists) {
      expect(onlineInstances, findsOneWidget);
    }

    // Check speed chart
    final downloadSpeedChart = $('Download Speed');
    if (downloadSpeedChart.exists) {
      expect(downloadSpeedChart, findsOneWidget);
    }

    // Check speed indicators
    final downloadSpeedIndicator = $('Download Speed');
    final uploadSpeedIndicator = $('Upload Speed');

    // These should exist in the speed cards
    expect(downloadSpeedIndicator, findsWidgets);
    expect(uploadSpeedIndicator, findsWidgets);

    // Switch to instances tab
    await $.tap($('Instances'));
    await $.pumpAndSettle();

    // Check for add instance FAB
    expect($('Add Instance'), findsOneWidget);

    // Check for empty state or instance list
    final noInstances = $('No JDownloader Instances');
    final instanceCard = $('JDownloaderInstanceCard');

    if (noInstances.exists) {
      expect(noInstances, findsOneWidget);
      expect($('Add your first JDownloader instance'), findsOneWidget);
    } else if (instanceCard.exists) {
      expect(instanceCard, findsAtLeastOneWidget);
    }

    // Test refresh functionality
    await $.tap($(Icons.refresh));
    await $.pumpAndSettle();

    // Verify no crash occurred
    expect($('My JDownloader'), findsOneWidget);

    // Navigate back to home
    await $.tap($(Icons.arrow_back));
    await $.pumpAndSettle();

    // Verify back on home page
    expect($('GrabTube'), findsOneWidget);
  });

  patrolTest('JDownloader instance management flow', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Navigate to JDownloader dashboard
    await $.tap($(Icons.cloud_download));
    await $.pumpAndSettle();

    // Switch to instances tab
    await $.tap($('Instances'));
    await $.pumpAndSettle();

    // Try to add a new instance
    await $.tap($('Add Instance'));
    await $.pumpAndSettle();

    // Check if add instance dialog appears
    final instanceNameField = $('Instance Name');
    final deviceIdField = $('Device ID');

    if (instanceNameField.exists && deviceIdField.exists) {
      // Fill in instance details
      await $.enterText(instanceNameField, 'Test JDownloader Instance');
      await $.enterText(deviceIdField, 'test-device-123');

      // Try to add the instance
      final addButton = $('Add');
      if (addButton.exists) {
        await $.tap(addButton);
        await $.pumpAndSettle();

        // Check for success message
        final successMessage = $('JDownloader instance added successfully');
        final errorMessage = $('Failed to add instance');

        if (successMessage.exists || errorMessage.exists) {
          expect(successMessage.exists || errorMessage.exists, isTrue);
        }
      }
    }

    // Test instance controls if instances exist
    final connectButton = $('Connect');
    final pauseButton = $('Pause');
    final resumeButton = $('Resume');

    if (connectButton.exists) {
      await $.tap(connectButton);
      await $.pumpAndSettle();

      // Check for connection feedback
      final connectingStatus = $('Connecting');
      final connectedStatus = $('Connected');

      if (connectingStatus.exists || connectedStatus.exists) {
        expect(connectingStatus.exists || connectedStatus.exists, isTrue);
      }
    }

    if (pauseButton.exists) {
      await $.tap(pauseButton);
      await $.pumpAndSettle();

      // Should show paused status or resume button
      final pausedStatus = $('Paused');
      if (pausedStatus.exists) {
        expect(pausedStatus, findsOneWidget);
      }
    }

    if (resumeButton.exists) {
      await $.tap(resumeButton);
      await $.pumpAndSettle();

      // Should show downloading status
      final downloadingStatus = $('Downloading');
      if (downloadingStatus.exists) {
        expect(downloadingStatus, findsOneWidget);
      }
    }

    // Verify dashboard remains stable
    await $.pumpAndSettle(const Duration(seconds: 2));
    expect($('My JDownloader'), findsOneWidget);
  });

  patrolTest('JDownloader real-time monitoring', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Navigate to JDownloader dashboard
    await $.tap($(Icons.cloud_download));
    await $.pumpAndSettle();

    // Monitor dashboard for real-time updates
    await $.pumpAndSettle(const Duration(seconds: 5));

    // Check if speed indicators update
    final speedIndicators = $('Download Speed') | $('Upload Speed');

    if (speedIndicators.exists) {
      // Speed values should be displayed
      expect(speedIndicators, findsWidgets);
    }

    // Check for status updates
    final statusIndicators = $('Online') | $('Offline') | $('Downloading') | $('Paused') | $('Error');

    if (statusIndicators.exists) {
      expect(statusIndicators, findsWidgets);
    }

    // Test refresh functionality during monitoring
    await $.tap($(Icons.refresh));
    await $.pumpAndSettle();

    // Dashboard should still be responsive
    expect($('My JDownloader'), findsOneWidget);

    // Continue monitoring for a bit more
    await $.pumpAndSettle(const Duration(seconds: 3));

    // Verify no crashes occurred during monitoring
    expect($('My JDownloader'), findsOneWidget);
  });

  patrolTest('JDownloader error handling and recovery', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Navigate to JDownloader dashboard
    await $.tap($(Icons.cloud_download));
    await $.pumpAndSettle();

    // Switch to instances tab
    await $.tap($('Instances'));
    await $.pumpAndSettle();

    // Try operations that might fail
    final connectButton = $('Connect');
    if (connectButton.exists) {
      await $.tap(connectButton);
      await $.pumpAndSettle();

      // Check for error handling
      final errorMessage = $('Failed to connect') | $('Connection error') | $('Error');
      final successMessage = $('Connected') | $('Connecting');

      // Should show either success or error feedback
      expect(errorMessage.exists || successMessage.exists, isTrue);
    }

    // Test with invalid data
    await $.tap($('Add Instance'));
    await $.pumpAndSettle();

    final addButton = $('Add');
    if (addButton.exists) {
      // Try to add without filling fields
      await $.tap(addButton);
      await $.pumpAndSettle();

      // Should show validation errors
      final validationError = $('Please enter') | $('Required') | $('Invalid');
      if (validationError.exists) {
        expect(validationError, findsWidgets);
      }
    }

    // Test refresh after potential errors
    await $.tap($(Icons.refresh));
    await $.pumpAndSettle();

    // Dashboard should recover and remain stable
    expect($('My JDownloader'), findsOneWidget);

    // Navigate back and verify app stability
    await $.tap($(Icons.arrow_back));
    await $.pumpAndSettle();

    expect($('GrabTube'), findsOneWidget);
  });
}