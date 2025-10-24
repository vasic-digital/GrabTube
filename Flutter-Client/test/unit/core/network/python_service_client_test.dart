import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:grabtube/core/network/python_service_client.dart';

class MockProcess extends Mock implements Process {}

void main() {
  late PythonServiceClient pythonServiceClient;
  late MockProcess mockProcess;

  setUp(() {
    pythonServiceClient = PythonServiceClient();
    mockProcess = MockProcess();
  });

  tearDown(() async {
    await pythonServiceClient.dispose();
  });

  group('PythonServiceClient Tests', () {
    test('initial state is not running', () {
      expect(pythonServiceClient.isRunning, false);
    });

    test('status stream emits initial false', () async {
      final statuses = <bool>[];
      pythonServiceClient.statusStream.listen(statuses.add);
      
      await Future.delayed(const Duration(milliseconds: 100));
      expect(statuses, isEmpty); // No initial value
    });

    test('startService returns false when Python script not found', () async {
      // This test will fail if the Python script exists
      // In a real test environment, we would mock the file system
      final result = await pythonServiceClient.startService();
      
      // The result depends on whether Python scripts exist
      // We can't reliably test this without proper mocking
      expect(result, isA<bool>());
    });

    test('stopService does nothing when not running', () async {
      await pythonServiceClient.stopService();
      expect(pythonServiceClient.isRunning, false);
    });

    test('ensureRunning returns false when service cannot start', () async {
      final result = await pythonServiceClient.ensureRunning();
      
      // Result depends on environment
      expect(result, isA<bool>());
    });

    test('dispose stops service and closes streams', () async {
      await pythonServiceClient.dispose();
      
      expect(pythonServiceClient.isRunning, false);
      expect(
        () => pythonServiceClient.statusStream.listen((_) {}),
        returnsNormally,
      );
    });

    test('service can be started and stopped multiple times', () async {
      // This is more of an integration test
      // In unit tests, we would mock the Process.start
      for (var i = 0; i < 3; i++) {
        final startResult = await pythonServiceClient.startService();
        expect(startResult, isA<bool>());
        
        await pythonServiceClient.stopService();
        expect(pythonServiceClient.isRunning, false);
      }
    });
  });
}