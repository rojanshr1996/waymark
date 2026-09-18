# WayMark Architectural & Development Rules

## Rule 1: Theme Context for Colors (Strict)
- **NEVER** reference `WaymarkColors.<color>` directly inside UI widgets or build methods.
- **ALWAYS** retrieve colors from the active `BuildContext` / `ThemeData`:
  - Use `context.colorScheme.primary`, `context.colorScheme.secondary`, `context.colorScheme.surface`, etc.
  - Use `context.colorScheme.surfaceCard`, `context.colorScheme.borderDivider`, `context.colorScheme.textPrimary`, `context.colorScheme.textSecondary`, etc. via `WaymarkColorSchemeExtension`.
  - Alternatively use `Theme.of(context).colorScheme.<color>`.
- **Rationale**: Hardcoded class constants break runtime theming, dynamic brightness, dark mode support, and accessibility contrast adjustments.

## Rule 2: Complete Localization (Strict)
- **NEVER** use hardcoded user-facing string literals in UI widgets (`Text('...')`, dialog titles, toasts, tooltips, validation messages, etc.).
- **ALWAYS** define localization strings in `lib/l10n/app_en.arb`, and expose them via `AppLocalizations` / `context.l10n.<key>`.

## Rule 3: Typography via Theme Context (Strict)
- **ALWAYS** use `context.textTheme.<style>` or `Theme.of(context).textTheme.<style>` rather than constructing raw ad-hoc `TextStyle`s.
