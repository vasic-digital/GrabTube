import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:grabtube/main.dart' as app;

void main() {
  patrolTest(
    'complete download flow E2E test',
    ($) async {
      // Launch the app
      await app.main();
      await $.pumpAndSettle();

      // Verify app launched successfully
      expect($('GrabTube'), findsOneWidget);

      // Test 1: Navigate through tabs
      await $('Completed').tap();
      await $.pumpAndSettle();
      expect($('Completed downloads will appear here'), findsOneWidget);

      await $('Pending').tap();
      await $.pumpAndSettle();
      expect($('Pending downloads will appear here'), findsOneWidget);

      await $('Queue').tap();
      await $.pumpAndSettle();

      // Test 2: Open add download dialog
      await $(FloatingActionButton).tap();
      await $.pumpAndSettle();

      expect($('Add Download'), findsOneWidget);

      // Test 3: Validate URL field
      await $('Add').tap();
      await $.pumpAndSettle();

      expect($('Please enter a URL'), findsOneWidget);

      // Test 4: Enter valid URL and configuration
      await $(TextField).enterText('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
      await $.pumpAndSettle();

      // Select quality
      await $(DropdownButtonFormField<String>).at(0).tap();
      await $.pumpAndSettle();
      await $('1080').tap();
      await $.pumpAndSettle();

      // Select format
      await $(DropdownButtonFormField<String>).at(1).tap();
      await $.pumpAndSettle();
      await $('MP4').tap();
      await $.pumpAndSettle();

      // Toggle auto-start
      await $(SwitchListTile).tap();
      await $.pumpAndSettle();

      // Cancel and verify dialog closed
      await $('Cancel').tap();
      await $.pumpAndSettle();

      expect($('Add Download'), findsNothing);

      // Test 5: Test refresh functionality
      await $(Icons.refresh).tap();
      await $.pumpAndSettle();

      // Test 6: Verify stats are displayed
      expect($('Active'), findsOneWidget);
      expect($('Pending'), findsWidgets);
      expect($('Completed'), findsWidgets);
    },
  );

  patrolTest(
    'UI responsiveness test',
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // Test rapid tab switching
      for (int i = 0; i < 5; i++) {
        await $('Completed').tap();
        await $.pump(const Duration(milliseconds: 100));
        await $('Queue').tap();
        await $.pump(const Duration(milliseconds: 100));
      }

      await $.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Test rapid dialog open/close
      for (int i = 0; i < 3; i++) {
        await $(FloatingActionButton).tap();
        await $.pumpAndSettle();
        await $('Cancel').tap();
        await $.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    },
  );

  patrolTest(
    'accessibility test',
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // Verify semantic labels are present
      expect(
        find.bySemanticsLabel(RegExp('.*refresh.*', caseSensitive: false)),
        findsWidgets,
      );

      // Test keyboard navigation simulation
      await $.native.pressHome();
      await $.native.openApp();
      await $.pumpAndSettle();

      expect($('GrabTube'), findsOneWidget);
    },
  );

  patrolTest(
    'theme switching test',
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // Verify Material Design 3 is applied
      final context = $.tester.element(find.byType(MaterialApp));
      final theme = Theme.of(context);

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme, isNotNull);
    },
  );

  patrolTest(
    'error handling test',
    ($) async {
      await app.main();
      await $.pumpAndSettle();

      // Test invalid URL submission
      await $(FloatingActionButton).tap();
      await $.pumpAndSettle();

      await $(TextField).enterText('not-a-valid-url');
      await $.pumpAndSettle();

      await $('Add').tap();
      await $.pumpAndSettle();

      // Should show validation error
      expect($('Please enter a valid URL'), findsOneWidget);
    },
  );
}
