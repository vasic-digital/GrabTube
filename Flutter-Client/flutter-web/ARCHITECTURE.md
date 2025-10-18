# Flutter Web Architecture Guide

Complete architecture documentation for the GrabTube Flutter Web client.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Layers](#architecture-layers)
3. [Project Structure](#project-structure)
4. [Data Flow](#data-flow)
5. [State Management](#state-management)
6. [Dependency Injection](#dependency-injection)
7. [Key Components](#key-components)
8. [Backend Integration](#backend-integration)

## Overview

The Flutter Web client follows **Clean Architecture** principles with clear separation of concerns across four main layers:

```
┌─────────────────────────────────────┐
│      Presentation Layer (UI)        │
│   (Pages, Widgets, BLoC)            │
├─────────────────────────────────────┤
│      Domain Layer (Business)        │
│   (Entities, Repository Interfaces) │
├─────────────────────────────────────┤
│      Data Layer (Implementation)    │
│   (Models, API, Repositories)       │
├─────────────────────────────────────┤
│      Core Layer (Infrastructure)    │
│   (DI, Constants, Utilities)        │
└─────────────────────────────────────┘
```

### Benefits

- ✅ **Testable**: Each layer can be tested independently
- ✅ **Maintainable**: Clear separation of concerns
- ✅ **Scalable**: Easy to add new features
- ✅ **Reusable**: Business logic independent of UI
- ✅ **Type-safe**: Full type safety with Dart

## Architecture Layers

### 1. Presentation Layer (`lib/presentation/`)

Handles UI and user interactions.

**Components:**
- **Pages**: Screen-level widgets (`home_page.dart`)
- **Widgets**: Reusable UI components (`download_card.dart`, `empty_state.dart`)
- **BLoC**: State management (`download_bloc.dart`, `download_event.dart`, `download_state.dart`)

**Responsibilities:**
- Display data to users
- Handle user input
- Manage UI state
- React to state changes

**Example:**
```dart
BlocBuilder<DownloadBloc, DownloadState>(
  builder: (context, state) {
    if (state is DownloadLoaded) {
      return ListView.builder(
        itemCount: state.activeDownloads.length,
        itemBuilder: (context, index) {
          return DownloadCard(download: state.activeDownloads[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

### 2. Domain Layer (`lib/domain/`)

Contains business logic and rules.

**Components:**
- **Entities**: Pure business objects (`download.dart`)
- **Repository Interfaces**: Abstract contracts (`download_repository.dart`)

**Responsibilities:**
- Define business entities
- Define repository contracts
- Contain business rules
- Independent of frameworks

**Example:**
```dart
abstract class DownloadRepository {
  Future<List<Download>> getActiveDownloads();
  Future<Download> addDownload({
    required String url,
    required String quality,
    required String format,
  });
  Stream<Download> watchDownloadUpdates();
}
```

### 3. Data Layer (`lib/data/`)

Implements data operations.

**Components:**
- **Models**: JSON serializable data models (`download_model.dart`)
- **Data Sources**: API clients and WebSocket (`download_api_client.dart`, `download_websocket_client.dart`)
- **Repository Implementations**: Concrete implementations (`download_repository_impl.dart`)

**Responsibilities:**
- Fetch data from API
- Parse JSON responses
- Implement repository interfaces
- Handle WebSocket events

**Example:**
```dart
@override
Future<List<Download>> getActiveDownloads() async {
  final models = await _apiClient.getQueue();
  return models.map((m) => m.toEntity()).toList();
}
```

### 4. Core Layer (`lib/core/`)

Infrastructure and shared code.

**Components:**
- **Dependency Injection**: Service locator setup (`injection.dart`)
- **Constants**: App-wide constants (`app_constants.dart`)
- **Utilities**: Helper functions (`logger.dart`)

**Responsibilities:**
- Configure dependencies
- Provide shared utilities
- Define constants
- Setup logging

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # App constants
│   ├── di/
│   │   └── injection.dart               # Dependency injection
│   └── utils/
│       └── logger.dart                  # Logging utility
│
├── data/
│   ├── datasources/
│   │   ├── download_api_client.dart     # REST API client (Retrofit)
│   │   ├── download_api_client.g.dart   # Generated
│   │   └── download_websocket_client.dart # WebSocket client
│   ├── models/
│   │   ├── download_model.dart          # JSON models
│   │   └── download_model.g.dart        # Generated
│   └── repositories/
│       └── download_repository_impl.dart # Repository implementation
│
├── domain/
│   ├── entities/
│   │   └── download.dart                # Business entities
│   └── repositories/
│       └── download_repository.dart     # Repository interface
│
├── presentation/
│   ├── bloc/
│   │   ├── download_bloc.dart           # BLoC logic
│   │   ├── download_event.dart          # Events
│   │   └── download_state.dart          # States
│   ├── pages/
│   │   └── home_page.dart               # Main page
│   ├── widgets/
│   │   ├── download_card.dart           # Download item card
│   │   ├── empty_state.dart             # Empty state widget
│   │   └── connection_status.dart       # Connection indicator
│   └── app.dart                         # App widget
│
└── main.dart                            # Entry point
```

## Data Flow

### User Action → Backend

```
User Taps "Add Download"
        ↓
HomePage dispatches AddDownload event
        ↓
DownloadBloc receives event
        ↓
DownloadBloc calls repository.addDownload()
        ↓
DownloadRepositoryImpl calls API client
        ↓
DownloadApiClient sends HTTP POST /add
        ↓
Python backend processes request
        ↓
Response returned through layers
        ↓
BLoC updates state
        ↓
UI rebuilds with new state
```

### Backend → User (WebSocket)

```
Backend sends WebSocket event
        ↓
DownloadWebSocketClient receives event
        ↓
Emits to stream
        ↓
DownloadRepositoryImpl listens to stream
        ↓
DownloadBloc subscribed to repository stream
        ↓
BLoC dispatches DownloadUpdated event
        ↓
BLoC updates state
        ↓
UI rebuilds automatically
```

## State Management

Using **flutter_bloc** for predictable state management.

### Events (User Actions)

```dart
// User wants to add download
AddDownload(url: 'https://...', quality: '1080', format: 'mp4')

// User wants to refresh
RefreshDownloads()

// User wants to cancel download
CancelDownload('download-id-123')
```

### States (UI States)

```dart
// Initial state
DownloadInitial()

// Loading data
DownloadLoading()

// Data loaded successfully
DownloadLoaded(
  activeDownloads: [...],
  completedDownloads: [...],
  pendingDownloads: [...],
  isConnected: true,
)

// Error occurred
DownloadError('Failed to load downloads')
```

### BLoC Flow

```dart
// 1. Dispatch event
context.read<DownloadBloc>().add(AddDownload(...));

// 2. BLoC processes event
on<AddDownload>((event, emit) async {
  await repository.addDownload(...);
  emit(DownloadLoaded(...));
});

// 3. UI reacts to state
BlocBuilder<DownloadBloc, DownloadState>(
  builder: (context, state) {
    if (state is DownloadLoaded) {
      return DownloadsList(downloads: state.activeDownloads);
    }
    return LoadingIndicator();
  },
)
```

## Dependency Injection

Using **get_it** for service location.

### Registration (`injection.dart`)

```dart
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // 1. Register Dio
  getIt.registerSingleton<Dio>(Dio(BaseOptions(...)));

  // 2. Register API Client
  getIt.registerSingleton<DownloadApiClient>(
    DownloadApiClient(getIt<Dio>())
  );

  // 3. Register WebSocket Client
  getIt.registerSingleton<DownloadWebSocketClient>(
    DownloadWebSocketClient(serverUrl: '...')
  );

  // 4. Register Repository
  getIt.registerSingleton<DownloadRepository>(
    DownloadRepositoryImpl(
      getIt<DownloadApiClient>(),
      getIt<DownloadWebSocketClient>(),
    )
  );

  // 5. Register BLoC
  getIt.registerFactory<DownloadBloc>(
    () => DownloadBloc(getIt<DownloadRepository>())
  );
}
```

### Usage

```dart
// Get BLoC instance
final bloc = getIt<DownloadBloc>();

// Or use with BlocProvider
BlocProvider(
  create: (_) => getIt<DownloadBloc>(),
  child: HomePage(),
)
```

## Key Components

### 1. Download Entity

Pure business object with no dependencies.

```dart
class Download extends Equatable {
  final String id;
  final String url;
  final String title;
  final DownloadStatus status;
  final double progress;
  final int speed;
  // ... more fields

  // Helper methods
  bool get isActive => status == DownloadStatus.downloading;
  String get formattedSize => '${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';
}
```

### 2. DownloadBloc

Manages download state and business logic.

```dart
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepository _repository;

  DownloadBloc(this._repository) : super(DownloadInitial()) {
    on<LoadDownloads>(_onLoadDownloads);
    on<AddDownload>(_onAddDownload);
    on<DownloadUpdated>(_onDownloadUpdated);
    // ... more handlers

    _subscribeToWebSocket();
  }
}
```

### 3. API Client (Retrofit)

Type-safe HTTP client.

```dart
@RestApi()
abstract class DownloadApiClient {
  factory DownloadApiClient(Dio dio, {String baseUrl}) = _DownloadApiClient;

  @GET('/queue')
  Future<List<DownloadModel>> getQueue();

  @POST('/add')
  Future<AddDownloadResponse> addDownload(@Body() AddDownloadRequest request);
}
```

### 4. WebSocket Client

Real-time updates.

```dart
class DownloadWebSocketClient {
  late io.Socket _socket;

  Stream<DownloadModel> get updates => _updateController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  void connect() {
    _socket = io.io(serverUrl, options);
    _setupEventListeners();
  }
}
```

## Backend Integration

### HTTP Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/queue` | Get active downloads |
| GET | `/done` | Get completed downloads |
| GET | `/pending` | Get pending downloads |
| POST | `/add` | Add new download |
| POST | `/start/{id}` | Start pending download |
| POST | `/cancel/{id}` | Cancel active download |
| DELETE | `/delete/{id}` | Delete download |
| POST | `/clear` | Clear completed |

### WebSocket Events

| Event | Direction | Payload | Purpose |
|-------|-----------|---------|---------|
| `added` | Server → Client | DownloadModel | New download added |
| `updated` | Server → Client | DownloadModel | Download progress updated |
| `completed` | Server → Client | DownloadModel | Download completed |
| `canceled` | Server → Client | DownloadModel | Download canceled |
| `deleted` | Server → Client | String (ID) | Download deleted |
| `cleared` | Server → Client | null | Completed cleared |
| `error` | Server → Client | DownloadModel | Download error |

### Request/Response Examples

**Add Download Request:**
```json
{
  "url": "https://youtube.com/watch?v=...",
  "quality": "1080",
  "format": "mp4",
  "folder": null,
  "auto_start": true
}
```

**Add Download Response:**
```json
{
  "status": "success",
  "download": {
    "id": "uuid-123",
    "url": "https://...",
    "title": "Video Title",
    "status": "downloading",
    "progress": 0.0,
    "quality": "1080",
    "format": "mp4",
    // ... more fields
  }
}
```

**WebSocket Update Event:**
```json
{
  "id": "uuid-123",
  "status": "downloading",
  "progress": 0.45,
  "speed": 1024000,
  "eta": 120,
  "downloaded_bytes": 45000000,
  "total_bytes": 100000000
}
```

## Development Workflow

### 1. Adding a New Feature

**Example: Add "Retry Failed Download" Feature**

1. **Domain Layer**: Add method to repository interface
```dart
// lib/domain/repositories/download_repository.dart
Future<void> retryDownload(String id);
```

2. **Data Layer**: Implement in repository
```dart
// lib/data/repositories/download_repository_impl.dart
@override
Future<void> retryDownload(String id) async {
  await _apiClient.retryDownload(id);
}
```

3. **Presentation Layer**: Add event and handler
```dart
// lib/presentation/bloc/download_event.dart
class RetryDownload extends DownloadEvent {
  final String id;
  const RetryDownload(this.id);
}

// lib/presentation/bloc/download_bloc.dart
on<RetryDownload>(_onRetryDownload);

Future<void> _onRetryDownload(RetryDownload event, Emitter emit) async {
  await _repository.retryDownload(event.id);
  add(const RefreshDownloads());
}
```

4. **UI**: Add button
```dart
// lib/presentation/widgets/download_card.dart
if (download.hasError)
  IconButton(
    icon: Icon(Icons.refresh),
    onPressed: () => context.read<DownloadBloc>().add(RetryDownload(download.id)),
  )
```

### 2. Code Generation

When you modify models or API client:

```bash
# Generate once
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch
```

### 3. Testing Strategy

**Unit Tests**: Test business logic
```dart
test('Download entity calculates formatted size correctly', () {
  final download = Download(totalBytes: 1048576, ...);
  expect(download.formattedSize, '1.0 MB');
});
```

**Widget Tests**: Test UI components
```dart
testWidgets('DownloadCard displays title', (tester) async {
  await tester.pumpWidget(DownloadCard(download: mockDownload));
  expect(find.text('Video Title'), findsOneWidget);
});
```

**BLoC Tests**: Test state management
```dart
blocTest<DownloadBloc, DownloadState>(
  'emits DownloadLoaded when LoadDownloads succeeds',
  build: () => DownloadBloc(mockRepository),
  act: (bloc) => bloc.add(LoadDownloads()),
  expect: () => [
    DownloadLoading(),
    DownloadLoaded(activeDownloads: [...]),
  ],
);
```

## Best Practices

### 1. Immutability

Always use immutable data structures:

```dart
// ✅ Good: Immutable
class Download extends Equatable {
  final String id;
  final String title;
  const Download({required this.id, required this.title});

  Download copyWith({String? id, String? title}) {
    return Download(id: id ?? this.id, title: title ?? this.title);
  }
}

// ❌ Bad: Mutable
class Download {
  String id;
  String title;
  Download(this.id, this.title);
}
```

### 2. Dependency Direction

Dependencies always point inward:

```
Presentation → Domain ← Data
                ↑
              Core
```

- Presentation depends on Domain
- Data depends on Domain
- Domain depends on nothing (except Core)
- Core is used by all layers

### 3. Error Handling

Handle errors at appropriate layers:

```dart
// Repository layer: Convert to domain exceptions
try {
  return await _apiClient.getDownloads();
} catch (e) {
  throw DownloadException('Failed to load downloads: $e');
}

// BLoC layer: Emit error state
try {
  final downloads = await _repository.getDownloads();
  emit(DownloadLoaded(downloads));
} catch (e) {
  emit(DownloadError(e.toString()));
}

// UI layer: Show error message
BlocListener<DownloadBloc, DownloadState>(
  listener: (context, state) {
    if (state is DownloadError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
)
```

### 4. Stream Management

Always clean up streams:

```dart
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  StreamSubscription? _updateSubscription;

  DownloadBloc(this._repository) : super(DownloadInitial()) {
    _updateSubscription = _repository.watchUpdates().listen((download) {
      add(DownloadUpdated(download));
    });
  }

  @override
  Future<void> close() {
    _updateSubscription?.cancel();
    return super.close();
  }
}
```

## Performance Optimization

### 1. Lazy Loading

Only create BLoCs when needed:

```dart
// ✅ Good: Factory registration
getIt.registerFactory<DownloadBloc>(() => DownloadBloc(...));

// ❌ Bad: Singleton (always in memory)
getIt.registerSingleton<DownloadBloc>(DownloadBloc(...));
```

### 2. Selective Rebuilds

Use `BlocBuilder` with `buildWhen`:

```dart
BlocBuilder<DownloadBloc, DownloadState>(
  buildWhen: (previous, current) {
    // Only rebuild if active downloads changed
    return previous is DownloadLoaded &&
           current is DownloadLoaded &&
           previous.activeDownloads != current.activeDownloads;
  },
  builder: (context, state) { ... },
)
```

### 3. Debouncing

Debounce frequent events:

```dart
on<SearchDownloads>(
  _onSearchDownloads,
  transformer: debounce(Duration(milliseconds: 300)),
);
```

## Troubleshooting

### Common Issues

**Issue**: BLoC not updating UI
- **Solution**: Ensure state objects are immutable and use `Equatable`

**Issue**: WebSocket not connecting
- **Solution**: Check CORS settings and server URL

**Issue**: Generated files not found
- **Solution**: Run `flutter pub run build_runner build`

**Issue**: DI not working
- **Solution**: Ensure `configureDependencies()` called in `main()`

---

**Version**: 1.0.0
**Last Updated**: 2024-10-18
**Status**: Production Ready ✅
