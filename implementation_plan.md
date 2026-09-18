# WayMark - Detailed Implementation Plan

This document provides a comprehensive, step-by-step implementation blueprint for the **WayMark** application, encompassing architecture, UI/UX, local database, maps, onboarding, permissions, and CI/CD distribution.

---

## 1. Feasibility Assessment (Local Storage & Maps)

**Can this app be developed solely using local storage and free map tiers without paying?**
**Yes, absolutely.**

*   **Local Storage & Media:** The combination of `drift` (SQLite) for structured relational data and the device's native file system (via `path_provider`) for media storage is 100% free, offline-capable, and highly performant. `flutter_image_compress` ensures that local storage doesn't bloat.
*   **Map Rendering:** The `google_maps_flutter` SDK for rendering maps on iOS and Android is **completely free** for mobile apps (unlimited map loads). 
*   **Routing & Geocoding:** Google's Directions API and Geocoding API offer a **$200/month recurring free credit** (~40,000 routing requests per month for free). 
*   **100% Free Alternative (Option A in SRS):** To guarantee zero costs at any scale, the app can utilize `flutter_map` (OpenStreetMap) combined with free OSRM (Open Source Routing Machine) public APIs and Nominatim (for geocoding). 

**Decision for MVP:** We will proceed with `flutter_map` and OSRM (Option A) to guarantee a zero-cost infrastructure, or utilize `google_maps_flutter` combined with a mocked/cached routing engine for the initial build.

---

## 2. Mandatory UI Architectural Rules (Design & Motion Standards)

The following UI/UX architectural rules are strictly enforced across **every page, screen, and component** in WayMark:

### Rule 1: Liquid Glass Effect
*   **App Bars:** Every page header must use `WaymarkLiquidGlassAppBar` (or `WaymarkLiquidGlass` for custom sliver headers). Headers must feature hardware-accelerated frosted blur (`BackdropFilter` with `ImageFilter.blur`), specular glass gradient highlights, and a delicate hairline divider.
*   **Bottom Navigation:** All primary destination pages must use `WaymarkLiquidGlassBottomNavBar` with upward ambient elevation shadow (`0 -2px 12px rgba(31, 36, 33, 0.05)`), active pill indicator, and tactile haptic feedback on tab changes.

### Rule 2: Page & Component Entrance Animations
*   **Zero Abrupt Transitions:** No widget or screen component may pop abruptly into existence. Every content block, card, list item, and detail section must animate into the viewport using `WaymarkAnimatedEntrance` or `WaymarkStaggeredColumn`.
*   **Choreography:** Coordinated opacity fade (`0.0 -> 1.0`), subtle vertical slide (`16.h -> 0.0`), and micro scale-in (`0.97 -> 1.0`) utilizing `Curves.easeOutCubic` (350ms – 500ms duration).
*   **Staggered Rhythm:** Cascading items (journeys deck, place milestones, photo grids) must apply incremental delays (`index * 60ms – 80ms`) to create a fluid editorial rhythm.

### Rule 3: Shimmer Effect for Loading Indicators
*   **Zero Generic Spinners:** CircularProgressIndicator or blank white screens are forbidden during data-fetching states.
*   **Warm Organic Shimmer:** All loading and asynchronous states must display a tailored skeleton placeholder utilizing `WaymarkShimmer` (`WaymarkShimmerCard`, `WaymarkShimmerBox`, `WaymarkShimmerPolaroid`).
*   **Palette Adherence:** Shimmer gradients must utilize warm linen and canvas tones (`#EBE7DF` to `#FBF9F5`) rather than cold digital grays.

### Rule 4: Cinematic Splash & Transition Standards
*   The splash screen must feature a choreographed sequence: compass emblem needle settle (`Curves.easeOutBack`), concentric pulsing halo ring, staggered typography entrance, and smooth cross-fade route transitions.

