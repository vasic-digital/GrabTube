import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube_web/core/constants/app_constants.dart';
import 'package:grabtube_web/presentation/pages/home_page.dart';

void main() {
  group('HomePage Widget Tests', () {
    testWidgets('displays app title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text(AppConstants.appName), findsOneWidget);
    });

    testWidgets('displays all three tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Queue'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('displays add download section', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Add Download'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has quality dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Quality'), findsOneWidget);

      // Tap dropdown to show options
      await tester.tap(find.text('Quality').first);
      await tester.pumpAndSettle();

      // Should show quality options
      for (final quality in AppConstants.qualityOptions) {
        expect(find.text(quality), findsWidgets);
      }
    });

    testWidgets('has format dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      expect(find.text('Format'), findsOneWidget);
    });

    testWidgets('shows validation error for empty URL',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Find and tap the Add button
      final addButton = find.widgetWithText(FilledButton, 'Add');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      // Should show error snackbar
      expect(find.text('Please enter a URL'), findsOneWidget);
    });

    testWidgets('refresh button triggers refresh', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pump();

      // Should show refresh message
      expect(find.textContaining('Refreshing'), findsOneWidget);
    });

    testWidgets('settings button shows message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      final settingsButton = find.byIcon(Icons.settings);
      expect(settingsButton, findsOneWidget);

      await tester.tap(settingsButton);
      await tester.pump();

      expect(find.textContaining('Settings'), findsOneWidget);
    });

    testWidgets('can switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Initially on Queue tab
      expect(find.text('No Active Downloads'), findsOneWidget);

      // Tap Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      expect(find.text('No Completed Downloads'), findsOneWidget);

      // Tap Pending tab
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      expect(find.text('No Pending Downloads'), findsOneWidget);
    });

    testWidgets('shows appropriate icons for each tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Queue tab
      expect(find.byIcon(Icons.download), findsWidgets);

      // Switch to Completed
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsWidgets);

      // Switch to Pending
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.pending), findsWidgets);
    });

    testWidgets('URL text field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      final urlField = find.byType(TextField);
      expect(urlField, findsOneWidget);

      const testUrl = 'https://youtube.com/watch?v=test';
      await tester.enterText(urlField, testUrl);
      await tester.pump();

      expect(find.text(testUrl), findsOneWidget);
    });
  });

  group('HomePage Responsive Tests', () {
    testWidgets('shows desktop layout on large screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Desktop layout should show everything in one row
      expect(find.byType(TextField), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('shows mobile layout on small screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Mobile layout should stack vertically
      expect(find.byType(TextField), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
