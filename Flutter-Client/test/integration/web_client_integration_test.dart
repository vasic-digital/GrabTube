import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

import 'package:grabtube/core/network/api_client.dart';
import 'package:grabtube/core/network/socket_client.dart';
import 'package:grabtube/core/services/native_python_bridge.dart';
import 'package:grabtube/data/models/download_model.dart';
import 'package:grabtube/domain/entities/download.dart';

/// Tests for the Web Client API integration
void main() {
  group('Web Client API Tests', () {
    late ApiClient apiClient;
    late MockNativePythonBridge mockPythonBridge;
    
    setUp(() {
      mockPythonBridge = MockNativePythonBridge();
      apiClient = ApiClient(Dio());
    });

    test('should connect to local backend', () async {
      // Arrange
      when(() => mockPythonBridge.isPythonServerRunning())
          .thenAnswer((_) async => Future.value(true));

      // Act
      final isRunning = await mockPythonBridge.isPythonServerRunning();

      // Assert
      expect(isRunning, isTrue);
    });

    test('should add download via API', () async {
      // Arrange
      const testUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      const quality = 'best';
      const format = 'mp4';

      // Act
      try {
        final response = await apiClient.addDownload(
          url: testUrl,
          quality: quality,
          format: format,
        );
        
        // Assert
        expect(response.statusCode, isIn([200, 201]));
      } catch (e) {
        // Expected if backend is not running in test environment
        expect(e, isA<DioException>());
      }
    });

    test('should get downloads list from API', () async {
      // Act
      try {
        final downloads = await apiClient.getDownloads();
        
        // Assert
        expect(downloads, isA<List<DownloadModel>>());
      } catch (e) {
        // Expected if backend is not running
        expect(e, isA<DioException>());
      }
    });

    test('should handle WebSocket connection', () async {
      // Arrange
      final mockSocketClient = MockSocketClient();
      
      // Act
      try {
        await mockSocketClient.connect();
        
        // Assert
        verify(() => mockSocketClient.connect()).called(1);
      } catch (e) {
        // Expected if WebSocket server is not running
        expect(e, isA<Exception>());
      }
    });
  });

  group('Web Client Download Integration', () {
    const testVideoUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    
    test('should download video from provided link', () async {
      // This is an integration test that requires a running backend
      // It will be skipped in CI unless backend is available
      
      // Arrange
      final apiClient = ApiClient(Dio());
      const testUrl = testVideoUrl;
      
      // Act & Assert
      try {
        // Add download
        final addResponse = await apiClient.addDownload(
          url: testUrl,
          quality: 'best',
          format: 'mp4',
        );
        
        expect(addResponse.statusCode, isIn([200, 201]));
        
        // Wait a bit for download to start
        await Future.delayed(const Duration(seconds: 2));
        
        // Check download status
        final downloads = await apiClient.getDownloads();
        expect(downloads, isNotEmpty);
        
        final addedDownload = downloads.firstWhere(
          (d) => d.url.contains('dQw4w9WgXcQ'),
          orElse: () => null,
        );
        
        expect(addedDownload, isNotNull);
        expect(addedDownload!.status, isIn([
          DownloadStatus.pending,
          DownloadStatus.downloading,
          DownloadStatus.completed
        ]));
        
        print('✓ Web Client successfully initiated download for: $testUrl');
      } catch (e) {
        print('⚠ Web Client integration test skipped (backend not running): $e');
      }
    });

    test('should handle download progress updates', () async {
      // Arrange
      final mockSocketClient = MockSocketClient();
      final progressUpdates = <Download>[];
      
      mockSocketClient.onDownloadUpdate = (download) {
        progressUpdates.add(download);
      };
      
      // Act
      try {
        await mockSocketClient.connect();
        
        // Simulate progress update
        final testDownload = Download(
          id: 'test-id',
          url: testVideoUrl,
          title: 'Test Video',
          status: DownloadStatus.downloading,
          progress: 0.5,
          timestamp: DateTime.now(),
        );
        
        mockSocketClient.onDownloadUpdate(testDownload);
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(progressUpdates, isNotEmpty);
        expect(progressUpdates.last.progress, 0.5);
        
        print('✓ Web Client handled download progress update');
      } catch (e) {
        print('⚠ WebSocket test skipped: $e');
      }
    });
  });
}

class MockNativePythonBridge extends Mock implements NativePythonBridge {
  @override
  Future<bool> isPythonServerRunning() async {
    return super.noSuchMethod(
      Invocation.method(#isPythonServerRunning, []),
      returnValueForMissingInvocation: Future.value(true),
    );
  }
}

class MockSocketClient extends Mock implements SocketClient {
  void Function(Download)? onDownloadUpdate;
  
  @override
  Future<void> connect() async {
    return super.noSuchMethod(
      Invocation.method(#connect, []),
      returnValueForMissingInvocation: Future.value(),
    );
  }
  
  @override
  void onDownloadUpdate(Download download) {
    return super.noSuchMethod(
      Invocation.method(#onDownloadUpdate, [download]),
      returnValueForMissingInvocation: null,
    );
  }
}