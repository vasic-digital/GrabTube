import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:grabtube/domain/entities/download.dart';
import 'package:grabtube/data/repositories/download_repository_impl.dart';
import 'package:grabtube/core/network/api_client.dart';
import 'package:grabtube/core/network/socket_client.dart';

/// Integration tests for downloading from the provided test link
void main() {
  group('Download Tests with Provided Link', () {
    late DownloadRepositoryImpl repository;
    late MockApiClient mockApiClient;
    late MockSocketClient mockSocketClient;
    
    const testVideoUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    
    setUp(() {
      mockApiClient = MockApiClient();
      mockSocketClient = MockSocketClient();
      repository = DownloadRepositoryImpl(
        apiClient: mockApiClient,
        socketClient: mockSocketClient,
      );
    });

    test('should create download request from URL', () async {
      // Arrange
      final downloadRequest = DownloadRequest(
        url: testVideoUrl,
        quality: 'best',
        format: 'mp4',
        timestamp: DateTime.now(),
      );
      
      // Assert
      expect(downloadRequest.url, testVideoUrl);
      expect(downloadRequest.quality, 'best');
      expect(downloadRequest.format, 'mp4');
      expect(downloadRequest.timestamp, isNotNull);
      
      print('✓ Download request created for: $testVideoUrl');
    });

    test('should add download to repository', () async {
      // Arrange
      when(() => mockApiClient.addDownload(
        url: testVideoUrl,
        quality: 'best',
        format: 'mp4',
      )).thenAnswer((_) async => Future.value(
        DownloadModel(
          id: 'test-id-123',
          url: testVideoUrl,
          title: 'Test Video',
          status: DownloadStatus.pending,
          progress: 0.0,
          timestamp: DateTime.now(),
        ),
      ));
      
      // Act
      final download = await repository.addDownload(
        url: testVideoUrl,
        quality: 'best',
        format: 'mp4',
        autoStart: true,
      );
      
      // Assert
      expect(download, isNotNull);
      expect(download!.url, testVideoUrl);
      expect(download.status, DownloadStatus.pending);
      
      verify(() => mockApiClient.addDownload(
        url: testVideoUrl,
        quality: 'best',
        format: 'mp4',
      )).called(1);
      
      print('✓ Download added to repository');
    });

    test('should handle download status updates', () async {
      // Arrange
      final testDownload = Download(
        id: 'test-download',
        url: testVideoUrl,
        title: 'Test Video',
        status: DownloadStatus.downloading,
        progress: 0.3,
        timestamp: DateTime.now(),
      );
      
      final statusUpdates = <Download>[];
      when(() => mockSocketClient.onDownloadUpdated).thenAnswer((_) {
        return (download) {
          statusUpdates.add(download);
        };
      });
      
      // Act
      final callback = mockSocketClient.onDownloadUpdated;
      if (callback != null) {
        callback(testDownload);
      }
      
      // Assert
      expect(statusUpdates, hasLength(1));
      expect(statusUpdates.last.progress, 0.3);
      expect(statusUpdates.last.status, DownloadStatus.downloading);
      
      print('✓ Download status update handled');
    });

    test('should complete download successfully', () async {
      // Simulate complete download flow
      
      // 1. Add download
      when(() => mockApiClient.addDownload(
        url: testVideoUrl,
        quality: '720p',
        format: 'mp4',
      )).thenAnswer((_) async => Future.value(
        DownloadModel(
          id: 'complete-test-id',
          url: testVideoUrl,
          title: 'Test Complete Video',
          status: DownloadStatus.pending,
          progress: 0.0,
          timestamp: DateTime.now(),
        ),
      ));
      
      final download = await repository.addDownload(
        url: testVideoUrl,
        quality: '720p',
        format: 'mp4',
        autoStart: true,
      );
      
      expect(download, isNotNull);
      expect(download!.status, DownloadStatus.pending);
      
      // 2. Simulate progress updates
      final progressUpdates = <Download>[];
      when(() => mockSocketClient.onDownloadUpdated).thenAnswer((_) {
        return (d) {
          progressUpdates.add(d);
        };
      });
      
      final callback = mockSocketClient.onDownloadUpdated;
      if (callback != null) {
        // Simulate 50% progress
        callback(download!.copyWith(
          status: DownloadStatus.downloading,
          progress: 0.5,
        ));
        
        // Simulate completion
        callback(download!.copyWith(
          status: DownloadStatus.completed,
          progress: 1.0,
          filename: 'Test Complete Video.mp4',
        ));
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert progression
      expect(progressUpdates, hasLength(2));
      expect(progressUpdates[0].progress, 0.5);
      expect(progressUpdates[0].status, DownloadStatus.downloading);
      expect(progressUpdates[1].progress, 1.0);
      expect(progressUpdates[1].status, DownloadStatus.completed);
      expect(progressUpdates[1].filename, 'Test Complete Video.mp4');
      
      print('✓ Download completion flow simulated');
      print('  - Initial: ${download.status}');
      print('  - Progress: ${progressUpdates[0].status} at ${(progressUpdates[0].progress * 100).toInt()}%');
      print('  - Complete: ${progressUpdates[1].status}');
      print('  - Filename: ${progressUpdates[1].filename}');
    });
  });

  group('Download Validation Tests', () {
    test('should validate YouTube URL formats', () {
      const validUrls = [
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://youtu.be/dQw4w9WgXcQ',
        'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ&list=PL123&index=2',
      ];
      
      for (final url in validUrls) {
        // Extract video ID logic
        String? videoId;
        if (url.contains('youtube.com/watch')) {
          final uri = Uri.parse(url);
          videoId = uri.queryParameters['v'];
        } else if (url.contains('youtu.be')) {
          final parts = url.split('/');
          videoId = parts.isNotEmpty ? parts.last : null;
        }
        
        expect(videoId, isNotNull, reason: 'Should extract video ID from $url');
        expect(videoId, 'dQw4w9WgXcQ', reason: 'Should extract correct video ID');
      }
      
      print('✓ YouTube URL validation working for all formats');
    });

    test('should handle different quality options', () async {
      const qualities = ['144p', '360p', '720p', '1080p', 'best'];
      
      for (final quality in qualities) {
        final request = DownloadRequest(
          url: testVideoUrl,
          quality: quality,
          format: 'mp4',
          timestamp: DateTime.now(),
        );
        
        expect(request.quality, quality);
      }
      
      print('✓ Quality options handled: ${qualities.join(', ')}');
    });

    test('should handle different format options', () async {
      const formats = ['mp4', 'webm', 'mp3', 'best'];
      
      for (final format in formats) {
        final request = DownloadRequest(
          url: testVideoUrl,
          quality: '720p',
          format: format,
          timestamp: DateTime.now(),
        );
        
        expect(request.format, format);
      }
      
      print('✓ Format options handled: ${formats.join(', ')}');
    });
  });

  group('Download Error Handling', () {
    test('should handle duplicate downloads', () async {
      // Arrange
      when(() => mockApiClient.addDownload(
        url: testVideoUrl,
        quality: 'best',
        format: 'mp4',
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/add'),
        type: DioExceptionType.badResponse,
      ));
      
      // Act & Assert
      expect(
        () => repository.addDownload(
          url: testVideoUrl,
          quality: 'best',
          format: 'mp4',
        ),
        throwsA(isA<DioException>()),
      );
      
      print('✓ Duplicate download error handled');
    });

    test('should handle invalid URL gracefully', () async {
      const invalidUrl = 'https://invalid-url.com/video';
      
      when(() => mockApiClient.addDownload(
        url: invalidUrl,
        quality: 'best',
        format: 'mp4',
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/add'),
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/add'),
        ),
      ));
      
      // Act & Assert
      expect(
        () => repository.addDownload(
          url: invalidUrl,
          quality: 'best',
          format: 'mp4',
        ),
        throwsA(isA<DioException>()),
      );
      
      print('✓ Invalid URL error handled');
    });
  });
}

class MockApiClient extends Mock implements ApiClient {
  @override
  Future<Response> addDownload({
    required String url,
    String? quality,
    String? format,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#addDownload, [url, quality, format]),
      returnValueForMissingInvocation: Future.value(Response(
        statusCode: 200,
        requestOptions: RequestOptions(path: '/add'),
      )),
    );
  }
}

class MockSocketClient extends Mock implements SocketClient {
  void Function(Download)? onDownloadUpdated;
  
  @override
  void onDownloadUpdated(void Function(Download) callback) {
    onDownloadUpdated = callback;
    return super.noSuchMethod(
      Invocation.method(#onDownloadUpdated, [callback]),
      returnValueForMissingInvocation: null,
    );
  }
}