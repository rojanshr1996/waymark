# Project Waymark Coding Standards & Architectural Guidelines

## 1. Strict State Management Standard: NO `setState`
- **Rule**: Do **NOT** use `setState()` anywhere in this codebase (`lib/**`).
- **Standard**: Always use reactive Flutter **Notifiers**:
  - `ValueNotifier<T>` for individual primitives, enums, models, or single state items.
  - `ChangeNotifier` for multi-field form controllers or complex local component states.
  - `ValueListenableBuilder<T>` or `ListenableBuilder` to selectively listen and rebuild ONLY the specific widgets that depend on that state, avoiding full-screen rebuilds.
- **Disposal**: Always remember to call `.dispose()` on all `ValueNotifier` and `ChangeNotifier` instances inside the `State.dispose()` method to prevent memory leaks.
- **Testing & Verification**: Every new feature or refactor must ensure zero instances of `setState()` are introduced.

## 2. Liquid Glass Design System
- Waymark uses an artistic, travel-memoir aesthetic inspired by field journals and frosted glass (`WaymarkLiquidGlass`, `WaymarkLiquidGlassAppBar`, `WaymarkLiquidGlassBottomNavBar`).
- Keep overlay cards radiant, high-contrast, and legible with subtle blurs (`blurSigma: 8.0 - 10.0`) and high-opacity tints (`tintAlpha: 0.82 - 0.94`).

## 3. Database & Data Flow
- Drift ORM (`AppDatabase`) serves as the single source of truth for offline-first journal records.
- Watch tables using DAOs and reactive `StreamBuilder` widgets.
