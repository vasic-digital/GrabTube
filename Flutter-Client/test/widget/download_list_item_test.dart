import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/download.dart';
import 'package:grabtube/presentation/widgets/download_list_item.dart';

void main() {
  group('DownloadListItem Widget Tests', () {
    testWidgets('should display download title', (WidgetTester tester) async {
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Test Video Title',
        status: DownloadStatus.downloading,
        progress: 0.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Video Title'), findsOneWidget);
    });

    testWidgets('should display progress bar for active downloads',
        (WidgetTester tester) async {
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Downloading Video',
        status: DownloadStatus.downloading,
        progress: 0.75,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('should display status chip', (WidgetTester tester) async {
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Completed Video',
        status: DownloadStatus.completed,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should display error message when download has error',
        (WidgetTester tester) async {
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Failed Video',
        status: DownloadStatus.error,
        error: 'Network error occurred',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Network error occurred'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call onDelete when delete is tapped',
        (WidgetTester tester) async {
      bool deleteCalled = false;
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Test Video',
        status: DownloadStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Tap delete option
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(deleteCalled, true);
    });

    testWidgets('should display speed and ETA when available',
        (WidgetTester tester) async {
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Downloading Video',
        status: DownloadStatus.downloading,
        progress: 0.5,
        speed: '2.5 MB/s',
        eta: '2 minutes',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('2.5 MB/s'), findsOneWidget);
      expect(find.textContaining('2 minutes'), findsOneWidget);
    });

    testWidgets('should display quality chip when quality is available',
        (WidgetTester tester) async {
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'HD Video',
        status: DownloadStatus.downloading,
        quality: '1080',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('1080'), findsOneWidget);
    });

    testWidgets('should show start button for pending downloads',
        (WidgetTester tester) async {
      bool startCalled = false;
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Pending Video',
        status: DownloadStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DownloadListItem(
              download: download,
              onDelete: () {},
              onStart: () => startCalled = true,
            ),
          ),
        ),
      );

      // Open popup menu
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Verify start option exists
      expect(find.text('Start'), findsOneWidget);

      // Tap start option
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(startCalled, true);
    });
  });
}
