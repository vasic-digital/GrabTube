import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/data/repositories/search_repository_impl.dart';
import 'package:grabtube/domain/entities/download.dart';
import 'package:grabtube/domain/entities/search_parameters.dart';
import 'package:grabtube/domain/entities/search_result.dart';
import 'package:grabtube/domain/repositories/download_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'search_repository_impl_test.mocks.dart';

@GenerateMocks([DownloadRepository])
void main() {
  late SearchRepositoryImpl searchRepository;
  late MockDownloadRepository mockDownloadRepository;

  setUp(() {
    mockDownloadRepository = MockDownloadRepository();
    searchRepository = SearchRepositoryImpl(mockDownloadRepository);
  });

  group('SearchRepositoryImpl Tests', () {
    final mockDownloads = [
      Download(
        id: '1',
        url: 'https://youtube.com/watch?v=123',
        title: 'Flutter Tutorial',
        status: DownloadStatus.completed,
        quality: '1080p',
        format: 'mp4',
        isFavorite: true,
      ),
      Download(
        id: '2',
        url: 'https://youtube.com/watch?v=456',
        title: 'Dart Programming',
        status: DownloadStatus.downloading,
        quality: '720p',
        format: 'webm',
        isFavorite: false,
      ),
      Download(
        id: '3',
        url: 'https://vimeo.com/789',
        title: 'UI Design Basics',
        status: DownloadStatus.failed,
        quality: '480p',
        format: 'mp4',
        isFavorite: true,
      ),
    ];

    test('should search downloads by query', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(query: 'flutter');
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 1);
      expect(result.downloads.first.title, 'Flutter Tutorial');
      expect(result.totalCount, 1);
    });

    test('should filter favorites only', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(favoritesOnly: true);
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 2);
      expect(result.downloads.every((d) => d.isFavorite), isTrue);
    });

    test('should filter by status', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(status: ['completed']);
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 1);
      expect(result.downloads.first.status, DownloadStatus.completed);
    });

    test('should filter by quality', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(quality: ['1080p']);
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 1);
      expect(result.downloads.first.quality, '1080p');
    });

    test('should filter by format', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(format: ['webm']);
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 1);
      expect(result.downloads.first.format, 'webm');
    });

    test('should combine multiple filters', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(
        query: 'tutorial',
        favoritesOnly: true,
        status: ['completed'],
      );
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 1);
      expect(result.downloads.first.title, 'Flutter Tutorial');
      expect(result.downloads.first.isFavorite, isTrue);
      expect(result.downloads.first.status, DownloadStatus.completed);
    });

    test('should sort by title ascending', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(sortBy: 'title', sortOrder: 'asc');
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 3);
      expect(result.downloads[0].title, 'Dart Programming');
      expect(result.downloads[1].title, 'Flutter Tutorial');
      expect(result.downloads[2].title, 'UI Design Basics');
    });

    test('should sort by title descending', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(sortBy: 'title', sortOrder: 'desc');
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 3);
      expect(result.downloads[0].title, 'UI Design Basics');
      expect(result.downloads[1].title, 'Flutter Tutorial');
      expect(result.downloads[2].title, 'Dart Programming');
    });

    test('should paginate results', () async {
      final manyDownloads = List.generate(
        10,
        (index) => Download(
          id: index.toString(),
          url: 'https://example.com/$index',
          title: 'Video $index',
          status: DownloadStatus.completed,
        ),
      );

      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => manyDownloads);

      final params = SearchParameters(page: 2, pageSize: 3);
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 3);
      expect(result.page, 2);
      expect(result.pageSize, 3);
      expect(result.hasMore, isTrue);
      expect(result.downloads.first.title, 'Video 3');
    });

    test('should handle empty results', () async {
      when(mockDownloadRepository.getAllDownloads())
          .thenAnswer((_) async => mockDownloads);

      final params = SearchParameters(query: 'nonexistent');
      final result = await searchRepository.searchDownloads(params);

      expect(result.downloads.length, 0);
      expect(result.totalCount, 0);
      expect(result.hasMore, isFalse);
    });

    test('should handle search history', () async {
      final params = SearchParameters(query: 'test query');
      await searchRepository.saveSearchHistory(params);

      final history = await searchRepository.getSearchHistory();
      expect(history.length, 1);
      expect(history.first.query, 'test query');
    });

    test('should limit search history to 10 items', () async {
      for (int i = 0; i < 15; i++) {
        final params = SearchParameters(query: 'query $i');
        await searchRepository.saveSearchHistory(params);
      }

      final history = await searchRepository.getSearchHistory();
      expect(history.length, 10);
      expect(history.first.query, 'query 14'); // Most recent first
    });

    test('should clear search history', () async {
      final params = SearchParameters(query: 'test');
      await searchRepository.saveSearchHistory(params);

      var history = await searchRepository.getSearchHistory();
      expect(history.length, 1);

      await searchRepository.clearSearchHistory();

      history = await searchRepository.getSearchHistory();
      expect(history.length, 0);
    });
  });
}