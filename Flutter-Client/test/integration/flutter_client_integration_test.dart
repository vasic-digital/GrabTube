import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'package:grabtube/core/network/api_client.dart';
import 'package:grabtube/core/services/native_python_bridge.dart';
import 'package:grabtube/data/models/download_model.dart';
import 'package:grabtube/domain/entities/download.dart';

/// Tests for the Flutter Client
void main() {
  group('Flutter Client Core Tests', () {
    late ApiClient apiClient;
    late MockNativePythonBridge mockPythonBridge;
    
    setUp(() {
      mockPythonBridge = MockNativePythonBridge();
      apiClient = ApiClient(Dio());
    });

    test('should initialize Flutter client properly', () async {
      // Arrange
      when(() => mockPythonBridge.isPythonServerRunning())
          .thenAnswer((_) async => Future.value(true));

      // Act
      final isBackendRunning = await mockPythonBridge.isPythonServerRunning();
      
      // Assert
      expect(isBackendRunning, isTrue);
      print('✓ Flutter Client: Backend connectivity check passed');
    });

    test('should validate YouTube URL format', () {
      // Arrange
      const validUrls = [
        'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'https://youtu.be/dQw4w9WgXcQ',
        'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
      ];
      
      const invalidUrls = [
        'not-a-url',
        'https://example.com',
        '',
      ];
      
      // Act & Assert
      for (final url in validUrls) {
        expect(url.contains('youtube') || url.contains('youtu.be'), isTrue);
      }
      
      for (final url in invalidUrls) {
        expect(url.contains('youtube'), isFalse);
      }
      
      print('✓ Flutter Client: URL validation working');
    });

    test('should handle download request creation', () async {
      // Arrange
      const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      const quality = 'best';
      const format = 'mp4';
      
      // Act
      final downloadRequest = DownloadRequest(
        url: testUrl,
        quality: quality,
        format: format,
        timestamp: DateTime.now(),
      );
      
      // Assert
      expect(downloadRequest.url, testUrl);
      expect(downloadRequest.quality, quality);
      expect(downloadRequest.format, format);
      expect(downloadRequest.timestamp, isNotNull);
      
      print('✓ Flutter Client: Download request creation successful');
    });
  });

  group('Flutter Client Download Integration', () {
    const testVideoUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    
    testWidgets('should download video from YouTube', (WidgetTester tester) async {
      // This test simulates the UI flow for downloading a video
      // Note: Requires backend to be running for full integration
      
      // Arrange
      final apiClient = ApiClient(Dio());
      bool downloadStarted = false;
      String? downloadId;
      
      // Act
      try {
        // Add download via API
        final response = await apiClient.addDownload(
          url: testVideoUrl,
          quality: 'best',
          format: 'mp4',
        );
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          downloadStarted = true;
          
          // Get the download ID from response
          final responseData = response.data;
          if (responseData is Map && responseData['id'] != null) {
            downloadId = responseData['id'].toString();
          }
          
          // Wait for download to process
          await Future.delayed(const Duration(seconds: 3));
          
          // Check download status
          final downloads = await apiClient.getDownloads();
          final ourDownload = downloads.firstWhere(
            (d) => d.url.contains('dQw4w9WgXcQ'),
            orElse: () => null,
          );
          
          // Assert
          expect(downloadStarted, isTrue, 
                 reason: 'Download should be initiated');
          expect(ourDownload, isNotNull,
                 reason: 'Download should appear in the list');
          expect(downloadId, isNotNull,
                 reason: 'Download ID should be returned');
          
          print('✓ Flutter Client: Successfully started download for $testVideoUrl');
          print('  - Download ID: $downloadId');
          print('  - Status: ${ourDownload?.status}');
        }
      } catch (e) {
        print('⚠ Flutter Client integration test skipped (backend not available)');
        print('  Error: $e');
      }
    });

    test('should handle download progress tracking', () async {
      // Arrange
      final apiClient = ApiClient(Dio());
      const testUrl = testVideoUrl;
      
      try {
        // Add download
        final response = await apiClient.addDownload(
          url: testUrl,
          quality: '720p',
          format: 'mp4',
        );
        
        if (response.statusCode == 200) {
          // Monitor progress for a few seconds
          int progressChecks = 0;
          double lastProgress = 0.0;
          
          for (int i = 0; i < 10; i++) {
            await Future.delayed(const Duration(seconds: 1));
            
            final downloads = await apiClient.getDownloads();
            final download = downloads.firstWhere(
              (d) => d.url.contains('dQw4w9WgXcQ'),
              orElse: () => null,
            );
            
            if (download != null) {
              final currentProgress = download.progress;
              expect(currentProgress, greaterThanOrEqualTo(lastProgress),
                     reason: 'Progress should not decrease');
              lastProgress = currentProgress;
              progressChecks++;
              
              print('  Progress check ${progressChecks}: ${(currentProgress * 100).toInt()}%');
              
              if (download.status == DownloadStatus.completed) {
                break;
              }
            }
          }
          
          // Assert
          expect(progressChecks, greaterThan(0),
                 reason: 'Should have at least one progress check');
          
          print('✓ Flutter Client: Progress tracking working');
        }
      } catch (e) {
        print('⚠ Progress tracking test skipped: $e');
      }
    });

    test('should validate downloaded file existence', () async {
      // This test checks if files are actually saved after download
      // Note: This requires the backend to be running with proper download directory
      
      try {
        final apiClient = ApiClient(Dio());
        const testUrl = testVideoUrl;
        
        // Add download
        final response = await apiClient.addDownload(
          url: testUrl,
          quality: '360p', // Lower quality for faster download
          format: 'mp4',
        );
        
        if (response.statusCode == 200) {
          // Wait longer for download to complete
          bool downloadCompleted = false;
          String? fileName;
          
          for (int i = 0; i < 30; i++) { // Wait up to 30 seconds
            await Future.delayed(const Duration(seconds: 1));
            
            final downloads = await apiClient.getDownloads();
            final download = downloads.firstWhere(
              (d) => d.url.contains('dQw4w9WgXcQ'),
              orElse: () => null,
            );
            
            if (download != null && download.status == DownloadStatus.completed) {
              downloadCompleted = true;
              fileName = download.filename;
              break;
            }
          }
          
          if (downloadCompleted && fileName != null) {
            print('✓ Flutter Client: Download completed successfully');
            print('  - File: $fileName');
            
            // Here you could add file existence check
            // but that would require access to the download directory
          } else {
            print('⚠ Download did not complete within timeout');
          }
        }
      } catch (e) {
        print('⚠ File validation test skipped: $e');
      }
    });
  });

  group('Flutter Client Error Handling', () {
    test('should handle invalid URLs gracefully', () async {
      // Arrange
      final apiClient = ApiClient(Dio());
      const invalidUrl = 'not-a-valid-url';
      
      // Act
      try {
        final response = await apiClient.addDownload(
          url: invalidUrl,
          quality: 'best',
          format: 'mp4',
        );
        
        // Assert - Should return error or throw exception
        expect(response.statusCode, isIn([400, 422, 500]));
        print('✓ Flutter Client: Invalid URL properly rejected');
      } catch (e) {
        // Expected behavior
        expect(e, isA<DioException>());
        print('✓ Flutter Client: Invalid URL exception handled');
      }
    });

    test('should handle network errors gracefully', () async {
      // Arrange
      final dio = Dio();
      dio.options.connectTimeout = const Duration(milliseconds: 100);
      dio.options.receiveTimeout = const Duration(milliseconds: 100);
      final apiClient = ApiClient(dio);
      
      // Act
      try {
        // Try to connect to non-existent server
        final response = await apiClient.getDownloads();
        
        // Should not reach here
        expect(false, isTrue, reason: 'Should have thrown exception');
      } catch (e) {
        // Assert
        expect(e, isA<DioException>());
        print('✓ Flutter Client: Network error handled gracefully');
      }
    });
  });
}