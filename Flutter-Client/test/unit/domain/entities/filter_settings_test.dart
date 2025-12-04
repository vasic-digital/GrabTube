import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/filter_settings.dart';

void main() {
  group('FilterSettings Tests', () {
    test('should create filter settings with defaults', () {
      const settings = FilterSettings();
      
      expect(settings.category, equals(FilterCategory.all));
      expect(settings.duration, equals(DurationFilter.any));
      expect(settings.quality, equals(QualityFilter.any));
      expect(settings.dateRange, equals(DateRangeFilter.any));
      expect(settings.sortBy, equals(SortBy.relevance));
    });

    test('should create filter settings with custom values', () {
      const settings = FilterSettings(
        category: FilterCategory.video,
        duration: DurationFilter.medium,
        quality: QualityFilter.hd,
        dateRange: DateRangeFilter.week,
        sortBy: SortBy.viewCount,
      );
      
      expect(settings.category, equals(FilterCategory.video));
      expect(settings.duration, equals(DurationFilter.medium));
      expect(settings.quality, equals(QualityFilter.hd));
      expect(settings.dateRange, equals(DateRangeFilter.week));
      expect(settings.sortBy, equals(SortBy.viewCount));
    });

    test('should copy with updated fields', () {
      const original = FilterSettings();
      final updated = original.copyWith(
        category: FilterCategory.video,
        quality: QualityFilter.hd4k,
      );
      
      expect(updated.category, equals(FilterCategory.video));
      expect(updated.quality, equals(QualityFilter.hd4k));
      expect(updated.duration, equals(original.duration));
      expect(updated.dateRange, equals(original.dateRange));
      expect(updated.sortBy, equals(original.sortBy));
    });

    test('should have correct props', () {
      const settings = FilterSettings(
        category: FilterCategory.audio,
        duration: DurationFilter.short,
      );
      
      expect(settings.props, containsAll([
        FilterCategory.audio,
        DurationFilter.short,
        QualityFilter.any,
        DateRangeFilter.any,
        SortBy.relevance,
      ]));
    });

    test('should compare equal when all fields match', () {
      const settings1 = FilterSettings(
        category: FilterCategory.video,
        duration: DurationFilter.long,
      );
      
      const settings2 = FilterSettings(
        category: FilterCategory.video,
        duration: DurationFilter.long,
      );
      
      expect(settings1, equals(settings2));
    });

    test('should compare different when fields differ', () {
      const settings1 = FilterSettings(
        category: FilterCategory.video,
        duration: DurationFilter.long,
      );
      
      const settings2 = FilterSettings(
        category: FilterCategory.audio,
        duration: DurationFilter.long,
      );
      
      expect(settings1, isNot(equals(settings2)));
    });

    test('toString should contain all field values', () {
      const settings = FilterSettings(
        category: FilterCategory.playlist,
        quality: QualityFilter.hd4k,
      );
      
      final str = settings.toString();
      expect(str, contains('FilterSettings'));
      expect(str, contains('category: FilterCategory.playlist'));
      expect(str, contains('quality: QualityFilter.hd4k'));
    });
  });

  group('Enum Tests', () {
    test('FilterCategory enum values should be correct', () {
      expect(FilterCategory.all.toString(), 'FilterCategory.all');
      expect(FilterCategory.video.toString(), 'FilterCategory.video');
      expect(FilterCategory.audio.toString(), 'FilterCategory.audio');
      expect(FilterCategory.playlist.toString(), 'FilterCategory.playlist');
    });

    test('DurationFilter enum values should be correct', () {
      expect(DurationFilter.any.toString(), 'DurationFilter.any');
      expect(DurationFilter.short.toString(), 'DurationFilter.short');
      expect(DurationFilter.medium.toString(), 'DurationFilter.medium');
      expect(DurationFilter.long.toString(), 'DurationFilter.long');
    });

    test('QualityFilter enum values should be correct', () {
      expect(QualityFilter.any.toString(), 'QualityFilter.any');
      expect(QualityFilter.low.toString(), 'QualityFilter.low');
      expect(QualityFilter.medium.toString(), 'QualityFilter.medium');
      expect(QualityFilter.high.toString(), 'QualityFilter.high');
      expect(QualityFilter.hd.toString(), 'QualityFilter.hd');
      expect(QualityFilter.hd4k.toString(), 'QualityFilter.hd4k');
    });

    test('DateRangeFilter enum values should be correct', () {
      expect(DateRangeFilter.any.toString(), 'DateRangeFilter.any');
      expect(DateRangeFilter.today.toString(), 'DateRangeFilter.today');
      expect(DateRangeFilter.week.toString(), 'DateRangeFilter.week');
      expect(DateRangeFilter.month.toString(), 'DateRangeFilter.month');
      expect(DateRangeFilter.year.toString(), 'DateRangeFilter.year');
    });

    test('SortBy enum values should be correct', () {
      expect(SortBy.relevance.toString(), 'SortBy.relevance');
      expect(SortBy.rating.toString(), 'SortBy.rating');
      expect(SortBy.uploadDate.toString(), 'SortBy.uploadDate');
      expect(SortBy.viewCount.toString(), 'SortBy.viewCount');
      expect(SortBy.title.toString(), 'SortBy.title');
    });
  });
}