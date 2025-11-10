# Flutter Implementation Templates

This file contains ready-to-use templates for implementing Phase 1 features.

---

## 🎯 Entity Template

**Use for:** Creating domain entities (Stage 1.1)

```dart
// File: lib/domain/entities/[entity_name].dart
import 'package:equatable/equatable.dart';

/// Represents a [EntityName] in the domain layer.
///
/// [Add detailed description of what this entity represents]
class EntityName extends Equatable {
  /// The unique identifier for this entity.
  final String id;

  /// [Add description for each field]
  final String name;

  /// [Add more fields as needed]
  final DateTime createdAt;

  /// Creates an instance of [EntityName].
  const EntityName({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  /// Creates a copy of this entity with updated fields.
  EntityName copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return EntityName(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt];

  @override
  String toString() => 'EntityName(id: $id, name: $name, createdAt: $createdAt)';
}
```

**Next Step:** Create corresponding test file (see Unit Test Template below)

---

## 🧪 Unit Test Template (Entity)

**Use for:** Testing domain entities

```dart
// File: test/unit/domain/entities/[entity_name]_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/domain/entities/entity_name.dart';

void main() {
  group('EntityName', () {
    late EntityName testEntity;

    setUp(() {
      testEntity = EntityName(
        id: 'test-id',
        name: 'Test Name',
        createdAt: DateTime(2025, 1, 1),
      );
    });

    test('should be a subclass of Equatable', () {
      expect(testEntity, isA<Equatable>());
    });

    test('should support value equality', () {
      final entity1 = EntityName(
        id: 'test-id',
        name: 'Test Name',
        createdAt: DateTime(2025, 1, 1),
      );
      final entity2 = EntityName(
        id: 'test-id',
        name: 'Test Name',
        createdAt: DateTime(2025, 1, 1),
      );

      expect(entity1, equals(entity2));
    });

    test('should return correct props', () {
      expect(
        testEntity.props,
        equals(['test-id', 'Test Name', DateTime(2025, 1, 1)]),
      );
    });

    test('copyWith should return entity with updated values', () {
      final result = testEntity.copyWith(name: 'Updated Name');

      expect(result.id, equals('test-id'));
      expect(result.name, equals('Updated Name'));
      expect(result.createdAt, equals(DateTime(2025, 1, 1)));
    });

    test('copyWith should keep original values when null is passed', () {
      final result = testEntity.copyWith();

      expect(result, equals(testEntity));
    });

    test('toString should return correct string representation', () {
      expect(
        testEntity.toString(),
        equals('EntityName(id: test-id, name: Test Name, createdAt: 2025-01-01 00:00:00.000)'),
      );
    });
  });
}
```

---

## 🔌 Repository Interface Template

**Use for:** Creating repository interfaces (Stage 1.2)

```dart
// File: lib/domain/repositories/[feature]_repository.dart
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/entity_name.dart';

/// Repository for managing [EntityName] data.
///
/// Provides methods to interact with [EntityName] data from various sources.
abstract class EntityNameRepository {
  /// Retrieves all entities.
  ///
  /// Returns [Either]:
  /// - [Left] with [Failure] if the operation fails
  /// - [Right] with list of [EntityName] if successful
  Future<Either<Failure, List<EntityName>>> getAll();

  /// Retrieves a single entity by [id].
  ///
  /// Returns [Either]:
  /// - [Left] with [Failure] if entity not found or operation fails
  /// - [Right] with [EntityName] if successful
  Future<Either<Failure, EntityName>> getById(String id);

  /// Creates a new entity.
  ///
  /// Returns [Either]:
  /// - [Left] with [Failure] if creation fails
  /// - [Right] with created [EntityName] if successful
  Future<Either<Failure, EntityName>> create(EntityName entity);

  /// Updates an existing entity.
  ///
  /// Returns [Either]:
  /// - [Left] with [Failure] if update fails
  /// - [Right] with updated [EntityName] if successful
  Future<Either<Failure, EntityName>> update(EntityName entity);

  /// Deletes an entity by [id].
  ///
  /// Returns [Either]:
  /// - [Left] with [Failure] if deletion fails
  /// - [Right] with void if successful
  Future<Either<Failure, void>> delete(String id);

  /// Stream of entity updates for real-time synchronization.
  Stream<EntityName> get updates;
}
```