### Rule 5: Centralized Typography & Context TextTheme Standard
*   **Single Source of Truth:** All font families, weights, font sizes, line heights, and letter spacings throughout the entire application must be defined centrally in `WaymarkTypography` (`lib/core/theme/waymark_typography.dart`) and registered within Material 3 `ThemeData.textTheme`.
*   **Zero Ad-Hoc `TextStyle`:** No widget or screen component may declare arbitrary `TextStyle(fontSize: ..., fontWeight: ...)` or hardcode font families (`fontFamily: 'Inter'`). All text elements must derive directly from `Theme.of(context).textTheme` (or `context.textTheme`).
*   **Text Extensions:** Specialized brand typography tokens (such as Caveat editorial signature script and micro metadata captions) are accessed cleanly via `context.textTheme.brandScript` and `context.textTheme.caption`.

### Rule 6: Mandatory Localization & Type-Safe Asset Generation
*   **Zero Hardcoded Strings:** Every piece of user-facing text, label, button CTA, title, and descriptive copy must be declared in `lib/l10n/app_en.arb` and accessed through `AppLocalizations` (`context.l10n`). Hardcoded string literals in UI code are strictly forbidden.
*   **Type-Safe Asset References (`flutter_gen`):** All local images, illustrations, and icons must be generated using `flutter_gen` and referenced via type-safe accessors (`Assets.images.*` from `lib/core/gen/assets.gen.dart`). Hardcoded asset string paths (e.g. `'assets/images/...'`) are prohibited in UI components.

### Rule 7: Standardized Reusable Custom Snackbar Component
*   **Zero Ad-Hoc `SnackBar` Declarations:** Never directly instantiate `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))` with ad-hoc layout, arbitrary containers, or inline color styling in screen widgets.
*   **Unified Custom Component (`WaymarkSnackbar`):** All toasts, alerts, and notifications throughout the application must use the centralized `WaymarkSnackbar` widget (`lib/core/presentation/widgets/waymark_snackbar.dart`), invoked through `WaymarkSnackbar.show(...)` (or semantic convenience helpers: `WaymarkSnackbar.showSuccess`, `WaymarkSnackbar.showInfo`, `WaymarkSnackbar.showWarning`, `WaymarkSnackbar.showError`).
*   **Design System Compliance:** Every snackbar must enforce `SnackBarBehavior.floating`, subtle tactile elevation shadow, rounded border corners (`WaymarkSpacing.radiusMd`), typography strictly from `context.textTheme`, and thematic semantic color accents from `WaymarkColors`.

---

## 3. Phase 1: Core Architecture, Theming & Spacing

### 2.1 Theme & Typography Structure
*   **Typography:** Outfit (Display/Headlines) and Inter (Body/Labels) using `google_fonts`.
*   **Colors:** Earth Terracotta (`#E26D5C`), Forest Teal (`#2C6E49`), Sunset Gold (`#FFB703`), Canvas (`#FBF9F5`), Deep Peat (`#1F2421`).
*   **Implementation:** Defined in `WaymarkTheme` inside `lib/core/theme/` utilizing Material 3's `ThemeData`, `ColorScheme`, and custom `TextTheme`.

### 2.2 Standardized Spacing & Margins (NEW)
To ensure layout consistency and adherence to `DESIGN.md`, we will implement a centralized `WaymarkSpacing` class in `lib/core/constants/waymark_spacing.dart`. This eliminates hardcoded paddings and margins.
*   **Base Unit:** 1rem = 16.0 logical pixels.
*   **Values:** 
    *   `space2xs` (4.0), `spaceXs` (8.0), `spaceSm` (12.0), `spaceMd` (16.0), `spaceLg` (24.0), `spaceXl` (32.0), `space2xl` (48.0)
    *   `gutter` (16.0 for mobile, 24.0 for desktop)
    *   `margin` (16.0 for mobile, 24.0 for tablet, 40.0 for desktop)

### 2.3 Custom Common Components
Develop reusable widgets inside `lib/core/presentation/widgets/`:
*   `WaymarkPrimaryButton` (Terracotta pill-shaped FAB/CTA with glow shadow).
*   `WaymarkSecondaryButton` (Forest Teal outline).
*   `WaymarkCard` (Crisp white surface, hairline border, subtle shadow).
*   `WaymarkPolaroid` (Vintage photo frame with heavy bottom chin).
*   `WaymarkStatusPill` (Low opacity background with solid text).

---

