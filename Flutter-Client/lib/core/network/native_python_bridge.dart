import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../utils/logger.dart';

/// Platform-specific bridge for Python integration
/// This provides different implementations for different platforms
@singleton
class NativePythonBridge {
  /// Check if Python is available on the current platform
  Future<bool> isPythonAvailable() async {
    try {
      if (Platform.isWindows) {
        // On Windows, try both 'python' and 'python3'
        final result1 = await Process.run('python', ['--version']);
        if (result1.exitCode == 0) return true;
        
        final result2 = await Process.run('python3', ['--version']);
        return result2.exitCode == 0;
      } else {
        // On Unix-like systems, try 'python3'
        final result = await Process.run('python3', ['--version']);
        return result.exitCode == 0;
      }
    } catch (e) {
      AppLogger.error('Failed to check Python availability: $e');
      return false;
    }
  }

  /// Get the Python executable path
  Future<String?> getPythonExecutable() async {
    try {
      if (Platform.isWindows) {
        // Try 'python' first, then 'python3'
        final result1 = await Process.run('where', ['python']);
        if (result1.exitCode == 0) {
          return result1.stdout.toString().split('\n').first.trim();
        }
        
        final result2 = await Process.run('where', ['python3']);
        if (result2.exitCode == 0) {
          return result2.stdout.toString().split('\n').first.trim();
        }
      } else {
        // Unix-like systems
        final result = await Process.run('which', ['python3']);
        if (result.exitCode == 0) {
          return result.stdout.toString().trim();
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.error('Failed to get Python executable: $e');
      return null;
    }
  }

  /// Get the platform-specific Python requirements
  Future<Map<String, dynamic>> getPlatformRequirements() async {
    final requirements = <String, dynamic>{
      'pythonAvailable': await isPythonAvailable(),
      'pythonExecutable': await getPythonExecutable(),
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
    };

    // Check for required Python packages
    requirements['packages'] = await _checkPythonPackages();

    return requirements;
  }

  /// Check if required Python packages are installed
  Future<Map<String, bool>> _checkPythonPackages() async {
    final packages = {
      'yt-dlp': false,
      'aiohttp': false,
      'socketio': false,
      'watchfiles': false,
    };

    try {
      final pythonExecutable = await getPythonExecutable();
      if (pythonExecutable == null) return packages;

      for (final package in packages.keys) {
        final result = await Process.run(
          pythonExecutable,
          ['-c', 'import $package; print("OK")'],
        );
        packages[package] = result.exitCode == 0;
      }
    } catch (e) {
      AppLogger.error('Failed to check Python packages: $e');
    }

    return packages;
  }

  /// Install required Python packages
  Future<bool> installPythonPackages() async {
    try {
      final pythonExecutable = await getPythonExecutable();
      if (pythonExecutable == null) {
        AppLogger.error('Python executable not found');
        return false;
      }

      AppLogger.info('Installing required Python packages...');

      // Install packages using pip
      final packages = [
        'yt-dlp',
        'aiohttp',
        'python-socketio[asyncio_client]',
        'watchfiles',
      ];

      for (final package in packages) {
        AppLogger.info('Installing $package...');
        final result = await Process.run(
          pythonExecutable,
          ['-m', 'pip', 'install', package],
        );

        if (result.exitCode != 0) {
          AppLogger.error('Failed to install $package: ${result.stderr}');
          return false;
        }
      }

      AppLogger.info('All Python packages installed successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to install Python packages', e, stackTrace);
      return false;
    }
  }

  /// Get platform-specific download directory
  String getDownloadDirectory() {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/GrabTube';
    } else if (Platform.isIOS) {
      return 'Documents/GrabTube';
    } else if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Downloads\\GrabTube';
    } else {
      // Linux, macOS, etc.
      return '${Platform.environment['HOME']}/Downloads/GrabTube';
    }
  }

  /// Check if we can write to the download directory
  Future<bool> canWriteToDownloadDirectory() async {
    try {
      final downloadDir = Directory(getDownloadDirectory());
      
      // Try to create the directory
      await downloadDir.create(recursive: true);
      
      // Try to write a test file
      final testFile = File('${downloadDir.path}/test_write.txt');
      await testFile.writeAsString('test', flush: true);
      await testFile.delete();
      
      return true;
    } catch (e) {
      AppLogger.error('Cannot write to download directory: $e');
      return false;
    }
  }

  /// Get platform information for debugging
  Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': Platform.operatingSystem,
      'version': Platform.operatingSystemVersion,
      'localHostname': Platform.localHostname,
      'environment': Platform.environment,
      'executable': Platform.executable,
      'resolvedExecutable': Platform.resolvedExecutable,
      'script': Platform.script,
      'numberOfProcessors': Platform.numberOfProcessors,
    };
  }
}