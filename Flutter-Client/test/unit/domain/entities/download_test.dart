import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/download.dart';

void main() {
  group('Download Entity Tests', () {
    test('should create Download with all fields', () {
      final download = Download(
        id: '1',
        url: 'https://example.com/video',
        title: 'Test Video',
        status: DownloadStatus.downloading,
        thumbnail: 'https://example.com/thumb.jpg',
        quality: '1080',
        format: 'mp4',
        progress: 0.5,
        speed: '1.2 MB/s',
        eta: '5 minutes',
        fileSize: 1048576,
        downloadedSize: 524288,
      );

      expect(download.id, '1');
      expect(download.title, 'Test Video');
      expect(download.status, DownloadStatus.downloading);
      expect(download.progress, 0.5);
      expect(download.progressPercentage, 50);
    });

    test('should return correct status checks', () {
      final downloading = Download(
        id: '1',
        url: 'test',
        title: 'test',
        status: DownloadStatus.downloading,
      );

      expect(downloading.isActive, true);
      expect(downloading.isCompleted, false);
      expect(downloading.hasError, false);
      expect(downloading.isPending, false);

      final completed = Download(
        id: '2',
        url: 'test',
        title: 'test',
        status: DownloadStatus.completed,
      );

      expect(completed.isActive, false);
      expect(completed.isCompleted, true);
    });

    test('should create copy with updated fields', () {
      final original = Download(
        id: '1',
        url: 'test',
        title: 'test',
        status: DownloadStatus.pending,
        progress: 0.0,
      );

      final updated = original.copyWith(
        status: DownloadStatus.downloading,
        progress: 0.5,
      );

      expect(updated.id, original.id);
      expect(updated.status, DownloadStatus.downloading);
      expect(updated.progress, 0.5);
    });

    test('should calculate progress percentage correctly', () {
      final download = Download(
        id: '1',
        url: 'test',
        title: 'test',
        status: DownloadStatus.downloading,
        progress: 0.756,
      );

      expect(download.progressPercentage, 76);
    });

    test('should support equatable comparison', () {
      final download1 = Download(
        id: '1',
        url: 'test',
        title: 'test',
        status: DownloadStatus.pending,
      );

      final download2 = Download(
        id: '1',
        url: 'test',
        title: 'test',
        status: DownloadStatus.pending,
      );

      expect(download1, equals(download2));
    });
  });
}
