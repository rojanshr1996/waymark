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

## 2. Phase 1: Core Architecture, Theming & Spacing

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

## 3. Phase 2: Data Layer (Offline-First)

### 3.1 Local Database (Drift)
*   **Setup:** Initialize `AppDatabase` in `lib/core/database/app_database.dart`.
*   **Schema Definitions:**
    *   `TripAlbums`: Tracks overarching journey (title, dates, status, aggregated stats).
    *   `TripPlaces`: Tracks individual stops (coordinates, timestamps, weather, order).
    *   `PlaceMediaFiles`: Tracks associated photos (relative path, sizes, EXIF timestamps).
    *   `RouteWaypoints`: Tracks encoded polylines linking Places.
*   **DAOs:** Create dedicated Data Access Objects (`AlbumDao`, `PlaceDao`, `MediaDao`) exposing standard CRUD operations and reactive Streams (`watchAllAlbums()`).

### 3.2 Media Optimization Service
*   **Implementation:** Use `flutter_image_compress` and `path_provider`.
*   **Pipeline:** 
    1. Read RAW image -> Extract EXIF (GPS/Time) -> Compress to WebP (1920x1080 max).
    2. Save to app sandboxed documents folder: `albums/{albumId}/places/{placeId}/`.
    3. Save the *relative* path into Drift to prevent iOS sandbox directory shift issues.

---

## 4. Phase 3: App Initialization, Onboarding & Permissions (NEW)

### 4.1 Bootstrapping
*   Initialize local storage, Drift DB, and environment configurations in `main_common.dart`.
*   Check "First Launch" flag in `SharedPreferences`.

### 4.2 Onboarding Flow
*   **Screen 1:** "Welcome to WayMark" - Value proposition (Memories organized by journey).
*   **Screen 2:** "Track Your Steps" - Explanation of map routing.
*   **Screen 3:** "Offline First" - Emphasizing privacy and battery preservation.

### 4.3 Permission Handling Flow
Using the `permission_handler` package, we implement a transparent, rationale-first permission flow:
*   **Location Permission:** Requested prior to creating the first Trip Place. We show an interstitial card: *"WayMark needs your location to accurately drop pins on your journey map."* 
    *   Handles `PermissionStatus.denied` and `PermissionStatus.permanentlyDenied` (prompt to open OS settings).
*   **Photos/Storage Permission:** Requested when a user attempts to add a photo to a place. Rationale: *"WayMark needs access to your gallery to attach memories and extract EXIF location data."*
*   **Camera Permission:** Requested when opening the native camera interface.

---

## 5. Phase 4: Domain Layer & State Management

*   **Entities:** Convert Drift Data Classes to pure Domain Entities (e.g., `TripAlbumEntity`).
*   **Use Cases:** Implement atomic business logic (e.g., `CreateTripAlbumUseCase`, `AddPlaceToAlbumUseCase`, `CalculateRouteUseCase`).
*   **State Management (Riverpod):** 
    *   Utilize `@riverpod` annotations for code generation.
    *   Providers: `albumsProvider` (Stream), `currentJourneyProvider`, `locationServiceProvider`.

---

## 6. Phase 5: Presentation & UI Implementation

*   **Screen 1: Album Deck:** Hero carousel of active trips, floating action button for new trips.
*   **Screen 2: Create Journey Modal:** Form with date pickers (`showDateRangePicker`) and cover photo selection.
*   **Screen 3: Journey Album Detail:** 
    *   Collapsible sliver app bar.
    *   Segmented view switcher (Timeline, Map, Gallery).
*   **Screen 4: Place Logger:** 
    *   Location picker (auto-detect or manual pin drag).
    *   EXIF-aware multi-image picker.
    *   Tags and story notes.
*   **Screen 5: Artistic Postcard Generator:** `RepaintBoundary` composition canvas for capturing trip summaries as shareable high-res PNGs.

---

## 7. Phase 6: Map & Polyline Integration

*   **Engine Integration:** Implement `MapEngineService` abstraction over `flutter_map` or `google_maps_flutter`.
*   **Polyline Logic:** When Place B is added after Place A, the app requests the route geometry from the local cache or OSRM online.
*   **Rendering:** Draw animated polyline gradients (Start: Blue -> Mid: Purple -> End: Red) on the map view. Auto-fit bounds when viewing a trip.

---

## 8. Phase 7: DevOps, CI/CD & Fastlane Integration (NEW)

To manage the four flavors (`dev`, `qa`, `uat`, `production`) and streamline beta distribution, we will integrate **Fastlane** and **Firebase App Distribution**.

### 8.1 Fastlane Setup
*   Initialize Fastlane in both `ios/` and `android/` directories.
*   Integrate the `fastlane-plugin-firebase_app_distribution`.
*   **iOS Fastlane (`ios/fastlane/Fastfile`):**
    *   Setup `match` for code signing (development and ad-hoc profiles per environment bundle ID).
    *   Define lanes using `gym` to build `.ipa` files mapped to specific Xcode schemes (`dev`, `qa`, `uat`, `production`).
*   **Android Fastlane (`android/fastlane/Fastfile`):**
    *   Define lanes using `gradle` action to build `.apk` (or `.aab`) files for specific product flavors (e.g., `assembleDevRelease`).

### 8.2 Interactive Distribution Shell Script
Create a `distribute.sh` script in the project root to trigger the pipeline easily via terminal:
1.  **Menu Prompt:** Uses `select` or simple `read` to ask the developer which environment to build (1: Dev, 2: QA, 3: UAT, 4: Prod).
2.  **Platform Prompt:** Ask whether to distribute iOS, Android, or Both.
3.  **Release Notes:** Prompt the developer to input a short string for Firebase App Distribution release notes.
4.  **Execution:** Translates the selection into the appropriate Fastlane command (e.g., `cd ios && bundle exec fastlane distribute_qa notes:"$notes"`).

---

## 9. Testing & Review Strategy

*   **Unit Tests:** Test all Mappers and Use Cases using Mockito/Mocktail.
*   **Widget Tests:** Verify custom components match design specifications, ensuring `WaymarkSpacing` usage.
*   **Integration Tests:** Simulate full offline user flow (Create Trip -> Grant Permissions -> Log Place -> View Timeline).
