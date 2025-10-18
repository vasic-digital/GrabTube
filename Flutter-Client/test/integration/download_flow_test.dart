import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grabtube/presentation/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Download Flow Integration Tests', () {
    testWidgets('should display home page on launch',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      expect(find.text('GrabTube'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should open add download dialog when FAB is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.text('Add Download'), findsOneWidget);
      expect(find.text('Video URL'), findsOneWidget);
    });

    testWidgets('should validate URL input in add download dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Open add download dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to submit empty URL
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Please enter a URL'), findsOneWidget);
    });

    testWidgets('should display tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Verify all tabs are present
      expect(find.text('Queue'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('should switch between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Tap on Completed tab
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();

      // Verify tab switched (check for empty state in completed)
      expect(find.textContaining('Completed downloads will appear here'),
          findsOneWidget);

      // Tap on Pending tab
      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();

      // Verify tab switched
      expect(find.textContaining('Pending downloads will appear here'),
          findsOneWidget);
    });

    testWidgets('should display stats correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Verify stats cards are displayed
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('should close add download dialog on cancel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Add Download'), findsNothing);
    });

    testWidgets('should refresh downloads on pull-to-refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Perform pull-to-refresh gesture
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      // Verify refresh indicator was shown (no exception thrown)
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display settings button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should display refresh button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify no exception thrown
      expect(tester.takeException(), isNull);
    });
  });
}
