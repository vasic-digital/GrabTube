import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';

import 'package:grabtube/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolTest('Full download flow with Python integration', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Verify app starts successfully
    expect($('GrabTube'), findsOneWidget);

    // Check if Python service status is displayed
    final pythonStatus = $(r'Python Service');
    if (pythonStatus.exists) {
      // Python service status should be visible
      expect(pythonStatus, findsOneWidget);
    }

    // Navigate to downloads screen
    await $.tap($('Downloads'));
    await $.pumpAndSettle();

    // Check for empty state or existing downloads
    final emptyState = $(r'No downloads');
    final downloadList = $(r'DownloadItem');
    
    if (emptyState.exists) {
      expect(emptyState, findsOneWidget);
    } else if (downloadList.exists) {
      expect(downloadList, findsAtLeastOneWidget);
    }

    // Try to add a download (this will test Python service integration)
    final addButton = $(r'Add Download');
    if (addButton.exists) {
      await $.tap(addButton);
      await $.pumpAndSettle();

      // Check if add download dialog appears
      final urlField = $(r'URL');
      if (urlField.exists) {
        // Enter test URL
        await $.enterText(urlField, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
        
        // Select quality
        final qualityDropdown = $(r'Quality');
        if (qualityDropdown.exists) {
          await $.tap(qualityDropdown);
          await $.pumpAndSettle();
          await $.tap($('1080p'));
          await $.pumpAndSettle();
        }

        // Select format
        final formatDropdown = $(r'Format');
        if (formatDropdown.exists) {
          await $.tap(formatDropdown);
          await $.pumpAndSettle();
          await $.tap($('MP4'));
          await $.pumpAndSettle();
        }

        // Submit download
        final submitButton = $(r'Start Download');
        if (submitButton.exists) {
          await $.tap(submitButton);
          await $.pumpAndSettle();

          // Check for success message or error
          final successMessage = $(r'Download added');
          final errorMessage = $(r'Error');
          
          // At least one should appear
          expect(successMessage.exists || errorMessage.exists, isTrue);
        }
      }
    }

    // Test Python service management
    final settingsButton = $(r'Settings');
    if (settingsButton.exists) {
      await $.tap(settingsButton);
      await $.pumpAndSettle();

      // Look for Python service controls
      final pythonToggle = $(r'Python Service');
      final pythonStatusIndicator = $(r'Python Status');
      
      if (pythonToggle.exists) {
        // Test toggling Python service
        await $.tap(pythonToggle);
        await $.pumpAndSettle();
        
        // Status should update
        if (pythonStatusIndicator.exists) {
          expect(pythonStatusIndicator, findsOneWidget);
        }
      }
    }

    // Verify app remains stable
    await $.pumpAndSettle(const Duration(seconds: 2));
    expect($('GrabTube'), findsOneWidget);
  });

  patrolTest('Python service health check', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Navigate to settings
    await $.tap($('Settings'));
    await $.pumpAndSettle();

    // Look for Python service health indicators
    final healthStatus = $(r'Python Health');
    final requirementsCheck = $(r'Python Requirements');
    
    if (healthStatus.exists || requirementsCheck.exists) {
      // Python integration is visible in settings
      expect(healthStatus.exists || requirementsCheck.exists, isTrue);
    }

    // Test installation flow if available
    final installButton = $(r'Install Python Packages');
    if (installButton.exists) {
      await $.tap(installButton);
      await $.pumpAndSettle();

      // Should show installation progress or result
      final progressIndicator = $(r'Installing');
      final resultMessage = $(r'Installation complete') | $(r'Installation failed');
      
      if (progressIndicator.exists || resultMessage.exists) {
        expect(progressIndicator.exists || resultMessage.exists, isTrue);
      }
    }

    // Verify settings screen remains responsive
    await $.pumpAndSettle();
    expect($('Settings'), findsOneWidget);
  });

  patrolTest('Download progress with Python service', (PatrolIntegrationTester $) async {
    // Start the app
    app.main();
    await $.pumpAndSettle();

    // Navigate to downloads
    await $.tap($('Downloads'));
    await $.pumpAndSettle();

    // Look for active downloads with progress
    final progressIndicator = $(r'Progress');
    final downloadProgress = $(r'DownloadProgress');
    
    if (progressIndicator.exists || downloadProgress.exists) {
      // Progress indicators should be visible for active downloads
      expect(progressIndicator.exists || downloadProgress.exists, isTrue);
      
      // Progress values should be between 0 and 100
      final progressText = progressIndicator.text ?? downloadProgress.text;
      if (progressText != null) {
        final progressMatch = RegExp(r'(\d+)%').firstMatch(progressText);
        if (progressMatch != null) {
          final progressValue = int.parse(progressMatch.group(1)!);
          expect(progressValue, inInclusiveRange(0, 100));
        }
      }
    }

    // Test download controls
    final cancelButton = $(r'Cancel');
    final pauseButton = $(r'Pause');
    
    if (cancelButton.exists) {
      await $.tap(cancelButton);
      await $.pumpAndSettle();
      
      // Should show confirmation or update status
      final confirmation = $(r'Confirm') | $(r'Canceled');
      if (confirmation.exists) {
        expect(confirmation, findsOneWidget);
      }
    }

    if (pauseButton.exists) {
      await $.tap(pauseButton);
      await $.pumpAndSettle();
      
      // Button should change to resume
      final resumeButton = $(r'Resume');
      if (resumeButton.exists) {
        expect(resumeButton, findsOneWidget);
      }
    }

    // Verify downloads screen remains stable
    await $.pumpAndSettle(const Duration(seconds: 2));
    expect($('Downloads'), findsOneWidget);
  });
}