## 4. Phase 2: Data Layer (Offline-First)

### 4.1 Local Database (Drift)
*   **Setup:** Initialize `AppDatabase` in `lib/core/database/app_database.dart`.
*   **Schema Definitions:**
    *   `TripAlbums`: Tracks overarching journey (title, dates, status, aggregated stats).
    *   `TripPlaces`: Tracks individual stops (coordinates, timestamps, weather, order).
    *   `PlaceMediaFiles`: Tracks associated photos (relative path, sizes, EXIF timestamps).
    *   `RouteWaypoints`: Tracks encoded polylines linking Places.
*   **DAOs:** Create dedicated Data Access Objects (`AlbumDao`, `PlaceDao`, `MediaDao`) exposing standard CRUD operations and reactive Streams (`watchAllAlbums()`).

### 4.2 Media Optimization Service
*   **Implementation:** Use `flutter_image_compress` and `path_provider`.
*   **Pipeline:** 
    1. Read RAW image -> Extract EXIF (GPS/Time) -> Compress to WebP (1920x1080 max).
    2. Save to app sandboxed documents folder: `albums/{albumId}/places/{placeId}/`.
    3. Save the *relative* path into Drift to prevent iOS sandbox directory shift issues.

---

## 5. Phase 3: App Initialization, Onboarding & Permissions

### 5.1 Bootstrapping
*   Initialize local storage, Drift DB, and environment configurations in `main_common.dart`.
*   Check "First Launch" flag in `SharedPreferences`.

### 5.2 Onboarding Flow
*   **Screen 1:** "Welcome to WayMark" - Value proposition (Memories organized by journey).
*   **Screen 2:** "Track Your Steps" - Explanation of map routing.
*   **Screen 3:** "Offline First" - Emphasizing privacy and battery preservation.

### 5.3 Permission Handling Flow
Using the `permission_handler` package, we implement a transparent, rationale-first permission flow:
*   **Location Permission:** Requested prior to creating the first Trip Place. We show an interstitial card: *"WayMark needs your location to accurately drop pins on your journey map."* 
    *   Handles `PermissionStatus.denied` and `PermissionStatus.permanentlyDenied` (prompt to open OS settings).
*   **Photos/Storage Permission:** Requested when a user attempts to add a photo to a place. Rationale: *"WayMark needs access to your gallery to attach memories and extract EXIF location data."*
*   **Camera Permission:** Requested when opening the native camera interface.

---

## 6. Phase 4: Domain Layer & State Management

*   **Entities:** Convert Drift Data Classes to pure Domain Entities (e.g., `TripAlbumEntity`).
*   **Use Cases:** Implement atomic business logic (e.g., `CreateTripAlbumUseCase`, `AddPlaceToAlbumUseCase`, `CalculateRouteUseCase`).
*   **State Management (Riverpod):** 
    *   Utilize `@riverpod` annotations for code generation.
    *   Providers: `albumsProvider` (Stream), `currentJourneyProvider`, `locationServiceProvider`.

---

## 7. Phase 5: Presentation, Declarative Routing (GoRouter) & UI Implementation

### 7.1 Declarative Routing Architecture (`go_router`)
*   **Routing Engine:** Configured via `AppRouter` in `lib/core/router/app_router.dart` utilizing `MaterialApp.router`.
*   **Stateful Navigation Shell:** Implemented via `StatefulShellRoute.indexedStack` wrapping `WaymarkNavigationShell` to preserve scroll positions, map state, and tab histories across the 4 primary bottom navigation branches.
*   **Deep Linking:** Centralized route path and name definitions in `AppRoutes` (`lib/core/router/route_names.dart`).

### 7.2 Standardized Screens & Route Mapping
*   **Root & Bootstrap:**
    *   `SplashScreen` — Route: `/` (`splash`). Rebuilt with Pokhara lake imagery, animated logo, feature cards, and linear progress loader.
*   **Onboarding & Rationale:**
    *   `OnboardingScreen` — Route: `/onboarding` (`onboarding`). Value propositions and contextual permission requests.
