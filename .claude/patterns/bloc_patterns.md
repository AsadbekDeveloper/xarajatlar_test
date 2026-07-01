# BLoC Patterns

## Cubit Lifecycle

**`close()` override** — required whenever a cubit holds subscriptions or timers:

```dart
StreamSubscription<X>? _sub;

@override
Future<void> close() async {
  await _sub?.cancel();
  await super.close();
}
```

**`isClosed` guard** — before every `emit()` that follows an async gap:

```dart
final res = await _repo.getItems();
if (isClosed) return;
emit(state.copyWith(items: res.data ?? []));
```

**`context.mounted` guard** — in widget listeners after any async gap:

```dart
final ok = await showDialog<bool>(context: context, builder: ...);
if (!context.mounted) return;
Navigator.of(context).pop();
```

---

## BlocSelector — single field, fewer rebuilds

Use instead of `BlocBuilder` when you only need one field.

```dart
BlocSelector<ItemsCubit, ItemsState, Item?>(
  selector: (state) => state.items.firstWhereOrNull((i) => i.id == id),
  builder: (context, item) {
    if (item == null) return const SizedBox.shrink();
    return _ItemCard(item: item);
  },
)
```

## BlocConsumer — side effects + UI on the same cubit

Prefer over nested `BlocListener` + `BlocBuilder` when both target the same cubit.

```dart
BlocConsumer<ItemActionsCubit, ItemActionsState>(
  listenWhen: (prev, curr) =>
      curr is ItemActionsDeleteSuccessState || curr is ItemActionsErrorState,
  listener: (context, state) {
    if (!context.mounted) return;
    switch (state) {
      case ItemActionsDeleteSuccessState(): Navigator.of(context).pop();
      case ItemActionsErrorState(:final message): context.showError(message);
      default: break;
    }
  },
  buildWhen: (prev, curr) =>
      prev is ItemActionsLoadingState != curr is ItemActionsLoadingState,
  builder: (context, state) => ElevatedButton(
    onPressed: () => context.read<ItemActionsCubit>().delete(),
    child: state is ItemActionsLoadingState
        ? const CircularProgressIndicator()
        : Text(context.l10n.itemActionsDeleteButton),
  ),
)
```

Always guard listeners: `if (!context.mounted) return;`

## Pagination (loadingMore + hasMore)

State needs two separate loading flags. Guard at the top; append on load-more:

```dart
// state fields: loading, loadingMore, hasMore, List<X> items

Future<void> loadMore() async {
  if (state.loadingMore || !state.hasMore) return;  // guard first
  emit(state.copyWith(loadingMore: true));
  final res = await _repo.getItems(offset: state.items.length);
  switch (res) {
    case Success(:final value):
      emit(state.copyWith(
        loadingMore: false,
        items: [...state.items, ...value.data],
        hasMore: value.currentPage < value.totalPages - 1,
      ));
    case FailureResult():
      emit(state.copyWith(loadingMore: false));
  }
}
```

In the list widget: `itemCount: items.length + (hasMore ? 1 : 0)` — the extra slot renders a spinner.
Trigger `loadMore()` when `isNearEnd && !loadingMore && hasMore`.
Use a `sequential()` transformer, defined in `lib/core/bloc_utils.dart` once you need it, for Bloc events (see §Pagination above for the calling pattern).

## Result / Failure

See `.claude/patterns/models.md` §Result/Failure for the sealed-class shape used across `Response`-style calls and how to switch on it in state updates.

## Base cubit inheritance

When 2+ cubits share fetch/pagination logic, extract an abstract base:
```dart
// item_list_base_cubit.dart
abstract class ItemListBaseCubit extends Cubit<ItemListBaseState> {
  ItemSortOrder get sortOrder; // subclass provides
}
class RecentItemListCubit extends ItemListBaseCubit {
  @override ItemSortOrder get sortOrder => ItemSortOrder.recent;
}
class ArchivedItemListCubit extends ItemListBaseCubit {
  @override ItemSortOrder get sortOrder => ItemSortOrder.archived;
}
```
