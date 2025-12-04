import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:grabtube/core/network/python_service_client.dart';

class MockProcess extends Mock implements Process {}
class MockStreamController<T> extends Mock implements StreamController<T> {}
class MockStream<T> extends Mock implements Stream<T> {}

void main() {
  group('PythonServiceClient Tests', () {
    late PythonServiceClient pythonServiceClient;
    late MockProcess mockProcess;

    setUp(() {
      pythonServiceClient = PythonServiceClient();
      mockProcess = MockProcess();
    });

    tearDown(() async {
      await pythonServiceClient.dispose();
    });

    test('initial state is not running', () {
      expect(pythonServiceClient.isRunning, false);
    });

    test('status stream provides status updates', () async {
      final statuses = <bool>[];
      final subscription = pythonServiceClient.statusStream.listen(statuses.add);
      
      // Initial state should not emit anything
      await Future.delayed(const Duration(milliseconds: 100));
      expect(statuses, isEmpty);
      
      await subscription.cancel();
    });

    test('stopService does nothing when not running', () async {
      await pythonServiceClient.stopService();
      expect(pythonServiceClient.isRunning, false);
    });

    test('ensureRunning returns false when service cannot start', () async {
      final result = await pythonServiceClient.ensureRunning();
      
      // In test environment without Python scripts, should return false
      expect(result, false);
    });

    test('dispose closes all resources', () async {
      await pythonServiceClient.dispose();
      
      expect(pythonServiceClient.isRunning, false);
    });

    test('startService fails when Python script not found', () async {
      final result = await pythonServiceClient.startService();
      
      // Should return false when Python script is not found
      expect(result, false);
      expect(pythonServiceClient.isRunning, false);
    });

    test('multiple stop calls are safe', () async {
      await pythonServiceClient.stopService();
      await pythonServiceClient.stopService();
      await pythonServiceClient.stopService();
      
      expect(pythonServiceClient.isRunning, false);
    });

    test('statusStream listener can be added and removed', () async {
      final listener1 = <bool>[];
      final listener2 = <bool>[];
      
      final subscription1 = pythonServiceClient.statusStream.listen(listener1.add);
      final subscription2 = pythonServiceClient.statusStream.listen(listener2.add);
      
      await Future.delayed(const Duration(milliseconds: 50));
      
      await subscription1.cancel();
      await subscription2.cancel();
      
      // Should not throw
      expect(listener1, isEmpty);
      expect(listener2, isEmpty);
    });

    test('service handles ensureRunning with port parameter', () async {
      final result = await pythonServiceClient.ensureRunning(port: 8082);
      
      expect(result, false);
      expect(pythonServiceClient.isRunning, false);
    });
  });
}