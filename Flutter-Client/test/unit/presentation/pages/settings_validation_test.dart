import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

/// Test suite for settings validation logic
/// Tests the validation function that would be extracted from settings_page.dart
void main() {
  group('Settings Validation Tests', () {
    group('Valid Settings', () {
      test('accepts complete valid settings with all fields', () {
        final settings = {
          'theme_mode': 'dark',
          'default_quality': 'best',
          'default_format': 'mp4',
          'auto_start_downloads': true,
          'show_thumbnails': true,
          'notifications_enabled': true,
          'compact_mode': false,
          'max_concurrent_downloads': 3,
          'connection_timeout': 30,
          'auto_retry_failed': true,
          'max_retry_attempts': 3,
          'wifi_only_downloads': false,
          'schedule_notifications_enabled': true,
          'default_schedule_time': '09:00',
          'show_completed_notification': true,
          'play_sound_on_complete': true,
          'vibrate_on_complete': true,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, true);
        expect(result.errors, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('accepts settings with light theme mode', () {
        final settings = {
          'theme_mode': 'light',
          'max_concurrent_downloads': 1,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, true);
        expect(result.warnings, isNotEmpty); // Missing optional fields
      });

      test('accepts settings with system theme mode', () {
        final settings = {
          'theme_mode': 'system',
          'max_concurrent_downloads': 5,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, true);
      });

      test('accepts max_concurrent_downloads at boundary values', () {
        final settingsMin = {
          'theme_mode': 'dark',
          'max_concurrent_downloads': 1,
        };

        final settingsMax = {
          'theme_mode': 'dark',
          'max_concurrent_downloads': 10,
        };

        expect(_validateSettings(settingsMin).isValid, true);
        expect(_validateSettings(settingsMax).isValid, true);
      });
    });

    group('Invalid Settings - Type Errors', () {
      test('rejects theme_mode with wrong type', () {
        final settings = {
          'theme_mode': 123, // Should be String
          'max_concurrent_downloads': 3,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('Invalid type for theme_mode')),
        );
      });

      test('rejects max_concurrent_downloads with string type', () {
        final settings = {
          'theme_mode': 'dark',
          'max_concurrent_downloads': '3', // Should be int
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('Invalid type for max_concurrent_downloads')),
        );
      });

      test('rejects boolean fields with wrong types', () {
        final settings = {
          'theme_mode': 'dark',
          'auto_start_downloads': 'true', // Should be bool
          'notifications_enabled': 1, // Should be bool
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(result.errors.length, greaterThanOrEqualTo(2));
      });
    });

    group('Invalid Settings - Value Errors', () {
      test('rejects invalid theme_mode value', () {
        final settings = {
          'theme_mode': 'invalid',
          'max_concurrent_downloads': 3,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('Invalid theme_mode')),
        );
      });

      test('rejects max_concurrent_downloads below minimum', () {
        final settings = {
          'theme_mode': 'dark',
          'max_concurrent_downloads': 0,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('max_concurrent_downloads must be between 1 and 10')),
        );
      });

      test('rejects max_concurrent_downloads above maximum', () {
        final settings = {
          'theme_mode': 'dark',
          'max_concurrent_downloads': 11,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('max_concurrent_downloads must be between 1 and 10')),
        );
      });

      test('rejects connection_timeout below minimum', () {
        final settings = {
          'theme_mode': 'dark',
          'connection_timeout': 4, // Below 5 second minimum
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('connection_timeout must be between 5 and 120')),
        );
      });

      test('rejects connection_timeout above maximum', () {
        final settings = {
          'theme_mode': 'dark',
          'connection_timeout': 121, // Above 120 second maximum
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('connection_timeout must be between 5 and 120')),
        );
      });

      test('rejects max_retry_attempts out of range', () {
        final settings = {
          'theme_mode': 'dark',
          'max_retry_attempts': 0, // Below minimum
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(
          result.errors,
          contains(contains('max_retry_attempts must be between 1 and 10')),
        );
      });
    });

    group('Missing Fields', () {
      test('warns about missing optional fields', () {
        final settings = {
          'theme_mode': 'dark',
        };

        final result = _validateSettings(settings);

        expect(result.isValid, true); // Still valid, just warnings
        expect(result.warnings, isNotEmpty);
        expect(
          result.warnings,
          contains(contains('Missing key: max_concurrent_downloads')),
        );
      });

      test('warns about all missing optional fields', () {
        final settings = <String, dynamic>{};

        final result = _validateSettings(settings);

        expect(result.warnings.length, greaterThan(10));
      });
    });

    group('JSON Parsing', () {
      test('parses valid JSON string', () {
        final jsonString = json.encode({
          'theme_mode': 'dark',
          'max_concurrent_downloads': 3,
          'notifications_enabled': true,
        });

        final parsed = json.decode(jsonString) as Map<String, dynamic>;
        final result = _validateSettings(parsed);

        expect(result.isValid, true);
      });

      test('handles JSON with nested structures gracefully', () {
        final settings = {
          'theme_mode': 'dark',
          'nested': {'invalid': 'structure'}, // Should be ignored or flagged
        };

        final result = _validateSettings(settings);

        // Should still validate known fields
        expect(result.warnings, contains(contains('Missing key')));
      });
    });

    group('Edge Cases', () {
      test('handles empty settings map', () {
        final settings = <String, dynamic>{};

        final result = _validateSettings(settings);

        expect(result.isValid, true); // No errors, just warnings
        expect(result.warnings, isNotEmpty);
      });

      test('handles null values in settings', () {
        final settings = {
          'theme_mode': null,
          'max_concurrent_downloads': null,
        };

        final result = _validateSettings(settings);

        // Null values should trigger type errors
        expect(result.isValid, false);
      });

      test('handles extremely large numbers', () {
        final settings = {
          'theme_mode': 'dark',
          'max_concurrent_downloads': 999999,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(result.errors, isNotEmpty);
      });

      test('handles negative numbers', () {
        final settings = {
          'theme_mode': 'dark',
          'max_concurrent_downloads': -5,
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(result.errors, isNotEmpty);
      });
    });

    group('Multiple Errors', () {
      test('reports multiple errors when settings have multiple issues', () {
        final settings = {
          'theme_mode': 'invalid',
          'max_concurrent_downloads': 100,
          'connection_timeout': 500,
          'auto_start_downloads': 'not a bool',
        };

        final result = _validateSettings(settings);

        expect(result.isValid, false);
        expect(result.errors.length, greaterThanOrEqualTo(3));
      });
    });

    group('Quality and Format Values', () {
      test('accepts standard quality values', () {
        final qualities = ['best', 'worst', '1080p', '720p', '480p', '360p'];

        for (final quality in qualities) {
          final settings = {
            'theme_mode': 'dark',
            'default_quality': quality,
          };

          final result = _validateSettings(settings);
          expect(result.isValid, true, reason: 'Failed for quality: $quality');
        }
      });

      test('accepts standard format values', () {
        final formats = ['mp4', 'webm', 'mp3', 'opus', 'm4a'];

        for (final format in formats) {
          final settings = {
            'theme_mode': 'dark',
            'default_format': format,
          };

          final result = _validateSettings(settings);
          expect(result.isValid, true, reason: 'Failed for format: $format');
        }
      });
    });

    group('Time Format Validation', () {
      test('accepts valid time format for default_schedule_time', () {
        final validTimes = ['00:00', '09:30', '12:00', '23:59'];

        for (final time in validTimes) {
          final settings = {
            'theme_mode': 'dark',
            'default_schedule_time': time,
          };

          final result = _validateSettings(settings);
          expect(result.isValid, true, reason: 'Failed for time: $time');
        }
      });

      test('rejects invalid time formats', () {
        final invalidTimes = ['25:00', '12:60', 'invalid', '9:30', '12:00 PM'];

        for (final time in invalidTimes) {
          final settings = {
            'theme_mode': 'dark',
            'default_schedule_time': time,
          };

          final result = _validateSettings(settings);
          expect(result.isValid, false, reason: 'Should reject time: $time');
        }
      });
    });
  });
}

