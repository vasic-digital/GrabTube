import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:grabtube/core/network/native_python_bridge.dart';

void main() {
  late NativePythonBridge nativePythonBridge;

  setUp(() {
    nativePythonBridge = NativePythonBridge();
  });

  group('NativePythonBridge Tests', () {
    test('getPlatformInfo returns valid platform information', () {
      final platformInfo = nativePythonBridge.getPlatformInfo();
      
      expect(platformInfo, isA<Map<String, dynamic>>());
      expect(platformInfo['platform'], isA<String>());
      expect(platformInfo['version'], isA<String>());
      expect(platformInfo['numberOfProcessors'], isA<int>());
    });

    test('getDownloadDirectory returns valid path for current platform', () {
      final downloadDir = nativePythonBridge.getDownloadDirectory();
      
      expect(downloadDir, isA<String>());
      expect(downloadDir, isNotEmpty);
      
      // Platform-specific path validation
      if (downloadDir.contains('Android')) {
        expect(downloadDir, contains('/storage/emulated/0/Download/GrabTube'));
      } else if (downloadDir.contains('Documents')) {
        expect(downloadDir, contains('Documents/GrabTube'));
      } else if (downloadDir.contains('USERPROFILE')) {
        expect(downloadDir, contains('Downloads\\GrabTube'));
      } else {
        expect(downloadDir, contains('Downloads/GrabTube'));
      }
    });

    test('isPythonAvailable returns boolean', () async {
      final result = await nativePythonBridge.isPythonAvailable();
      
      expect(result, isA<bool>());
    });

    test('getPythonExecutable returns string or null', () async {
      final result = await nativePythonBridge.getPythonExecutable();
      
      expect(result == null || result is String, isTrue);
    });

    test('getPlatformRequirements returns complete requirements map', () async {
      final requirements = await nativePythonBridge.getPlatformRequirements();
      
      expect(requirements, isA<Map<String, dynamic>>());
      expect(requirements['pythonAvailable'], isA<bool>());
      expect(requirements['pythonExecutable'], isA<String?>() || isNull);
      expect(requirements['platform'], isA<String>());
      expect(requirements['platformVersion'], isA<String>());
      expect(requirements['packages'], isA<Map<String, bool>>());
    });

    test('installPythonPackages returns boolean', () async {
      final result = await nativePythonBridge.installPythonPackages();
      
      expect(result, isA<bool>());
    });

    test('canWriteToDownloadDirectory returns boolean', () async {
      final result = await nativePythonBridge.canWriteToDownloadDirectory();
      
      expect(result, isA<bool>());
    });

    test('platform requirements contain all expected packages', () async {
      final requirements = await nativePythonBridge.getPlatformRequirements();
      final packages = requirements['packages'] as Map<String, bool>;
      
      expect(packages.containsKey('yt-dlp'), isTrue);
      expect(packages.containsKey('aiohttp'), isTrue);
      expect(packages.containsKey('socketio'), isTrue);
      expect(packages.containsKey('watchfiles'), isTrue);
      
      // All package values should be booleans
      for (final value in packages.values) {
        expect(value, isA<bool>());
      }
    });
  });
}