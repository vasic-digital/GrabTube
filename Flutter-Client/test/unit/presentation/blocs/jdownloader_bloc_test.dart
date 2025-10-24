import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grabtube/domain/entities/jdownloader_instance.dart';
import 'package:grabtube/domain/entities/speed_data_point.dart';
import 'package:grabtube/domain/repositories/jdownloader_repository.dart';
import 'package:grabtube/presentation/blocs/jdownloader/jdownloader_bloc.dart';
import 'package:grabtube/presentation/blocs/jdownloader/jdownloader_event.dart';
import 'package:grabtube/presentation/blocs/jdownloader/jdownloader_state.dart';

class MockJDownloaderRepository extends Mock implements JDownloaderRepository {}

void main() {
  late MockJDownloaderRepository mockRepository;
  late JDownloaderBloc jdownloaderBloc;

  setUp(() {
    mockRepository = MockJDownloaderRepository();
    jdownloaderBloc = JDownloaderBloc(mockRepository);

    // Setup default stream responses
    when(() => mockRepository.instanceUpdates).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockRepository.speedUpdates).thenAnswer(
      (_) => const Stream.empty(),
    );
  });

  tearDown(() {
    jdownloaderBloc.close();
  });

  group('JDownloaderBloc Tests', () {
    final testInstance = JDownloaderInstance(
      id: '1',
      name: 'Test JDownloader',
      deviceId: 'device123',
      status: JDownloaderStatus.online,
      downloadSpeed: 2048000,
      activeDownloads: 3,
    );

    final testSpeedData = SpeedDataPoint(
      timestamp: DateTime.now(),
      downloadSpeed: 1024000,
      uploadSpeed: 512000,
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'emits JDownloaderInstancesLoaded when LoadJDownloaderInstances succeeds',
      build: () {
        when(() => mockRepository.getInstances())
            .thenAnswer((_) async => [testInstance]);
        return jdownloaderBloc;
      },
      act: (bloc) => bloc.add(const LoadJDownloaderInstances()),
      expect: () => [
        const JDownloaderLoading(),
        isA<JDownloaderInstancesLoaded>()
            .having((state) => state.instances.length, 'instances length', 1)
            .having((state) => state.speedHistory.length, 'speed history length', 0),
      ],
      verify: (_) {
        verify(() => mockRepository.getInstances()).called(1);
      },
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'emits JDownloaderError when LoadJDownloaderInstances fails',
      build: () {
        when(() => mockRepository.getInstances())
            .thenThrow(Exception('Network error'));
        return jdownloaderBloc;
      },
      act: (bloc) => bloc.add(const LoadJDownloaderInstances()),
      expect: () => [
        const JDownloaderLoading(),
        isA<JDownloaderError>()
            .having((state) => state.message, 'error message',
                contains('Failed to load instances')),
      ],
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'emits success states when AddJDownloaderInstance succeeds',
      build: () {
        when(() => mockRepository.addInstance(
              name: any(named: 'name'),
              deviceId: any(named: 'deviceId'),
              host: any(named: 'host'),
              port: any(named: 'port'),
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testInstance);
        when(() => mockRepository.getInstances())
            .thenAnswer((_) async => [testInstance]);
        return jdownloaderBloc;
      },
      act: (bloc) => bloc.add(const AddJDownloaderInstance(
        name: 'Test JDownloader',
        deviceId: 'device123',
      )),
      expect: () => [
        const JDownloaderOperationInProgress(message: 'Adding JDownloader instance...'),
        const JDownloaderOperationSuccess(message: 'JDownloader instance added successfully'),
        const JDownloaderLoading(),
        isA<JDownloaderInstancesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.addInstance(
              name: 'Test JDownloader',
              deviceId: 'device123',
              host: null,
              port: null,
              username: null,
              password: null,
            )).called(1);
      },
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'emits success states when ConnectJDownloaderInstance succeeds',
      build: () {
        when(() => mockRepository.connectInstance(any()))
            .thenAnswer((_) async => testInstance);
        when(() => mockRepository.getInstances())
            .thenAnswer((_) async => [testInstance]);
        return jdownloaderBloc;
      },
      act: (bloc) => bloc.add(const ConnectJDownloaderInstance(instanceId: '1')),
      expect: () => [
        const JDownloaderOperationInProgress(message: 'Connecting to JDownloader instance...'),
        const JDownloaderOperationSuccess(message: 'Connected to JDownloader instance successfully'),
        const JDownloaderLoading(),
        isA<JDownloaderInstancesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.connectInstance('1')).called(1);
      },
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'emits success states when PauseJDownloaderInstance succeeds',
      build: () {
        when(() => mockRepository.pauseInstance(any()))
            .thenAnswer((_) async => {});
        when(() => mockRepository.getInstances())
            .thenAnswer((_) async => [testInstance]);
        return jdownloaderBloc;
      },
      act: (bloc) => bloc.add(const PauseJDownloaderInstance(instanceId: '1')),
      expect: () => [
        const JDownloaderOperationInProgress(message: 'Pausing downloads...'),
        const JDownloaderOperationSuccess(message: 'Downloads paused successfully'),
        const JDownloaderLoading(),
        isA<JDownloaderInstancesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.pauseInstance('1')).called(1);
      },
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'emits success states when ResumeJDownloaderInstance succeeds',
      build: () {
        when(() => mockRepository.resumeInstance(any()))
            .thenAnswer((_) async => {});
        when(() => mockRepository.getInstances())
            .thenAnswer((_) async => [testInstance]);
        return jdownloaderBloc;
      },
      act: (bloc) => bloc.add(const ResumeJDownloaderInstance(instanceId: '1')),
      expect: () => [
        const JDownloaderOperationInProgress(message: 'Resuming downloads...'),
        const JDownloaderOperationSuccess(message: 'Downloads resumed successfully'),
        const JDownloaderLoading(),
        isA<JDownloaderInstancesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.resumeInstance('1')).called(1);
      },
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'updates state when JDownloaderInstanceUpdated event is added',
      build: () => jdownloaderBloc,
      seed: () => JDownloaderInstancesLoaded(
        instances: [testInstance],
        speedHistory: [],
      ),
      act: (bloc) => bloc.add(JDownloaderInstanceUpdated(instance: testInstance.copyWith(status: JDownloaderStatus.downloading))),
      expect: () => [
        isA<JDownloaderInstancesLoaded>()
            .having((state) => state.instances.first.status, 'updated status', JDownloaderStatus.downloading),
      ],
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'updates speed history when JDownloaderSpeedUpdated event is added',
      build: () => jdownloaderBloc,
      seed: () => JDownloaderInstancesLoaded(
        instances: [testInstance],
        speedHistory: [],
      ),
      act: (bloc) => bloc.add(JDownloaderSpeedUpdated(dataPoint: testSpeedData)),
      expect: () => [
        isA<JDownloaderInstancesLoaded>()
            .having((state) => state.speedHistory.length, 'speed history length', 1)
            .having((state) => state.speedHistory.first, 'first speed data point', testSpeedData),
      ],
    );

    blocTest<JDownloaderBloc, JDownloaderState>(
      'emits JDownloaderError when operations fail',
      build: () {
        when(() => mockRepository.connectInstance(any()))
            .thenThrow(Exception('Connection failed'));
        return jdownloaderBloc;
      },
      act: (bloc) => bloc.add(const ConnectJDownloaderInstance(instanceId: '1')),
      expect: () => [
        const JDownloaderOperationInProgress(message: 'Connecting to JDownloader instance...'),
        isA<JDownloaderError>()
            .having((state) => state.message, 'error message',
                contains('Failed to connect')),
      ],
    );
  });
}