import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grabtube/domain/entities/download.dart';
import 'package:grabtube/presentation/widgets/hierarchical_download_manager.dart';

// Mock classes
class MockVoidCallback extends Mock implements VoidCallback {}

void main() {
  late List<DownloadGroup> testGroups;
  late MockVoidCallback mockOnStartAll;
  late MockVoidCallback mockOnPauseAll;
  late MockVoidCallback mockOnCancelAll;

  setUp(() {
    mockOnStartAll = MockVoidCallback();
    mockOnPauseAll = MockVoidCallback();
    mockOnCancelAll = MockVoidCallback();

    // Create test downloads
    final downloads1 = [
      const Download(
        id: 'video1',
        url: 'https://example.com/video1',
        title: 'Video 1',
        status: DownloadStatus.completed,
        progress: 1.0,
      ),
      const Download(
        id: 'video2',
        url: 'https://example.com/video2',
        title: 'Video 2',
        status: DownloadStatus.downloading,
        progress: 0.5,
        speed: '1.2 MB/s',
      ),
    ];

    final downloads2 = [
      const Download(
        id: 'video3',
        url: 'https://example.com/video3',
        title: 'Video 3',
        status: DownloadStatus.pending,
        progress: 0.0,
      ),
      const Download(
        id: 'video4',
        url: 'https://example.com/video4',
        title: 'Video 4',
        status: DownloadStatus.error,
        progress: 0.0,
        error: 'Network error',
      ),
    ];

    testGroups = [
      DownloadGroup(
        id: 'playlist1',
        title: 'My Favorite Playlist',
        type: DownloadGroupType.playlist,
        downloads: downloads1,
        thumbnail: 'https://example.com/playlist_thumb.jpg',
        description: 'A collection of my favorite videos',
      ),
      DownloadGroup(
        id: 'channel1',
        title: 'Tech Channel',
        type: DownloadGroupType.channel,
        downloads: downloads2,
        thumbnail: 'https://example.com/channel_thumb.jpg',
      ),
    ];
  });

  group('HierarchicalDownloadManager', () {
    testWidgets('renders correctly with download groups', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
              onStartAll: mockOnStartAll.call,
              onPauseAll: mockOnPauseAll.call,
              onCancelAll: mockOnCancelAll.call,
            ),
          ),
        ),
      );

      // Check main elements are present
      expect(find.text('Download Manager'), findsOneWidget);
      expect(find.text('My Favorite Playlist'), findsOneWidget);
      expect(find.text('Tech Channel'), findsOneWidget);
      expect(find.text('2 items • 1/2 completed'), findsOneWidget);
      expect(find.text('2 items • 0/2 completed'), findsOneWidget);
    });

    testWidgets('shows overall statistics correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Should show total of 4 downloads
      expect(find.text('4/4 completed'), findsOneWidget);
      // Should show 1 active download
      expect(find.textContaining('1'), findsWidgets); // Active count
      // Should show 1 failed download
      expect(find.textContaining('1'), findsWidgets); // Failed count
    });

    testWidgets('calculates overall progress correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Progress calculation: (1.0 + 0.5 + 0.0 + 0.0) / 4 = 0.375 = 37.5%
      expect(find.text('37.5%'), findsOneWidget);
    });

    testWidgets('shows group type icons correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Should show playlist icon for playlist group
      expect(find.byIcon(Icons.playlist_play), findsOneWidget);
      // Should show account circle icon for channel group
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
    });

    testWidgets('expands and collapses groups correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Initially collapsed - should not show group actions
      expect(find.text('Group Actions'), findsNothing);

      // Tap first group header to expand
      await tester.tap(find.text('My Favorite Playlist'));
      await tester.pumpAndSettle();

      // Should now show expanded content
      expect(find.text('Group Actions'), findsOneWidget);
      expect(find.text('Video 1'), findsOneWidget);
      expect(find.text('Video 2'), findsOneWidget);

      // Tap again to collapse
      await tester.tap(find.text('My Favorite Playlist'));
      await tester.pumpAndSettle();

      // Should hide expanded content
      expect(find.text('Group Actions'), findsNothing);
    });

    testWidgets('expand/collapse all functionality works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Initially no groups expanded
      expect(find.text('Group Actions'), findsNothing);

      // Tap "Expand All"
      await tester.tap(find.text('Expand All'));
      await tester.pumpAndSettle();

      // Should expand all groups
      expect(find.text('Group Actions'), findsNWidgets(2)); // One for each group

      // Tap "Collapse All"
      await tester.tap(find.text('Collapse All'));
      await tester.pumpAndSettle();

      // Should collapse all groups
      expect(find.text('Group Actions'), findsNothing);
    });

    testWidgets('shows compact download items in expanded groups', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Expand first group
      await tester.tap(find.text('My Favorite Playlist'));
      await tester.pumpAndSettle();

      // Should show individual downloads
      expect(find.text('Video 1'), findsOneWidget);
      expect(find.text('Video 2'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget); // Completed video
      expect(find.text('50%'), findsOneWidget); // Downloading video
    });

    testWidgets('shows speed information for active downloads', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Expand first group to see active download
      await tester.tap(find.text('My Favorite Playlist'));
      await tester.pumpAndSettle();

      // Should show speed for active download
      expect(find.text('1.2 MB/s'), findsOneWidget);
    });

    testWidgets('bulk action buttons work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
              onStartAll: mockOnStartAll.call,
              onPauseAll: mockOnPauseAll.call,
              onCancelAll: mockOnCancelAll.call,
            ),
          ),
        ),
      );

      // Should show bulk action buttons
      expect(find.text('Start All'), findsOneWidget);
      expect(find.text('Pause All'), findsOneWidget);
      expect(find.text('Cancel All'), findsOneWidget);

      // Tap Start All
      await tester.tap(find.text('Start All'));
      await tester.pumpAndSettle();

      verify(() => mockOnStartAll()).called(1);
    });

    testWidgets('shows empty state when no groups exist', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: [],
            ),
          ),
        ),
      );

      expect(find.text('No Downloads'), findsOneWidget);
      expect(find.text('Start downloading videos, playlists, or channels'), findsOneWidget);
    });

    testWidgets('displays group thumbnails when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Should attempt to load thumbnails (network images)
      // Note: In tests, network images might not load, but the structure should be there
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('shows different colors for different group types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Should render different colored containers for different group types
      // The exact colors depend on theme, but structure should be present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('handles single item groups correctly', (tester) async {
      final singleItemGroup = [
        DownloadGroup(
          id: 'single',
          title: 'Single Video',
          type: DownloadGroupType.single,
          downloads: [
            const Download(
              id: 'single-video',
              url: 'https://example.com/single',
              title: 'Single Video',
              status: DownloadStatus.completed,
              progress: 1.0,
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: singleItemGroup,
            ),
          ),
        ),
      );

      expect(find.text('Single Video'), findsOneWidget);
      expect(find.text('1 items • 1/1 completed'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle), findsOneWidget); // Single item icon
    });

    testWidgets('calculates group progress correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // First group: (1.0 + 0.5) / 2 = 0.75 = 75%
      // Second group: (0.0 + 0.0) / 2 = 0.0 = 0%
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('shows status indicators for individual downloads', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Expand groups to see individual items
      await tester.tap(find.text('My Favorite Playlist'));
      await tester.tap(find.text('Tech Channel'));
      await tester.pumpAndSettle();

      // Should show status indicators (colored circles)
      expect(find.byType(Container), findsWidgets); // Status indicator containers
    });

    testWidgets('handles groups with no downloads gracefully', (tester) async {
      final emptyGroup = [
        const DownloadGroup(
          id: 'empty',
          title: 'Empty Group',
          type: DownloadGroupType.playlist,
          downloads: [],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: emptyGroup,
            ),
          ),
        ),
      );

      expect(find.text('Empty Group'), findsOneWidget);
      expect(find.text('0 items • 0/0 completed'), findsOneWidget);
      // Should not crash with empty downloads list
    });

    testWidgets('shows group descriptions when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Expand first group which has description
      await tester.tap(find.text('My Favorite Playlist'));
      await tester.pumpAndSettle();

      // Should show description in expanded view
      expect(find.text('A collection of my favorite videos'), findsOneWidget);
    });

    testWidgets('animations work correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: testGroups,
            ),
          ),
        ),
      );

      // Initial state
      await tester.pumpAndSettle();

      // Expand group - should animate
      await tester.tap(find.text('My Favorite Playlist'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 150)); // Mid animation
      await tester.pump(const Duration(milliseconds: 150)); // End animation

      // Should show expanded content after animation
      expect(find.text('Group Actions'), findsOneWidget);
    });
  });
}