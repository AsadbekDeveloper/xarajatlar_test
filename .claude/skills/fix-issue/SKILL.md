---
name: fix-issue
description: Investigate and fix a Flutter bug or issue. Gathers context automatically, finds root cause, confirms approach, then implements and verifies.
disable-model-invocation: true
argument-hint: "issue description"
---

# Fix Issue

## Context
- Branch: !`git branch --show-current`
- Commits: !`git log --oneline -8`
- Changes: !`git diff --stat`
- Analysis: !`flutter analyze --no-pub 2>&1 | tail -20`

**Task:** Fix: $ARGUMENTS

## Steps

### 1: Understand
Parse the issue description. Identify the affected feature/widget/cubit.

### 2: Investigate
- Glob `lib/features/<feature>/`; read cubit/state/page/widget files
- Trace: repository → cubit → widget
- Identify root cause (state bug, rebuild, API parsing, navigation, etc.)

### 3: Confirm
State root cause + minimal fix (files + changes). Ask for confirmation before writing code.

### 4: Implement (follow CLAUDE.md)
- State: `copyWith(loading: false, error: ...)` pattern
- Errors: `Result<T>` (`Success`/`FailureResult`), never throw
- Widgets: `const` · `buildWhen` · private classes only (no `_buildFoo()` methods) · check `lib/widgets/` before creating new · extract to `widgets/` if >60 lines or multi-use
- No hardcoded strings once l10n is in use

### 5: Verify
```bash
flutter analyze --no-pub
flutter test <path>   # if tests exist for this area
```

## Output
1. **Root cause** — what/where
2. **Fix** — files + line refs
3. **Verification** — analyze output
4. **Side effects** — related areas to watch
