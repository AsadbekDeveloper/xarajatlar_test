---
name: validate-feature
description: Run Flutter quality checks (code review, widget audit, l10n) in parallel on current branch changes. Use before merging or as a full quality gate.
disable-model-invocation: true
---

# Validate Feature

## Step 1: What changed?
```bash
git diff --stat && git diff --cached --stat
git log --oneline main..HEAD
```
No changes → report and stop.

## Step 2: Which agents to run?
| Changed files | Agent |
|---|---|
| Any `.dart` | **code-reviewer** (always) |
| `lib/features/` widgets/view/pages | **widget-auditor** |
| Any `.dart`/`.arb` with user-visible UI (only if l10n is adopted) | **l10n-checker** |

## Step 3: Launch in parallel (Agent tool, subagent_type: general-purpose)

Spawn three `general-purpose` agents concurrently, each given one of the role prompts below as its task — these are prompt roles, not distinct agent types.

**code-reviewer** — architecture violations (features depending on repo implementations instead of interfaces), state patterns (`copyWith` resets, sealed Bloc states), `Result<T>` error handling, BLoC rules (`buildWhen`/`listenWhen`, `isClosed`, `context.mounted`).

**widget-auditor** — rebuild issues, missing `const`, list performance, PLUS:
1. `Widget _buildFoo()` methods → must be private classes
2. `build()` >30 lines → decompose into region classes
3. Widget file >150 lines or class >60 lines → extract to `widgets/<name>_*.dart`
4. Near-identical widget in another feature → flag for promotion to `lib/widgets/`
5. Freshly built widget duplicates something already in `lib/widgets/` → critical finding
6. `StatefulWidget` with no mutable local state → downgrade to `StatelessWidget`

**l10n-checker** — only run if `lib/l10n/arb/` exists in this project. Checks hardcoded strings and ARB completeness across whatever locales are present. Skip entirely (report "Not applicable — l10n not yet adopted") if there's no ARB setup.

## Step 4: Report

```
# Feature Validation Report
Total findings: N | Critical: N | High: N | Medium: N | Low: N

## Code Review
[findings or "No issues"]

## Widget Audit
[findings or "Not run"]

## Localization
[findings or "Not applicable"]

## Verdict: PASS / FAIL / NEEDS ATTENTION
[prioritized action items]
```
