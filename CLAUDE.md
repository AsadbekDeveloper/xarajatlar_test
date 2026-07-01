# Flutter Development Standards

## Tech Stack
**Clean Architecture (lightweight)** · **Feature-first single app** · **flutter_bloc** · **Material 3**

Current dependencies are minimal (see `pubspec.yaml`) — this doc describes the target conventions to grow into as features are added, not infrastructure that already exists. Don't introduce a package/mono-repo split, Freezed, or third-party SDKs (analytics, crash reporting, auth providers, etc.) unless the user explicitly asks for them.

**Layer rule**: features depend only on repository *interfaces*; keep networking/persistence details out of `cubit`/`bloc` and widget code.

---

## Project Structure

```
lib/
  app.dart                    # MaterialApp/theme root
  main.dart                   # entry point, DI bootstrap
  core/                       # cross-feature utilities: result.dart, extensions, constants
  features/<name>/
    data/                     # repository interface + implementation (once needed)
    cubit/<name>_{cubit,state}.dart
    bloc/<name>_{bloc,event,state}.dart   # if using Bloc instead of Cubit
    view/<name>_page.dart                 # route wrapper only; static Route<void> get page
    view/<name>_view.dart                 # Scaffold + content; no BlocProvider here
    widgets/<name>_*.dart                 # extracted widget classes
    <name>.dart                           # barrel export
  widgets/                    # shared widgets used by 2+ features
```

Single `lib/` tree — no `packages/`, no melos. If the app later grows large enough to need a mono-repo, that's a deliberate follow-up decision, not a default.

---

## State Management

**Cubit vs Bloc** — use `Cubit` for data-fetch/CRUD state with direct method calls. Use `Bloc` when you need event transformers (`restartable`, `droppable`, `sequential`) or multiple events with different payloads.

**Cubit state** — plain class + `copyWith` (NOT Freezed):
```dart
ItemsState copyWith({List<Item>? items, bool? loading, Failure? error}) =>
    ItemsState(
      items: items ?? this.items,
      loading: loading ?? false, // always resets — never carry stale loading
      error: error,              // no ?? — always resets to null
    );
```
Add `extends Equatable` + `get props` when state equality matters for `buildWhen`. Use `Failure?` (not `String?`) — see `.claude/patterns/models.md` §Result/Failure.

**Bloc state** — sealed class (NOT Freezed):
```dart
sealed class ItemsState { const ItemsState._(); }
final class ItemsLoaded extends ItemsState {
  const ItemsLoaded(this.items) : super._();
  final List<Item> items;
}
```

**Freezed** — optional, only worth adding once DTOs/models get complex enough that generated `copyWith`/equality pays for the build_runner overhead. Never use it for Cubit/Bloc states.

---

## Error Handling

Never throw across a repository boundary. Return a `Result<T>` (success/failure):
```dart
sealed class Result<T> {}
class Success<T> extends Result<T> { Success(this.value); final T value; }
class FailureResult<T> extends Result<T> { FailureResult(this.failure); final Failure failure; }

sealed class Failure { const Failure(this.message); final String message; }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class ValidationFailure extends Failure { const ValidationFailure(super.message); }
class UnknownFailure extends Failure { const UnknownFailure(super.message); }
```
```dart
final res = await repository.getItems();
switch (res) {
  case Success(:final value): emit(state.copyWith(items: value));
  case FailureResult(:final failure): emit(state.copyWith(error: failure));
}
```
Full construction pattern + repository usage example → `.claude/patterns/models.md`.

---

## Key Patterns

**Stream cleanup** — always override `close()` and cancel subscriptions; missing `close()` → resource leak. See `.claude/patterns/bloc_patterns.md` §Cubit Lifecycle.

**`isClosed` guard** — `if (isClosed) return;` before every `emit()` after an async gap. Never the inverted form.

**`context.mounted` guard** — `if (!context.mounted) return;` after any `await` or `.then()` in widget/listener code.

**No static mutable fields on Cubits** — static state survives disposal; causes bugs after logout→re-login or any cubit rebuild. Use a coordinator cubit or repository instead.

**Event transformers** (define in `lib/core/bloc_utils.dart` once needed): `debounceRestartable()` for search · `sequential()` for pagination · `droppable()` for submit.

**Fire-and-forget**: `unawaited(repo.uploadAnalyticsEvent(event));` for non-blocking calls.

**DI** — `RepositoryProvider`/`BlocProvider`, not GetIt. Instantiate repositories once near the app root (e.g. in `main.dart` or an `AppProviders` widget) and expose via `MultiRepositoryProvider`. Global cubits needed app-wide go in a top-level `MultiBlocProvider`; feature-local cubits use `BlocProvider` at the page level.

---

## Widgets & UI

**Page** — route wrapper, delegates to view:
```dart
static Route<void> get page => MaterialPageRoute(
  settings: const RouteSettings(name: 'FeaturePage'),
  builder: (_) => const FeaturePage(),
);
```

