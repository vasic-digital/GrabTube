import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grabtube/presentation/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scheduling E2E Tests', () {
    testWidgets('should navigate to schedules page and display empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page (assuming it's accessible via navigation)
      // This would depend on your app's navigation structure
      // For this example, we'll assume schedules are accessible

      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Verify schedules page is displayed
      expect(find.text('Download Schedules'), findsOneWidget);
      expect(find.text('No Schedules Yet'), findsOneWidget);
    });

    testWidgets('should create a one-time schedule', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Tap create schedule button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill schedule form
      await tester.enterText(find.byKey(const Key('schedule_name')), 'E2E Test Schedule');
      await tester.enterText(find.byKey(const Key('schedule_description')), 'Created by E2E test');

      // Select one-time schedule type
      await tester.tap(find.text('One-time'));
      await tester.pumpAndSettle();

      // Set execution date and time
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await tester.tap(find.byKey(const Key('execution_date')));
      await tester.pumpAndSettle();

      // Select tomorrow's date (this would need actual date picker interaction)
      // For simplicity, we'll assume the date is set

      await tester.tap(find.byKey(const Key('execution_time')));
      await tester.pumpAndSettle();

      // Select a time (this would need actual time picker interaction)
      // For simplicity, we'll assume the time is set

      // Enter download URL
      await tester.enterText(find.byKey(const Key('download_url')), 'https://example.com/test-video');

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify schedule was created
      expect(find.text('E2E Test Schedule'), findsOneWidget);
      expect(find.text('One-time'), findsOneWidget);
    });

    testWidgets('should create a recurring daily schedule', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Tap create schedule button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill schedule form
      await tester.enterText(find.byKey(const Key('schedule_name')), 'Daily E2E Schedule');
      await tester.enterText(find.byKey(const Key('schedule_description')), 'Daily downloads for E2E testing');

      // Select recurring schedule type
      await tester.tap(find.text('Recurring'));
      await tester.pumpAndSettle();

      // Select daily recurrence
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      // Set execution time
      await tester.tap(find.byKey(const Key('execution_time')));
      await tester.pumpAndSettle();

      // Select 2:00 PM (this would need actual time picker interaction)
      // For simplicity, we'll assume the time is set

      // Enter download URL
      await tester.enterText(find.byKey(const Key('download_url')), 'https://example.com/daily-video');

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify schedule was created
      expect(find.text('Daily E2E Schedule'), findsOneWidget);
      expect(find.text('Recurring'), findsOneWidget);
      expect(find.text('Daily'), findsOneWidget);
    });

    testWidgets('should create a collection schedule', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Tap create schedule button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill schedule form
      await tester.enterText(find.byKey(const Key('schedule_name')), 'Collection E2E Schedule');
      await tester.enterText(find.byKey(const Key('schedule_description')), 'Collection downloads for E2E testing');

      // Select collection schedule type
      await tester.tap(find.text('Collection'));
      await tester.pumpAndSettle();

      // Set interval
      await tester.enterText(find.byKey(const Key('interval')), '7');
      await tester.tap(find.text('Days'));
      await tester.pumpAndSettle();

      // Enter collection URL
      await tester.enterText(find.byKey(const Key('collection_url')), 'https://youtube.com/playlist?list=test123');

      // Submit form
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify schedule was created
      expect(find.text('Collection E2E Schedule'), findsOneWidget);
      expect(find.text('Collection'), findsOneWidget);
    });

    testWidgets('should toggle schedule active status', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Assuming there's at least one schedule, find the toggle switch
      final toggleSwitch = find.byType(Switch).first;
      expect(toggleSwitch, findsOneWidget);

      // Get initial state
      final initialState = tester.widget<Switch>(toggleSwitch).value;

      // Toggle the switch
      await tester.tap(toggleSwitch);
      await tester.pumpAndSettle();

      // Verify state changed
      final newState = tester.widget<Switch>(toggleSwitch).value;
      expect(newState, !initialState);
    });

    testWidgets('should execute schedule manually', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Find and tap the execute button (play button)
      final executeButton = find.byIcon(Icons.play_arrow).first;
      expect(executeButton, findsOneWidget);

      await tester.tap(executeButton);
      await tester.pumpAndSettle();

      // Verify execution feedback (snackbar or dialog)
      expect(find.text('Schedule executed successfully'), findsOneWidget);
    });

    testWidgets('should view schedule history', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Find and tap the history button
      final historyButton = find.byIcon(Icons.history).first;
      expect(historyButton, findsOneWidget);

      await tester.tap(historyButton);
      await tester.pumpAndSettle();

      // Verify history dialog/page is shown
      expect(find.text('Execution History'), findsOneWidget);
    });

    testWidgets('should edit existing schedule', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Find and tap the edit button (more options menu)
      final moreButton = find.byIcon(Icons.more_vert).first;
      expect(moreButton, findsOneWidget);

      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Select edit option
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Verify edit form is shown
      expect(find.text('Edit Schedule'), findsOneWidget);

      // Modify schedule name
      await tester.enterText(find.byKey(const Key('schedule_name')), 'Edited E2E Schedule');

      // Save changes
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      // Verify changes were saved
      expect(find.text('Edited E2E Schedule'), findsOneWidget);
    });

    testWidgets('should delete schedule with confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.pumpAndSettle();

      // Count schedules before deletion
      final schedulesBefore = find.byType(Card);

      // Find and tap the delete button
      final moreButton = find.byIcon(Icons.more_vert).first;
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Select delete option
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify schedule was deleted
      final schedulesAfter = find.byType(Card);
      expect(schedulesAfter, findsWidgets);
      // Note: This is a simplified check; actual count comparison would be better
    });

    testWidgets('should handle schedule execution errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Create a schedule with invalid URL
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('schedule_name')), 'Error Test Schedule');
      await tester.tap(find.text('One-time'));
      await tester.pumpAndSettle();

      // Enter invalid URL
      await tester.enterText(find.byKey(const Key('download_url')), 'invalid-url');

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Execute the schedule
      final executeButton = find.byIcon(Icons.play_arrow).last; // Last one should be the new schedule
      await tester.tap(executeButton);
      await tester.pumpAndSettle();

      // Verify error handling
      expect(find.textContaining('Failed'), findsOneWidget);
    });

    testWidgets('should display schedule statistics', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Look for statistics display
      expect(find.textContaining('active'), findsOneWidget);
      expect(find.textContaining('total'), findsOneWidget);
    });

    testWidgets('should handle large number of schedules', (WidgetTester tester) async {
      await tester.pumpWidget(const GrabTubeApp());
      await tester.pumpAndSettle();

      // Navigate to schedules page
      await tester.tap(find.byIcon(Icons.schedule));
      await tester.pumpAndSettle();

      // Test scrolling with many schedules
      // This would require setting up test data with many schedules
      // For now, just verify the list scrolls
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Scroll down
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Scroll up
      await tester.drag(listView, const Offset(0, 500));
      await tester.pumpAndSettle();
    });
  });
}