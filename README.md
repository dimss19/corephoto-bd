# corephoto-bd

Aplikasi Desktop Native Geological Core Photo Management System (Delphi / Object Pascal Edition).

## Ringkasan Proyek
**CorePhoto BD** adalah versi Windows native berkonsumsi memori rendah (< 10 MB standalone executable) yang di-porting dari CorePhoto Python dengan paritas data, fungsionalitas, visual, dan pengujian 100%.

### Fitur Utama
- **Paritas Data 100%**: Sesi, format folder, SQLite skema, dan CSV kompatibel timbal balik dengan versi Python.
- **Subsistem Kamera Lengkap (4 Adapter)**:
  - DirectShow UVC Webcam dengan visual simulator fallback.
  - Native Direct USB DSLR (WIA / COM API tanpa vendor SDK).
  - Hot-Folder automated ingestion watcher.
  - Wi-Fi DSLR Wireless Tethering dengan socket probe & auto-ingest.
- **Geological Slate & Processing Pipeline**:
  - Boundary-checked tray cropping.
  - Instant RAW crash resilience & MD5 checksum hashing.
  - Geological Metadata Slate Banner di footer citra.
  - Incremental JPEG quality compression untuk menjaga ukuran file <= 10 MB.
  - Otomatis membuat thumbnail, metadata JSON sidecar, dan CSV drillhole record.
- **Crash-Resilient Database**:
  - SQLite WAL (Write-Ahead Logging) mode, Foreign Keys ON, zero database corruption on sudden power loss.
- **Validasi & Diagnostik**:
  - 10-point Geological Pre-flight checks.
  - Validasi interval kedalaman core & audit integritas file.
  - Built-in hardware/storage/DB diagnostics dan crash recovery wizard.
- **Industrial Safety UI**:
  - Dark Charcoal & Safety Orange theme berbasis VCL + GDI+ anti-aliasing.

## Struktur Direktori
- `src/core/`: Context aplikasi, logger rotasi file, format helper identik Python.
- `src/config/`: JSON configuration manager (`config/settings.json`).
- `src/storage/`: Sandbox direktori penyimpanan & proteksi traversal.
- `src/database/`: SQLite database manager, model data, dan repository CRUD berparameter.
- `src/camera/`: Antarmuka kamera dan 4 adapter (Webcam, Direct USB, Hot-Folder, Wi-Fi DSLR).
- `src/imaging/`: Image processing pipeline, banner slate geologi, WIC resize & compressor.
- `src/validation/`: Rule engine validasi interval, penamaan, preflight, dan audit runner.
- `src/diagnostics/`: Diagnostic suite dan crash recovery.
- `src/ui/`: VCL forms & dialogs (Capture, Review, DataHub, Settings, DatePicker, Theme).
- `tests/`: DUnitX unit test suite (`CorePhotoTests.dpr`).

## Lisensi & Hak Cipta
Hak cipta dilindungi undang-undang.
