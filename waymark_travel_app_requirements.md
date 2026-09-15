# Software Requirements Specification (SRS) & Design Document
## Project Name: WayMark (Travel Memoir & Route Album App)
**Target Platforms:** Flutter (iOS & Android — Mobile & Tablet Adaptive)  
**Architecture:** Clean Architecture (Domain, Data, Presentation)  
**Local Persistence:** Drift (SQLite) with encrypted/compressed local media store  
**Version:** 1.0.0-PROD-SPEC  
**Date:** September 2026  

---

## 1. Executive Summary & Product Vision

**WayMark** is a travel memoir and visual journaling application designed for modern travelers, wanderers, and storytellers. Rather than treating travel as fragmented checklists or static photo dumps, WayMark organizes memories by journey albums. 

Each trip is a living digital album where users log places, record sensory impressions, attach compressed photos, and trace chronological routes with interactive polylines. WayMark automatically synthesizes this data into:
1. **Interactive Route Maps:** Seamless journey visualization with custom markers and elevation/distance context.
2. **Generative "Artistic Journey Postcards":** Rendered high-fidelity graphics combining map traces, vintage photo polaroids, stats, and badges ready for export or social sharing.
3. **Offline-First Resilience:** Zero-cloud dependency for full app functionality using **Drift SQLite**, preserving battery, privacy, and usability in off-grid remote destinations.

---

## 2. System Architecture: Clean Architecture Specification

The application strictly adheres to **Clean Architecture** principles, maintaining clear boundaries across layers and decoupling UI widgets from data access and third-party SDKs.

```
                  ┌────────────────────────────────────────┐
                  │           Presentation Layer           │
                  │  (Pages, Widgets, Riverpod StateNotif) │
                  └───────────────────┬────────────────────┘
                                      │ Depends on
                                      ▼
                  ┌────────────────────────────────────────┐
                  │              Domain Layer              │
                  │  (Entities, Use Cases, Repos Contracts)│
                  └───────────────────▲────────────────────┘
                                      │ Implemented by
                                      ▼
                  ┌────────────────────────────────────────┐
                  │               Data Layer               │
                  │ (Drift DB, Map APIs, Repos Impl, DAO)  │
                  └────────────────────────────────────────┘
```

### 2.1 Layer Breakdown

#### Domain Layer (`lib/features/[feature]/domain/`)
* Completely agnostic of Flutter UI framework and external plugins (no `dart:ui`, `drift`, or `google_maps_flutter`).
* **Entities:** Pure Dart data structures (`TripAlbum`, `TripPlace`, `PlaceMedia`, `JourneyStats`, `TripRouteSummary`).
* **Repository Interfaces:** Abstract contracts defining data operations (`TripRepository`, `MediaRepository`, `RouteRepository`).
* **Use Cases:** Atomic business transaction units:
  * `CreateTripAlbumUseCase`
  * `AddPlaceToAlbumUseCase`
  * `CalculateTripPolylinesUseCase`
  * `GenerateArtisticCardUseCase`
  * `ExportTripArchiveUseCase`

#### Data Layer (`lib/features/[feature]/data/`)
* Concrete implementation of domain contracts.
* **Data Sources:**
  * `DriftLocalDataSource`: SQLite tables, DAOs, reactive streams via Drift queries.
  * `LocalFileDataSource`: File I/O for image compression, file caching, path management via `path_provider`.
  * `MapRoutingDataSource`: Integration with OpenStreetMap OSRM / Google Directions API with offline caching fallback.
* **Mappers:** Convert Drift Data Classes to Domain Entities and vice versa.
* **Repositories:** Coordinate data from DAOs and file systems, emit Domain models.

#### Presentation Layer (`lib/features/[feature]/presentation/`)
* **State Management:** **Riverpod 2.x** with code-generation (`@riverpod`, `AsyncNotifierProvider`) or **BLoC** pattern.
* **UI Components:** Clean separation between Screens (Pages) and atomic, reusable design system components.
* **Rendering Engines:** `RepaintBoundary` rendering pipelines for image postcard generation, interactive map view controllers.

### 2.2 Recommended Folder Structure

```
lib/
├── core/
│   ├── constants/            # Colors, typography, spacing, assets
│   ├── database/             # Drift schema, migrations, connection
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   └── daos/
│   ├── error/                # Failures & Exceptions
│   ├── services/             # Compression, Exif, Map engine, Share/Export
│   ├── theme/                # ThemeMode, Material 3 specs, responsive tokens
│   └── utils/                # Date formatters, math utilities, polyline decoders
├── features/
│   ├── album/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── controllers/
│   │       ├── screens/
│   │       └── widgets/
│   ├── place/
│   ├── map_journey/
│   └── artistic_summary/
└── main.dart
```

