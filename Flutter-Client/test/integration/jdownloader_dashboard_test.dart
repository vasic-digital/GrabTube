import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grabtube/presentation/app.dart';
import 'package:grabtube/presentation/pages/jdownloader_dashboard_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('JDownloader Dashboard Integration Tests', () {
    testWidgets('should navigate to JDownloader dashboard from home page',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Tap the JDownloader button in app bar
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify dashboard is displayed
      expect(find.text('My JDownloader'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Instances'), findsOneWidget);
    });

    testWidgets('should display dashboard tabs correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify tabs are present
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Instances'), findsOneWidget);
    });

    testWidgets('should switch between dashboard tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Tap on Instances tab
      await tester.tap(find.text('Instances'));
      await tester.pumpAndSettle();

      // Verify tab switched
      expect(find.text('Add Instance'), findsOneWidget);
    });

    testWidgets('should display overview stats on dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify overview cards are displayed
      expect(find.text('Total Instances'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('should display speed chart on dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify speed chart is displayed
      expect(find.text('Download Speed'), findsOneWidget);
    });

    testWidgets('should display speed indicators on dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify speed indicators are displayed
      expect(find.text('Download Speed'), findsOneWidget);
      expect(find.text('Upload Speed'), findsOneWidget);
    });

    testWidgets('should display floating action button for adding instances',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Switch to instances tab
      await tester.tap(find.text('Instances'));
      await tester.pumpAndSettle();

      // Verify FAB is displayed
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Add Instance'), findsOneWidget);
    });

    testWidgets('should display refresh button in dashboard app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify refresh button is displayed
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify no exception thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display settings button in dashboard app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify settings button is displayed
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should navigate back to home page from dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify back on home page
      expect(find.text('GrabTube'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should handle empty instances state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Switch to instances tab
      await tester.tap(find.text('Instances'));
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('No JDownloader Instances'), findsOneWidget);
      expect(find.text('Add your first JDownloader instance'), findsOneWidget);
    });

    testWidgets('should display instance status summary on dashboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to dashboard
      await tester.tap(find.byIcon(Icons.cloud_download));
      await tester.pumpAndSettle();

      // Verify instance status section is displayed
      expect(find.text('Instance Status'), findsOneWidget);
    });
  });
}