/// Validation result class
class _ValidationResult {
  const _ValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.validSettings,
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> validSettings;
}

/// Validate imported settings structure and values
/// This mirrors the validation logic from settings_page.dart
_ValidationResult _validateSettings(Map<String, dynamic> settings) {
  final errors = <String>[];
  final warnings = <String>[];

  // Expected keys with their types
  final expectedKeys = {
    'theme_mode': String,
    'default_quality': String,
    'default_format': String,
    'auto_start_downloads': bool,
    'show_thumbnails': bool,
    'notifications_enabled': bool,
    'compact_mode': bool,
    'max_concurrent_downloads': int,
    'connection_timeout': int,
    'auto_retry_failed': bool,
    'max_retry_attempts': int,
    'wifi_only_downloads': bool,
    'schedule_notifications_enabled': bool,
    'default_schedule_time': String,
    'show_completed_notification': bool,
    'play_sound_on_complete': bool,
    'vibrate_on_complete': bool,
  };

  // Check for required keys and validate types
  for (final entry in expectedKeys.entries) {
    if (!settings.containsKey(entry.key)) {
      warnings.add('Missing key: ${entry.key}');
      continue;
    }

    // Validate type
    final value = settings[entry.key];
    if (value == null || value.runtimeType != entry.value) {
      errors.add(
          'Invalid type for ${entry.key}: expected ${entry.value}, got ${value.runtimeType}');
    }
  }

  // Validate specific values
  if (settings.containsKey('theme_mode')) {
    final themeMode = settings['theme_mode'];
    if (themeMode is String &&
        !['light', 'dark', 'system'].contains(themeMode)) {
      errors.add('Invalid theme_mode: $themeMode');
    }
  }

  if (settings.containsKey('max_concurrent_downloads')) {
    final maxDownloads = settings['max_concurrent_downloads'];
    if (maxDownloads is int && (maxDownloads < 1 || maxDownloads > 10)) {
      errors.add('max_concurrent_downloads must be between 1 and 10');
    }
  }

  if (settings.containsKey('connection_timeout')) {
    final timeout = settings['connection_timeout'];
    if (timeout is int && (timeout < 5 || timeout > 120)) {
      errors.add('connection_timeout must be between 5 and 120');
    }
  }

  if (settings.containsKey('max_retry_attempts')) {
    final retries = settings['max_retry_attempts'];
    if (retries is int && (retries < 1 || retries > 10)) {
      errors.add('max_retry_attempts must be between 1 and 10');
    }
  }

  if (settings.containsKey('default_schedule_time')) {
    final time = settings['default_schedule_time'];
    if (time is String) {
      final timeRegex = RegExp(r'^([01][0-9]|2[0-3]):[0-5][0-9]$');
      if (!timeRegex.hasMatch(time)) {
        errors.add('Invalid time format for default_schedule_time: $time');
      }
    }
  }

  return _ValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: warnings,
    validSettings: errors.isEmpty ? settings : {},
  );
}
