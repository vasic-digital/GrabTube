import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:grabtube/domain/entities/download.dart';
import 'package:grabtube/presentation/widgets/enhanced_download_progress.dart';
import 'package:grabtube/presentation/widgets/hierarchical_download_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Enhanced Download Progress Integration Tests', () {
    late Download testDownload;

    setUp(() {
      testDownload = const Download(
        id: 'integration-test-id',
        url: 'https://example.com/test-video',
        title: 'Integration Test Video',
        status: DownloadStatus.downloading,
        thumbnail: null,
        quality: '720p',
        format: 'mp4',
        progress: 0.0,
        speed: '1.5 MB/s',
        eta: '02:30',
        fileSize: 524288000, // 500MB
        downloadedSize: 0,
        timestamp: null,
        description: 'A test video for integration testing',
        duration: 900, // 15 minutes
        uploader: 'Test Channel',
        viewCount: 10000,
        uploadDate: '2024-01-01',
        webpageUrl: 'https://example.com/watch?v=test',
        extractor: 'youtube',
        likeCount: 1000,
      );
    });

    testWidgets('complete download progress workflow', (tester) async {
      // Start with 0% progress
      Download currentDownload = testDownload;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: currentDownload,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Integration Test Video'), findsOneWidget);
      expect(find.text('Downloading'), findsOneWidget);
      expect(find.text('0.0%'), findsOneWidget);
      expect(find.text('1.5 MB/s'), findsOneWidget);

      // Simulate progress updates
      final progressUpdates = [0.1, 0.25, 0.5, 0.75, 0.9, 1.0];

      for (final progress in progressUpdates) {
        currentDownload = currentDownload.copyWith(
          progress: progress,
          downloadedSize: (524288000 * progress).round(),
          speed: '${(1.5 + progress * 2).toStringAsFixed(1)} MB/s', // Speed increases
          eta: progress < 1.0 ? '00:${(30 * (1 - progress)).round().toString().padLeft(2, '0')}' : null,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedDownloadProgress(
                download: currentDownload,
                onDelete: () {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 300)); // Allow animations

        final expectedPercentage = '${(progress * 100).toStringAsFixed(1)}%';
        expect(find.text(expectedPercentage), findsOneWidget);
      }

      // Final state - completed
      currentDownload = currentDownload.copyWith(
        status: DownloadStatus.completed,
        progress: 1.0,
        downloadedSize: 524288000,
        speed: null,
        eta: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: currentDownload,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('100.0%'), findsOneWidget);
    });

    testWidgets('error handling and recovery workflow', (tester) async {
      Download currentDownload = testDownload;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: currentDownload,
              onDelete: () {},
              onStart: () {},
            ),
          ),
        ),
      );

      // Simulate download progressing
      currentDownload = currentDownload.copyWith(
        progress: 0.3,
        downloadedSize: 157286400, // 150MB
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: currentDownload,
              onDelete: () {},
              onStart: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('30.0%'), findsOneWidget);

      // Simulate network error
      currentDownload = currentDownload.copyWith(
        status: DownloadStatus.error,
        error: 'Connection timeout - network unreachable',
        speed: null,
        eta: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: currentDownload,
              onDelete: () {},
              onStart: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error state
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Download Error'), findsOneWidget);
      expect(find.text('Connection timeout - network unreachable'), findsOneWidget);

      // Simulate retry - back to pending
      currentDownload = currentDownload.copyWith(
        status: DownloadStatus.pending,
        error: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: currentDownload,
              onDelete: () {},
              onStart: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Download Error'), findsNothing);
    });

    testWidgets('hierarchical download manager with multiple groups', (tester) async {
      final playlistDownloads = [
        const Download(
          id: 'p1',
          url: 'https://example.com/p1',
          title: 'Playlist Video 1',
          status: DownloadStatus.completed,
          progress: 1.0,
        ),
        const Download(
          id: 'p2',
          url: 'https://example.com/p2',
          title: 'Playlist Video 2',
          status: DownloadStatus.downloading,
          progress: 0.6,
          speed: '2.1 MB/s',
        ),
        const Download(
          id: 'p3',
          url: 'https://example.com/p3',
          title: 'Playlist Video 3',
          status: DownloadStatus.pending,
          progress: 0.0,
        ),
      ];

      final channelDownloads = [
        const Download(
          id: 'c1',
          url: 'https://example.com/c1',
          title: 'Channel Video 1',
          status: DownloadStatus.completed,
          progress: 1.0,
        ),
        const Download(
          id: 'c2',
          url: 'https://example.com/c2',
          title: 'Channel Video 2',
          status: DownloadStatus.error,
          progress: 0.0,
          error: 'File not found',
        ),
      ];

      final downloadGroups = [
        DownloadGroup(
          id: 'playlist-group',
          title: 'My Awesome Playlist',
          type: DownloadGroupType.playlist,
          downloads: playlistDownloads,
          description: 'A curated collection of amazing videos',
        ),
        DownloadGroup(
          id: 'channel-group',
          title: 'Tech Reviews Channel',
          type: DownloadGroupType.channel,
          downloads: channelDownloads,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: downloadGroups,
              onStartAll: () {},
              onPauseAll: () {},
              onCancelAll: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify overall statistics
      expect(find.text('Download Manager'), findsOneWidget);
      expect(find.text('5/5 completed'), findsOneWidget); // 5 total downloads
      expect(find.text('1'), findsWidgets); // 1 active download
      expect(find.text('1'), findsWidgets); // 1 failed download

      // Verify group headers
      expect(find.text('My Awesome Playlist'), findsOneWidget);
      expect(find.text('Tech Reviews Channel'), findsOneWidget);
      expect(find.text('3 items • 1/3 completed'), findsOneWidget);
      expect(find.text('2 items • 1/2 completed'), findsOneWidget);

      // Test group expansion
      await tester.tap(find.text('My Awesome Playlist'));
      await tester.pumpAndSettle();

      expect(find.text('Group Actions'), findsOneWidget);
      expect(find.text('Playlist Video 1'), findsOneWidget);
      expect(find.text('Playlist Video 2'), findsOneWidget);
      expect(find.text('Playlist Video 3'), findsOneWidget);

      // Test expand all functionality
      await tester.tap(find.text('Expand All'));
      await tester.pumpAndSettle();

      expect(find.text('Group Actions'), findsNWidgets(2));

      // Test collapse all functionality
      await tester.tap(find.text('Collapse All'));
      await tester.pumpAndSettle();

      expect(find.text('Group Actions'), findsNothing);
    });

    testWidgets('speed visualization and performance tracking', (tester) async {
      Download currentDownload = testDownload;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedDownloadProgress(
              download: currentDownload,
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate varying download speeds over time
      final speedProgression = [
        '0.5 MB/s',
        '1.2 MB/s',
        '2.8 MB/s',
        '1.8 MB/s',
        '3.1 MB/s',
        '2.5 MB/s',
      ];

      for (int i = 0; i < speedProgression.length; i++) {
        currentDownload = currentDownload.copyWith(
          progress: 0.1 + (i * 0.15),
          speed: speedProgression[i],
          downloadedSize: (524288000 * (0.1 + (i * 0.15))).round(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedDownloadProgress(
                download: currentDownload,
                onDelete: () {},
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 600)); // Allow speed tracking
      }

      // Should show speed visualization
      expect(find.text('Speed Visualization'), findsOneWidget);

      // Should show speed statistics
      expect(find.textContaining('Current'), findsOneWidget);
      expect(find.textContaining('Average'), findsOneWidget);
      expect(find.textContaining('Peak'), findsOneWidget);
    });

    testWidgets('responsive design and accessibility', (tester) async {
      // Test on different screen sizes
      const testSizes = [
        Size(320, 568),  // iPhone SE
        Size(375, 667),  // iPhone 6/7/8
        Size(414, 896),  // iPhone 11
        Size(768, 1024), // iPad
        Size(1024, 768), // Tablet landscape
      ];

      for (final size in testSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EnhancedDownloadProgress(
                download: testDownload,
                onDelete: () {},
                isExpanded: true,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify core elements are always visible
        expect(find.text('Integration Test Video'), findsOneWidget);
        expect(find.text('Downloading'), findsOneWidget);

        // Test tap targets are accessible (minimum 48x48)
        final inkWellFinder = find.byType(InkWell);
        expect(inkWellFinder, findsOneWidget);

        final inkWell = tester.widget<InkWell>(inkWellFinder);
        final inkWellSize = tester.getSize(find.byWidget(inkWell));

        // Should be reasonably sized for touch
        expect(inkWellSize.width, greaterThanOrEqualTo(44));
        expect(inkWellSize.height, greaterThanOrEqualTo(44));
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(const Size(800, 600));
    });

    testWidgets('memory and performance stress test', (tester) async {
      // Create many download groups with many downloads each
      final stressTestGroups = <DownloadGroup>[];

      for (int groupIndex = 0; groupIndex < 10; groupIndex++) {
        final downloads = <Download>[];

        for (int downloadIndex = 0; downloadIndex < 20; downloadIndex++) {
          downloads.add(
            Download(
              id: 'stress-${groupIndex}-${downloadIndex}',
              url: 'https://example.com/stress-${groupIndex}-${downloadIndex}',
              title: 'Stress Test Video ${groupIndex}-${downloadIndex}',
              status: DownloadStatus.values[downloadIndex % DownloadStatus.values.length],
              progress: downloadIndex / 20.0,
              speed: downloadIndex % 3 == 0 ? '${(downloadIndex % 5) + 1}.0 MB/s' : null,
            ),
          );
        }

        stressTestGroups.add(
          DownloadGroup(
            id: 'stress-group-$groupIndex',
            title: 'Stress Test Group $groupIndex',
            type: DownloadGroupType.values[groupIndex % DownloadGroupType.values.length],
            downloads: downloads,
          ),
        );
      }

      // Measure performance
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HierarchicalDownloadManager(
              downloadGroups: stressTestGroups,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render within reasonable time (less than 5 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Should render all groups
      expect(find.textContaining('Stress Test Group'), findsNWidgets(10));

      // Test scrolling performance
      final scrollableFinder = find.byType(Scrollable);
      expect(scrollableFinder, findsOneWidget);

      // Simulate scrolling
      await tester.drag(scrollableFinder, const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still be responsive
      expect(find.text('Download Manager'), findsOneWidget);
    });

    testWidgets('real-time updates and state synchronization', (tester) async {
      Download currentDownload = testDownload;

      // Set up a stream to simulate real-time updates
      final streamController = StreamController<Download>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamBuilder<Download>(
              stream: streamController.stream,
              initialData: currentDownload,
              builder: (context, snapshot) => EnhancedDownloadProgress(
                download: snapshot.data!,
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate real-time progress updates
      final updates = [
        currentDownload.copyWith(progress: 0.2, downloadedSize: 104857600),
        currentDownload.copyWith(progress: 0.4, downloadedSize: 209715200, speed: '2.0 MB/s'),
        currentDownload.copyWith(progress: 0.6, downloadedSize: 314572800, speed: '2.5 MB/s'),
        currentDownload.copyWith(progress: 0.8, downloadedSize: 419430400, speed: '3.0 MB/s'),
        currentDownload.copyWith(progress: 1.0, downloadedSize: 524288000, status: DownloadStatus.completed, speed: null),
      ];

      for (final update in updates) {
        streamController.add(update);
        await tester.pumpAndSettle(const Duration(milliseconds: 100));

        final expectedProgress = '${(update.progress * 100).toStringAsFixed(1)}%';
        expect(find.text(expectedProgress), findsOneWidget);
      }

      // Verify final state
      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await streamController.close();
    });
  });
}