# Wanderline

> **An offline-first travel journal and living atlas that turns your routes, photos, and fleeting moments into artistic memoirs and vintage postcards.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Database](https://img.shields.io/badge/Database-Drift%20SQLite-00599C?logo=sqlite)](https://drift.simonbinder.eu/)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Offline-4CAF50)](https://github.com)
[![License](https://img.shields.io/badge/License-Proprietary-orange)](#)

---

## 📌 App Descriptions

### One-Sentence Description
> **Wanderline is a private, 100% offline travel journal and living atlas that transforms your trips, photos, and routes into artistic memoirs and vintage postcards.**

---

## 📱 Google Play Store Listing

### Short Description *(Play Console limit: 80 characters)*
```text
Offline travel journal & living atlas: map routes and craft vintage postcards.
```
*(Character count: 78 / 80)*

**Alternative short descriptions:**
- `Private offline travel journal, interactive route maps, and vintage postcards.` *(78 chars)*
- `Track journeys, map vector trails, and craft vintage postcards 100% offline.` *(76 chars)*

---

### Full Description *(Ready to copy into Google Play Console)*

```text
Turn your journeys into timeless memoirs with Wanderline — an artistic, 100% offline travel journal and living atlas.

Whether you are backpacking through remote mountain passes, wandering cobblestone alleys, or taking a weekend road trip, Wanderline chronicles your footsteps without ever requiring an internet connection or compromising your privacy.

✦ 100% OFFLINE & PRIVACY-FIRST
Your travels are personal. Wanderline keeps all your journeys, waypoints, notes, and photos safely locked inside an encrypted local SQLite vault on your device. Zero accounts, zero cloud tracking, zero data collection. Your data never leaves your phone.

✦ LIVING ATLAS & VECTOR ROUTE MAPS
Watch your expeditions unfold on an interactive map. Wanderline connects your photo stops and recorded waypoints into continuous vector trails, complete with distance tracking and route chronologies.

✦ SMART EXIF PHOTO IMPORT
Import photos directly from your camera roll. Wanderline automatically extracts GPS coordinates, altitudes, and capture timestamps from EXIF metadata, pinning each moment precisely where it happened.

✦ VINTAGE POSTCARD ATELIER
Transform fleeting travel memories into tactile, vintage-style postcards. Customize aspect ratios, stamp authentic GPS coordinates, elevation, and weather stamps, and share or save high-resolution keepsake prints.

✦ EXPEDITION FIELD NOTES & SENSORY LOGS
Capture more than just photos. Document sensory impressions — the scent of mountain rain, ambient city sounds, temperature, and sky conditions. Categorize stops by Sightseeing, Food, Stays, Hikes, and Transit.

✦ SEAMLESS LOCAL BACKUP & RESTORE
Keep your travel memoirs secure with portable, human-readable CSV backups stored directly in your local files. Restore your travel history anytime with built-in version verification.

✦ DESIGNED WITH LIQUID GLASS ELEGANCE
Enjoy a tactile, field-journal aesthetic crafted with frosted glass layers, warm typography, and fluid responsive animations that make journaling a joy.

Record your steps. Preserve your memories. Relive your adventures.
Claim your compass with Wanderline today.
```

---

## ✨ Key Features

- **🗺️ Living Atlas & Breadcrumb Trails**: Renders continuous polyline vector routes connecting waypoints and photo stops chronologically.
- **📷 Hardware EXIF Parsing**: Automatically pulls coordinates, timestamps, and locations directly from image metadata without network calls.
- **🎨 Postcard Studio**: Exportable print-ready postcards with custom aspect ratios (Story 9:16, Portrait 3:4, Classic 1:1), vintage badges, weather stamps, and coordinate seals.
- **🔒 Zero-Cloud Local SQLite Vault**: Powered by Drift ORM for lightning-fast querying, atomic transactions, and absolute privacy.
- **💾 Automated & Manual CSV Backups**: Transparent and portable CSV snapshot exports saved directly to user storage (`Downloads/wanderline/`).
- **🪟 Liquid Glass Design System**: Frosted glass cards, ambient blurs, and tactile field journal aesthetics.

---

## 🛠️ Architecture & Tech Stack

- **Framework**: Flutter 3.x / Dart 3
- **Database / ORM**: [Drift](https://drift.simonbinder.eu/) + `sqlite3_flutter_libs`
- **State Management**: Reactive Flutter Notifiers (`ValueNotifier<T>`, `ChangeNotifier`, `ValueListenableBuilder`) — *Strictly NO `setState()` in the codebase*
- **Design System**: Liquid Glass (`WaymarkLiquidGlass`, `WaymarkLiquidGlassAppBar`, `WaymarkLiquidGlassBottomNavBar`)
- **Mapping**: `flutter_map` (OpenStreetMap vector tiles) + `latlong2`
- **Navigation**: `go_router` declarative routing
- **Localization**: Flutter `intl` (`app_en.arb`)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.12.2` or later
- Dart SDK `^3.0.0`
- Android Studio / Xcode configured

### Build Flavors

Wanderline is configured with four environment flavors:

| Flavor | Entrypoint | Target |
| :--- | :--- | :--- |
| **Development** | `lib/main_dev.dart` | Local development & debug logging |
| **QA** | `lib/main_qa.dart` | Quality assurance testing builds |
| **UAT** | `lib/main_uat.dart` | User acceptance testing |
| **Production** | `lib/main_production.dart` | Release builds for app stores |

#### Run with a specific flavor:
```bash
# Development
flutter run -t lib/main_dev.dart --flavor dev

# Production
flutter run -t lib/main_production.dart --flavor production
```

#### Build Release App Bundle (Android):
```bash
flutter build appbundle -t lib/main_production.dart --flavor production
```

#### Run Code Generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```
