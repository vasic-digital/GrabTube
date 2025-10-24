import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;

import '../../core/utils/logger.dart';

/// Client for managing the embedded Python service
@singleton
class PythonServiceClient {
  Process? _pythonProcess;
  bool _isRunning = false;
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  /// Check if the Python service is running
  bool get isRunning => _isRunning;

  /// Stream of service status changes
  Stream<bool> get statusStream => _statusController.stream;

  /// Start the embedded Python service
  Future<bool> startService({int port = 8081}) async {
    try {
      if (_isRunning) {
        AppLogger.info('Python service is already running');
        return true;
      }

      AppLogger.info('Starting embedded Python service...');

      // Get Python script path
      final pythonScriptPath = await _getPythonScriptPath();
      final mainScript = path.join(pythonScriptPath, 'main.py');

      // Check if Python script exists
      final scriptFile = File(mainScript);
      if (!await scriptFile.exists()) {
        AppLogger.error('Python script not found: $mainScript');
        return false;
      }

      // Start Python process
      _pythonProcess = await Process.start(
        'python',
        [
          mainScript,
          '--port',
          port.toString(),
        ],
        runInShell: true,
      );

      // Listen to process output
      _pythonProcess!.stdout.transform(const Utf8Decoder()).listen((data) {
        AppLogger.info('Python Service: $data');
      });

      _pythonProcess!.stderr.transform(const Utf8Decoder()).listen((data) {
        AppLogger.error('Python Service Error: $data');
      });

      // Wait for process to start
      await Future.delayed(const Duration(seconds: 2));

      // Check if process is still running
      final exitCode = await _pythonProcess!.exitCode.timeout(
        const Duration(seconds: 1),
        onTimeout: () => null,
      );

      if (exitCode != null) {
        AppLogger.error('Python service failed to start. Exit code: $exitCode');
        return false;
      }

      _isRunning = true;
      _statusController.add(true);
      AppLogger.info('Embedded Python service started successfully');

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start Python service', e, stackTrace);
      return false;
    }
  }

  /// Stop the embedded Python service
  Future<void> stopService() async {
    try {
      if (_pythonProcess != null) {
        AppLogger.info('Stopping embedded Python service...');
        _pythonProcess!.kill();
        await _pythonProcess!.exitCode;
        _pythonProcess = null;
      }

      _isRunning = false;
      _statusController.add(false);
      AppLogger.info('Embedded Python service stopped');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to stop Python service', e, stackTrace);
    }
  }

  /// Ensure the service is running, start if not
  Future<bool> ensureRunning({int port = 8081}) async {
    if (_isRunning) {
      return true;
    }
    return await startService(port: port);
  }

  /// Get the path to Python scripts
  Future<String> _getPythonScriptPath() async {
    // For Flutter apps, Python scripts are bundled in the assets
    // For development, we can use the project directory
    final currentDir = Directory.current.path;
    final pythonDir = path.join(currentDir, 'python');
    
    // Check if Python directory exists
    final dir = Directory(pythonDir);
    if (await dir.exists()) {
      return pythonDir;
    }
    
    // Fallback: check in parent directory
    final parentPythonDir = path.join(currentDir, '..', 'python');
    final parentDir = Directory(parentPythonDir);
    if (await parentDir.exists()) {
      return parentPythonDir;
    }
    
    throw Exception('Python scripts directory not found');
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopService();
    await _statusController.close();
  }
}

/// Utf8Decoder for process output
class Utf8Decoder extends StreamTransformerBase<List<int>, String> {
  const Utf8Decoder();

  @override
  Stream<String> bind(Stream<List<int>> stream) {
    return stream.transform(const Utf8Codec().decoder);
  }
}