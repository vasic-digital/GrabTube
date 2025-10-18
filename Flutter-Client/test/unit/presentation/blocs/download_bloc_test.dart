import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grabtube/domain/entities/download.dart';
import 'package:grabtube/domain/repositories/download_repository.dart';
import 'package:grabtube/presentation/blocs/download/download_bloc.dart';
import 'package:grabtube/presentation/blocs/download/download_event.dart';
import 'package:grabtube/presentation/blocs/download/download_state.dart';

class MockDownloadRepository extends Mock implements DownloadRepository {}

void main() {
  late MockDownloadRepository mockRepository;
  late DownloadBloc downloadBloc;

  setUp(() {
    mockRepository = MockDownloadRepository();
    downloadBloc = DownloadBloc(mockRepository);

    // Setup default stream responses
    when(() => mockRepository.downloadUpdates).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockRepository.newDownloads).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockRepository.completedDownloads).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockRepository.canceledDownloads).thenAnswer(
      (_) => const Stream.empty(),
    );
    when(() => mockRepository.connectionStatus).thenAnswer(
      (_) => Stream.value(true),
    );
  });

  tearDown(() {
    downloadBloc.close();
  });

  group('DownloadBloc Tests', () {
    final testDownload = Download(
      id: '1',
      url: 'https://youtube.com/watch?v=test',
      title: 'Test Video',
      status: DownloadStatus.downloading,
      progress: 0.5,
    );

    blocTest<DownloadBloc, DownloadState>(
      'emits DownloadsLoaded when LoadDownloads succeeds',
      build: () {
        when(() => mockRepository.getQueue())
            .thenAnswer((_) async => [testDownload]);
        when(() => mockRepository.getCompleted())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getPending())
            .thenAnswer((_) async => []);
        return downloadBloc;
      },
      act: (bloc) => bloc.add(const LoadDownloads()),
      expect: () => [
        const DownloadLoading(),
        isA<DownloadsLoaded>()
            .having((state) => state.queue.length, 'queue length', 1)
            .having((state) => state.completed.length, 'completed length', 0)
            .having((state) => state.pending.length, 'pending length', 0),
      ],
      verify: (_) {
        verify(() => mockRepository.getQueue()).called(1);
        verify(() => mockRepository.getCompleted()).called(1);
        verify(() => mockRepository.getPending()).called(1);
      },
    );

    blocTest<DownloadBloc, DownloadState>(
      'emits DownloadError when LoadDownloads fails',
      build: () {
        when(() => mockRepository.getQueue())
            .thenThrow(Exception('Network error'));
        when(() => mockRepository.getCompleted())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getPending())
            .thenAnswer((_) async => []);
        return downloadBloc;
      },
      act: (bloc) => bloc.add(const LoadDownloads()),
      expect: () => [
        const DownloadLoading(),
        isA<DownloadError>()
            .having((state) => state.message, 'error message',
                contains('Failed to load downloads')),
      ],
    );

    blocTest<DownloadBloc, DownloadState>(
      'emits success states when AddDownload succeeds',
      build: () {
        when(() => mockRepository.addDownload(
              url: any(named: 'url'),
              quality: any(named: 'quality'),
              format: any(named: 'format'),
              folder: any(named: 'folder'),
              autoStart: any(named: 'autoStart'),
            )).thenAnswer((_) async => testDownload);
        when(() => mockRepository.getQueue())
            .thenAnswer((_) async => [testDownload]);
        when(() => mockRepository.getCompleted())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getPending())
            .thenAnswer((_) async => []);
        return downloadBloc;
      },
      act: (bloc) => bloc.add(const AddDownload(
        url: 'https://youtube.com/watch?v=test',
        quality: '1080',
        format: 'mp4',
      )),
      expect: () => [
        const DownloadOperationInProgress(message: 'Adding download...'),
        const DownloadOperationSuccess(message: 'Download added to queue'),
        const DownloadLoading(),
        isA<DownloadsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.addDownload(
              url: 'https://youtube.com/watch?v=test',
              quality: '1080',
              format: 'mp4',
              folder: null,
              autoStart: null,
            )).called(1);
      },
    );

    blocTest<DownloadBloc, DownloadState>(
      'emits success states when DeleteDownloads succeeds',
      build: () {
        when(() => mockRepository.deleteDownload(
              ids: any(named: 'ids'),
              where: any(named: 'where'),
            )).thenAnswer((_) async => {});
        when(() => mockRepository.getQueue())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getCompleted())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getPending())
            .thenAnswer((_) async => []);
        return downloadBloc;
      },
      act: (bloc) => bloc.add(const DeleteDownloads(ids: ['1'])),
      expect: () => [
        const DownloadOperationInProgress(message: 'Deleting downloads...'),
        const DownloadOperationSuccess(message: 'Downloads deleted successfully'),
        const DownloadLoading(),
        isA<DownloadsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteDownload(
              ids: ['1'],
              where: 'queue',
            )).called(1);
      },
    );

    blocTest<DownloadBloc, DownloadState>(
      'emits success states when StartDownloads succeeds',
      build: () {
        when(() => mockRepository.startDownload(ids: any(named: 'ids')))
            .thenAnswer((_) async => {});
        when(() => mockRepository.getQueue())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getCompleted())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getPending())
            .thenAnswer((_) async => []);
        return downloadBloc;
      },
      act: (bloc) => bloc.add(const StartDownloads(ids: ['1'])),
      expect: () => [
        const DownloadOperationInProgress(message: 'Starting downloads...'),
        const DownloadOperationSuccess(message: 'Download started'),
        const DownloadLoading(),
        isA<DownloadsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.startDownload(ids: ['1'])).called(1);
      },
    );

    blocTest<DownloadBloc, DownloadState>(
      'emits success states when ClearCompleted succeeds',
      build: () {
        when(() => mockRepository.clearCompleted())
            .thenAnswer((_) async => {});
        when(() => mockRepository.getQueue())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getCompleted())
            .thenAnswer((_) async => []);
        when(() => mockRepository.getPending())
            .thenAnswer((_) async => []);
        return downloadBloc;
      },
      act: (bloc) => bloc.add(const ClearCompleted()),
      expect: () => [
        const DownloadOperationInProgress(
            message: 'Clearing completed downloads...'),
        const DownloadOperationSuccess(message: 'Completed downloads cleared'),
        const DownloadLoading(),
        isA<DownloadsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.clearCompleted()).called(1);
      },
    );
  });
}
