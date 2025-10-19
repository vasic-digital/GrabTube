import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/presentation/widgets/grabtube_progress_indicator.dart';

void main() {
  group('GrabTubeProgressIndicator', () {
    testWidgets('displays with valid progress value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeProgressIndicator(
              progress: 0.5,
              size: 48,
            ),
          ),
        ),
      );

      expect(find.byType(GrabTubeProgressIndicator), findsOneWidget);
    });

    testWidgets('displays percentage when showPercentage is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeProgressIndicator(
              progress: 0.75,
              size: 48,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('does not display percentage when showPercentage is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeProgressIndicator(
              progress: 0.75,
              size: 48,
              showPercentage: false,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsNothing);
    });

    testWidgets('clamps progress to valid range (0.0 - 1.0)', (WidgetTester tester) async {
      // Test with progress > 1.0
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeProgressIndicator(
              progress: 1.5,
              size: 48,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);

      // Test with progress < 0.0
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeProgressIndicator(
              progress: -0.5,
              size: 48,
              showPercentage: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('uses custom text color when provided', (WidgetTester tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeProgressIndicator(
              progress: 0.5,
              size: 48,
              showPercentage: true,
              textColor: customColor,
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('50%'));
      expect(textWidget.style?.color, customColor);
    });

    testWidgets('respects custom size parameter', (WidgetTester tester) async {
      const customSize = 64.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeProgressIndicator(
              progress: 0.5,
              size: customSize,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(GrabTubeProgressIndicator),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, customSize);
      expect(sizedBox.height, customSize);
    });
  });

  group('GrabTubeLinearProgress', () {
    testWidgets('displays linear progress bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.6,
            ),
          ),
        ),
      );

      expect(find.byType(GrabTubeLinearProgress), findsOneWidget);
    });

    testWidgets('displays percentage when showPercentage is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.45,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('45%'), findsOneWidget);
    });

    testWidgets('does not display percentage when showPercentage is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.45,
              showPercentage: false,
            ),
          ),
        ),
      );

      expect(find.text('45%'), findsNothing);
    });

    testWidgets('displays optional label', (WidgetTester tester) async {
      const testLabel = 'Downloading...';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.5,
              label: testLabel,
            ),
          ),
        ),
      );

      expect(find.text(testLabel), findsOneWidget);
    });

    testWidgets('clamps progress to valid range', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 1.5,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('animates progress changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.3,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('30%'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.7,
              showPercentage: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('70%'), findsOneWidget);
    });
  });

  group('GrabTubeCircularProgress', () {
    testWidgets('displays circular progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeCircularProgress(
              progress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(GrabTubeCircularProgress), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2)); // Background + progress
    });

    testWidgets('displays percentage in center when showPercentage is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeCircularProgress(
              progress: 0.85,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
      expect(find.byType(GrabTubeProgressIndicator), findsOneWidget);
    });

    testWidgets('does not display percentage when showPercentage is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeCircularProgress(
              progress: 0.85,
              showPercentage: false,
            ),
          ),
        ),
      );

      expect(find.text('85%'), findsNothing);
      expect(find.byType(GrabTubeProgressIndicator), findsOneWidget);
    });

    testWidgets('respects custom size parameter', (WidgetTester tester) async {
      const customSize = 80.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeCircularProgress(
              progress: 0.5,
              size: customSize,
            ),
          ),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(GrabTubeCircularProgress),
          matching: find.byType(SizedBox),
        ),
      );

      // Check that the outer SizedBox has the custom size
      final outerSizedBox = sizedBoxes.first;
      expect(outerSizedBox.width, customSize);
      expect(outerSizedBox.height, customSize);
    });

    testWidgets('clamps progress to valid range', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeCircularProgress(
              progress: 2.0,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('uses custom stroke width', (WidgetTester tester) async {
      const customStrokeWidth = 8.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeCircularProgress(
              progress: 0.5,
              strokeWidth: customStrokeWidth,
            ),
          ),
        ),
      );

      final circularProgressIndicators = tester.widgetList<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

      for (final indicator in circularProgressIndicators) {
        expect(indicator.strokeWidth, customStrokeWidth);
      }
    });
  });

  group('Progress Indicator Edge Cases', () {
    testWidgets('handles zero progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GrabTubeProgressIndicator(progress: 0.0, showPercentage: true),
                GrabTubeLinearProgress(progress: 0.0, showPercentage: true),
                GrabTubeCircularProgress(progress: 0.0, showPercentage: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsNWidgets(3));
    });

    testWidgets('handles complete progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GrabTubeProgressIndicator(progress: 1.0, showPercentage: true),
                GrabTubeLinearProgress(progress: 1.0, showPercentage: true),
                GrabTubeCircularProgress(progress: 1.0, showPercentage: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('100%'), findsNWidgets(3));
    });

    testWidgets('handles fractional percentages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.456,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('46%'), findsOneWidget);
    });
  });
}
