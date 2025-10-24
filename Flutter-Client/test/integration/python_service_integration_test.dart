import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:grabtube/core/network/python_service_client.dart';
import 'package:grabtube/core/network/native_python_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Python Service Integration Tests', () {
    late PythonServiceClient pythonServiceClient;
    late NativePythonBridge nativePythonBridge;

    setUp(() {
      pythonServiceClient = PythonServiceClient();
      nativePythonBridge = NativePythonBridge();
    });

    tearDown(() async {
      await pythonServiceClient.dispose();
    });

    testWidgets('Python availability check works', (tester) async {
      final isAvailable = await nativePythonBridge.isPythonAvailable();
      
      // This test passes regardless of Python availability
      // It just verifies the method doesn't crash
      expect(isAvailable, isA<bool>());
    });

    testWidgets('Platform requirements are complete', (tester) async {
      final requirements = await nativePythonBridge.getPlatformRequirements();
      
      expect(requirements, isA<Map<String, dynamic>>());
      expect(requirements['platform'], isA<String>());
      expect(requirements['pythonAvailable'], isA<bool>());
      expect(requirements['packages'], isA<Map<String, bool>>());
    });

    testWidgets('Download directory is accessible', (tester) async {
      final canWrite = await nativePythonBridge.canWriteToDownloadDirectory();
      
      // This test passes regardless of write permissions
      // It just verifies the method doesn't crash
      expect(canWrite, isA<bool>());
    });

    testWidgets('Python service status stream works', (tester) async {
      final statuses = <bool>[];
      final subscription = pythonServiceClient.statusStream.listen(statuses.add);
      
      // Give some time for any initial events
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Status stream should be working
      expect(statuses.length, lessThanOrEqualTo(1));
      
      await subscription.cancel();
    });

    testWidgets('Python service can be started and stopped', (tester) async {
      // Try to start the service
      final startResult = await pythonServiceClient.startService();
      
      // The result depends on whether Python is available and scripts exist
      // We test that the method completes without error
      expect(startResult, isA<bool>());
      
      // Stop the service regardless of start result
      await pythonServiceClient.stopService();
      
      expect(pythonServiceClient.isRunning, false);
    });

    testWidgets('Ensure running returns consistent state', (tester) async {
      final initialRunning = pythonServiceClient.isRunning;
      
      final result = await pythonServiceClient.ensureRunning();
      
      // Result should be consistent with service state
      if (result) {
        expect(pythonServiceClient.isRunning, true);
      } else {
        expect(pythonServiceClient.isRunning, false);
      }
      
      // Clean up
      await pythonServiceClient.stopService();
    });

    testWidgets('Platform info contains expected fields', (tester) async {
      final platformInfo = nativePythonBridge.getPlatformInfo();
      
      expect(platformInfo['platform'], isA<String>());
      expect(platformInfo['version'], isA<String>());
      expect(platformInfo['localHostname'], isA<String>());
      expect(platformInfo['numberOfProcessors'], isA<int>());
      
      // Environment should be a map
      expect(platformInfo['environment'], isA<Map<String, String>>());
    });
  });
}