---

## 3. Database Schema & Local Media Storage (Drift)

### 3.1 Drift Database Table Definitions

```dart
// lib/core/database/tables/trip_tables.dart
import 'package:drift/drift.dart';

class TripAlbums extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get coverImagePath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('ONGOING'))(); // ONGOING, COMPLETED, ARCHIVED
  RealColumn get totalDistanceKm => real().withDefault(const Constant(0.0))();
  IntColumn get totalPlacesCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class TripPlaces extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get albumId => text().references(TripAlbums, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get notes => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  DateTimeColumn get visitedAt => dateTime()();
  IntColumn get visitOrder => integer()(); // Sequential index in trip
  TextColumn get weatherCondition => text().nullable()(); // Sunny, Rainy, etc.
  RealColumn get temperatureCelsius => real().nullable()();
  TextColumn get category => text().withDefault(const Constant('GENERAL'))(); // SIGHTSEEING, FOOD, STAY, HIKE, TRANSIT
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaceMediaFiles extends Table {
  TextColumn get id => text()();
  TextColumn get placeId => text().references(TripPlaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get localFilePath => text()(); // Sandbox relative path
  TextColumn get thumbnailPath => text()(); // Low-res 200x200 path
  IntColumn get fileSizeBytes => integer()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  BoolColumn get isCoverPhoto => boolean().withDefault(const Constant(false))();
  DateTimeColumn get capturedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RouteWaypoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get albumId => text().references(TripAlbums, #id, onDelete: KeyAction.cascade)();
  IntColumn get segmentOrder => integer()(); // Segment between Place N and Place N+1
  TextColumn get encodedPolyline => text()(); // Google Polyline algorithm string
  RealColumn get segmentDistanceMeters => real()();
  IntColumn get estimatedDurationSeconds => integer().nullable()();
}
```

### 3.2 Media Optimization & Sandbox Storage Strategy

Raw camera photos (12MP–48MP, 5MB–15MB each) cause instant memory leaks and fast storage exhaustion if kept uncompressed.
1. **Pipeline:**
   * User picks or takes photo (`image_picker`).
   * Read EXIF data (`native_exif`) to capture GPS coordinates & original timestamp.
   * Compression via `flutter_image_compress`:
     * Full View: Max width/height `1920x1080`, WebP format, quality `80%` (~250 KB).
     * Thumbnail: Max width/height `300x300`, WebP format, quality `70%` (~25 KB).
   * Storage: Write to `getApplicationDocumentsDirectory()/albums/{albumId}/places/{placeId}/`.
   * Drift only stores the relative file path to protect against sandbox directory UUID changes on iOS updates.

---

## 4. Map & Automated Route Polyline Engine

### 4.1 Map Provider Strategy
To balance production visual fidelity with cost efficiency, the app provides a decoupled map abstraction:
* **Option A (Free / Open Source):** `flutter_map` with OpenStreetMap / CartoDB Voyager raster/vector tiles. Routing via **OSRM** (Open Source Routing Machine) or **Mapbox Directions Free Tier**.
* **Option B (Enterprise Standard):** `google_maps_flutter` with Google Maps Directions API.
* **Decoupled Map Interface:**
  ```dart
  abstract class MapEngineService {
    Future<List<LatLng>> calculateRouteCoordinates({
      required LatLng origin,
      required LatLng destination,
      TravelMode mode = TravelMode.driving,
    });
  }
  ```

### 4.2 Automated Polyline & Segment Generation
1. When user logs Place $P_n$ ($n \ge 2$):
   * App automatically queries route between $P_{n-1}$ and $P_n$.
   * If online: Fetches actual road network route geometry.
   * If offline: Computes Great-Circle / Haversine curved geodesic polyline or straight segment fallback.
   * Saves encoded polyline into `RouteWaypoints` table in Drift.
2. When displaying the Journey Map:
   * Decodes polyline strings into coordinate list (`flutter_polyline_points`).
   * Renders color-gradient polylines:
     * Start point: `#3B82F6` (Electric Blue)
     * Intermediate transit: `#8B5CF6` (Vibrant Purple)
     * End point: `#F43F5E` (Rose Coral)
   * Auto-fits map camera bounds with animated padding (`LatLngBounds.fromPoints(allPoints)`).

