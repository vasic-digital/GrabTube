import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grabtube/domain/entities/download.dart';
import 'package:grabtube/presentation/widgets/enhanced_download_progress.dart';

// Mock classes
class MockVoidCallback extends Mock implements VoidCallback {}

void main() {
  late Download testDownload;
  late MockVoidCallback mockOnDelete;
  late MockVoidCallback mockOnStart;
  late MockVoidCallback mockOnPause;
  late MockVoidCallback mockOnResume;

  setUp(() {
    mockOnDelete = MockVoidCallback();
    mockOnStart = MockVoidCallback();
    mockOnPause = MockVoidCallback();
    mockOnResume = MockVoidCallback();

    testDownload = const Download(
      id: 'test-id',
      url: 'https://example.com/video',
      title: 'Test Video',
      status: DownloadStatus.downloading,
      thumbnail: 'https://example.com/thumbnail.jpg',
      quality: '1080p',
      format: 'mp4',
      progress: 0.75,
      speed: '2.5 MB/s',
      eta: '00:30',
      fileSize: 104857600, // 100MB
      downloadedSize: 78643200, // 75MB
      timestamp: null,
    );
  });

  group('EnhancedDownloadProgress', () {
    testWidgets('renders correctly with downloading status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
              onStart: mockOnStart.call,
              onPause: mockOnPause.call,
              onResume: mockOnResume.call,
            ),
          ),
        ),
      );

      // Check basic elements are present
      expect(find.text('Test Video'), findsOneWidget);
      expect(find.text('Downloading'), findsOneWidget);
      expect(find.text('1080p'), findsOneWidget);
      expect(find.text('mp4'), findsOneWidget);
      expect(find.text('2.5 MB/s'), findsOneWidget);
      expect(find.text('00:30'), findsOneWidget);
      expect(find.text('75.0%'), findsOneWidget);
    });

    testWidgets('shows progress bar for active downloads', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      // Should show progress bar for downloading status
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('does not show progress bar for completed downloads', (tester) async {
      final completedDownload = testDownload.copyWith(status: DownloadStatus.completed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: completedDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      // Should not show progress bar for completed downloads
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('shows error section for failed downloads', (tester) async {
      final errorDownload = testDownload.copyWith(
        status: DownloadStatus.error,
        error: 'Download failed due to network error',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: errorDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      expect(find.text('Download Error'), findsOneWidget);
      expect(find.text('Download failed due to network error'), findsOneWidget);
    });

    testWidgets('shows expanded details when expanded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
              isExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Download Details'), findsOneWidget);
      expect(find.text('Download Components'), findsOneWidget);
    });

    testWidgets('calls onDelete when delete button is tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      // Find and tap the delete menu item
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(() => mockOnDelete()).called(1);
    });

    testWidgets('calls onStart when start button is tapped', (tester) async {
      final pendingDownload = testDownload.copyWith(status: DownloadStatus.pending);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: pendingDownload,
              onDelete: mockOnDelete.call,
              onStart: mockOnStart.call,
            ),
          ),
        ),
      );

      // Find and tap the start menu item
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      verify(() => mockOnStart()).called(1);
    });

    testWidgets('shows speed visualization for active downloads', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      expect(find.text('Speed Visualization'), findsOneWidget);
    });

    testWidgets('formats file sizes correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      // Should show "100.0 MB" for fileSize and "75.0 MB / 100.0 MB" for progress
      expect(find.textContaining('100.0 MB'), findsOneWidget);
      expect(find.textContaining('75.0 MB / 100.0 MB'), findsOneWidget);
    });

    testWidgets('handles missing optional fields gracefully', (tester) async {
      final minimalDownload = const Download(
        id: 'minimal-id',
        url: 'https://example.com',
        title: 'Minimal Video',
        status: DownloadStatus.pending,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: minimalDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      expect(find.text('Minimal Video'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      // Should not crash with missing optional fields
    });

    testWidgets('shows completion checkmark for completed downloads', (tester) async {
      final completedDownload = testDownload.copyWith(status: DownloadStatus.completed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: completedDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      // Should show check icon for completed status
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows different status colors for different states', (tester) async {
      final statuses = [
        DownloadStatus.pending,
        DownloadStatus.downloading,
        DownloadStatus.completed,
        DownloadStatus.error,
        DownloadStatus.canceled,
      ];

      for (final status in statuses) {
        final statusDownload = testDownload.copyWith(status: status);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedDownloadProgress(
                download: statusDownload,
                onDelete: mockOnDelete.call,
              ),
            ),
          ),
        );

        // Should render without crashing for all status types
        expect(find.text(statusDownload.title), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('handles expansion state changes', (tester) async {
      bool isExpanded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => EnhancedDownloadProgress(
                download: testDownload,
                onDelete: mockOnDelete.call,
                isExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  setState(() => isExpanded = expanded);
                },
              ),
            ),
          ),
        ),
      );

      // Initially not expanded
      expect(find.text('Download Details'), findsNothing);

      // Tap to expand
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Should now show expanded details
      expect(find.text('Download Details'), findsOneWidget);
    });

    testWidgets('shows download components in expanded view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
              isExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Video'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Quality: 1080p'), findsOneWidget);
      expect(find.text('Format: mp4'), findsOneWidget);
      expect(find.text('Thumbnail'), findsOneWidget);
      expect(find.text('Metadata'), findsOneWidget);
    });

    testWidgets('displays metadata in expanded view', (tester) async {
      final downloadWithMetadata = testDownload.copyWith(
        uploader: 'Test Channel',
        duration: 3600, // 1 hour
        viewCount: 1000000,
        uploadDate: '2024-01-15',
        extractor: 'youtube',
        likeCount: 50000,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: downloadWithMetadata,
              onDelete: mockOnDelete.call,
              isExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Test Channel'), findsOneWidget);
      expect(find.text('1:00:00'), findsOneWidget); // Formatted duration
      expect(find.text('1.0M'), findsOneWidget); // Formatted view count
      expect(find.text('2024-01-15'), findsOneWidget);
      expect(find.text('youtube'), findsOneWidget);
    });

    testWidgets('handles progress animation smoothly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: testDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      // Initial progress should be visible
      expect(find.text('75.0%'), findsOneWidget);

      // Update download with new progress
      final updatedDownload = testDownload.copyWith(progress: 0.9);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: updatedDownload,
              onDelete: mockOnDelete.call,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show updated progress
      expect(find.text('90.0%'), findsOneWidget);
    });
  });
}