**View** — `Scaffold` + `BlocBuilder`/`BlocSelector` with `buildWhen`:
```dart
body: BlocBuilder<ItemsCubit, ItemsState>(
  buildWhen: (prev, curr) => prev.items != curr.items,
  builder: (context, state) => _ItemList(state.items),
),
```
Use `BlocSelector` for single-field reads (fewer rebuilds).

### Widget Extraction & Reuse

**Reuse first** — before writing any widget or logic, check in order:
1. `lib/widgets/` — app-wide shared widgets
2. `lib/features/*/widgets/` — existing feature widgets
3. `lib/core/` — shared utilities and helpers
For shared cubit logic → extract a base cubit (see `.claude/patterns/bloc_patterns.md`).

**Classes, never methods** — `Widget _buildFoo()` is always wrong. Always a private `StatelessWidget` with a `const` constructor: `class _Header extends StatelessWidget { const _Header(); ... }`. Named after its role, not its position.

**Extract to `widgets/<name>_*.dart`** when: class >60 lines · has own state · used in >1 view.

**Promote to `lib/widgets/`** when: used in 2+ features AND no feature-specific cubit/repo deps.

**Decompose aggressively** — `build()` bodies ≤ ~30 lines. Each visual region (header, item, empty state, loading) → its own class.

### Mandatory Style Rules
- `const` everywhere possible
- `Scaffold` — default for all screens; use `CustomScrollView` + `SliverAppBar` only when the screen needs a pinned/collapsing header with custom scroll physics.
- Never hardcode spacing pixels ad hoc — once a value repeats 3+ times, add it to a small `AppSpacing` constants class in `lib/core/` and reuse it; `SizedBox` for gaps.
- `Theme.of(context).colorScheme` for color — no hardcoded `Colors.*`.
- `context.l10n.key` for all user-visible strings once l10n is set up (ARB in `lib/l10n/arb/`, start with `app_en.arb`). Until l10n exists, keep strings as `const` in one obvious place rather than scattered literals.
- `Navigator.of(context).push(FeaturePage.page)` for navigation (or a thin `context.navigator` extension if you add one) — keep it imperative; don't add GoRouter unless deep-linking is a real requirement.
- Route all error/success feedback through one small set of context extensions (e.g. `context.showError(msg)`, `context.showSuccessToast(msg)`) defined once in `lib/core/` — never call `ScaffoldMessenger` directly in feature code.
- `ListView.builder`/`SliverList` for dynamic lists — never `.map().toList()` in Column
- `buildWhen` on every `BlocBuilder`; `listenWhen` on every `BlocListener`
- `context.read<X>()` one-off · `context.watch<X>()` only inside `build`
- `StatefulWidget` only for genuinely mutable local state

---

## Commands
```bash
flutter analyze                                            # before every PR
dart format .
flutter test
dart run build_runner build --delete-conflicting-outputs  # only once Freezed/JsonSerializable is added
flutter gen-l10n                                           # only once ARB files exist
```

---

## Comments
**Why, not what.** Only comment complex business logic, non-obvious workarounds, or perf decisions.

---

## Workflow

**Be concise** — no repeated unchanged code. Use `/compact` when context grows. Read files before proposing changes. No speculative abstractions or error handling.

### Definition of Done
1. ✅ Code committed (new commit, not amended) — once this becomes a git repo
2. ✅ `flutter analyze` clean
3. ✅ `build_runner` up-to-date (if Freezed/JSON changed)
4. ✅ `flutter gen-l10n` run (if ARB changed)
5. ✅ Barrel exports updated (if new files added)
6. ✅ New repository wired into the app's provider tree (if new repo)
7. ✅ Global cubit added to the top-level `MultiBlocProvider` (if needed app-wide)
8. ✅ All temp files deleted (`plan.md`, analysis notes, any task `.md` files)

### Feature Checklist
- [ ] Structure: `cubit/` (or `bloc/`), `view/`, `widgets/`
- [ ] State: Cubit (`copyWith`) or Bloc (sealed)
- [ ] DI wired (top-level `MultiBlocProvider` or page-local `BlocProvider`)
- [ ] Page/view split; no `BlocProvider` in view
- [ ] Strings → ARB (if l10n adopted); spacing → shared constants; `const` everywhere
- [ ] `buildWhen` on every `BlocBuilder`; `listenWhen` on every `BlocListener`
- [ ] `isClosed` guard before every `emit()` after async gap
- [ ] `close()` overridden if cubit holds subscriptions or timers
- [ ] Errors via `Result<T>`, `Failure?` in state — never `throw` or `String?`
- [ ] Widgets: classes not methods; extracted to file if >60 lines/stateful/multi-use
- [ ] Reused existing shared widgets where applicable

---

## Extended Docs

`.claude/rules/naming.md` — file, class, state, and ARB key conventions
`.claude/patterns/bloc_patterns.md` — Cubit Lifecycle (`close`, `isClosed`), `BlocSelector`, `BlocConsumer`, pagination
`.claude/patterns/models.md` — `Result`/`Failure` pattern, optional Freezed models, repository interface pattern

Update the relevant `.claude/` file when a pattern changes; update CLAUDE.md only for core rules that apply to every file.