*   **Navigation Shell (`WaymarkNavigationShell`):** Hosts the persistent `WaymarkLiquidGlassBottomNavBar` across 4 persistent branches:
    *   **Branch 0 (Journeys):**
        *   `AllJourneysDashboardScreen` — Route: `/journeys` (`journeys`). Hero carousel of journey albums, search, notifications, and status cards.
        *   `JourneyAlbumDetailScreen` — Route: `/journeys/:id` (`journeyDetail`). Timeline milestones, polyline map preview, and polaroid media grid.
        *   `CreateJourneyModalScreen` — Route: `/journeys/create` (`createJourney`). Interactive trip creation sheet with date range pickers.
    *   **Branch 1 (Explore):**
        *   `ExploreMapViewScreen` — Route: `/explore` (`explore`). Fullscreen interactive map view with polyline tracks and cluster markers.
    *   **Branch 2 (Studio):**
        *   `PostcardStudioScreen` — Route: `/studio` (`studio`). Vintage postcard gallery, layout selector, and stamp customization.
    *   **Branch 3 (Profile):**
        *   `TravelerProfileScreen` — Route: `/profile` (`profile`). Local storage vault diagnostics, stats overview, and privacy controls.
*   **Action & Sheet Routes (Fullscreen Modals):**
    *   `PlaceLoggerStorySheetScreen` — Route: `/logger/:albumId` (`placeLogger`). Location tagging, multi-photo attachment, and editorial memoir notes.
    *   `PostcardGeneratorScreen` — Route: `/postcard/:albumId` (`postcardGenerator`). High-resolution `RepaintBoundary` rendering and export canvas.

### 7.3 Motion & Shimmer Enforcement
*   **Rule:** Every screen component must enter using `WaymarkAnimatedEntrance` / `WaymarkStaggeredColumn` and display warm `WaymarkShimmer` skeleton loaders during asynchronous data fetching.

---

## 8. Phase 6: Map & Polyline Integration

*   **Engine Integration:** Implement `MapEngineService` abstraction over `flutter_map` or `google_maps_flutter`.
*   **Polyline Logic:** When Place B is added after Place A, the app requests the route geometry from the local cache or OSRM online.
*   **Rendering:** Draw animated polyline gradients (Start: Blue -> Mid: Purple -> End: Red) on the map view. Auto-fit bounds when viewing a trip.

---

## 9. Phase 7: DevOps, CI/CD & Fastlane Integration

To manage the four flavors (`dev`, `qa`, `uat`, `production`) and streamline beta distribution, we will integrate **Fastlane** and **Firebase App Distribution**.

### 9.1 Fastlane Setup
*   Initialize Fastlane in both `ios/` and `android/` directories.
*   Integrate the `fastlane-plugin-firebase_app_distribution`.
*   **iOS Fastlane (`ios/fastlane/Fastfile`):**
    *   Setup `match` for code signing (development and ad-hoc profiles per environment bundle ID).
    *   Define lanes using `gym` to build `.ipa` files mapped to specific Xcode schemes (`dev`, `qa`, `uat`, `production`).
*   **Android Fastlane (`android/fastlane/Fastfile`):**
    *   Define lanes using `gradle` action to build `.apk` (or `.aab`) files for specific product flavors (e.g., `assembleDevRelease`).

### 9.2 Interactive Distribution Shell Script
Create a `distribute.sh` script in the project root to trigger the pipeline easily via terminal:
1.  **Menu Prompt:** Uses `select` or simple `read` to ask the developer which environment to build (1: Dev, 2: QA, 3: UAT, 4: Prod).
2.  **Platform Prompt:** Ask whether to distribute iOS, Android, or Both.
3.  **Release Notes:** Prompt the developer to input a short string for Firebase App Distribution release notes.
4.  **Execution:** Translates the selection into the appropriate Fastlane command (e.g., `cd ios && bundle exec fastlane distribute_qa notes:"$notes"`).

---

## 10. Testing & Review Strategy

*   **Unit Tests:** Test all Mappers and Use Cases using Mockito/Mocktail.
*   **Widget Tests:** Verify custom components match design specifications, ensuring `WaymarkSpacing` usage.
*   **Integration Tests:** Simulate full offline user flow (Create Trip -> Grant Permissions -> Log Place -> View Timeline).