---

## 5. Automated Artistic Journey Postcard Generation

### 5.1 Concept & Output Specifications
The app dynamically synthesizes a shareable, print-ready travel graphic (Aspect ratios: `9:16` for Instagram Stories/Shorts, `4:5` for Feed, and `1:1` Square).

```
+-------------------------------------------------------------+
|  WAYMARK JOURNEY POSTCARD              [Date: Oct 12 - 20]  |
|                                                             |
|   /=====================================================\   |
|   |                  MAP ROUTE CANVAS                   |   |
|   |     (Stylized Monochromatic/Sepia Vector Map)       |   |
|   |          [A] Kyoto                                  |   |
|   |            \                                        |   |
|   |             \===== [B] Nara                         |   |
|   |                     \                               |   |
|   |                      \====== [C] Osaka (End)        |   |
|   \=====================================================/   |
|                                                             |
|   +-------------------+  +-------------------+              |
|   |  Polaroid 1       |  |  Polaroid 2       |              |
|   |  [Place Photo]    |  |  [Place Photo]    |              |
|   |  "Fushimi Inari"  |  |  "Nara Deer Park" |              |
|   +-------------------+  +-------------------+              |
|                                                             |
|   TRIP METRICS:                                             |
|   Total Distance: 142.6 km  |  Places Visited: 8            |
|   Pace: 5 Days              |  Top Altitude: 340m           |
|                                                             |
|   [WayMark Watermark / QR Code to Shareable Album]          |
+-------------------------------------------------------------+
```

### 5.2 Technical Implementation Pipeline
1. **Composition Layer:** A custom Flutter widget tree (`ArtisticTripCardLayout`) wrapped inside a `RepaintBoundary(key: _renderKey)`.
2. **Components of the Postcard:**
   * **Static Map Snapshot:** Captured from map controller or rendered via static map tile canvas with rendered bezier curve pathing.
   * **Polaroid Photo Grid:** Tilted card widgets with paper shadows (`box-shadow: 0 10px 25px rgba(0,0,0,0.15)`), white borders, and location stamp captions.
   * **Typography & Stats Strip:** Trip duration, total distance, place badges, elevation gain.
3. **Export Engine:**
   ```dart
   RenderRepaintBoundary boundary = _renderKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
   ui.Image image = await boundary.toImage(pixelRatio: 3.0); // 3x UHD Crispness
   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
   Uint8List pngBytes = byteData!.buffer.asUint8List();
   // Save to gallery via gal or share via share_plus
   ```

---

## 6. Comprehensive Pixel-Perfect UI/UX Design Specifications

### 6.1 Design Tokens & Theme

#### Color Palette
* **Primary (Earth Terracotta):** Light `#E26D5C` | Dark `#F08070`
* **Secondary (Forest Teal):** Light `#38B000` / `#007200` | Dark `#70E000`
* **Accent (Sunset Gold):** `#FFB703`
* **Background Surface (Warm Canvas):** Light `#FBF9F5` | Dark `#121416`
* **Card Surface:** Light `#FFFFFF` | Dark `#1E2226`
* **Text Main:** Light `#1F2421` | Dark `#F4F5F6`
* **Text Secondary:** Light `#6C757D` | Dark `#9CA3AF`
* **Dividers / Outlines:** Light `#E9ECEF` | Dark `#2D3238`

#### Typography (System Font: Inter or Outfit)
* **Display (Trip Titles):** 28pt, SemiBold, Line-Height: 34pt, Letter-spacing: -0.5px.
* **Heading 1 (Section Headers):** 20pt, Bold, Line-Height: 26pt.
* **Heading 2 (Card Titles):** 16pt, SemiBold, Line-Height: 22pt.
* **Body Regular:** 14pt, Regular, Line-Height: 20pt.
* **Caption / Meta:** 11pt, Medium, Line-Height: 14pt.

---

### 6.2 Application Navigation & Pages Blueprint

```
App Navigation Root
├── Screen 1: Album Deck (Home Dashboard)
├── Screen 2: Create / Edit Journey Modal
├── Screen 3: Journey Album Detail View (Tabs: Timeline / Map / Gallery)
├── Screen 4: Place Logger & Story Detail Sheet
├── Screen 5: Place Detail & Memory Deep-Dive
├── Screen 6: Artistic Journey Postcard Studio & Exporter
└── Screen 7: Tablet Split-View Layout (Master-Detail Dual Canvas)
```

