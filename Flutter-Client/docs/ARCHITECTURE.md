# GrabTube Architecture Guide

## Table of Contents
1. [Overview](#overview)
2. [Clean Architecture](#clean-architecture)
3. [State Management](#state-management)
4. [Dependency Injection](#dependency-injection)
5. [Data Flow](#data-flow)
6. [API Communication](#api-communication)
7. [Testing Strategy](#testing-strategy)
8. [Platform Integration](#platform-integration)

## Overview

GrabTube Flutter Client is built using **Clean Architecture** principles with **BLoC pattern** for state management. This ensures:
- **Separation of concerns**
- **Testability**
- **Maintainability**
- **Scalability**
- **Platform independence**

## Clean Architecture

### Layer Structure

```
┌─────────────────────────────────────────┐
│         Presentation Layer               │
│    (UI, BLoCs, Pages, Widgets)          │
├─────────────────────────────────────────┤
│          Domain Layer                    │
│   (Entities, Use Cases, Repositories)    │
├─────────────────────────────────────────┤
│           Data Layer                     │
│  (Models, Repository Impl, Data Sources) │
├─────────────────────────────────────────┤
│           Core Layer                     │
│  (Network, DI, Constants, Utils)         │
└─────────────────────────────────────────┘
```

### Dependency Rule
- **Inner layers** know nothing about outer layers
- **Outer layers** depend on inner layers
- **Domain layer** has no external dependencies

### Layer Responsibilities

#### 1. Presentation Layer (`lib/presentation/`)
**Purpose**: User interface and user interaction

**Components**:
- **Pages**: Full-screen views (`home_page.dart`)
- **Widgets**: Reusable UI components (`download_list_item.dart`)
- **BLoCs**: State management (`download_bloc.dart`)

**Example**:
```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        // UI based on state
      },
    );
  }
}
```

#### 2. Domain Layer (`lib/domain/`)
**Purpose**: Business logic and rules

**Components**:
- **Entities**: Core business objects (`download.dart`, `video_info.dart`)
- **Repository Interfaces**: Abstract data access
- **Use Cases**: Specific business operations

**Example**:
```dart
// Entity
class Download extends Equatable {
  final String id;
  final String title;
  final DownloadStatus status;
  final double progress;
}

// Repository Interface
abstract class DownloadRepository {
  Future<Download> addDownload({required String url});
  Future<List<Download>> getDownloads();
  Stream<Download> get downloadUpdates;
}
```

#### 3. Data Layer (`lib/data/`)
**Purpose**: Data access and external communication

**Components**:
- **Models**: JSON serializable data structures
- **Repository Implementations**: Concrete data access
- **Data Sources**: API clients, local storage

**Example**:
```dart
@Singleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository {
  final ApiClient _apiClient;
  final SocketClient _socketClient;

  @override
  Future<Download> addDownload({required String url}) async {
    final response = await _apiClient.addDownload(url: url);
    return DownloadModel.fromJson(response).toEntity();
  }
}
```

#### 4. Core Layer (`lib/core/`)
**Purpose**: Shared utilities and infrastructure

**Components**:
- **Network**: API client, WebSocket client
- **DI**: Dependency injection configuration
- **Constants**: App-wide constants
- **Utils**: Helper functions

## State Management

### BLoC Pattern

We use **flutter_bloc** for predictable state management:

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Event   │────────▶│   BLoC   │────────▶│  State   │
└──────────┘         └──────────┘         └──────────┘
     ▲                     │                     │
     │                     │                     │
     └─────────────────────┴─────────────────────┘
           User Interaction/Updates
```

### Event-State Flow

1. **User Action** → Event dispatched
2. **BLoC** receives event
3. **BLoC** executes business logic (via repositories)
4. **BLoC** emits new state
5. **UI** rebuilds based on new state

### Example Flow

```dart
// 1. User taps "Add Download"
context.read<DownloadBloc>().add(
  AddDownload(url: 'https://youtube.com/watch?v=...'),
);

// 2. BLoC handles event
on<AddDownload>((event, emit) async {
  emit(DownloadLoading());

  try {
    final download = await repository.addDownload(url: event.url);
    emit(DownloadSuccess(download));
  } catch (e) {
    emit(DownloadError(e.toString()));
  }
});

// 3. UI rebuilds
BlocBuilder<DownloadBloc, DownloadState>(
  builder: (context, state) {
    if (state is DownloadLoading) return CircularProgressIndicator();
    if (state is DownloadSuccess) return DownloadCard(state.download);
    if (state is DownloadError) return ErrorWidget(state.message);
  },
)
```

## Dependency Injection

### Using get_it + injectable

**Setup**:
```dart
@InjectableInit()
Future<void> configureDependencies() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  getIt.registerSingleton(sharedPrefs);

  getIt.init();
}
```

**Registration**:
```dart
@Singleton(as: DownloadRepository)
class DownloadRepositoryImpl implements DownloadRepository { ... }

@injectable
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> { ... }
```

**Usage**:
```dart
final bloc = getIt<DownloadBloc>();
```

## Data Flow

### Download Operation Flow

```
┌──────────────┐
│     User     │
│  Adds URL    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  DownloadBloc│ AddDownload Event
└──────┬───────┘
       │
       ▼
┌──────────────────┐
│ DownloadRepository│
│   (Interface)     │
└──────┬────────────┘
       │
       ▼
┌──────────────────────┐
│ DownloadRepositoryImpl│
└──────┬────────────────┘
       │
       ▼
┌──────────────┐         ┌──────────────┐
│  ApiClient   │         │ SocketClient │
│  (HTTP)      │         │  (WebSocket) │
└──────┬───────┘         └──────┬───────┘
       │                        │
       │                        │
       ▼                        ▼
┌────────────────────────────────────┐
│      Python Backend (yt-dlp)       │
└────────────────────────────────────┘
```

### Real-Time Update Flow

```
Backend Download Progress
       │
       ▼
WebSocket Event ("updated")
       │
       ▼
SocketClient Stream
       │
       ▼
Repository Stream Mapping
       │
       ▼
BLoC Subscription
       │
       ▼
BLoC Emits Updated State
       │
       ▼
UI Rebuilds with New Progress
```

## API Communication

### HTTP Communication (Retrofit + Dio)

```dart
@RestApi()
abstract class ApiClient {
  @POST('/add')
  Future<Map<String, dynamic>> addDownload({
    @Field('url') required String url,
    @Field('quality') String? quality,
  });

  @GET('/queue')
  Future<List<DownloadModel>> getQueue();

  @POST('/delete')
  Future<void> deleteDownload({
    @Field('ids') required List<String> ids,
  });
}
```

### WebSocket Communication (Socket.IO)

```dart
class SocketClient {
  late io.Socket _socket;

  final _downloadUpdatedController = BehaviorSubject<DownloadModel>();
  Stream<DownloadModel> get downloadUpdated => _downloadUpdatedController.stream;

  void _initialize() {
    _socket = io.io(serverUrl, options);

    _socket.on('updated', (data) {
      final download = DownloadModel.fromJson(data);
      _downloadUpdatedController.add(download);
    });
  }
}
```

## Testing Strategy

### Test Pyramid

```
        /\
       /  \      E2E Tests (Patrol)
      /    \     - Complete user flows
     /──────\    - Real devices
    /        \
   /  Integration  \   Integration Tests
  /     Tests      \  - Feature flows
 /                  \ - Multiple components
/────────────────────\
│   Widget Tests     │ Widget Tests
│   Unit Tests       │ - UI components
│                    │ - Business logic
└────────────────────┘
```

### Coverage Goals
- **Unit Tests**: >90% coverage
- **Widget Tests**: All UI components
- **Integration Tests**: Critical paths
- **E2E Tests**: Major user flows

### Example Tests

**Unit Test**:
```dart
test('should return correct progress percentage', () {
  final download = Download(progress: 0.75);
  expect(download.progressPercentage, 75);
});
```

**Widget Test**:
```dart
testWidgets('should display download title', (tester) async {
  await tester.pumpWidget(DownloadListItem(download: testDownload));
  expect(find.text('Test Video'), findsOneWidget);
});
```

**Integration Test**:
```dart
testWidgets('should add download successfully', (tester) async {
  // Open add dialog
  await tester.tap(find.byType(FloatingActionButton));

  // Enter URL
  await tester.enterText(find.byType(TextField), testUrl);

  // Submit
  await tester.tap(find.text('Add'));

  // Verify success
  expect(find.text('Download added'), findsOneWidget);
});
```

**E2E Test (Patrol)**:
```dart
patrolTest('complete download flow', ($) async {
  await $.tap(find.byType(FloatingActionButton));
  await $(TextField).enterText(testUrl);
  await $('Add').tap();

  // Verify download appears in queue
  expect($('Test Video'), findsOneWidget);
});
```

## Platform Integration

### Android
- Native channels for device info
- Workmanager for background tasks
- Notifications via flutter_local_notifications
- Deep links via intent filters

### iOS
- Method channels for device info
- Background fetch for updates
- Notifications via UNUserNotificationCenter
- Universal links

### Desktop
- System tray (Windows/macOS/Linux)
- File system integration
- Native menus
- Keyboard shortcuts

### Platform Channel Example

```dart
// Dart side
class NativeChannel {
  static const platform = MethodChannel('com.grabtube.app/native');

  Future<Map<String, String>> getDeviceInfo() async {
    return await platform.invokeMethod('getDeviceInfo');
  }
}

// Kotlin (Android)
MethodChannel(flutterEngine.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
  when (call.method) {
    "getDeviceInfo" -> result.success(getDeviceInfo())
  }
}

// Swift (iOS)
let channel = FlutterMethodChannel(name: CHANNEL, binaryMessenger: controller.binaryMessenger)
channel.setMethodCallHandler { call, result in
  if call.method == "getDeviceInfo" {
    result(getDeviceInfo())
  }
}
```

## Performance Optimization

### Best Practices
1. **Lazy Loading**: Load data on demand
2. **Pagination**: Infinite scroll for large lists
3. **Caching**: Cache network responses
4. **Debouncing**: Debounce search inputs
5. **Image Optimization**: Use cached_network_image
6. **State Optimization**: Use Equatable for efficient rebuilds

### Memory Management
- Dispose streams and controllers
- Cancel subscriptions in BLoC close()
- Use const constructors where possible
- Optimize list rendering with ListView.builder

## Security Considerations

1. **API Keys**: Store in environment variables
2. **Secure Storage**: Use flutter_secure_storage
3. **HTTPS Only**: Enforce secure connections
4. **Input Validation**: Validate all user input
5. **Error Handling**: Never expose sensitive info in errors

## Conclusion

This architecture provides:
- ✅ **Testability**: Each layer can be tested independently
- ✅ **Maintainability**: Clear separation of concerns
- ✅ **Scalability**: Easy to add new features
- ✅ **Platform Independence**: Core logic works everywhere
- ✅ **Performance**: Optimized for all platforms

For questions or clarifications, please refer to the code examples or reach out to the team.
