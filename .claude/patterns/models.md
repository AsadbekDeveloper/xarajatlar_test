# Models & Repository Patterns

## Result / Failure

Define once in `lib/core/result.dart` and reuse everywhere a repository can fail. Never `throw` across a repository boundary — return a `Result<T>` instead:

```dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}
class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}

sealed class Failure {
  const Failure(this.message);
  final String message;
}
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class ValidationFailure extends Failure { const ValidationFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }
```

Usage in a repository:
```dart
Future<Result<List<Item>>> getItems() async {
  try {
    final response = await _client.get('/items');
    return Success(response.data.map(Item.fromJson).toList());
  } on Exception catch (e) {
    return FailureResult(NetworkFailure(e.toString()));
  }
}
```

Usage in a cubit:
```dart
final res = await _repo.getItems();
if (isClosed) return;
switch (res) {
  case Success(:final value): emit(state.copyWith(items: value));
  case FailureResult(:final failure): emit(state.copyWith(error: failure));
}
```

## Freezed Models (optional)

Only reach for Freezed once a model's generated `copyWith`/equality/`toJson` genuinely saves more than the build_runner overhead costs — plain classes are fine for simple DTOs. Never use Freezed for Cubit/Bloc states.

```dart
@freezed
abstract class ItemDto with _$ItemDto {
  const factory ItemDto({
    required String id,
    required String name,
    required double amount,
  }) = _ItemDto;

  factory ItemDto.fromJson(Map<String, dynamic> json) =>
      _$ItemDtoFromJson(json);
}
```

Parts: `part 'name.freezed.dart';` and `part 'name.g.dart';` (g.dart only when using `fromJson`).
After changes: `dart run build_runner build --delete-conflicting-outputs`

## Repository Interface Pattern

Keep the interface and its implementation in the feature's `data/` folder unless the repository is shared by multiple features, in which case put it under `lib/repositories/`. Either way, **features depend only on the interface**, never the concrete implementation:

```dart
// lib/features/items/data/items_repository.dart — interface
abstract class ItemsRepository {
  Future<Result<List<Item>>> getItems();
  Future<Result<void>> addItem(Item item);
}

// lib/features/items/data/items_api_repository.dart — implementation
class ItemsApiRepository implements ItemsRepository {
  ItemsApiRepository({required Dio client}) : _client = client;
  final Dio _client;

  @override
  Future<Result<List<Item>>> getItems() async {
    try {
      final response = await _client.get('/items');
      return Success((response.data as List).map(Item.fromJson).toList());
    } on Exception catch (e) {
      return FailureResult(NetworkFailure(e.toString()));
    }
  }
}
```

After creating a new repo: instantiate it near the app root and expose it via `RepositoryProvider`. See `CLAUDE.md` §Key Patterns.