---

### Page-by-Page Wireframe & Layout Specifications

#### Screen 1: Album Deck (Home Dashboard)
* **Top App Bar:**
  * Left: User profile avatar & greeting ("Welcome back, Explorer").
  * Right: Filter chip (All, Ongoing, Completed), Search icon.
* **Hero Carousel / Grid:**
  * Displays active trip cards with cover photo, live route mini-thumb, trip dates, and distance pill (`142.8 km`).
  * Floating "+ Start New Journey" CTA button with haptic feedback.
* **Recent Discoveries Section:** Horizontal scrolling cards of recently visited locations with mini thumbnails and timestamps.

#### Screen 2: Create / Edit Journey Modal
* Full-screen dialog with smooth transition.
* Form fields:
  * Trip Title (`TextFormField` with clear icon).
  * Travel Date Range (`showDateRangePicker`).
  * Description & Goal of journey.
  * Cover Photo selector with preset travel illustration banners or gallery upload.
  * Transport Mode picker (Backpacking, Road Trip, Cycling, Flight/Train).
* Action Bar: "Launch Journey" (Full-width sticky bottom button).

#### Screen 3: Journey Album Detail View
* **Collapsible Sliver App Bar:** Displays high-res cover image, trip title, date range, total places count, and total kilometers.
* **View Switcher (Segmented Pill Tab):**
  * `Tab 1: Timeline`: Vertical dotted path connecting each place card in chronological order ($P_1 	o P_2 	o P_3$). Each card shows thumbnail, place title, time visited, and short note preview.
  * `Tab 2: Route Map`: Full-screen interactive map with animated polylines, custom numbered pins for each place, and tap-to-expand place bottom sheet.
  * `Tab 3: Visual Wall`: Staggered Masonry photo grid (`flutter_staggered_grid_view`) of all images logged across all places in this trip.
* **Floating Action Buttons:**
  * Primary: "+ Add Place" (Earth Terracotta background).
  * Secondary: "Generate Postcard" (Sunset Gold badge icon).

#### Screen 4: Place Logger & Story Detail Sheet
* **Input Fields:**
  * Search Place via Geocoding or auto-detect current location button (`geolocator`).
  * Interactive mini-map confirming marker placement with pin-drag capability.
  * Place Name & Location Alias (e.g., "Grandma's Hillside Cafe").
  * Date & Time Picker (Defaults to photo EXIF or current time).
  * Multi-Image Picker (Max 6 photos per place). Displays horizontal reorderable thumbnail tray with delete badge.
  * Story Notes (`TextField` multiline, 5 lines max).
  * Tag Pills: Sightseeing, Dining, Coffee, Hiking, Hotel, Transit.
* Bottom Bar: "Log Place to Journey" CTA.

#### Screen 5: Place Detail & Memory Deep-Dive
* Hero Photo Slider with smooth dot indicators.
* Full-screen interactive photo lightbox viewer with pinch-to-zoom (`photo_view`).
* Map snippet showing exact pin and route connection from previous location.
* EXIF Metadata Badge Bar: Visited Date, Weather & Temperature, GPS coordinates.
* Action Bar: Edit, Delete, or Share individual Place snippet.

#### Screen 6: Artistic Journey Postcard Studio & Exporter
* Top App Bar: "Postcard Studio" with Close (X) and Export Button.
* Live Interactive Preview Canvas (`RepaintBoundary`):
  * Dynamic layout switching: Minimalist Modern, Vintage Travel Journal, or Cyber Glow.
  * Customizable toggles: Show/Hide Map, Show/Hide Weather, Number of Photos (1 to 4).
* Bottom Control Drawer:
  * Aspect Ratio Selector (`9:16`, `4:5`, `1:1`).
  * Palette Theme Switcher (Sepia, Charcoal, Vibrant Sunset).
* Bottom Action Row:
  * "Save to Photos" (Stores PNG to device gallery).
  * "Share Journey" (Native share sheet for Instagram, WhatsApp, AirDrop).

#### Screen 7: Tablet Adaptive Dual-Pane Layout
* Screen Width $\ge 768	ext{dp}$:
  * Left Master Pane (380dp fixed): Journey list, Place timeline, and metadata entry forms.
  * Right Detail Pane (Expanded flexible): Live persistent Map view with interactive polyline updates and real-time Postcard Preview.

---

## 7. Innovative Features for Local Database (Drift SQLite)