---

## ⚙️ Use Case Template

**Use for:** Creating use cases (Stage 1.3)

```dart
// File: lib/domain/usecases/[feature]/[action]_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/entity_name.dart';
import '../../repositories/entity_name_repository.dart';

/// Use case for [describe what this use case does].
///
/// Example:
/// ```dart
/// final useCase = GetEntityByIdUseCase(repository);
/// final result = await useCase(GetEntityByIdParams(id: '123'));
/// result.fold(
///   (failure) => print('Error: $failure'),
///   (entity) => print('Got entity: $entity'),
/// );
/// ```
class GetEntityByIdUseCase implements UseCase<EntityName, GetEntityByIdParams> {
  final EntityNameRepository repository;

  /// Creates a [GetEntityByIdUseCase] with the given [repository].
  GetEntityByIdUseCase(this.repository);

  @override
  Future<Either<Failure, EntityName>> call(GetEntityByIdParams params) async {
    // Add any business logic/validation here
    if (params.id.isEmpty) {
      return Left(InvalidInputFailure('ID cannot be empty'));
    }

    return await repository.getById(params.id);
  }
}

/// Parameters for [GetEntityByIdUseCase].
class GetEntityByIdParams extends Equatable {
  /// The entity ID to retrieve.
  final String id;

  /// Creates parameters for getting an entity by ID.
  const GetEntityByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
```

**Use Case Test Template:**

```dart
// File: test/unit/domain/usecases/[feature]/[action]_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grabtube/core/error/failures.dart';
import 'package:grabtube/domain/entities/entity_name.dart';
import 'package:grabtube/domain/repositories/entity_name_repository.dart';
import 'package:grabtube/domain/usecases/feature/get_entity_by_id_usecase.dart';

class MockEntityNameRepository extends Mock implements EntityNameRepository {}

void main() {
  late GetEntityByIdUseCase useCase;
  late MockEntityNameRepository mockRepository;

  setUp(() {
    mockRepository = MockEntityNameRepository();
    useCase = GetEntityByIdUseCase(mockRepository);
  });

  const testId = 'test-id';
  final testEntity = EntityName(
    id: testId,
    name: 'Test',
    createdAt: DateTime(2025, 1, 1),
  );

  group('GetEntityByIdUseCase', () {
    test('should get entity from repository when ID is valid', () async {
      // arrange
      when(() => mockRepository.getById(testId))
          .thenAnswer((_) async => Right(testEntity));

      // act
      final result = await useCase(const GetEntityByIdParams(id: testId));

      // assert
      expect(result, equals(Right(testEntity)));
      verify(() => mockRepository.getById(testId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // arrange
      when(() => mockRepository.getById(testId))
          .thenAnswer((_) async => Left(ServerFailure('Not found')));

      // act
      final result = await useCase(const GetEntityByIdParams(id: testId));

      // assert
      expect(result, equals(Left(ServerFailure('Not found'))));
      verify(() => mockRepository.getById(testId)).called(1);
    });

    test('should return InvalidInputFailure when ID is empty', () async {
      // act
      final result = await useCase(const GetEntityByIdParams(id: ''));

      // assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<InvalidInputFailure>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(() => mockRepository.getById(any()));
    });
  });
}
```

---

## 📦 Data Model Template

**Use for:** Creating data models with JSON serialization (Stage 1.4)

```dart
// File: lib/data/models/[entity_name]_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/entity_name.dart';

part 'entity_name_model.g.dart';

/// Data model for [EntityName].
///
/// Extends [EntityName] entity and adds JSON serialization.
@JsonSerializable()
class EntityNameModel extends EntityName {
  /// Creates an [EntityNameModel].
  const EntityNameModel({
    required String id,
    required String name,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          createdAt: createdAt,
        );

  /// Creates an [EntityNameModel] from JSON.
  factory EntityNameModel.fromJson(Map<String, dynamic> json) =>
      _$EntityNameModelFromJson(json);

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() => _$EntityNameModelToJson(this);

  /// Creates an [EntityNameModel] from an [EntityName] entity.
  factory EntityNameModel.fromEntity(EntityName entity) {
    return EntityNameModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
  }

  /// Converts this model to an [EntityName] entity.
  EntityName toEntity() {
    return EntityName(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }
}
```

**After creating the model, run:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Model Test Template:**

```dart
// File: test/unit/data/models/[entity_name]_model_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:grabtube/data/models/entity_name_model.dart';
import 'package:grabtube/domain/entities/entity_name.dart';

void main() {
  group('EntityNameModel', () {
    final testModel = EntityNameModel(
      id: 'test-id',
      name: 'Test Name',
      createdAt: DateTime(2025, 1, 1),
    );

    final testJson = {
      'id': 'test-id',
      'name': 'Test Name',
      'createdAt': '2025-01-01T00:00:00.000',
    };

    test('should be a subclass of EntityName', () {
      expect(testModel, isA<EntityName>());
    });

    group('fromJson', () {
      test('should return valid model from JSON', () {
        final result = EntityNameModel.fromJson(testJson);

        expect(result.id, equals('test-id'));
        expect(result.name, equals('Test Name'));
        expect(result.createdAt, equals(DateTime(2025, 1, 1)));
      });
    });

    group('toJson', () {
      test('should return valid JSON map', () {
        final result = testModel.toJson();

        expect(result, equals(testJson));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final entity = EntityName(
          id: 'test-id',
          name: 'Test Name',
          createdAt: DateTime(2025, 1, 1),
        );

        final result = EntityNameModel.fromEntity(entity);

        expect(result.id, equals(entity.id));
        expect(result.name, equals(entity.name));
        expect(result.createdAt, equals(entity.createdAt));
      });
    });

    group('toEntity', () {
      test('should create entity from model', () {
        final result = testModel.toEntity();

        expect(result, isA<EntityName>());
        expect(result.id, equals(testModel.id));
        expect(result.name, equals(testModel.name));
        expect(result.createdAt, equals(testModel.createdAt));
      });
    });
  });
}
```

---

## 🎯 BLoC Template

**Use for:** Creating BLoC state management (Stage 1.6)

### BLoC Event

```dart
// File: lib/presentation/blocs/[feature]/[feature]_event.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entity_name.dart';

/// Base class for [Feature] events.
abstract class FeatureEvent extends Equatable {
  const FeatureEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all entities.
class LoadEntities extends FeatureEvent {
  const LoadEntities();
}

/// Event to load entity by ID.
class LoadEntityById extends FeatureEvent {
  final String id;

  const LoadEntityById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to create new entity.
class CreateEntity extends FeatureEvent {
  final EntityName entity;

  const CreateEntity(this.entity);

  @override
  List<Object?> get props => [entity];
}

/// Event to update entity.
class UpdateEntity extends FeatureEvent {
  final EntityName entity;

  const UpdateEntity(this.entity);

  @override
  List<Object?> get props => [entity];
}

/// Event to delete entity.
class DeleteEntity extends FeatureEvent {
  final String id;

  const DeleteEntity(this.id);

  @override
  List<Object?> get props => [id];
}
```

### BLoC State

```dart
// File: lib/presentation/blocs/[feature]/[feature]_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/entity_name.dart';

/// Base class for [Feature] states.
abstract class FeatureState extends Equatable {
  const FeatureState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class FeatureInitial extends FeatureState {
  const FeatureInitial();
}

/// Loading state.
class FeatureLoading extends FeatureState {
  const FeatureLoading();
}

/// Loaded state with entities.
class FeatureLoaded extends FeatureState {
  final List<EntityName> entities;

  const FeatureLoaded(this.entities);

  @override
  List<Object?> get props => [entities];
}

/// Single entity loaded state.
class FeatureSingleLoaded extends FeatureState {
  final EntityName entity;

  const FeatureSingleLoaded(this.entity);

  @override
  List<Object?> get props => [entity];
}

/// Error state.
class FeatureError extends FeatureState {
  final String message;

  const FeatureError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Entity created successfully.
class FeatureCreated extends FeatureState {
  final EntityName entity;

  const FeatureCreated(this.entity);

  @override
  List<Object?> get props => [entity];
}

/// Entity updated successfully.
class FeatureUpdated extends FeatureState {
  final EntityName entity;

  const FeatureUpdated(this.entity);

  @override
  List<Object?> get props => [entity];
}

/// Entity deleted successfully.
class FeatureDeleted extends FeatureState {
  final String id;

  const FeatureDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
```

### BLoC Implementation

```dart
// File: lib/presentation/blocs/[feature]/[feature]_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/feature/get_all_entities_usecase.dart';
import '../../../domain/usecases/feature/get_entity_by_id_usecase.dart';
import '../../../domain/usecases/feature/create_entity_usecase.dart';
import '../../../domain/usecases/feature/update_entity_usecase.dart';
import '../../../domain/usecases/feature/delete_entity_usecase.dart';
import 'feature_event.dart';
import 'feature_state.dart';

/// BLoC for managing [Feature] state.
@injectable
class FeatureBloc extends Bloc<FeatureEvent, FeatureState> {
  final GetAllEntitiesUseCase getAllEntitiesUseCase;
  final GetEntityByIdUseCase getEntityByIdUseCase;
  final CreateEntityUseCase createEntityUseCase;
  final UpdateEntityUseCase updateEntityUseCase;
  final DeleteEntityUseCase deleteEntityUseCase;

  /// Creates a [FeatureBloc].
  FeatureBloc({
    required this.getAllEntitiesUseCase,
    required this.getEntityByIdUseCase,
    required this.createEntityUseCase,
    required this.updateEntityUseCase,
    required this.deleteEntityUseCase,
  }) : super(const FeatureInitial()) {
    on<LoadEntities>(_onLoadEntities);
    on<LoadEntityById>(_onLoadEntityById);
    on<CreateEntity>(_onCreateEntity);
    on<UpdateEntity>(_onUpdateEntity);
    on<DeleteEntity>(_onDeleteEntity);
  }

  Future<void> _onLoadEntities(
    LoadEntities event,
    Emitter<FeatureState> emit,
  ) async {
    emit(const FeatureLoading());

    final result = await getAllEntitiesUseCase(NoParams());

    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (entities) => emit(FeatureLoaded(entities)),
    );
  }

  Future<void> _onLoadEntityById(
    LoadEntityById event,
    Emitter<FeatureState> emit,
  ) async {
    emit(const FeatureLoading());

    final result = await getEntityByIdUseCase(
      GetEntityByIdParams(id: event.id),
    );

    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (entity) => emit(FeatureSingleLoaded(entity)),
    );
  }

  Future<void> _onCreateEntity(
    CreateEntity event,
    Emitter<FeatureState> emit,
  ) async {
    emit(const FeatureLoading());

    final result = await createEntityUseCase(
      CreateEntityParams(entity: event.entity),
    );

    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (entity) => emit(FeatureCreated(entity)),
    );
  }

  Future<void> _onUpdateEntity(
    UpdateEntity event,
    Emitter<FeatureState> emit,
  ) async {
    emit(const FeatureLoading());

    final result = await updateEntityUseCase(
      UpdateEntityParams(entity: event.entity),
    );

    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (entity) => emit(FeatureUpdated(entity)),
    );
  }

  Future<void> _onDeleteEntity(
    DeleteEntity event,
    Emitter<FeatureState> emit,
  ) async {
    emit(const FeatureLoading());

    final result = await deleteEntityUseCase(
      DeleteEntityParams(id: event.id),
    );

    result.fold(
      (failure) => emit(FeatureError(failure.message)),
      (_) => emit(FeatureDeleted(event.id)),
    );
  }
}
```

---

## 📱 Page Template

**Use for:** Creating presentation pages (Stage 1.7)

```dart
// File: lib/presentation/pages/[feature]_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../blocs/feature/feature_bloc.dart';
import '../blocs/feature/feature_event.dart';
import '../blocs/feature/feature_state.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state_widget.dart';

/// Page for displaying and managing [Feature].
class FeaturePage extends StatelessWidget {
  const FeaturePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FeatureBloc>()..add(const LoadEntities()),
      child: const FeatureView(),
    );
  }
}

/// View component for [FeaturePage].
class FeatureView extends StatelessWidget {
  const FeatureView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FeatureBloc>().add(const LoadEntities());
            },
          ),
        ],
      ),
      body: BlocConsumer<FeatureBloc, FeatureState>(
        listener: (context, state) {
          if (state is FeatureError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is FeatureCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entity created successfully')),
            );
            context.read<FeatureBloc>().add(const LoadEntities());
          }
        },
        builder: (context, state) {
          if (state is FeatureLoading) {
            return const LoadingView();
          } else if (state is FeatureError) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<FeatureBloc>().add(const LoadEntities());
              },
            );
          } else if (state is FeatureLoaded) {
            if (state.entities.isEmpty) {
              return const EmptyStateWidget(
                message: 'No entities found',
              );
            }
            return ListView.builder(
              itemCount: state.entities.length,
              itemBuilder: (context, index) {
                final entity = state.entities[index];
                return ListTile(
                  title: Text(entity.name),
                  subtitle: Text(entity.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<FeatureBloc>().add(
                        DeleteEntity(entity.id),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create entity page or show dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## 🚀 Quick Start Checklist

Use this checklist when implementing a new feature:

### Phase 1: Domain Layer
- [ ] Create entity class
- [ ] Write entity tests
- [ ] Run tests: `flutter test test/unit/domain/entities/[entity]_test.dart`
- [ ] Create repository interface
- [ ] Create use case classes (typically 4-6 per feature)
- [ ] Write use case tests
- [ ] Run tests: `flutter test test/unit/domain/usecases/[feature]/`

### Phase 2: Data Layer
- [ ] Create data model class
- [ ] Add JSON serialization annotations
- [ ] Run code generation: `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Write model tests
- [ ] Run tests: `flutter test test/unit/data/models/[model]_test.dart`
- [ ] Implement repository
- [ ] Write repository tests
- [ ] Run tests: `flutter test test/unit/data/repositories/[repo]_test.dart`

### Phase 3: Presentation Layer
- [ ] Create BLoC event class
- [ ] Create BLoC state class
- [ ] Create BLoC implementation
- [ ] Write BLoC tests
- [ ] Run tests: `flutter test test/unit/presentation/blocs/[feature]/`
- [ ] Create page/screen
- [ ] Write widget tests
- [ ] Run tests: `flutter test test/widget/[page]_test.dart`

### Phase 4: Integration
- [ ] Register in DI (injection.dart)
- [ ] Run code generation for DI
- [ ] Add navigation routes
- [ ] Write integration tests
- [ ] Run all tests: `flutter test`
- [ ] Manual testing on device

---

## 💡 Pro Tips

1. **Copy-Paste-Modify:** Don't type everything from scratch. Copy a template, modify names and logic.

2. **Test-First:** Create the test file first, then implement to pass the tests.

3. **Run Tests Often:** After each file, run its tests immediately.

4. **Code Generation:** Remember to run `flutter pub run build_runner build --delete-conflicting-outputs` after creating/modifying models.

5. **DI Registration:** Don't forget to register new components in `injection.dart` and run code generation.

6. **Follow Patterns:** Look at existing implementations (like `download_bloc.dart`) for reference.

7. **Small Commits:** Commit after each working file or small feature.

---

## 🔗 Related Documentation

- Full implementation plan: `DETAILED_IMPLEMENTATION_PLAN.md`
- Quick start guide: `IMPLEMENTATION_QUICK_START.md`
- Project architecture: `Flutter-Client/docs/ARCHITECTURE.md`

---

**Happy coding! Use these templates to speed up your implementation! 🚀**
