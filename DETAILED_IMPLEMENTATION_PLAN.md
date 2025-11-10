# GrabTube - Detailed Phased Implementation Plan

**Plan Date:** November 10, 2025
**Project:** GrabTube Multi-Platform Video Downloader
**Goal:** Achieve 100% completion with full test coverage, comprehensive documentation, and zero broken components
**Timeline:** 7-10 weeks (full-time equivalent)

---

## Table of Contents

1. [Phase 0: Preparation & Setup](#phase-0-preparation--setup)
2. [Phase 1: Core Feature Implementation](#phase-1-core-feature-implementation)
3. [Phase 2: Testing & Quality Assurance](#phase-2-testing--quality-assurance)
4. [Phase 3: Documentation](#phase-3-documentation)
5. [Phase 4: Website Development](#phase-4-website-development)
6. [Phase 5: Video Course Production](#phase-5-video-course-production)
7. [Phase 6: Final Polish & Release](#phase-6-final-polish--release)
8. [Appendix: Test Types Reference](#appendix-test-types-reference)

---

## Phase 0: Preparation & Setup

**Duration:** 1-2 days
**Goal:** Set up development environment and project structure
**Status:** Pre-implementation

### Task 0.1: Environment Verification

**Duration:** 2 hours

**Steps:**
1. Run environment verification script:
   ```bash
   ./verify-environment.sh
   ```

2. Verify all tools are installed:
   - ✅ Flutter SDK 3.24+
   - ✅ Dart SDK 3.5+
   - ✅ Python 3.13+ with uv
   - ✅ Node.js LTS
   - ✅ Android Studio with SDK 24+
   - ✅ Java 17+
   - ✅ Git

3. Install missing tools if needed

4. Configure IDE/Editor:
   - VS Code with Flutter/Dart extensions
   - Android Studio with Kotlin plugin
   - Configure linters and formatters

**Deliverable:** ✅ All development tools working

---

### Task 0.2: Create Missing Directories

**Duration:** 30 minutes

**Steps:**
1. Create Website directory structure:
   ```bash
   mkdir -p Website/{public/{css,js,assets/{images,videos,downloads}},src,docs}
   ```

2. Create missing lib directories:
   ```bash
   cd Flutter-Client/lib
   mkdir -p domain/usecases/{download,qr_scanner,search,schedule,jdownloader}
   mkdir -p presentation/blocs/{qr_scanner,search,favorites,schedule,jdownloader}
   mkdir -p presentation/pages
   ```

3. Create videos directory:
   ```bash
   mkdir -p videos/{user_tutorials,developer_courses,advanced_topics}
   ```

4. Initialize git tracking:
   ```bash
   git add .gitkeep files to preserve directory structure
   ```

**Deliverable:** ✅ Complete directory structure

---

### Task 0.3: Create Development Branches

**Duration:** 30 minutes

**Steps:**
1. Create feature branches:
   ```bash
   git checkout -b feature/advanced-features
   git checkout -b feature/android-docs
   git checkout -b feature/website
   git checkout -b feature/video-courses
   ```

2. Set up branch protection rules on main

3. Configure CI/CD to run on all feature branches

**Deliverable:** ✅ Git workflow ready

---

### Task 0.4: Update Project Documentation

**Duration:** 1 hour

**Steps:**
1. Update CLAUDE.md with new structure
2. Create CHANGELOG.md:
   ```bash
   touch CHANGELOG.md
   ```
3. Create CONTRIBUTING.md
4. Create SECURITY.md

**Deliverable:** ✅ Project documentation foundation

---

## Phase 1: Core Feature Implementation

**Duration:** 2-3 weeks
**Goal:** Implement all missing Flutter-Client advanced features
**Status:** Not started

---

### Stage 1.1: Domain Layer - Entities

**Duration:** 3-4 days
**Priority:** P0 - Critical

#### Task 1.1.1: Create Missing Entity Classes

**Duration:** 1 day (8 hours)

**Files to Create:**

1. **`domain/entities/qr_scan_result.dart`** (~80 lines)
   ```dart
   class QrScanResult extends Equatable {
     final String rawValue;
     final QrCodeType type;
     final DateTime scannedAt;
     final String? extractedUrl;
     final bool isValid;

     // Constructor, copyWith, props, etc.
   }
   ```

2. **`domain/entities/search_result.dart`** (~100 lines)
   ```dart
   class SearchResult extends Equatable {
     final String id;
     final String title;
     final String url;
     final String? thumbnailUrl;
     final Duration? duration;
     final String? channel;
     final DateTime? publishedAt;

     // Constructor, methods
   }
   ```

3. **`domain/entities/search_parameters.dart`** (~60 lines)
   ```dart
   class SearchParameters extends Equatable {
     final String query;
     final SearchType type;
     final SortOrder sortOrder;
     final int maxResults;
     final DateRange? dateRange;

     // Constructor, methods
   }
   ```

4. **`domain/entities/schedule.dart`** (~120 lines)
   ```dart
   class Schedule extends Equatable {
     final String id;
     final String name;
     final ScheduleType type;
     final DateTime startTime;
     final Duration? interval;
     final List<DayOfWeek>? daysOfWeek;
     final bool isActive;

     // Constructor, methods
   }
   ```

5. **`domain/entities/scheduled_download.dart`** (~100 lines)
   ```dart
   class ScheduledDownload extends Equatable {
     final String id;
     final String url;
     final String scheduleId;
     final String quality;
     final String format;
     final ScheduledDownloadStatus status;
     final DateTime? nextExecutionTime;

     // Constructor, methods
   }
   ```

6. **`domain/entities/jdownloader_instance.dart`** (~150 lines)
   ```dart
   class JDownloaderInstance extends Equatable {
     final String id;
     final String name;
     final String host;
     final int port;
     final ConnectionStatus status;
     final String? version;
     final List<JDownloaderDownload> downloads;

     // Constructor, methods
   }
   ```

7. **`domain/entities/speed_data_point.dart`** (~50 lines)
   ```dart
   class SpeedDataPoint extends Equatable {
     final DateTime timestamp;
     final double bytesPerSecond;
     final double mbpsSpeed;

     // Constructor, methods
   }
   ```

**Testing:**
- Each entity must have corresponding unit test
- Test all methods, equality, copyWith, serialization

**Checklist:**
- [ ] All 7 entity files created
- [ ] All entities extend Equatable
- [ ] All entities are immutable
- [ ] Unit tests created for each entity (in `test/unit/domain/entities/`)
- [ ] All tests pass
- [ ] Code reviewed

---

#### Task 1.1.2: Create Enums and Value Objects

**Duration:** 4 hours

**Files to Create:**

1. **`domain/entities/enums.dart`** (~200 lines)
   ```dart
   enum QrCodeType { url, text, vCard, wiFi, unknown }
   enum SearchType { videos, channels, playlists, all }
   enum SortOrder { relevance, date, viewCount, rating }
   enum ScheduleType { oneTime, daily, weekly, monthly, interval }
   enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }
   enum ScheduledDownloadStatus { pending, active, completed, failed, cancelled }
   enum ConnectionStatus { connected, disconnected, connecting, error }
   ```

**Checklist:**
- [ ] All enums created
- [ ] Extension methods added for string conversion
- [ ] Unit tests for enum conversions
- [ ] All tests pass

---

### Stage 1.2: Domain Layer - Repository Interfaces

**Duration:** 2 days
**Priority:** P0 - Critical

#### Task 1.2.1: Create Repository Interfaces

**Duration:** 1.5 days (12 hours)

**Files to Create:**

1. **`domain/repositories/qr_scanner_repository.dart`** (~80 lines)
   ```dart
   abstract class QrScannerRepository {
     Future<Either<Failure, QrScanResult>> scanQrCode();
     Future<Either<Failure, String>> extractUrlFromQr(String rawValue);
     Future<Either<Failure, bool>> validateQrUrl(String url);
     Stream<QrScanResult> get scanStream;
   }
   ```

2. **`domain/repositories/search_repository.dart`** (~100 lines)
   ```dart
   abstract class SearchRepository {
     Future<Either<Failure, List<SearchResult>>> search(SearchParameters params);
     Future<Either<Failure, List<SearchResult>>> getSearchHistory();
     Future<Either<Failure, void>> saveSearchHistory(SearchResult result);
     Future<Either<Failure, void>> clearSearchHistory();
   }
   ```

3. **`domain/repositories/favorites_repository.dart`** (~80 lines)
   ```dart
   abstract class FavoritesRepository {
     Future<Either<Failure, List<Download>>> getFavorites();
     Future<Either<Failure, void>> addFavorite(String downloadId);
     Future<Either<Failure, void>> removeFavorite(String downloadId);
     Future<Either<Failure, bool>> isFavorite(String downloadId);
   }
   ```

4. **`domain/repositories/schedule_repository.dart`** (~120 lines)
   ```dart
   abstract class ScheduleRepository {
     Future<Either<Failure, List<Schedule>>> getAllSchedules();
     Future<Either<Failure, Schedule>> getScheduleById(String id);
     Future<Either<Failure, void>> createSchedule(Schedule schedule);
     Future<Either<Failure, void>> updateSchedule(Schedule schedule);
     Future<Either<Failure, void>> deleteSchedule(String id);
     Future<Either<Failure, List<ScheduledDownload>>> getScheduledDownloads(String scheduleId);
     Stream<Schedule> get scheduleUpdates;
   }
   ```

5. **`domain/repositories/jdownloader_repository.dart`** (~150 lines)
   ```dart
   abstract class JDownloaderRepository {
     Future<Either<Failure, JDownloaderInstance>> connect(String host, int port);
     Future<Either<Failure, void>> disconnect();
     Future<Either<Failure, List<JDownloaderDownload>>> getDownloads();
     Future<Either<Failure, void>> addDownload(String url, String destinationFolder);
     Future<Either<Failure, void>> pauseDownload(String id);
     Future<Either<Failure, void>> resumeDownload(String id);
     Future<Either<Failure, ConnectionStatus>> getConnectionStatus();
     Stream<JDownloaderInstance> get instanceUpdates;
   }
   ```

**Checklist:**
- [ ] All 5 repository interfaces created
- [ ] All methods use Either<Failure, T> for error handling
- [ ] All async operations return Future
- [ ] Real-time updates use Stream
- [ ] Documentation comments added
- [ ] Code reviewed

---

### Stage 1.3: Domain Layer - Use Cases

**Duration:** 5-6 days
**Priority:** P0 - Critical

#### Task 1.3.1: Download Management Use Cases

**Duration:** 1.5 days (12 hours)

**Files to Create:**

1. **`domain/usecases/download/add_download_usecase.dart`** (~100 lines)
2. **`domain/usecases/download/cancel_download_usecase.dart`** (~80 lines)
3. **`domain/usecases/download/delete_download_usecase.dart`** (~80 lines)
4. **`domain/usecases/download/get_downloads_usecase.dart`** (~90 lines)
5. **`domain/usecases/download/get_download_history_usecase.dart`** (~90 lines)
6. **`domain/usecases/download/toggle_favorite_usecase.dart`** (~100 lines)

**Pattern for each use case:**
```dart
class AddDownloadUseCase implements UseCase<Download, AddDownloadParams> {
  final DownloadRepository repository;

  AddDownloadUseCase(this.repository);

  @override
  Future<Either<Failure, Download>> call(AddDownloadParams params) async {
    // Validate params
    // Call repository
    // Transform result
    return await repository.addDownload(
      url: params.url,
      quality: params.quality,
      format: params.format,
    );
  }
}

class AddDownloadParams extends Equatable {
  final String url;
  final String quality;
  final String format;
  // ...
}
```

**Testing:**
- Unit test for each use case
- Mock repository
- Test success and failure paths
- Test parameter validation

**Checklist:**
- [ ] All 6 use cases created
- [ ] Unit tests created (`test/unit/domain/usecases/download/`)
- [ ] All tests pass (100% coverage)
- [ ] Documentation added

---

#### Task 1.3.2: QR Scanner Use Cases

**Duration:** 1 day (8 hours)

**Files to Create:**

1. **`domain/usecases/qr_scanner/scan_qr_code_usecase.dart`** (~120 lines)
2. **`domain/usecases/qr_scanner/validate_qr_url_usecase.dart`** (~80 lines)
3. **`domain/usecases/qr_scanner/extract_url_from_qr_usecase.dart`** (~90 lines)

**Checklist:**
- [ ] All 3 use cases created
- [ ] Unit tests created
- [ ] Tests pass with 100% coverage
- [ ] Integration with mobile_scanner tested

---

#### Task 1.3.3: Search & Favorites Use Cases

**Duration:** 1 day (8 hours)

**Files to Create:**

1. **`domain/usecases/search/search_downloads_usecase.dart`** (~100 lines)
2. **`domain/usecases/search/get_search_history_usecase.dart`** (~80 lines)
3. **`domain/usecases/search/save_search_history_usecase.dart`** (~70 lines)
4. **`domain/usecases/search/clear_search_history_usecase.dart`** (~60 lines)
5. **`domain/usecases/favorites/add_favorite_usecase.dart`** (~80 lines)
6. **`domain/usecases/favorites/remove_favorite_usecase.dart`** (~80 lines)
7. **`domain/usecases/favorites/get_favorites_usecase.dart`** (~90 lines)
8. **`domain/usecases/favorites/is_favorite_usecase.dart`** (~70 lines)

**Checklist:**
- [ ] All 8 use cases created
- [ ] Unit tests created
- [ ] Tests pass with 100% coverage

---

#### Task 1.3.4: Scheduling Use Cases

**Duration:** 1.5 days (12 hours)

**Files to Create:**

1. **`domain/usecases/schedule/create_schedule_usecase.dart`** (~120 lines)
2. **`domain/usecases/schedule/update_schedule_usecase.dart`** (~110 lines)
3. **`domain/usecases/schedule/delete_schedule_usecase.dart`** (~80 lines)
4. **`domain/usecases/schedule/get_schedules_usecase.dart`** (~90 lines)
5. **`domain/usecases/schedule/get_schedule_by_id_usecase.dart`** (~90 lines)
6. **`domain/usecases/schedule/execute_scheduled_download_usecase.dart`** (~150 lines)

**Checklist:**
- [ ] All 6 use cases created
- [ ] Unit tests created
- [ ] Tests pass with 100% coverage
- [ ] WorkManager integration considered

---

#### Task 1.3.5: JDownloader Use Cases

**Duration:** 1.5 days (12 hours)

**Files to Create:**

1. **`domain/usecases/jdownloader/connect_jdownloader_usecase.dart`** (~120 lines)
2. **`domain/usecases/jdownloader/disconnect_jdownloader_usecase.dart`** (~80 lines)
3. **`domain/usecases/jdownloader/get_jdownloader_downloads_usecase.dart`** (~100 lines)
4. **`domain/usecases/jdownloader/add_jdownloader_download_usecase.dart`** (~120 lines)
5. **`domain/usecases/jdownloader/pause_jdownloader_download_usecase.dart`** (~90 lines)
6. **`domain/usecases/jdownloader/resume_jdownloader_download_usecase.dart`** (~90 lines)

**Checklist:**
- [ ] All 6 use cases created
- [ ] Unit tests created
- [ ] Tests pass with 100% coverage
- [ ] JDownloader API documented

---

### Stage 1.4: Data Layer - Models

**Duration:** 2 days
**Priority:** P0 - Critical

#### Task 1.4.1: Create Data Models with JSON Serialization

**Duration:** 2 days (16 hours)

**Files to Create:**

1. **`data/models/qr_scan_result_model.dart`** (~150 lines + generated)
2. **`data/models/search_result_model.dart`** (~180 lines + generated)
3. **`data/models/search_parameters_model.dart`** (~120 lines + generated)
4. **`data/models/schedule_model.dart`** (~200 lines + generated)
5. **`data/models/scheduled_download_model.dart`** (~180 lines + generated)
6. **`data/models/jdownloader_instance_model.dart`** (~250 lines + generated)
7. **`data/models/speed_data_point_model.dart`** (~100 lines + generated)

**Pattern for each model:**
```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/qr_scan_result.dart';

part 'qr_scan_result_model.g.dart';

@JsonSerializable()
class QrScanResultModel extends QrScanResult {
  const QrScanResultModel({
    required String rawValue,
    required QrCodeType type,
    required DateTime scannedAt,
    String? extractedUrl,
    required bool isValid,
  }) : super(
          rawValue: rawValue,
          type: type,
          scannedAt: scannedAt,
          extractedUrl: extractedUrl,
          isValid: isValid,
        );

  factory QrScanResultModel.fromJson(Map<String, dynamic> json) =>
      _$QrScanResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$QrScanResultModelToJson(this);

  factory QrScanResultModel.fromEntity(QrScanResult entity) {
    return QrScanResultModel(
      rawValue: entity.rawValue,
      type: entity.type,
      // ...
    );
  }
}
```

**Steps:**
1. Create all model files
2. Run code generation:
   ```bash
   cd Flutter-Client
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Verify `.g.dart` files are generated
4. Create unit tests for each model

**Testing:**
- Test JSON serialization/deserialization
- Test fromEntity/toEntity conversions
- Test edge cases (null values, invalid data)

**Checklist:**
- [ ] All 7 model files created
- [ ] Code generation successful
- [ ] Unit tests created (`test/unit/data/models/`)
- [ ] All tests pass (100% coverage)

---

### Stage 1.5: Data Layer - Repository Implementations

**Duration:** 4-5 days
**Priority:** P0 - Critical

#### Task 1.5.1: QR Scanner Repository Implementation

**Duration:** 1 day (8 hours)

**File:** `data/repositories/qr_scanner_repository_impl.dart` (~250 lines)

**Dependencies:**
- `mobile_scanner` package (already in pubspec.yaml)

**Implementation:**
```dart
class QrScannerRepositoryImpl implements QrScannerRepository {
  final MobileScannerController scannerController;
  final StreamController<QrScanResult> _scanStreamController;

  QrScannerRepositoryImpl({
    required this.scannerController,
  }) : _scanStreamController = StreamController.broadcast();

  @override
  Future<Either<Failure, QrScanResult>> scanQrCode() async {
    try {
      // Implement scanner logic
      final barcode = await scannerController.barcodes.first;
      final result = QrScanResultModel(/* ... */);
      _scanStreamController.add(result);
      return Right(result);
    } catch (e) {
      return Left(QrScannerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> extractUrlFromQr(String rawValue) async {
    // URL extraction logic
  }

  @override
  Future<Either<Failure, bool>> validateQrUrl(String url) async {
    // URL validation logic
  }

  @override
  Stream<QrScanResult> get scanStream => _scanStreamController.stream;

  void dispose() {
    _scanStreamController.close();
  }
}
```

**Testing:**
- Unit tests with mocked scanner controller
- Test all success/failure scenarios
- Test stream behavior

**Checklist:**
- [ ] Repository implemented
- [ ] Registered in DI (injection.dart)
- [ ] Unit tests created
- [ ] Tests pass (100% coverage)

---

#### Task 1.5.2: Search Repository Implementation

**Duration:** 1 day (8 hours)

**File:** `data/repositories/search_repository_impl.dart` (~200 lines)

**Dependencies:**
- `hive` for local storage (already in pubspec.yaml)
- Backend API for search

**Implementation:**
```dart
class SearchRepositoryImpl implements SearchRepository {
  final ApiClient apiClient;
  final Box<SearchResultModel> searchHistoryBox;

  SearchRepositoryImpl({
    required this.apiClient,
    required this.searchHistoryBox,
  });

  @override
  Future<Either<Failure, List<SearchResult>>> search(
    SearchParameters params,
  ) async {
    try {
      final response = await apiClient.search(
        query: params.query,
        type: params.type.toString(),
        sortOrder: params.sortOrder.toString(),
        maxResults: params.maxResults,
      );

      final results = response.data
          .map((json) => SearchResultModel.fromJson(json))
          .toList();

      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> getSearchHistory() async {
    try {
      final history = searchHistoryBox.values.toList();
      return Right(history);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchHistory(SearchResult result) async {
    try {
      final model = SearchResultModel.fromEntity(result);
      await searchHistoryBox.put(result.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearSearchHistory() async {
    try {
      await searchHistoryBox.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
```

**Checklist:**
- [ ] Repository implemented
- [ ] Hive box initialization added
- [ ] Registered in DI
- [ ] Unit tests created with mocked dependencies
- [ ] Tests pass (100% coverage)

---

#### Task 1.5.3: Favorites Repository Implementation

**Duration:** 0.5 days (4 hours)

**File:** `data/repositories/favorites_repository_impl.dart` (~150 lines)

**Implementation:** Similar to search, uses Hive for persistence

**Checklist:**
- [ ] Repository implemented
- [ ] Registered in DI
- [ ] Unit tests created
- [ ] Tests pass (100% coverage)

---

#### Task 1.5.4: Schedule Repository Implementation

**Duration:** 1.5 days (12 hours)

**File:** `data/repositories/schedule_repository_impl.dart` (~300 lines)

**Dependencies:**
- `hive` for schedule storage
- `workmanager` for background execution (already in pubspec.yaml)

**Implementation:**
```dart
class ScheduleRepositoryImpl implements ScheduleRepository {
  final Box<ScheduleModel> scheduleBox;
  final Box<ScheduledDownloadModel> scheduledDownloadBox;
  final Workmanager workmanager;
  final StreamController<Schedule> _scheduleUpdatesController;

  // Implementation with WorkManager integration
  // Schedule background tasks
  // Persist schedules to Hive
  // Emit updates via stream
}
```

**Checklist:**
- [ ] Repository implemented
- [ ] WorkManager configured
- [ ] Background task handler created
- [ ] Registered in DI
- [ ] Unit tests created
- [ ] Integration tests for background execution
- [ ] Tests pass (100% coverage)

---

#### Task 1.5.5: JDownloader Repository Implementation

**Duration:** 1.5 days (12 hours)

**File:** `data/repositories/jdownloader_repository_impl.dart` (~350 lines)

**Dependencies:**
- HTTP client for JDownloader API
- WebSocket for real-time updates

**Implementation:**
```dart
class JDownloaderRepositoryImpl implements JDownloaderRepository {
  final Dio httpClient;
  final IOClient webSocketClient;
  final StreamController<JDownloaderInstance> _instanceUpdatesController;

  String? _sessionToken;
  JDownloaderInstanceModel? _currentInstance;

  // Implement JDownloader My.JDownloader API
  // Handle authentication
  // Manage WebSocket connection
  // Parse and transform responses
}
```

**API Documentation Required:**
- Document JDownloader API endpoints
- Document authentication flow
- Document WebSocket protocol

**Checklist:**
- [ ] Repository implemented
- [ ] JDownloader API client created
- [ ] Authentication flow working
- [ ] WebSocket connection stable
- [ ] Registered in DI
- [ ] Unit tests created
- [ ] Integration tests with mock JDownloader server
- [ ] Tests pass (100% coverage)
- [ ] API documentation created in `docs/JDOWNLOADER_API.md`

---

### Stage 1.6: Presentation Layer - BLoCs

**Duration:** 5-6 days
**Priority:** P0 - Critical

#### Task 1.6.1: QR Scanner BLoC

**Duration:** 1 day (8 hours)

**Files to Create:**
1. **`presentation/blocs/qr_scanner/qr_scanner_bloc.dart`** (~200 lines)
2. **`presentation/blocs/qr_scanner/qr_scanner_event.dart`** (~100 lines)
3. **`presentation/blocs/qr_scanner/qr_scanner_state.dart`** (~150 lines)

**Events:**
```dart
abstract class QrScannerEvent extends Equatable {}

class StartScanning extends QrScannerEvent {}
class StopScanning extends QrScannerEvent {}
class QrCodeDetected extends QrScannerEvent {
  final String rawValue;
}
class ValidateQrUrl extends QrScannerEvent {
  final String url;
}
class AddDownloadFromQr extends QrScannerEvent {
  final String url;
}
```

**States:**
```dart
abstract class QrScannerState extends Equatable {}

class QrScannerInitial extends QrScannerState {}
class QrScannerScanning extends QrScannerState {}
class QrScannerSuccess extends QrScannerState {
  final QrScanResult result;
}
class QrScannerValidating extends QrScannerState {}
class QrScannerValidated extends QrScannerState {
  final bool isValid;
}
class QrScannerAddingDownload extends QrScannerState {}
class QrScannerDownloadAdded extends QrScannerState {
  final Download download;
}
class QrScannerError extends QrScannerState {
  final String message;
}
```

**BLoC:**
```dart
class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  final ScanQrCodeUseCase scanQrCodeUseCase;
  final ValidateQrUrlUseCase validateQrUrlUseCase;
  final AddDownloadUseCase addDownloadUseCase;

  StreamSubscription<QrScanResult>? _scanSubscription;

  QrScannerBloc({
    required this.scanQrCodeUseCase,
    required this.validateQrUrlUseCase,
    required this.addDownloadUseCase,
  }) : super(QrScannerInitial()) {
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
    on<QrCodeDetected>(_onQrCodeDetected);
    on<ValidateQrUrl>(_onValidateQrUrl);
    on<AddDownloadFromQr>(_onAddDownloadFromQr);
  }

  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<QrScannerState> emit,
  ) async {
    emit(QrScannerScanning());

    _scanSubscription = scanQrCodeUseCase.scanStream.listen(
      (result) => add(QrCodeDetected(result.rawValue)),
    );
  }

  // ... other handlers

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
```

**Testing:**
- Unit tests using bloc_test
- Test all event->state transitions
- Test stream subscriptions
- Test error handling

**Checklist:**
- [ ] All 3 BLoC files created
- [ ] Registered in DI
- [ ] Unit tests created (`test/unit/presentation/blocs/qr_scanner/`)
- [ ] Tests pass (100% coverage)

---

#### Task 1.6.2: Search BLoC

**Duration:** 1 day (8 hours)

**Files to Create:**
1. **`presentation/blocs/search/search_bloc.dart`**
2. **`presentation/blocs/search/search_event.dart`**
3. **`presentation/blocs/search/search_state.dart`**

**Events:** SearchQueryChanged, SearchSubmitted, SearchHistoryLoaded, SearchHistoryCleared, etc.

**Checklist:**
- [ ] All 3 BLoC files created
- [ ] Registered in DI
- [ ] Unit tests created
- [ ] Tests pass (100% coverage)

---

#### Task 1.6.3: Favorites BLoC

**Duration:** 0.5 days (4 hours)

**Files to Create:**
1. **`presentation/blocs/favorites/favorites_bloc.dart`**
2. **`presentation/blocs/favorites/favorites_event.dart`**
3. **`presentation/blocs/favorites/favorites_state.dart`**

**Checklist:**
- [ ] All 3 BLoC files created
- [ ] Registered in DI
- [ ] Unit tests created
- [ ] Tests pass (100% coverage)

---

#### Task 1.6.4: Schedule BLoC

**Duration:** 1.5 days (12 hours)

**Files to Create:**
1. **`presentation/blocs/schedule/schedule_bloc.dart`**
2. **`presentation/blocs/schedule/schedule_event.dart`**
3. **`presentation/blocs/schedule/schedule_state.dart`**

**Complex State Management:**
- List of schedules
- List of scheduled downloads per schedule
- Active/inactive state management
- Next execution time calculations

**Checklist:**
- [ ] All 3 BLoC files created
- [ ] Registered in DI
- [ ] Unit tests created
- [ ] Tests pass (100% coverage)

---

#### Task 1.6.5: JDownloader BLoC

**Duration:** 1.5 days (12 hours)

**Files to Create:**
1. **`presentation/blocs/jdownloader/jdownloader_bloc.dart`**
2. **`presentation/blocs/jdownloader/jdownloader_event.dart`**
3. **`presentation/blocs/jdownloader/jdownloader_state.dart`**

**Complex Features:**
- Connection state management
- Real-time download updates via WebSocket
- Authentication handling
- Error recovery

**Checklist:**
- [ ] All 3 BLoC files created
- [ ] Registered in DI
- [ ] Unit tests created
- [ ] Tests pass (100% coverage)

---

### Stage 1.7: Presentation Layer - Pages

**Duration:** 5-6 days
**Priority:** P0 - Critical

#### Task 1.7.1: QR Scanner Page

**Duration:** 1.5 days (12 hours)

**File:** `presentation/pages/qr_scanner_page.dart` (~400 lines)

**UI Components:**
- Camera viewfinder with overlay
- Scanning animation
- URL validation indicator
- "Add Download" button when valid URL detected
- Error handling UI
- Permission request handling

**Dependencies:**
- `mobile_scanner` widget
- `permission_handler` for camera permissions

**Implementation:**
```dart
class QrScannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<QrScannerBloc>()..add(StartScanning()),
      child: const QrScannerView(),
    );
  }
}

class QrScannerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: BlocConsumer<QrScannerBloc, QrScannerState>(
        listener: (context, state) {
          if (state is QrScannerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is QrScannerDownloadAdded) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download added!')),
            );
          }
        },
        builder: (context, state) {
          if (state is QrScannerScanning) {
            return Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    if (barcode.rawValue != null) {
                      context.read<QrScannerBloc>().add(
                        QrCodeDetected(barcode.rawValue!),
                      );
                    }
                  },
                ),
                // Overlay with scanning frame
                // ...
              ],
            );
          } else if (state is QrScannerSuccess) {
            return QrResultView(result: state.result);
          }
          // ... other states
        },
      ),
    );
  }
}
```

**Testing:**
- Widget tests for UI components
- Integration tests for full flow
- Test camera permission handling
- Test QR code detection

**Checklist:**
- [ ] Page implemented
- [ ] UI polished and responsive
- [ ] Widget tests created (`test/widget/qr_scanner_page_test.dart`)
- [ ] Integration tests created
- [ ] Tests pass
- [ ] Manual testing on device completed

---

#### Task 1.7.2: Search Page

**Duration:** 1.5 days (12 hours)

**File:** `presentation/pages/search_page.dart` (~450 lines)

**UI Components:**
- Search bar with auto-complete
- Filter chips (type, sort order, date range)
- Search results list with thumbnails
- Search history list
- Empty state
- Loading indicators
- Error handling

**Implementation:** Similar pattern to QR Scanner Page

**Checklist:**
- [ ] Page implemented
- [ ] Widget tests created
- [ ] Integration tests created
- [ ] Tests pass
- [ ] Manual testing completed

---

#### Task 1.7.3: Favorites Page

**Duration:** 1 day (8 hours)

**File:** `presentation/pages/favorites_page.dart` (~350 lines)

**UI Components:**
- Favorites list (reuse DownloadListItem widget)
- Empty state ("No favorites yet")
- Sort/filter options
- Swipe to remove
- Bulk actions

**Checklist:**
- [ ] Page implemented
- [ ] Widget tests created
- [ ] Integration tests created
- [ ] Tests pass

---

#### Task 1.7.4: Schedule Page

**Duration:** 1.5 days (12 hours)

**File:** `presentation/pages/schedule_page.dart` (~500 lines)

**UI Components:**
- Schedule list with cards
- "Create Schedule" FAB
- Schedule detail view
- Schedule editor dialog/page
- Scheduled downloads list per schedule
- Next execution time display
- Active/inactive toggle

**Additional File:** `presentation/pages/schedule_editor_page.dart` (~400 lines)

**Checklist:**
- [ ] Both pages implemented
- [ ] Widget tests created
- [ ] Integration tests created
- [ ] Tests pass

---

#### Task 1.7.5: JDownloader Page

**Duration:** 1.5 days (12 hours)

**File:** `presentation/pages/jdownloader_page.dart` (~500 lines)

**UI Components:**
- Connection status indicator
- Connect/disconnect button
- JDownloader downloads list
- Download controls (pause/resume/cancel)
- Settings for host/port configuration

**Additional File:** `presentation/pages/jdownloader_settings_page.dart` (~300 lines)

**Checklist:**
- [ ] Both pages implemented
- [ ] Widget tests created
- [ ] Integration tests created
- [ ] Tests pass

---

#### Task 1.7.6: Settings Page

**Duration:** 1 day (8 hours)

**File:** `presentation/pages/settings_page.dart` (~400 lines)

**UI Components:**
- Server configuration
- Download preferences
- Theme selection
- Language selection (if i18n planned)
- Notification settings
- Storage management
- About section

**Checklist:**
- [ ] Page implemented
- [ ] Widget tests created
- [ ] Tests pass

---

### Stage 1.8: Navigation & Integration

**Duration:** 2 days
**Priority:** P0 - Critical

#### Task 1.8.1: Update Main Navigation

**Duration:** 1 day (8 hours)

**Files to Update:**
1. **`presentation/app.dart`** - Add new routes
2. **`presentation/pages/home_page.dart`** - Add navigation to new pages

**Navigation Structure:**
```
Home
├── Downloads (current)
├── History (current)
├── Favorites (NEW)
├── Search (NEW)
├── QR Scanner (NEW)
├── Schedules (NEW)
├── JDownloader (NEW)
└── Settings (NEW)
```

**Implementation:**
- Use bottom navigation bar or drawer
- Add routes to MaterialApp
- Implement deep linking if needed

**Checklist:**
- [ ] Navigation implemented
- [ ] All pages accessible
- [ ] Back navigation working
- [ ] Deep linking tested (optional)

---

#### Task 1.8.2: Update Dependency Injection

**Duration:** 0.5 days (4 hours)

**File:** `core/di/injection.dart`

**Register All New Components:**
```dart
@module
abstract class AppModule {
  // Repositories
  @lazySingleton
  QrScannerRepository get qrScannerRepository => QrScannerRepositoryImpl(...);

  @lazySingleton
  SearchRepository get searchRepository => SearchRepositoryImpl(...);

  // ... all other repositories

  // Use Cases
  @lazySingleton
  ScanQrCodeUseCase get scanQrCodeUseCase => ScanQrCodeUseCase(...);

  // ... all use cases

  // BLoCs
  @injectable
  QrScannerBloc get qrScannerBloc => QrScannerBloc(...);

  // ... all BLoCs
}
```

**Steps:**
1. Update injection.dart
2. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Verify `injection.config.dart` updated
4. Test DI container initialization

**Checklist:**
- [ ] All components registered
- [ ] Code generation successful
- [ ] DI tests pass
- [ ] Manual verification in app

---

#### Task 1.8.3: Fix history_page.dart TODO

**Duration:** 2 hours

**File:** `presentation/pages/history_page.dart`
**Line:** 388

**Implementation:**
```dart
void _openOriginalUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open URL')),
    );
  }
}
```

**Checklist:**
- [ ] TODO removed
- [ ] Implementation added
- [ ] Tested on device
- [ ] Tests updated

---

### Stage 1.9: End-to-End Testing

**Duration:** 2 days
**Priority:** P1 - High

#### Task 1.9.1: Integration Tests for New Features

**Duration:** 1.5 days (12 hours)

**Files to Create:**

1. **`test/integration/qr_scanner_feature_test.dart`** (~300 lines)
   - Test QR scanning flow
   - Test URL validation
   - Test adding download from QR

2. **`test/integration/search_feature_test.dart`** (~300 lines)
   - Test search functionality
   - Test search history
   - Test adding download from search

3. **`test/integration/favorites_feature_test.dart`** (~200 lines)
   - Test adding/removing favorites
   - Test favorites persistence
   - Test favorites display

4. **`test/integration/schedule_feature_test.dart`** (~400 lines)
   - Test schedule creation
   - Test schedule execution
   - Test schedule editing/deletion

5. **`test/integration/jdownloader_feature_test.dart`** (~350 lines)
   - Test JDownloader connection
   - Test download sync
   - Test download control

**Checklist:**
- [ ] All 5 integration test files created
- [ ] All tests pass
- [ ] Coverage >80% for new features

---

#### Task 1.9.2: E2E Tests with Patrol

**Duration:** 0.5 days (4 hours)

**Files to Create:**

1. **`test/e2e/complete_user_journey_test.dart`** (~400 lines)
   - User opens app
   - Scans QR code
   - Downloads video
   - Adds to favorites
   - Creates schedule
   - Checks history

**Checklist:**
- [ ] E2E test created
- [ ] Test passes on device
- [ ] Video recording of test run captured

---

## Phase 2: Testing & Quality Assurance

**Duration:** 1 week
**Goal:** Achieve 100% test coverage and fix all issues
**Status:** Not started

---

### Stage 2.1: Missing Unit Tests

**Duration:** 2 days
**Priority:** P2 - Medium

#### Task 2.1.1: Core Component Unit Tests

**Duration:** 1 day (8 hours)

**Files to Create:**

1. **`test/unit/core/network/socket_client_test.dart`** (~200 lines)
   - Test WebSocket connection
   - Test message sending/receiving
   - Test reconnection logic
   - Test error handling

2. **`test/unit/core/network/dio_module_test.dart`** (~150 lines)
   - Test Dio configuration
   - Test interceptors
   - Test error handling

3. **`test/unit/core/utils/logger_test.dart`** (~100 lines)
   - Test log formatting
   - Test log levels
   - Test log output

**Checklist:**
- [ ] All 3 test files created
- [ ] All tests pass
- [ ] Coverage 100% for tested files

---

#### Task 2.1.2: Widget Tests

**Duration:** 1 day (8 hours)

**Files to Create:**

1. **`test/widget/add_download_dialog_test.dart`** (~200 lines)
2. **`test/widget/empty_state_widget_test.dart`** (~150 lines)
3. **`test/widget/loading_view_test.dart`** (~150 lines)
4. **`test/widget/qr_scanner_page_test.dart`** (~250 lines)
5. **`test/widget/search_page_test.dart`** (~250 lines)

**Checklist:**
- [ ] All 5 test files created
- [ ] All tests pass
- [ ] Coverage >90% for widgets

---

### Stage 2.2: Test Infrastructure Enhancements

**Duration:** 2 days
**Priority:** P2 - Medium

#### Task 2.2.1: Performance Tests

**Duration:** 1 day (8 hours)

**Create Performance Test Suite:**

**File:** `test/performance/app_performance_test.dart` (~300 lines)

**Tests:**
- App startup time
- Page navigation performance
- List scrolling performance (1000+ items)
- Memory usage monitoring
- Network request latency

**Tools:**
- `flutter_driver`
- `integration_test`
- Custom performance metrics

**Checklist:**
- [ ] Performance test suite created
- [ ] Baseline metrics established
- [ ] Performance report generated
- [ ] No performance regressions detected

---

#### Task 2.2.2: Golden Tests

**Duration:** 1 day (8 hours)

**Create Golden Test Suite:**

**File:** `test/golden/widget_golden_test.dart` (~400 lines)

**Golden Tests For:**
- All major widgets
- All pages (light/dark theme)
- All screen sizes (phone, tablet)
- Various states (loading, error, success, empty)

**Steps:**
1. Generate golden files:
   ```bash
   flutter test --update-goldens
   ```
2. Add golden files to version control
3. Run golden tests in CI

**Checklist:**
- [ ] Golden test suite created
- [ ] Golden files generated
- [ ] Tests pass consistently
- [ ] CI integration configured

---

### Stage 2.3: Test Bank Framework Enhancement

**Duration:** 2 days
**Priority:** P2 - Medium

#### Task 2.3.1: Test Case Database

**Duration:** 1 day (8 hours)

**Create Test Case Database:**

**File:** `tools/test_case_database.py` (~500 lines)

**Features:**
- SQLite database for test cases
- Test metadata (name, type, priority, tags)
- Test execution history
- Test failure tracking
- Test coverage mapping

**Schema:**
```sql
CREATE TABLE test_cases (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  file_path TEXT NOT NULL,
  priority INTEGER,
  tags TEXT,
  created_at TIMESTAMP,
  last_executed TIMESTAMP,
  execution_count INTEGER,
  failure_count INTEGER,
  average_duration REAL
);

CREATE TABLE test_executions (
  id INTEGER PRIMARY KEY,
  test_case_id INTEGER,
  executed_at TIMESTAMP,
  status TEXT,
  duration REAL,
  error_message TEXT,
  FOREIGN KEY (test_case_id) REFERENCES test_cases(id)
);
```

**Checklist:**
- [ ] Database schema created
- [ ] Python script implemented
- [ ] Test case import functional
- [ ] Execution tracking working

---

#### Task 2.3.2: Enhanced Test Runner

**Duration:** 1 day (8 hours)

**Enhance:** `tools/run_tests.sh` and `tools/ai_test_validator.py`

**New Features:**
1. **Test Prioritization:**
   - Run recently failed tests first
   - Run tests affected by code changes
   - Skip stable tests in quick mode

2. **Regression Detection:**
   - Compare current run with historical data
   - Flag new failures
   - Flag performance regressions

3. **Load Testing:**
   - Simulate high load scenarios
   - Test concurrent operations
   - Measure system limits

4. **Mutation Testing:**
   - Generate code mutations
   - Verify tests catch mutations
   - Report mutation score

**Checklist:**
- [ ] All features implemented
- [ ] Documentation updated
- [ ] CI integration tested
- [ ] Performance acceptable

---

### Stage 2.4: Coverage Verification

**Duration:** 1 day
**Priority:** P1 - High

#### Task 2.4.1: Achieve 100% Coverage

**Duration:** 1 day (8 hours)

**Steps:**
1. Run coverage analysis:
   ```bash
   cd Flutter-Client
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

2. Identify uncovered lines

3. Write tests for uncovered code

4. Verify 100% coverage achieved

**Exceptions:**
- Generated code (*.g.dart, *.config.dart)
- Main entry point (main.dart)
- Platform channel code (if minimal)

**Checklist:**
- [ ] Coverage report generated
- [ ] All gaps identified
- [ ] Additional tests written
- [ ] 100% coverage achieved (excluding exceptions)
- [ ] Coverage badge updated in README

---

## Phase 3: Documentation

**Duration:** 1.5 weeks
**Goal:** Complete all missing documentation
**Status:** Not started

---

### Stage 3.1: Android-Client Documentation

**Duration:** 3 days
**Priority:** P1 - High

#### Task 3.1.1: Android README.md

**Duration:** 0.5 days (4 hours)

**File:** `Android-Client/README.md` (~500 lines)

**Sections:**
1. **Project Overview**
   - What is GrabTube Android Client
   - Key features
   - Screenshots

2. **Prerequisites**
   - Android Studio version
   - SDK requirements
   - Kotlin version

3. **Installation**
   - Clone repository
   - Open in Android Studio
   - Sync Gradle

4. **Configuration**
   - Server URL setup
   - Build variants
   - ProGuard rules

5. **Building**
   - Debug build
   - Release build
   - Signing configuration

6. **Running**
   - Run on emulator
   - Run on device
   - Debugging

7. **Testing**
   - Run unit tests
   - Run instrumentation tests
   - Code coverage

8. **Architecture**
   - Link to ARCHITECTURE.md
   - Brief overview

9. **Contributing**
   - Link to CONTRIBUTING.md

**Checklist:**
- [ ] README.md created
- [ ] All sections completed
- [ ] Code examples tested
- [ ] Screenshots added
- [ ] Reviewed and proofread

---

#### Task 3.1.2: Android ARCHITECTURE.md

**Duration:** 1 day (8 hours)

**File:** `Android-Client/docs/ARCHITECTURE.md` (~800 lines)

**Sections:**
1. **Overview**
   - Architecture pattern (MVVM + Clean Architecture)
   - Layer diagram

2. **Project Structure**
   - Package organization
   - Module breakdown

3. **Presentation Layer**
   - Jetpack Compose UI
   - ViewModels
   - Navigation
   - Theme system

4. **Domain Layer**
   - Use cases
   - Repository interfaces
   - Domain models

5. **Data Layer**
   - Repository implementations
   - Data sources (local, remote)
   - DTOs and mapping

6. **Dependency Injection**
   - Hilt setup
   - Module configuration
   - Scope management

7. **State Management**
   - StateFlow
   - UI state patterns
   - Error handling

8. **Navigation**
   - Compose Navigation
   - Deep linking

9. **Testing Strategy**
   - Unit testing approach
   - Integration testing
   - UI testing with Compose

**Checklist:**
- [ ] ARCHITECTURE.md created
- [ ] Diagrams added (use Mermaid or ASCII)
- [ ] Code examples included
- [ ] Reviewed and proofread

---

#### Task 3.1.3: Android API.md

**Duration:** 0.5 days (4 hours)

**File:** `Android-Client/docs/API.md` (~400 lines)

**Sections:**
1. **Backend API Integration**
   - Base URL configuration
   - API client setup
   - Authentication

2. **HTTP Endpoints**
   - List all endpoints used
   - Request/response examples

3. **WebSocket Integration**
   - Connection setup
   - Event handling
   - Reconnection logic

4. **Error Handling**
   - HTTP errors
   - Network errors
   - Parsing errors

**Checklist:**
- [ ] API.md created
- [ ] All endpoints documented
- [ ] Examples tested
- [ ] Reviewed

---

#### Task 3.1.4: Android USER_GUIDE.md

**Duration:** 0.5 days (4 hours)

**File:** `Android-Client/docs/USER_GUIDE.md` (~600 lines)

**Sections:**
1. **Getting Started**
   - First launch
   - Server connection

2. **Adding Downloads**
   - Manual URL entry
   - Share from other apps
   - QR code scanning

3. **Managing Downloads**
   - View active downloads
   - Pause/resume
   - Cancel downloads

4. **Quality Selection**
   - Video quality options
   - Format selection

5. **Scheduled Downloads**
   - Creating schedules
   - Managing schedules

6. **History & Favorites**
   - View history
   - Mark favorites

7. **Settings**
   - Server configuration
   - Download preferences
   - Theme selection

8. **Troubleshooting**
   - Common issues
   - Error messages
   - FAQ

**Checklist:**
- [ ] USER_GUIDE.md created
- [ ] Screenshots added
- [ ] All features covered
- [ ] Reviewed

---

#### Task 3.1.5: Android DEVELOPMENT.md

**Duration:** 0.5 days (4 hours)

**File:** `Android-Client/docs/DEVELOPMENT.md` (~400 lines)

**Sections:**
1. **Development Setup**
   - IDE configuration
   - Git hooks
   - Code style

2. **Coding Conventions**
   - Kotlin style guide
   - Naming conventions
   - File organization

3. **Adding Features**
   - Step-by-step guide
   - Best practices

4. **Debugging**
   - Logging
   - Debugging tools
   - Performance profiling

5. **Common Tasks**
   - Adding a new screen
   - Adding a new API endpoint
   - Adding a new use case

**Checklist:**
- [ ] DEVELOPMENT.md created
- [ ] All sections completed
- [ ] Reviewed

---

### Stage 3.2: API Documentation

**Duration:** 2 days
**Priority:** P1 - High

#### Task 3.2.1: Generate Dart Documentation

**Duration:** 1 day (8 hours)

**Steps:**
1. Add doc comments to all public APIs:
   ```dart
   /// Scans a QR code using the device camera.
   ///
   /// Returns [Either] a [Failure] or a [QrScanResult] containing
   /// the scanned data.
   ///
   /// Throws [CameraException] if camera access is denied.
   ///
   /// Example:
   /// ```dart
   /// final result = await scanQrCodeUseCase.call();
   /// result.fold(
   ///   (failure) => print('Error: $failure'),
   ///   (scanResult) => print('Scanned: ${scanResult.rawValue}'),
   /// );
   /// ```
   Future<Either<Failure, QrScanResult>> call();
   ```

2. Generate documentation:
   ```bash
   cd Flutter-Client
   dart doc .
   ```

3. Host documentation (GitHub Pages or similar)

**Files to Document:**
- All public classes
- All public methods
- All public properties
- All parameters
- All return types

**Checklist:**
- [ ] Doc comments added to all files
- [ ] Documentation generated successfully
- [ ] No dartdoc warnings
- [ ] Documentation hosted
- [ ] Link added to README

---

#### Task 3.2.2: Generate Kotlin Documentation

**Duration:** 1 day (8 hours)

**Steps:**
1. Add KDoc comments to all public APIs:
   ```kotlin
   /**
    * Scans a QR code using the device camera.
    *
    * @return Flow emitting [Result] with [QrScanResult] or error
    * @throws CameraAccessDeniedException if camera permission not granted
    *
    * @sample com.grabtube.android.samples.QrScannerSamples.basicScanning
    */
   fun scanQrCode(): Flow<Result<QrScanResult>>
   ```

2. Generate documentation with Dokka:
   ```bash
   cd Android-Client
   ./gradlew dokkaHtml
   ```

3. Host documentation

**Checklist:**
- [ ] KDoc comments added
- [ ] Dokka configuration added to build.gradle
- [ ] Documentation generated
- [ ] Documentation hosted
- [ ] Link added to README

---

### Stage 3.3: Project-Level Documentation

**Duration:** 2 days
**Priority:** P2 - Medium

#### Task 3.3.1: CONTRIBUTING.md

**Duration:** 0.5 days (4 hours)

**File:** `CONTRIBUTING.md` (~200 lines)

**Sections:**
1. **Welcome**
2. **Code of Conduct**
3. **How to Contribute**
   - Reporting bugs
   - Suggesting features
   - Submitting pull requests
4. **Development Workflow**
   - Fork and clone
   - Create branch
   - Make changes
   - Run tests
   - Submit PR
5. **Coding Standards**
6. **Commit Message Format**
7. **Review Process**

**Checklist:**
- [ ] File created
- [ ] Reviewed
- [ ] Link added to README

---

#### Task 3.3.2: SECURITY.md

**Duration:** 0.25 days (2 hours)

**File:** `SECURITY.md` (~100 lines)

**Sections:**
1. **Supported Versions**
2. **Reporting a Vulnerability**
3. **Security Update Policy**
4. **Known Security Considerations**

**Checklist:**
- [ ] File created
- [ ] Contact email added
- [ ] Reviewed

---

#### Task 3.3.3: CHANGELOG.md

**Duration:** 0.5 days (4 hours)

**File:** `CHANGELOG.md` (~300 lines)

**Format:** Follow [Keep a Changelog](https://keepachangelog.com/)

**Sections:**
- Unreleased
- Version 1.0.0 (release date)
  - Added
  - Changed
  - Deprecated
  - Removed
  - Fixed
  - Security

**Checklist:**
- [ ] File created
- [ ] All major changes documented
- [ ] Versions tagged in git
- [ ] Reviewed

---

#### Task 3.3.4: CODE_OF_CONDUCT.md

**Duration:** 0.25 days (2 hours)

**File:** `CODE_OF_CONDUCT.md` (~150 lines)

**Content:** Use [Contributor Covenant](https://www.contributor-covenant.org/)

**Checklist:**
- [ ] File created
- [ ] Contact method added
- [ ] Reviewed

---

### Stage 3.4: User Manuals

**Duration:** 2 days
**Priority:** P1 - High

#### Task 3.4.1: Comprehensive User Guide

**Duration:** 1 day (8 hours)

**File:** `docs/COMPLETE_USER_GUIDE.md` (~1000 lines)

**Sections:**
1. **Introduction**
   - What is GrabTube
   - Supported platforms
   - System requirements

2. **Installation**
   - Web Client
   - Flutter Client (Android, iOS, Desktop)
   - Android Native Client

3. **Getting Started**
   - First launch
   - Server configuration
   - First download

4. **Basic Features**
   - Adding downloads
   - Monitoring progress
   - Managing queue

5. **Advanced Features**
   - QR code scanning
   - Search functionality
   - Favorites management
   - Scheduled downloads
   - JDownloader integration

6. **Tips & Tricks**
   - Best quality settings
   - Batch downloads
   - Keyboard shortcuts (desktop)

7. **Troubleshooting**
   - Common issues
   - Error messages
   - FAQ

8. **Appendix**
   - Supported sites (link to yt-dlp)
   - Format codes
   - Quality options

**Checklist:**
- [ ] Guide created
- [ ] Screenshots added (50+)
- [ ] All features covered
- [ ] Reviewed and proofread
- [ ] PDF version generated

---

#### Task 3.4.2: Quick Start Guides

**Duration:** 0.5 days (4 hours)

**Create Platform-Specific Quick Start Guides:**

1. **`docs/QUICK_START_ANDROID.md`** (~200 lines)
2. **`docs/QUICK_START_IOS.md`** (~200 lines)
3. **`docs/QUICK_START_DESKTOP.md`** (~200 lines)
4. **`docs/QUICK_START_WEB.md`** (~200 lines)

**Each Guide Includes:**
- Installation (5 minutes)
- First download (2 minutes)
- Key features overview

**Checklist:**
- [ ] All 4 guides created
- [ ] Screenshots added
- [ ] Tested by new user
- [ ] Reviewed

---

#### Task 3.4.3: Administrator Guide

**Duration:** 0.5 days (4 hours)

**File:** `docs/ADMINISTRATOR_GUIDE.md` (~500 lines)

**Sections:**
1. **Server Installation**
   - Prerequisites
   - Installation methods (Docker, uv, source)

2. **Configuration**
   - Environment variables
   - yt-dlp options
   - Output templates

3. **Security**
   - HTTPS setup
   - Authentication (if implemented)
   - Firewall rules

4. **Monitoring**
   - Logs
   - Performance metrics
   - Resource usage

5. **Maintenance**
   - Updates
   - Backups
   - Database cleanup

6. **Troubleshooting**
   - Common issues
   - Log analysis

**Checklist:**
- [ ] Guide created
- [ ] All configurations documented
- [ ] Reviewed

---

## Phase 4: Website Development

**Duration:** 2 weeks
**Goal:** Create complete marketing and documentation website
**Status:** Not started

---

### Stage 4.1: Website Planning

**Duration:** 1 day
**Priority:** P1 - High

#### Task 4.1.1: Website Architecture & Design

**Duration:** 1 day (8 hours)

**Deliverables:**

1. **Site Map:**
   ```
   GrabTube Website
   ├── Home
   ├── Features
   ├── Download
   │   ├── Web Client
   │   ├── Android
   │   ├── iOS
   │   ├── Windows
   │   ├── macOS
   │   └── Linux
   ├── Documentation
   │   ├── Getting Started
   │   ├── User Guide
   │   ├── API Reference
   │   ├── Developer Guide
   │   └── FAQ
   ├── Video Tutorials
   ├── About
   ├── Blog (optional)
   └── Contact/Support
   ```

2. **Design Mockups:**
   - Wireframes for all pages
   - Color scheme (use GrabTube brand colors)
   - Typography
   - Responsive breakpoints

3. **Technology Stack Decision:**
   - **Recommended:** Next.js + Tailwind CSS + MDX
   - **Alternative:** Hugo (static site generator)
   - **Hosting:** GitHub Pages, Netlify, or Vercel

**Checklist:**
- [ ] Site map created
- [ ] Wireframes designed (Figma/Sketch/paper)
- [ ] Technology stack chosen
- [ ] Design system documented

---

### Stage 4.2: Website Development Setup

**Duration:** 0.5 days
**Priority:** P1 - High

#### Task 4.2.1: Initialize Project

**Duration:** 0.5 days (4 hours)

**Steps:**

1. **Create Next.js project:**
   ```bash
   cd Website
   npx create-next-app@latest . --typescript --tailwind --app
   ```

2. **Install dependencies:**
   ```bash
   npm install @next/mdx @mdx-js/loader @mdx-js/react
   npm install gray-matter remark remark-html
   npm install lucide-react  # Icons
   npm install clsx tailwind-merge  # Utilities
   ```

3. **Configure project:**
   - Set up MDX for documentation
   - Configure Tailwind with brand colors
   - Set up layouts

4. **Create directory structure:**
   ```
   Website/
   ├── app/
   │   ├── (marketing)/
   │   │   ├── page.tsx         # Home
   │   │   ├── features/
   │   │   ├── download/
   │   │   └── about/
   │   ├── docs/
   │   │   ├── layout.tsx
   │   │   ├── page.tsx
   │   │   └── [...slug]/
   │   └── videos/
   ├── components/
   │   ├── ui/
   │   ├── marketing/
   │   └── docs/
   ├── content/
   │   ├── docs/
   │   └── blog/
   ├── public/
   │   ├── images/
   │   ├── videos/
   │   └── downloads/
   └── styles/
   ```

**Checklist:**
- [ ] Project initialized
- [ ] Dependencies installed
- [ ] Directory structure created
- [ ] Configuration complete

---

### Stage 4.3: Core Pages Development

**Duration:** 5 days
**Priority:** P1 - High

#### Task 4.3.1: Home Page

**Duration:** 1 day (8 hours)

**File:** `app/(marketing)/page.tsx` (~400 lines)

**Sections:**

1. **Hero Section:**
   - Headline: "Download Videos from Anywhere, On Any Platform"
   - Subheadline
   - CTA buttons (Download Now, View Demo)
   - Hero image/animation

2. **Features Overview:**
   - 6-8 key features with icons
   - Brief descriptions

3. **Platform Support:**
   - Badges/icons for all platforms
   - "One solution for all devices"

4. **Screenshots/Demo:**
   - Carousel of app screenshots
   - Or embedded demo video

5. **Testimonials:** (if available)
   - User quotes
   - Ratings

6. **Call to Action:**
   - Download buttons for all platforms
   - Link to documentation

**Components to Create:**
- `<Hero />`
- `<FeatureGrid />`
- `<PlatformBadges />`
- `<ScreenshotCarousel />`
- `<CTASection />`

**Checklist:**
- [ ] Page implemented
- [ ] All sections completed
- [ ] Responsive design tested
- [ ] Images optimized
- [ ] SEO meta tags added

---

#### Task 4.3.2: Features Page

**Duration:** 1 day (8 hours)

**File:** `app/(marketing)/features/page.tsx` (~500 lines)

**Sections:**

1. **Header:**
   - "Powerful Features for Modern Video Downloading"

2. **Feature Categories:**
   - **Core Features:**
     - Multi-platform support
     - Quality selection
     - Format support
     - Real-time progress
     - Queue management

   - **Advanced Features:**
     - QR code scanning
     - Search functionality
     - Favorites management
     - Scheduled downloads
     - JDownloader integration

   - **Technical Features:**
     - Background downloads
     - Offline queue
     - Push notifications
     - Cross-device sync (if planned)

3. **Feature Comparison Table:**
   - Compare Web vs Flutter vs Android clients
   - Show which features are available on each

4. **Coming Soon:**
   - Teaser for planned features

**Components to Create:**
- `<FeatureCard />`
- `<FeatureCategory />`
- `<ComparisonTable />`

**Checklist:**
- [ ] Page implemented
- [ ] All features documented
- [ ] Images/icons added
- [ ] Comparison table accurate
- [ ] SEO optimized

---

#### Task 4.3.3: Download Page

**Duration:** 1 day (8 hours)

**File:** `app/(marketing)/download/page.tsx` (~600 lines)

**Sections:**

1. **Platform Selection:**
   - Large buttons/cards for each platform
   - Auto-detect user's platform and highlight

2. **Per-Platform Sections:**
   - **Web Client:**
     - No download needed
     - Server setup instructions
     - Docker command

   - **Android:**
     - APK download button
     - Google Play badge (when published)
     - Requirements: Android 7.0+
     - Installation instructions

   - **iOS:**
     - App Store badge (when published)
     - TestFlight link (during beta)
     - Requirements: iOS 13+

   - **Windows:**
     - Download button (.exe or .msi)
     - Requirements: Windows 10+

   - **macOS:**
     - Download button (.dmg)
     - Requirements: macOS 11+

   - **Linux:**
     - Download options (AppImage, .deb, .rpm)
     - Package manager commands
     - Requirements: Various distros

3. **Release Information:**
   - Current version
   - Release date
   - Changelog link
   - SHA256 checksums for verification

4. **System Requirements:**
   - Table showing requirements per platform

**Components to Create:**
- `<PlatformSelector />`
- `<DownloadButton />`
- `<SystemRequirements />`
- `<ReleaseNotes />`

**Checklist:**
- [ ] Page implemented
- [ ] Download links functional (placeholders OK)
- [ ] Auto-detection working
- [ ] Installation instructions clear
- [ ] Checksums generated

---

#### Task 4.3.4: About Page

**Duration:** 0.5 days (4 hours)

**File:** `app/(marketing)/about/page.tsx` (~300 lines)

**Sections:**

1. **Project Mission:**
   - Why GrabTube exists
   - Goals and vision

2. **Technology Stack:**
   - Frontend: Flutter, Angular
   - Backend: Python, yt-dlp
   - Infrastructure: Docker, CI/CD

3. **Open Source:**
   - Link to GitHub
   - License information
   - How to contribute

4. **Team:** (optional)
   - Contributors
   - Maintainers

5. **Contact:**
   - GitHub Issues
   - Email (if available)
   - Discord/Community links

**Checklist:**
- [ ] Page implemented
- [ ] Content written
- [ ] Links verified
- [ ] SEO optimized

---

#### Task 4.3.5: Contact/Support Page

**Duration:** 0.5 days (4 hours)

**File:** `app/(marketing)/contact/page.tsx` (~250 lines)

**Sections:**

1. **Support Channels:**
   - GitHub Issues (for bugs)
   - Documentation (for how-tos)
   - Community forums (if available)

2. **FAQ Preview:**
   - Link to full FAQ in docs
   - Top 5 questions

3. **Contact Form:** (optional)
   - Simple form for inquiries
   - Email notification setup

**Checklist:**
- [ ] Page implemented
- [ ] Support channels listed
- [ ] FAQ links working
- [ ] Contact form functional (if added)

---

### Stage 4.4: Documentation Section

**Duration:** 3 days
**Priority:** P1 - High

#### Task 4.4.1: Documentation Layout & Navigation

**Duration:** 1 day (8 hours)

**File:** `app/docs/layout.tsx` (~300 lines)

**Features:**

1. **Sidebar Navigation:**
   - Hierarchical menu
   - Current page highlighting
   - Collapsible sections

2. **Table of Contents:**
   - Auto-generated from headings
   - Smooth scroll to sections

3. **Search:**
   - Full-text search across all docs
   - Keyboard shortcut (Cmd/Ctrl + K)

4. **Theme Toggle:**
   - Light/dark mode

5. **Breadcrumbs:**
   - Show current location

**Components to Create:**
- `<DocsSidebar />`
- `<TableOfContents />`
- `<DocsSearch />`
- `<Breadcrumbs />`

**Checklist:**
- [ ] Layout implemented
- [ ] Navigation working
- [ ] Search functional
- [ ] Responsive design

---

#### Task 4.4.2: Convert Documentation to MDX

**Duration:** 1 day (8 hours)

**Steps:**

1. **Copy existing documentation to `content/docs/`:**
   ```bash
   mkdir -p Website/content/docs
   cp -r Flutter-Client/docs/* Website/content/docs/
   cp CLAUDE.md Website/content/docs/developer/
   # etc.
   ```

2. **Convert to MDX format:**
   - Add front matter:
     ```mdx
     ---
     title: "Architecture Guide"
     description: "Learn about GrabTube's clean architecture"
     order: 2
     category: "Developer"
     ---
     ```

3. **Enhance with interactive elements:**
   - Add code playgrounds (CodeSandbox embeds)
   - Add interactive diagrams
   - Add collapsible sections

4. **Organize structure:**
   ```
   content/docs/
   ├── getting-started/
   │   ├── installation.mdx
   │   ├── quick-start.mdx
   │   └── first-download.mdx
   ├── user-guide/
   │   ├── basic-features.mdx
   │   ├── advanced-features.mdx
   │   └── troubleshooting.mdx
   ├── developer/
   │   ├── architecture.mdx
   │   ├── contributing.mdx
   │   └── api-reference.mdx
   └── faq.mdx
   ```

**Checklist:**
- [ ] All docs copied
- [ ] Front matter added
- [ ] MDX conversion complete
- [ ] Links updated
- [ ] Images referenced correctly

---

#### Task 4.4.3: Documentation Pages Rendering

**Duration:** 1 day (8 hours)

**File:** `app/docs/[...slug]/page.tsx` (~200 lines)

**Implementation:**

```typescript
import { getDocBySlug, getAllDocs } from '@/lib/docs';
import { MDXRemote } from 'next-mdx-remote/rsc';

export async function generateStaticParams() {
  const docs = await getAllDocs();
  return docs.map((doc) => ({
    slug: doc.slug.split('/'),
  }));
}

export default async function DocPage({ params }: { params: { slug: string[] } }) {
  const doc = await getDocBySlug(params.slug.join('/'));

  return (
    <article className="prose prose-lg dark:prose-invert">
      <h1>{doc.title}</h1>
      <MDXRemote source={doc.content} />
    </article>
  );
}
```

**Checklist:**
- [ ] Dynamic routing working
- [ ] MDX rendering correctly
- [ ] Code blocks styled
- [ ] Images loading
- [ ] Links working

---

### Stage 4.5: Video Tutorials Section

**Duration:** 1 day
**Priority:** P2 - Medium

#### Task 4.5.1: Video Tutorials Page

**Duration:** 1 day (8 hours)

**File:** `app/videos/page.tsx` (~400 lines)

**Sections:**

1. **Video Categories:**
   - User Tutorials
   - Developer Courses
   - Advanced Topics

2. **Video Cards:**
   - Thumbnail
   - Title
   - Duration
   - Description
   - Link to video (YouTube embed or self-hosted)

3. **Playlist View:**
   - Group related videos
   - Progress tracking (if implemented)

**Components to Create:**
- `<VideoCard />`
- `<VideoPlayer />`
- `<VideoCategory />`

**Content:**
- Placeholders for videos (will be added in Phase 5)
- Structure ready for video embeds

**Checklist:**
- [ ] Page implemented
- [ ] Video embedding working
- [ ] Placeholder content added
- [ ] YouTube embeds tested

---

### Stage 4.6: Styling & Polish

**Duration:** 2 days
**Priority:** P1 - High

#### Task 4.6.1: Design System Implementation

**Duration:** 1 day (8 hours)

**Files:**
- `tailwind.config.ts` - Custom theme
- `styles/globals.css` - Global styles
- `components/ui/*` - Reusable UI components

**Tasks:**

1. **Define Brand Colors:**
   ```typescript
   // tailwind.config.ts
   export default {
     theme: {
       extend: {
         colors: {
           grabtube: {
             red: '#E74C3C',
             charcoal: '#2C3E50',
             gray: '#ECF0F1',
           },
         },
       },
     },
   };
   ```

2. **Create UI Components:**
   - Button
   - Card
   - Badge
   - Input
   - Modal
   - Dropdown
   - Toast/Alert

3. **Typography System:**
   - Headings (H1-H6)
   - Body text
   - Code blocks
   - Links

4. **Spacing System:**
   - Consistent margins/padding
   - Grid layouts

**Checklist:**
- [ ] Theme configured
- [ ] UI components created
- [ ] Typography system defined
- [ ] Consistent spacing applied

---

#### Task 4.6.2: Responsive Design & Accessibility

**Duration:** 1 day (8 hours)

**Tasks:**

1. **Responsive Breakpoints:**
   - Mobile (< 640px)
   - Tablet (640px - 1024px)
   - Desktop (> 1024px)

2. **Test All Pages:**
   - Chrome DevTools device emulation
   - Real devices (phone, tablet)

3. **Accessibility:**
   - Semantic HTML
   - ARIA labels
   - Keyboard navigation
   - Screen reader testing
   - Color contrast (WCAG AA)

4. **Performance:**
   - Image optimization (Next.js Image)
   - Lazy loading
   - Code splitting
   - Lighthouse score > 90

**Checklist:**
- [ ] All pages responsive
- [ ] Accessibility audit passed
- [ ] Performance optimized
- [ ] Cross-browser testing done

---

### Stage 4.7: SEO & Deployment

**Duration:** 1 day
**Priority:** P1 - High

#### Task 4.7.1: SEO Optimization

**Duration:** 0.5 days (4 hours)

**Tasks:**

1. **Meta Tags:**
   ```tsx
   export const metadata = {
     title: 'GrabTube - Universal Video Downloader',
     description: 'Download videos from YouTube and 1000+ sites...',
     keywords: ['video downloader', 'youtube downloader', '...'],
     openGraph: {
       title: 'GrabTube',
       description: '...',
       images: ['/og-image.png'],
     },
     twitter: {
       card: 'summary_large_image',
       // ...
     },
   };
   ```

2. **Sitemap:**
   ```typescript
   // app/sitemap.ts
   export default function sitemap() {
     return [
       { url: 'https://grabtube.com', priority: 1 },
       { url: 'https://grabtube.com/features', priority: 0.8 },
       // ...
     ];
   }
   ```

3. **robots.txt:**
   ```typescript
   // app/robots.ts
   export default function robots() {
     return {
       rules: {
         userAgent: '*',
         allow: '/',
       },
       sitemap: 'https://grabtube.com/sitemap.xml',
     };
   }
   ```

4. **Structured Data:**
   - Schema.org JSON-LD for SoftwareApplication

**Checklist:**
- [ ] Meta tags added to all pages
- [ ] Sitemap generated
- [ ] robots.txt configured
- [ ] Structured data added

---

#### Task 4.7.2: Deployment

**Duration:** 0.5 days (4 hours)

**Platform:** Vercel (recommended for Next.js)

**Steps:**

1. **Connect GitHub repository to Vercel**

2. **Configure build settings:**
   ```json
   {
     "buildCommand": "npm run build",
     "outputDirectory": ".next",
     "installCommand": "npm install"
   }
   ```

3. **Set environment variables** (if needed)

4. **Configure custom domain:**
   - Purchase domain (grabtube.com or similar)
   - Configure DNS
   - Set up SSL (automatic with Vercel)

5. **Set up analytics:**
   - Vercel Analytics
   - Or Google Analytics

6. **Configure redirects/rewrites** (if needed)

**Alternative:** GitHub Pages (for static export)

**Checklist:**
- [ ] Website deployed
- [ ] Custom domain configured
- [ ] SSL working (HTTPS)
- [ ] Analytics configured
- [ ] All pages loading correctly

---

## Phase 5: Video Course Production

**Duration:** 3-4 weeks
**Goal:** Create comprehensive video tutorial series
**Status:** Not started

---

### Stage 5.1: Pre-Production

**Duration:** 1 week
**Priority:** P1 - High

#### Task 5.1.1: Script Writing

**Duration:** 5 days (40 hours)

**Create Scripts for All 25 Videos:**

**Format for Each Script:**
```
Video Title: [Title]
Duration: [Target duration]
Target Audience: [Users/Developers]

INTRODUCTION (30 seconds)
- Hook
- What viewers will learn
- Prerequisites

MAIN CONTENT (80% of duration)
- Section 1: [Topic]
  - Key point 1
  - Key point 2
  - Demo/Example
- Section 2: [Topic]
  - ...

CONCLUSION (15% of duration)
- Recap
- Next steps
- Call to action (subscribe, documentation link)

OUTRO (5% of duration)
- Thank you
- Links in description
```

**Scripts to Write:**

**User Tutorials (10 scripts):**
1. Getting Started (5-7 min)
2. Web Client Guide (8-10 min)
3. Mobile App Guide (10-12 min)
4. Desktop App Guide (10-12 min)
5. Quality & Format Selection (6-8 min)
6. QR Code Scanning (5-7 min)
7. Scheduled Downloads (8-10 min)
8. Favorites & History (6-8 min)
9. JDownloader Integration (10-12 min)
10. Troubleshooting (8-10 min)

**Developer Courses (10 scripts):**
1. Architecture Overview (15-20 min)
2. Backend Setup (12-15 min)
3. Flutter Client Setup (15-18 min)
4. Android Client Setup (12-15 min)
5. Running Tests (10-12 min)
6. Contributing Code (15-18 min)
7. Adding New Features (20-25 min)
8. API Integration (12-15 min)
9. Platform-Specific Code (15-18 min)
10. Deployment (18-22 min)

**Advanced Topics (5 scripts):**
1. Custom yt-dlp Options (10-12 min)
2. Server Configuration (12-15 min)
3. Database Management (10-12 min)
4. Performance Optimization (15-18 min)
5. Security Best Practices (12-15 min)

**Checklist:**
- [ ] All 25 scripts written
- [ ] Scripts reviewed and edited
- [ ] Timestamps marked
- [ ] Demo sequences planned
- [ ] Visual aids identified (diagrams, screenshots)

---

#### Task 5.1.2: Recording Setup

**Duration:** 2 days (16 hours)

**Equipment:**

1. **Software:**
   - Screen recording: OBS Studio (free)
   - Video editing: DaVinci Resolve (free) or Adobe Premiere
   - Audio recording: Audacity (free)

2. **Hardware:**
   - Microphone: Blue Yeti or similar (~$100-150)
   - Headphones: For monitoring
   - Camera: (optional, for talking head sections)

3. **Environment:**
   - Quiet room
   - Minimal echo
   - Good lighting (if using camera)

**OBS Studio Configuration:**

1. **Scene Setup:**
   - Full screen capture
   - Or specific window capture
   - Overlay with webcam (optional)

2. **Audio:**
   - Microphone input (noise suppression enabled)
   - Desktop audio (for app sounds)

3. **Video Settings:**
   - Resolution: 1920x1080 (1080p)
   - FPS: 30
   - Encoder: H.264
   - Bitrate: 6000 kbps

4. **Output:**
   - Format: MP4
   - Encoder preset: High Quality

**Test Recording:**
- Record 2-minute test video
- Check audio quality
- Check video quality
- Adjust settings as needed

**Checklist:**
- [ ] Software installed and configured
- [ ] Microphone tested
- [ ] Recording environment optimized
- [ ] OBS scenes configured
- [ ] Test recording successful

---

### Stage 5.2: Production - User Tutorials

**Duration:** 1 week
**Priority:** P1 - High

#### Task 5.2.1: Record User Tutorial Videos

**Duration:** 5 days (40 hours - 4 hours per video average)

**Recording Process for Each Video:**

1. **Preparation:**
   - Review script
   - Set up demo environment (clean state)
   - Prepare any assets (example URLs, files)

2. **Recording:**
   - Record audio narration (multiple takes if needed)
   - Record screen actions
   - Record multiple segments if needed
   - Keep raw footage

3. **Quality Checks:**
   - Audio clear and consistent
   - No background noise
   - Screen actions visible
   - No personal information visible

**Videos to Record:**
1. ✅ Getting Started
2. ✅ Web Client Guide
3. ✅ Mobile App Guide
4. ✅ Desktop App Guide
5. ✅ Quality & Format Selection
6. ✅ QR Code Scanning
7. ✅ Scheduled Downloads
8. ✅ Favorites & History
9. ✅ JDownloader Integration
10. ✅ Troubleshooting

**Checklist:**
- [ ] All 10 videos recorded
- [ ] Raw footage organized and backed up
- [ ] Audio quality verified for all videos
- [ ] Video quality verified for all videos

---

### Stage 5.3: Production - Developer Courses

**Duration:** 1.5 weeks
**Priority:** P1 - High

#### Task 5.3.1: Record Developer Course Videos

**Duration:** 7 days (56 hours)

**Videos to Record:**
1. ✅ Architecture Overview
2. ✅ Backend Setup
3. ✅ Flutter Client Setup
4. ✅ Android Client Setup
5. ✅ Running Tests
6. ✅ Contributing Code
7. ✅ Adding New Features
8. ✅ API Integration
9. ✅ Platform-Specific Code
10. ✅ Deployment

**Checklist:**
- [ ] All 10 videos recorded
- [ ] Raw footage organized

---

### Stage 5.4: Production - Advanced Topics

**Duration:** 0.5 weeks
**Priority:** P2 - Medium

#### Task 5.4.1: Record Advanced Topic Videos

**Duration:** 3 days (24 hours)

**Videos to Record:**
1. ✅ Custom yt-dlp Options
2. ✅ Server Configuration
3. ✅ Database Management
4. ✅ Performance Optimization
5. ✅ Security Best Practices

**Checklist:**
- [ ] All 5 videos recorded
- [ ] Raw footage organized

---

### Stage 5.5: Post-Production

**Duration:** 2 weeks
**Priority:** P1 - High

#### Task 5.5.1: Video Editing

**Duration:** 10 days (80 hours - 3 hours per video)

**Editing Process for Each Video:**

1. **Import Footage:**
   - Import video and audio
   - Sync if recorded separately

2. **Cut and Trim:**
   - Remove mistakes
   - Remove long pauses
   - Cut filler words (um, uh)
   - Maintain natural pace

3. **Add Visuals:**
   - Intro animation (5 seconds)
     - GrabTube logo
     - Video title
   - Outro animation (5 seconds)
     - Subscribe prompt
     - Link to documentation
   - Lower thirds (name/title cards)
   - Highlight important areas (zoom, arrows)
   - Add diagrams/overlays where needed

4. **Add Audio:**
   - Background music (subtle, royalty-free)
   - Sound effects for transitions (optional)
   - Normalize audio levels

5. **Add Captions:**
   - Auto-generate with YouTube
   - Or manually create SRT files
   - Ensure accuracy

6. **Color Correction:**
   - Adjust brightness/contrast
   - Consistent look across all videos

7. **Export:**
   - Format: MP4
   - Resolution: 1920x1080
   - Codec: H.264
   - Bitrate: 8-10 Mbps
   - Audio: AAC, 192 kbps

**Checklist per Video:**
- [ ] Edited and polished
- [ ] Intro/outro added
- [ ] Visual aids added
- [ ] Audio mixed
- [ ] Captions added
- [ ] Exported in final format

**Overall Checklist:**
- [ ] All 25 videos edited
- [ ] Consistent style across all videos
- [ ] All videos under target duration (or close)

---

#### Task 5.5.2: Create Thumbnails

**Duration:** 2 days (16 hours)

**Thumbnail Design:**

1. **Template:**
   - Size: 1280x720 pixels
   - GrabTube branding
   - Video title (large, readable)
   - Category indicator
   - Screenshot or illustration

2. **Tools:**
   - Canva (easy, templates)
   - Photoshop/GIMP (advanced)

3. **Style Guide:**
   - Consistent color scheme
   - Readable at small sizes
   - Eye-catching
   - No misleading imagery

**Create 25 Thumbnails:**
- One for each video
- Export as PNG or JPG

**Checklist:**
- [ ] Thumbnail template designed
- [ ] All 25 thumbnails created
- [ ] Thumbnails reviewed and approved
- [ ] Thumbnails exported

---

### Stage 5.6: Publishing

**Duration:** 1 day
**Priority:** P1 - High

#### Task 5.6.1: YouTube Channel Setup

**Duration:** 2 hours

**Steps:**

1. **Create YouTube Channel:**
   - Channel name: "GrabTube Official"
   - Channel art (banner)
   - Profile picture (logo)

2. **Channel Description:**
   - About section
   - Links (website, GitHub)

3. **Organize Playlists:**
   - User Tutorials
   - Developer Courses
   - Advanced Topics

**Checklist:**
- [ ] Channel created
- [ ] Channel art uploaded
- [ ] Description written
- [ ] Playlists created

---

#### Task 5.6.2: Upload Videos

**Duration:** 6 hours

**Upload Process for Each Video:**

1. **Upload File**

2. **Fill Metadata:**
   - Title: Clear and descriptive
   - Description:
     ```
     [Video description]

     🔗 Links:
     - GrabTube Website: https://grabtube.com
     - Documentation: https://grabtube.com/docs
     - GitHub: https://github.com/yourusername/grabtube
     - Download: https://grabtube.com/download

     📚 Chapters:
     0:00 Introduction
     0:30 [Section 1]
     2:15 [Section 2]
     ...

     #GrabTube #VideoDownloader #Tutorial
     ```
   - Tags: Relevant keywords
   - Category: Education or Science & Technology

3. **Thumbnail:** Upload custom thumbnail

4. **Playlists:** Add to appropriate playlist

5. **Audience:** Not made for kids (unless it is)

6. **Subtitles:** Upload SRT file

7. **End Screen:** Add subscribe button and next video

8. **Cards:** Add relevant links

9. **Publish:** Set to Public

**Publishing Schedule:**
- Don't upload all at once
- Spread over 2-3 weeks for better algorithm performance
- Or upload all as Unlisted, then publish on schedule

**Checklist:**
- [ ] All 25 videos uploaded
- [ ] All metadata complete
- [ ] Thumbnails uploaded
- [ ] Playlists organized
- [ ] End screens and cards added
- [ ] Publishing schedule set (if staggered)

---

#### Task 5.6.3: Integrate with Website

**Duration:** 2 hours

**Steps:**

1. **Update Video Tutorials Page:**
   - Add YouTube embeds for each video
   - Link to full playlist

2. **Add to Documentation:**
   - Embed relevant videos in docs pages
   - E.g., "Getting Started" doc includes "Getting Started" video

3. **Add to Home Page:**
   - Feature latest or most popular video

**Checklist:**
- [ ] Videos embedded in website
- [ ] Links tested
- [ ] Video page updated

---

### Stage 5.7: Promotion

**Duration:** Ongoing
**Priority:** P3 - Low

#### Task 5.7.1: Promote Videos

**Channels:**

1. **Social Media:**
   - Twitter/X
   - Reddit (r/opensource, r/selfhosted)
   - LinkedIn
   - Facebook groups

2. **Communities:**
   - Discord servers
   - Slack workspaces
   - Forums

3. **Cross-Promotion:**
   - Link to videos in GitHub README
   - Link in documentation
   - Mention in blog posts (if blog exists)

**Checklist:**
- [ ] Promotion plan created
- [ ] Initial announcements posted
- [ ] Community feedback monitored

---

## Phase 6: Final Polish & Release

**Duration:** 1 week
**Goal:** Final testing, bug fixes, and production release
**Status:** Not started

---

### Stage 6.1: Comprehensive Testing

**Duration:** 3 days
**Priority:** P0 - Critical

#### Task 6.1.1: Full Regression Testing

**Duration:** 2 days (16 hours)

**Test All Platforms:**

1. **Flutter Client:**
   - Android (multiple devices/versions)
   - iOS (multiple devices/versions)
   - Windows
   - macOS
   - Linux
   - Web

2. **Android Native Client:**
   - Multiple devices
   - Multiple Android versions

3. **Web Client (Backend):**
   - Multiple browsers

**Test All Features:**
- ✅ Basic downloads
- ✅ Quality selection
- ✅ Format selection
- ✅ Queue management
- ✅ QR scanning
- ✅ Search
- ✅ Favorites
- ✅ Scheduled downloads
- ✅ JDownloader integration
- ✅ History
- ✅ Settings
- ✅ Theme switching
- ✅ Notifications
- ✅ Background downloads

**Test Edge Cases:**
- Poor network conditions
- App killed during download
- Invalid URLs
- Server unavailable
- Storage full
- Permissions denied

**Create Test Report:**
- Document all issues found
- Prioritize by severity
- Track fixes

**Checklist:**
- [ ] All platforms tested
- [ ] All features tested
- [ ] Edge cases tested
- [ ] Test report created

---

#### Task 6.1.2: Fix Critical Bugs

**Duration:** 1 day (8 hours)

**Priority Levels:**
- **P0 - Blocker:** Prevents core functionality, must fix before release
- **P1 - Critical:** Major feature broken, should fix before release
- **P2 - High:** Important bug, can fix in patch release
- **P3 - Medium:** Minor bug, fix when time allows
- **P4 - Low:** Cosmetic issue, low priority

**Process:**
1. Triage all bugs from test report
2. Fix all P0 and P1 bugs
3. Re-test fixed bugs
4. Document known issues (P2-P4)

**Checklist:**
- [ ] All P0 bugs fixed and verified
- [ ] All P1 bugs fixed and verified
- [ ] Known issues documented

---

### Stage 6.2: Release Preparation

**Duration:** 2 days
**Priority:** P0 - Critical

#### Task 6.2.1: Version Numbering

**Duration:** 1 hour

**Semantic Versioning:** v1.0.0

- **Major** (1): Incompatible API changes
- **Minor** (0): Add functionality (backwards-compatible)
- **Patch** (0): Bug fixes (backwards-compatible)

**Update Version Numbers:**
- `Flutter-Client/pubspec.yaml`: `version: 1.0.0+1`
- `Android-Client/app/build.gradle.kts`: `versionName = "1.0.0"`, `versionCode = 1`
- `Web-Client/pyproject.toml`: `version = "1.0.0"`
- `Website/package.json`: `"version": "1.0.0"`

**Checklist:**
- [ ] All version numbers updated
- [ ] Version numbers consistent
- [ ] Git tags created

---

#### Task 6.2.2: Update CHANGELOG

**Duration:** 2 hours

**File:** `CHANGELOG.md`

**Add v1.0.0 Entry:**

```markdown
## [1.0.0] - 2025-11-XX

### Added
- Complete Flutter Client with multi-platform support (Android, iOS, Windows, macOS, Linux, Web)
- QR code scanning for quick URL entry
- Search functionality with history
- Favorites management
- Scheduled downloads with WorkManager integration
- JDownloader integration for external download manager
- Comprehensive test suite (>100% coverage for implemented features)
- Complete documentation (Architecture, API, User Guides)
- Android Native Client with Kotlin + Jetpack Compose
- Project website with MDX documentation
- Video tutorial series (25 videos)

### Fixed
- URL launcher implementation in history page
- [List other bug fixes]

### Changed
- Updated to Flutter 3.24+
- Updated to Kotlin 1.9+
- [List other changes]

### Security
- Release signing configured for production builds
```

**Checklist:**
- [ ] CHANGELOG updated
- [ ] Release date set
- [ ] All changes documented

---

#### Task 6.2.3: Release Notes

**Duration:** 2 hours

**Create Release Notes:**

**File:** `RELEASE_NOTES_v1.0.0.md`

**Content:**
- Summary of release
- Major features
- Breaking changes (if any)
- Known issues
- Upgrade instructions
- Download links

**Checklist:**
- [ ] Release notes written
- [ ] Review and proofread
- [ ] Converted to GitHub release format

---

#### Task 6.2.4: Build Production Artifacts

**Duration:** 4 hours

**Flutter Client:**

```bash
cd Flutter-Client

# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
# (then create archive in Xcode)

# Desktop
flutter build linux --release
flutter build windows --release
flutter build macos --release

# Web
flutter build web --release
```

**Android Client:**

```bash
cd Android-Client
./gradlew assembleRelease
./gradlew bundleRelease
```

**Web Client (Backend):**

```bash
cd Web-Client
docker build -t grabtube-backend:1.0.0 .
docker tag grabtube-backend:1.0.0 grabtube-backend:latest
```

**Generate Checksums:**

```bash
# SHA256 checksums for all release artifacts
sha256sum Flutter-Client/build/app/outputs/flutter-apk/app-release.apk > checksums.txt
sha256sum Android-Client/app/build/outputs/apk/release/app-release.apk >> checksums.txt
# ... for all artifacts
```

**Checklist:**
- [ ] All builds successful
- [ ] All artifacts collected
- [ ] Checksums generated
- [ ] Artifacts tested on target platforms

---

### Stage 6.3: Release

**Duration:** 1 day
**Priority:** P0 - Critical

#### Task 6.3.1: GitHub Release

**Duration:** 2 hours

**Steps:**

1. **Create Git Tag:**
   ```bash
   git tag -a v1.0.0 -m "Version 1.0.0"
   git push origin v1.0.0
   ```

2. **Create GitHub Release:**
   - Go to repository > Releases
   - Click "Create a new release"
   - Tag: v1.0.0
   - Title: "GrabTube v1.0.0 - Initial Production Release"
   - Description: Paste release notes
   - Upload artifacts:
     - APKs
     - App Bundles
     - Desktop installers
     - checksums.txt

3. **Set as Latest Release**

**Checklist:**
- [ ] Git tag created
- [ ] GitHub release created
- [ ] All artifacts uploaded
- [ ] Release notes formatted correctly
- [ ] Release published

---

#### Task 6.3.2: Docker Hub Release

**Duration:** 1 hour

**Steps:**

1. **Login to Docker Hub:**
   ```bash
   docker login
   ```

2. **Tag and Push:**
   ```bash
   docker tag grabtube-backend:1.0.0 yourusername/grabtube:1.0.0
   docker tag grabtube-backend:1.0.0 yourusername/grabtube:latest
   docker push yourusername/grabtube:1.0.0
   docker push yourusername/grabtube:latest
   ```

3. **Update Docker Hub README**

**Checklist:**
- [ ] Docker images pushed
- [ ] Docker Hub README updated
- [ ] Tags verified

---

#### Task 6.3.3: App Store Submissions (Optional)

**Duration:** 4 hours (plus review time)

**Google Play Store (Android):**

1. **Create Play Console Account** (one-time $25 fee)

2. **Create App Listing:**
   - App name, description
   - Screenshots (required: 2-8 per device type)
   - Feature graphic
   - Privacy policy URL

3. **Upload App Bundle:**
   - Production track
   - Release notes

4. **Submit for Review**

**Apple App Store (iOS):**

1. **Enroll in Apple Developer Program** ($99/year)

2. **Create App in App Store Connect:**
   - App information
   - Screenshots
   - Description

3. **Upload via Xcode or Transporter**

4. **Submit for Review**

**Note:** App store reviews can take 1-7 days

**Checklist:**
- [ ] Google Play submission complete (if doing)
- [ ] App Store submission complete (if doing)
- [ ] Awaiting review

---

### Stage 6.4: Announcement & Documentation Update

**Duration:** 1 day
**Priority:** P1 - High

#### Task 6.4.1: Update Documentation

**Duration:** 2 hours

**Updates:**

1. **README.md:**
   - Add version badges
   - Update installation instructions
   - Add download links

2. **Website:**
   - Update download page with v1.0.0 links
   - Update homepage
   - Publish blog post (if blog exists)

3. **CLAUDE.md:**
   - Note v1.0.0 release
   - Update any outdated information

**Checklist:**
- [ ] All documentation updated
- [ ] Links verified
- [ ] Website deployed with updates

---

#### Task 6.4.2: Announcements

**Duration:** 2 hours

**Announce On:**

1. **GitHub:**
   - Pin release
   - Update repository description

2. **Social Media:**
   - Twitter/X
   - Reddit
   - LinkedIn
   - Facebook

3. **Communities:**
   - Discord
   - Slack
   - Forums

4. **Email:** (if mailing list exists)
   - Send release announcement

**Announcement Template:**

```
🎉 GrabTube v1.0.0 is now available!

After months of development, we're excited to announce the first production release of GrabTube - a powerful, multi-platform video downloader.

✨ Features:
- Cross-platform support (Android, iOS, Windows, macOS, Linux, Web)
- Download from YouTube and 1000+ sites
- QR code scanning
- Scheduled downloads
- JDownloader integration
- And much more!

📥 Download: https://grabtube.com/download
📖 Documentation: https://grabtube.com/docs
🎥 Video Tutorials: https://grabtube.com/videos
💻 Source Code: https://github.com/yourusername/grabtube

#GrabTube #OpenSource #VideoDownloader
```

**Checklist:**
- [ ] All announcements posted
- [ ] Community engagement monitored
- [ ] Feedback collected

---

### Stage 6.5: Post-Release Monitoring

**Duration:** Ongoing
**Priority:** P1 - High

#### Task 6.5.1: Monitor for Issues

**Duration:** 1 week intensive, then ongoing

**Monitor:**

1. **GitHub Issues:**
   - Respond to bug reports
   - Triage issues
   - Create hotfix plan if critical bugs found

2. **App Store Reviews:**
   - Monitor ratings
   - Respond to reviews
   - Note common complaints

3. **Analytics:**
   - Website traffic
   - Download numbers
   - Video views

4. **Community Feedback:**
   - Social media mentions
   - Forum discussions

**Prepare Hotfix:**
- If critical bugs found, prepare v1.0.1
- Document bug fixes
- Release as soon as possible

**Checklist:**
- [ ] Monitoring systems in place
- [ ] Response plan for issues
- [ ] Hotfix process documented

---

## Appendix: Test Types Reference

### Supported Test Types (7 Total)

| # | Test Type | Framework | Location | Purpose |
|---|-----------|-----------|----------|---------|
| **1** | **Unit Tests** | flutter_test + mocktail | `test/unit/` | Test individual functions, methods, classes in isolation |
| **2** | **Widget Tests** | flutter_test | `test/widget/` | Test individual widgets and their behavior |
| **3** | **Integration Tests** | flutter_test + mockito | `test/integration/` | Test multiple components working together |
| **4** | **E2E Tests** | Patrol | `test/e2e/` | Test complete user journeys on real devices |
| **5** | **Automation Tests** | Custom framework | `test/automation/` | Automated UI testing scripts |
| **6** | **Performance Tests** | flutter_driver | `test/performance/` | Measure and benchmark app performance |
| **7** | **Golden Tests** | flutter_test | `test/golden/` | UI regression testing with image comparisons |

---

## Summary

This implementation plan provides a complete, step-by-step roadmap to achieve 100% completion of the GrabTube project, including:

- **50+ files** of Flutter implementation (repositories, use cases, BLoCs, pages)
- **20+ test files** to achieve 100% coverage
- **15+ documentation files** for all clients and features
- **Complete website** with marketing pages and MDX documentation
- **25 video tutorials** totaling 280-350 minutes
- **Production release** with app store submissions

**Total Estimated Effort:** 270-380 hours (7-10 weeks full-time)

**Phases:**
1. Phase 0: Preparation (1-2 days)
2. Phase 1: Core Feature Implementation (2-3 weeks)
3. Phase 2: Testing & QA (1 week)
4. Phase 3: Documentation (1.5 weeks)
5. Phase 4: Website Development (2 weeks)
6. Phase 5: Video Course Production (3-4 weeks)
7. Phase 6: Final Polish & Release (1 week)

Each phase is broken down into stages and tasks with clear:
- Duration estimates
- Priority levels
- Deliverables
- Checklists

This plan ensures **nothing is left unfinished** and the project achieves 100% completion with comprehensive testing, documentation, and supplementary materials.

---

**Ready to proceed?** Start with Phase 0, Task 0.1 and work through the plan systematically! 🚀
