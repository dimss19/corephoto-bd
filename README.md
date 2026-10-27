# corephoto-bd

Aplikasi Desktop Native Geological Core Photo Management System (Delphi / Object Pascal Edition).

[![Latest Release](https://img.shields.io/github/v/release/dimss19/corephoto-bd?color=orange&label=Latest%20Release)](https://github.com/dimss19/corephoto-bd/releases/latest)
[![Download CorePhoto.exe](https://img.shields.io/badge/Download-CorePhoto.exe%20(v1.0.0)-22c55e?style=for-the-badge&logo=windows)](https://github.com/dimss19/corephoto-bd/releases/download/v1.0.0/CorePhoto.exe)

> **Unduh Langsung:** [CorePhoto.exe (v1.0.0 Standalone)](https://github.com/dimss19/corephoto-bd/releases/download/v1.0.0/CorePhoto.exe) (~9.3 MB) siap pakai langsung jalan tanpa instalasi runtime tambahan. Kunjungi halaman [GitHub Releases](https://github.com/dimss19/corephoto-bd/releases) untuk changelog lengkap.

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

## Cara Build & Kompilasi (.exe Standalone)

Project ini menggunakan VCL murni dan komponen native Windows (GDI+, WIA, DirectShow, WIC) tanpa library pihak ketiga eksternal, sehingga menghasilkan single standalone `.exe` (< 10 MB).

### Prasyarat
- **Embarcadero Delphi 11 Alexandria / 12 Athens** (Community, Professional, atau Enterprise Edition).
- *(Alternatif)* **Lazarus IDE / Free Pascal (FPC)** dengan converter proyek Delphi.

---

### Opsi 1: Menggunakan Delphi IDE (Paling Mudah)
1. Buka **Embarcadero Delphi IDE**.
2. Buka project file: `CorePhoto.dproj` melalui menu **File -> Open Project...**.
3. Pada panel **Project Manager** (sebelah kanan):
   - **Target Platforms**: Pilih `Windows 64-bit` (atau `Windows 32-bit`).
   - **Build Configurations**: Pilih `Release`.
4. Klik kanan project `CorePhoto.exe` -> pilih **Build** (atau shortcut `Shift + F9`).
5. File executable standalone akan otomatis dibuat di folder:
   ```text
   bin\CorePhoto.exe
   ```
   *(Ukuran hasil kompilasi bersih: ~7 – 9 MB)*

---

### Opsi 2: Menggunakan Command Line (MSBuild / RAD Studio Command Prompt)
1. Buka **RAD Studio Command Prompt** dari Start Menu.
2. Masuk ke direktori project:
   ```cmd
   cd /d "D:\laragon\www\corephoto bd"
   ```
3. Jalankan MSBuild:
   ```cmd
   msbuild CorePhoto.dproj /p:Configuration=Release /p:Platform=Win64
   ```

---

### Opsi 3: Kompresi Tambahan Menggunakan UPX (Opsional)
Jika ingin memampatkan ukuran `.exe` lebih kecil lagi menjadi **~3.5 MB**:
```cmd
upx --best --lzma bin\CorePhoto.exe
```

---

## Lisensi & Hak Cipta
Hak cipta dilindungi undang-undang.

