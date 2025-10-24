import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/search_parameters.dart';

void main() {
  group('SearchParameters Tests', () {
    test('should create SearchParameters with default values', () {
      final params = SearchParameters();

      expect(params.query, isNull);
      expect(params.favoritesOnly, isFalse);
      expect(params.status, isNull);
      expect(params.quality, isNull);
      expect(params.format, isNull);
      expect(params.extractor, isNull);
      expect(params.uploader, isNull);
      expect(params.minDuration, isNull);
      expect(params.maxDuration, isNull);
      expect(params.minViews, isNull);
      expect(params.maxViews, isNull);
      expect(params.minLikes, isNull);
      expect(params.maxLikes, isNull);
      expect(params.dateFrom, isNull);
      expect(params.dateTo, isNull);
      expect(params.sortBy, 'title');
      expect(params.sortOrder, 'asc');
      expect(params.page, 1);
      expect(params.pageSize, 20);
    });

    test('should create SearchParameters with custom values', () {
      final dateFrom = DateTime(2023, 1, 1);
      final dateTo = DateTime(2023, 12, 31);

      final params = SearchParameters(
        query: 'test query',
        favoritesOnly: true,
        status: ['completed', 'failed'],
        quality: ['1080p', '720p'],
        format: ['mp4', 'webm'],
        extractor: ['youtube'],
        uploader: ['TestChannel'],
        minDuration: 60,
        maxDuration: 3600,
        minViews: 1000,
        maxViews: 100000,
        minLikes: 100,
        maxLikes: 10000,
        dateFrom: dateFrom,
        dateTo: dateTo,
        sortBy: 'date',
        sortOrder: 'desc',
        page: 2,
        pageSize: 50,
      );

      expect(params.query, 'test query');
      expect(params.favoritesOnly, isTrue);
      expect(params.status, ['completed', 'failed']);
      expect(params.quality, ['1080p', '720p']);
      expect(params.format, ['mp4', 'webm']);
      expect(params.extractor, ['youtube']);
      expect(params.uploader, ['TestChannel']);
      expect(params.minDuration, 60);
      expect(params.maxDuration, 3600);
      expect(params.minViews, 1000);
      expect(params.maxViews, 100000);
      expect(params.minLikes, 100);
      expect(params.maxLikes, 10000);
      expect(params.dateFrom, dateFrom);
      expect(params.dateTo, dateTo);
      expect(params.sortBy, 'date');
      expect(params.sortOrder, 'desc');
      expect(params.page, 2);
      expect(params.pageSize, 50);
    });

    test('should create copy with updated fields', () {
      final original = SearchParameters(
        query: 'original',
        favoritesOnly: false,
        sortBy: 'title',
      );

      final updated = original.copyWith(
        query: 'updated',
        favoritesOnly: true,
        sortBy: 'date',
      );

      expect(updated.query, 'updated');
      expect(updated.favoritesOnly, isTrue);
      expect(updated.sortBy, 'date');
      expect(updated.status, original.status); // unchanged
    });

    test('should support equatable comparison', () {
      final params1 = SearchParameters(
        query: 'test',
        favoritesOnly: true,
        sortBy: 'date',
      );

      final params2 = SearchParameters(
        query: 'test',
        favoritesOnly: true,
        sortBy: 'date',
      );

      final params3 = SearchParameters(
        query: 'different',
        favoritesOnly: true,
        sortBy: 'date',
      );

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should validate date range', () {
      final dateFrom = DateTime(2023, 1, 1);
      final dateTo = DateTime(2023, 12, 31);

      final params = SearchParameters(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      expect(params.dateFrom, dateFrom);
      expect(params.dateTo, dateTo);
    });

    test('should handle null date range', () {
      final params = SearchParameters();

      expect(params.dateFrom, isNull);
      expect(params.dateTo, isNull);
    });
  });
}