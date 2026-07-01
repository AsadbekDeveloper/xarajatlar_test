# Naming Conventions

## Files

| Pattern | When |
|---|---|
| `<name>_page.dart` | Route wrapper with `static Route get page` |
| `<name>_view.dart` | Screen content (`Scaffold` + `BlocBuilder`) |
| `<name>_cubit.dart` + `<name>_state.dart` | Always paired |
| `<name>_bloc.dart` + `<name>_event.dart` + `<name>_state.dart` | Bloc triple |
| `<name>_base_cubit.dart` | Abstract base when 2+ cubits share logic |

## Classes

**Cubits:** `{Feature}{Purpose}Cubit`
Examples: `ItemsCubit`, `HomeSummaryCubit`, `SettingsCubit`

**States — copyWith pattern:** single class `{Feature}State` with `loading`, `error`, data fields.

**States — sealed pattern:** base + named subclasses:
```dart
sealed class ItemActionsState { const ItemActionsState(); }
final class ItemActionsInitialState extends ItemActionsState { const ItemActionsInitialState(); }
final class ItemActionsLoadingState extends ItemActionsState { const ItemActionsLoadingState(); }
final class ItemActionsDeleteSuccessState extends ItemActionsState { const ItemActionsDeleteSuccessState(); }
final class ItemActionsErrorState extends ItemActionsState {
  const ItemActionsErrorState(this.message);
  final String message;
}
```
Subclass format: `{CubitName}{Action}{Result}State` — e.g. `ItemActionsDeleteSuccessState`.

**Bloc events:** `{Feature}Event` base, `{Feature}{Action}Event` subclasses.

## ARB Keys

Format: `camelCase`, structured as `{featureName}{ComponentName}` or `{featureName}{Action}`.

```
homeCardTitle              → home feature, card, Title label
settingsSectionHeader      → settings feature, section header
itemDetailsSaveButton      → itemDetails feature, save button
```

## Git Branches

```
feat/{slug}          →  feat/expense-list
fix/{slug}           →  fix/category-crash
```
If an issue tracker is adopted later, prefix with its ID: `feat/{ISSUE-ID}-{slug}`.