1. **Smart Photo EXIF Auto-Populate:**
   * When user selects photos from gallery, app automatically reads EXIF GPS metadata. If place coordinates are missing, it asks: *"Found GPS in photo (34.9949° N, 135.7850° E). Auto-fill location?"*
2. **Offline Reverse Geocoding Cache:**
   * Pre-packaged or locally cached SQLite database of world cities / landmarks (Geonames lightweight dataset) allowing location names to resolve without internet connection.
3. **Journey Elevation & Terrain Profile:**
   * Calculates total elevation gain/loss between logged places using local digital elevation estimates and displays an interactive elevation profile chart (`fl_chart`).
4. **Local Encrypted Backup & Restore (.waymark package):**
   * Exports an entire album (Drift SQLite rows serialized to JSON + all compressed photos) into a single encrypted ZIP archive file (`.waymark`). Users can share this bundle via AirDrop/Nearby Share and import it on another device with 100% fidelity without any cloud server.
5. **Timeline Re-order & Travel Speed Estimator:**
   * Calculates average travel velocity between points. Detects transport mode (e.g., flight, driving, walking) based on timestamps and distance.

---

## 8. Migration Blueprint: Integrating a Remote Database (Sync Engine)

While WayMark is built as an offline-first local app, it is architected for seamless remote cloud synchronization.

### 8.1 Recommended Cloud Stack
* **Option 1:** **Supabase (PostgreSQL + PostGIS + Supabase Storage)**.
  * Best for geospatial queries (PostGIS handles spatial route queries effortlessly).
  * Row Level Security (RLS) handles user data isolation.
* **Option 2:** **Firebase (Firestore + Firebase Storage + Cloud Functions)**.

### 8.2 Two-Way Sync Architecture
1. **Drift Schema Extension:** Add sync state metadata to all tables:
   ```dart
   DateTimeColumn get updatedAt => dateTime()();
   DateTimeColumn get lastSyncedAt => dateTime().nullable()();
   BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
   BoolColumn get isDeleted => boolean().withDefault(const Constant(false))(); // Soft delete
   ```
2. **Conflict Resolution Strategy:**
   * **Last-Write-Wins (LWW)** using ISO-8601 UTC microsecond timestamps.
   * Media uploads sync lazily in the background (`workmanager` or background upload service).
3. **Real-Time Collaborative Albums:**
   * Using Supabase Realtime Channels or Firebase Realtime listeners, multiple travelers on the same trip can add places to a shared album.

---

## 9. Flutter Implementation Code Templates

### 9.1 Image Compression & Sandbox Storage Service

```dart
// lib/core/services/media_service.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class MediaService {
  final _uuid = const Uuid();

  Future<String> saveCompressedImage({
    required File rawFile,
    required String albumId,
    required String placeId,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final targetDir = Directory(p.join(appDir.path, 'albums', albumId, 'places', placeId));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final filename = '${_uuid.v4()}.webp';
    final targetPath = p.join(targetDir.path, filename);

    final result = await FlutterImageCompress.compressAndGetFile(
      rawFile.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1920,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    if (result == null) throw Exception("Failed to compress image");
    // Return relative path for database portability across iOS sandbox reinstalls
    return p.relative(result.path, from: appDir.path);
  }
}
```

### 9.2 Artistic Postcard RepaintBoundary Capture Service

```dart
// lib/features/artistic_summary/presentation/services/postcard_capture_service.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PostcardCaptureService {
  static Future<Uint8List> capturePng(GlobalKey boundaryKey) async {
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception("Boundary key not attached to context");
    }

    // High DPI rasterization for crisp text, borders and maps
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      throw Exception("Could not convert image to bytes");
    }

    return byteData.buffer.asUint8List();
  }
}
```

---

## 10. Verification, Testing & Acceptance Criteria

| Feature | Acceptance Criteria |
| :--- | :--- |
| **Local Album Creation** | User creates an album with title and dates. Album appears instantly on home deck with Drift reactive stream. |
| **Place Logging & Compression** | Taking a 15MB 4K photo compresses to $<350	ext{KB}$ WebP without user-perceptible UI stutter (runs in compute isolate). |
| **Automated Polylines** | Adding two or more places connects them with colored polyline paths on map automatically within $<500	ext{ms}$. |
| **Postcard Export** | "Export Postcard" produces a 3x resolution PNG combining map, photo polaroids, and trip stats without pixelation. |
| **100% Offline Integrity** | All features (album creation, place logging, route mapping via cached tiles, postcard generation) operate without active network connection. |
