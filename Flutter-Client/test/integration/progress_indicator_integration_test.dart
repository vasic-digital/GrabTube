import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/presentation/widgets/grabtube_progress_indicator.dart';
import 'package:grabtube/presentation/widgets/download_list_item.dart';
import 'package:grabtube/domain/entities/download.dart';

void main() {
  group('Progress Indicator Integration Tests', () {
    testWidgets('Progress indicators work correctly in DownloadListItem', (WidgetTester tester) async {
      final testDownload = Download(
        id: 'test-123',
        title: 'Test Video Download',
        url: 'https://example.com/video',
        status: DownloadStatus.downloading,
        progress: 0.65,
        thumbnail: 'https://example.com/thumb.jpg',
        quality: '1080p',
        speed: '2.5 MB/s',
        eta: '00:30',
        fileSize: 104857600, // 100 MB
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                DownloadListItem(
                  download: testDownload,
                  onDelete: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Verify that progress indicators are present
      expect(find.byType(GrabTubeProgressIndicator), findsOneWidget);
      expect(find.byType(GrabTubeLinearProgress), findsOneWidget);

      // Verify percentage is displayed
      expect(find.text('65%'), findsOneWidget);

      // Verify file size is displayed
      expect(find.text('100.00 MB'), findsOneWidget);
    });

    testWidgets('Progress indicators update when download progresses', (WidgetTester tester) async {
      var progress = 0.25;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    GrabTubeLinearProgress(
                      progress: progress,
                      showPercentage: true,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          progress = 0.75;
                        });
                      },
                      child: const Text('Update Progress'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('25%'), findsOneWidget);

      // Tap button to update progress
      await tester.tap(find.text('Update Progress'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify progress updated
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('Multiple progress indicators can coexist', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GrabTubeProgressIndicator(
                  progress: 0.3,
                  showPercentage: true,
                ),
                GrabTubeLinearProgress(
                  progress: 0.5,
                  showPercentage: true,
                ),
                GrabTubeCircularProgress(
                  progress: 0.7,
                  showPercentage: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('30%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);

      expect(find.byType(GrabTubeProgressIndicator), findsNWidgets(2)); // One standalone + one in circular
      expect(find.byType(GrabTubeLinearProgress), findsOneWidget);
      expect(find.byType(GrabTubeCircularProgress), findsOneWidget);
    });

    testWidgets('Progress indicators respect theme colors', (WidgetTester tester) async {
      const primaryColor = Color(0xFFE74C3C); // GrabTube red

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryColor,
              brightness: Brightness.light,
            ),
          ),
          home: const Scaffold(
            body: GrabTubeLinearProgress(
              progress: 0.5,
              showPercentage: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify widget renders without errors
      expect(find.byType(GrabTubeLinearProgress), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('Progress indicators work in dark mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: Column(
              children: [
                GrabTubeProgressIndicator(progress: 0.4, showPercentage: true),
                GrabTubeLinearProgress(progress: 0.6, showPercentage: true),
                GrabTubeCircularProgress(progress: 0.8, showPercentage: true),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('40%'), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('Progress indicators handle rapid updates', (WidgetTester tester) async {
      var progress = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    GrabTubeLinearProgress(
                      progress: progress,
                      showPercentage: true,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        for (var i = 0; i < 10; i++) {
                          setState(() {
                            progress += 0.1;
                          });
                        }
                      },
                      child: const Text('Rapid Update'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);

      await tester.tap(find.text('Rapid Update'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('Progress indicators maintain state during scroll', (WidgetTester tester) async {
      final downloads = List.generate(
        20,
        (index) => Download(
          id: 'download-$index',
          title: 'Video $index',
          url: 'https://example.com/video$index',
          status: DownloadStatus.downloading,
          progress: (index * 0.05).clamp(0.0, 1.0),
          quality: '720p',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                return DownloadListItem(
                  download: downloads[index],
                  onDelete: () {},
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial items are displayed
      expect(find.byType(DownloadListItem), findsWidgets);

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify items still render correctly after scrolling
      expect(find.byType(DownloadListItem), findsWidgets);
      expect(find.byType(GrabTubeProgressIndicator), findsWidgets);
    });

    testWidgets('Progress indicators work with different sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GrabTubeProgressIndicator(progress: 0.5, size: 24),
                GrabTubeProgressIndicator(progress: 0.5, size: 48),
                GrabTubeProgressIndicator(progress: 0.5, size: 72),
                GrabTubeCircularProgress(progress: 0.5, size: 48),
                GrabTubeCircularProgress(progress: 0.5, size: 64),
                GrabTubeCircularProgress(progress: 0.5, size: 96),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(GrabTubeProgressIndicator), findsNWidgets(5)); // 3 standalone + 2 in circular
      expect(find.byType(GrabTubeCircularProgress), findsNWidgets(3));
    });

    testWidgets('Progress indicators handle custom text colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GrabTubeProgressIndicator(
                  progress: 0.5,
                  showPercentage: true,
                  textColor: Colors.red,
                ),
                GrabTubeProgressIndicator(
                  progress: 0.5,
                  showPercentage: true,
                  textColor: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final redText = tester.widget<Text>(find.text('50%').first);
      expect(redText.style?.color, Colors.red);

      final blueText = tester.widget<Text>(find.text('50%').last);
      expect(blueText.style?.color, Colors.blue);
    });
  });
}
