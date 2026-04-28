# DataDash

DataDash is a mobile-first analytics app built with Flutter.

It provides a local, backend-free workflow to import tabular files, inspect and clean data, build dashboards with configurable widgets, and export/share the result as PDF.

## Overview

DataDash is designed as a lightweight "QuickSight-like" experience for mobile:

- Import data from device files (`.csv`, `.xls`, `.xlsx`)
- Inspect schema and row samples
- Rename/ignore columns and apply filters
- Compose dashboards using reusable widget types
- Save everything locally (Hive)
- Export dashboards as PDF and share via system share sheet/email apps

No remote API, authentication, or cloud dependency is required in this MVP.

## Implemented Features

### 1) App shell and navigation

- Animated splash screen
- Bottom navigation with 4 sections:
  - Home
  - Dashboards
  - Imported Files
  - Settings
- Route-based navigation via `AppRoutes`

### 2) File import

- Device picker integration (`file_picker`)
- Supported file extensions:
  - `csv`
  - `xls`
  - `xlsx`
- CSV parser with delimiter auto-detection (comma or semicolon)
- Excel parser (first valid sheet)
- Validation/error states for empty/invalid files

### 3) Data preparation

- Internal dataset normalization through `DataProcessingService`
- Automatic column key generation
- Type inference (numeric, text, date, boolean, empty)
- Column-level controls:
  - Rename
  - Ignore/restore
- Dataset-level filters:
  - contains
  - equals
  - greaterThan
  - lessThan

### 4) Dashboard builder

- Dashboard CRUD (create, rename, delete)
- Widget CRUD (add/edit/remove)
- Widget reordering (drag and drop)
- Widget configuration:
  - title
  - source column
  - aggregation (sum, average, count, min, max)
  - optional widget filter

### 5) Widget rendering

Implemented widget types:

- Numeric indicator
- Bar chart
- Line chart
- Pie chart
- Summary table

Rendered with `fl_chart` and custom UI cards.

### 6) Dashboard view

- Responsive widget grid (mobile-oriented)
- Global filters applied at view level
- Refresh action (recomputes current view from stored data)
- Direct export shortcut

### 7) PDF export and sharing

- PDF generation from dashboard state (`pdf`)
- Print/preview (`printing`)
- Save file to app documents directory
- Share through OS share sheet (`share_plus`) including email clients

### 8) Local persistence

- Hive-backed repositories:
  - imports
  - dashboards
  - settings
- Theme mode persisted across sessions
- Auto-seeded sample dataset on first run (if no imports exist)

### 9) UX and visual system

- Minimal UI with light and dark themes
- Brand palette aligned to:
  - Blue Mirage
  - Amber Smoke
- Custom DataDash wordmark component
- SVG illustrations for empty/error/loading-like states

## Tech Stack

- Flutter (Material 3)
- Dart
- Provider (state management / dependency injection style)
- Hive (local storage)
- fl_chart (charts)
- file_picker + csv + excel (import pipeline)
- pdf + printing + share_plus (export pipeline)
- flutter_svg + google_fonts (UI assets/branding)

## Package List

From `pubspec.yaml`:

- `provider`
- `file_picker`
- `csv`
- `excel`
- `fl_chart`
- `pdf`
- `printing`
- `share_plus`
- `path_provider`
- `hive`
- `hive_flutter`
- `flutter_svg`
- `google_fonts`
- `uuid`
- `intl`
- `collection`

## Architecture

The app follows a feature-first + layered approach:

- `core/`
  - app controller, theme, routes, shared utilities, errors
- `data/`
  - models
  - services (file parsing, processing, metrics, PDF)
  - repositories (Hive persistence)
- `features/`
  - presentation pages by feature (home/import/editor/dashboard/export/settings/splash)
- `shared/`
  - reusable UI widgets

State orchestration is centralized in `AppController` (`ChangeNotifier`), while domain-like operations stay inside services.

## Project Structure

```text
lib/
  core/
    app_controller.dart
    errors/
    theme/
    utils/
  data/
    models/
    repositories/
    services/
  features/
    splash/
    home/
    import/
    dashboard/
    editor/
    export/
    settings/
  shared/
    widgets/
  main.dart
```

## Data Model Summary

### `DataSetModel`

- File metadata (`fileName`, `sourceType`, `importedAt`)
- Normalized columns (`DataColumnModel`)
- Row map list (`List<Map<String, dynamic>>`)
- Attached filters (`List<DataFilterModel>`)

### `DashboardModel`

- Dashboard metadata (`name`, timestamps)
- Linked dataset id (`dataSetId`)
- Widget list (`List<DashboardWidgetModel>`)

### `DashboardWidgetModel`

- Widget id, title, type
- Source column key
- Aggregation type
- Optional local filter

## Main User Flow

1. App opens into splash and bootstraps local state
2. User imports CSV/XLS/XLSX file
3. User previews data and adjusts columns/filters
4. User creates a dashboard from the dataset
5. User adds and configures widgets
6. User views dashboard with optional global filters
7. User exports to PDF and shares/saves

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK compatible with project constraint (`^3.11.0`)
- Android Studio / VS Code + Flutter tooling
- Android/iOS emulator or physical device

### Installation

```bash
git clone <your-repo-url>
cd datadash
flutter pub get
```

### Run (debug)

```bash
flutter run
```

### Analyze

```bash
flutter analyze
```

### Build APK (example)

```bash
flutter build apk --release
```

## Storage Details

Hive boxes used:

- `imports_box`
- `dashboards_box`
- `settings_box`

Entities are serialized as JSON strings in their respective repositories.

## Import and Parsing Notes

- CSV is fully implemented and production-usable in this MVP.
- XLS/XLSX are implemented through `excel` package (first valid sheet is read).
- Column keys are sanitized and suffixed with index to avoid collisions.
- Numeric parsing supports common comma/dot decimal patterns.

## Export Notes

- PDF content includes:
  - dashboard name
  - export timestamp
  - widget sections
  - summary table (if configured)
- Chart widgets in PDF are rendered as compact bar-like summaries for portability and deterministic output.

## Theming and Branding

- Light mode and dark mode are both available.
- Theme mode is persisted in local storage.
- Current palette centers on:
  - `#5C6D7C` (Blue Mirage)
  - `#C79963` (Amber Smoke)

## Current Limitations

- UI text is currently PT-BR (Portuguese) while code/architecture is language-agnostic.
- No backend sync, user accounts, or cloud storage yet.
- No automated test suite added yet.
- Advanced BI features (calculated fields, joins, multi-dataset dashboards) are not part of this MVP.

## Suggested Next Steps

- Add i18n (EN/PT-BR) localization layer
- Introduce unit/widget/integration tests
- Add dataset-level refresh from original file path
- Add richer chart customization (colors, legends, axis formatting)
- Add dashboard templates and import/export of dashboard definitions

## License

This project currently has no explicit license file.
Add a `LICENSE` file before distribution.
