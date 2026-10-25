# Rencana Pembuatan CorePhoto BD (Delphi Edition)

> **Status:** DRAFT — menunggu persetujuan sebelum dieksekusi
> **Sumber acuan:** `D:\laragon\www\corephoto` (commit `725256b`)
> **Target:** Aplikasi desktop Windows native, **single `.exe` < 10 MB**, fitur & tampilan identik dengan versi Python.

---

## 1. Definisi "Kemiripan 100%"

Supaya targetnya bisa diukur, "100% mirip" saya bagi menjadi 4 lapisan paritas:

| # | Lapisan | Kriteria lulus |
|---|---------|----------------|
| 1 | **Paritas Data** | Sesi yang dibuat versi Python bisa dibuka di versi Delphi, dan sebaliknya. Struktur folder, skema SQLite, nama file, kolom CSV, dan kunci JSON sama persis. |
| 2 | **Paritas Fungsional** | Semua alur (Session → Tray → Live View → Pre-flight → Capture → Review → Approve/Retake → Transfer → Validasi → Diagnostics → Recovery) berperilaku sama, termasuk pesan error & fallback kamera. |
| 3 | **Paritas Visual** | Layout, warna (token `ui/theme.py`), font Segoe UI, ukuran window, teks label, dan overlay Live View sama. Dicek dengan screenshot berdampingan. |
| 4 | **Paritas Pengujian** | 36 unit test Python di-port ke DUnitX dan semuanya lulus. |

> [!NOTE]
> **Batasan teknis yang perlu dipahami:** hasil piksel JPG tidak akan *byte-identik* dengan Pillow, karena algoritma resize (Lanczos vs WIC) dan encoder JPEG berbeda. Dimensi, kualitas, batas ukuran file, banner metadata, dan nama file tetap sama. Begitu juga sudut membulat CustomTkinter akan direplikasi dengan GDI+ anti-aliasing, jadi sangat mirip tetapi tidak sampai identik per piksel.

---

## 2. Koreksi dari Diskusi Sebelumnya

Setelah membaca seluruh kode, ada beberapa saran saya sebelumnya yang perlu **diralat**:

| Saran sebelumnya | Fakta | Keputusan di rencana ini |
|---|---|---|
| Pakai **Skia4Delphi** untuk UI modern | Skia membutuhkan `sk4d.dll` sekitar **~10 MB**, sehingga target < 10 MB langsung terlewati | **Tidak pakai Skia.** Pakai VCL + **GDI+** bawaan Windows untuk anti-aliasing & rounded corner (0 KB tambahan) |
| WIC bisa membaca RAW "secara bawaan" | WIC baru bisa membaca CR2/NEF/ARW jika **Microsoft Raw Image Extension** terpasang (gratis dari Microsoft Store). Dukungan CR3 tergantung versi | Lihat keputusan RAW di §5.6 dan Pertanyaan Terbuka #3 |
| Delphi Community Edition gratis | Hanya untuk individu/perusahaan dengan **pendapatan < USD 5.000/tahun**. Perusahaan tambang hampir pasti wajib lisensi **Professional** (berbayar) | Lihat Pertanyaan Terbuka #1 |
| — | **Delphi belum terpasang** di mesin ini (tidak ada `bds.exe`/`dcc64.exe`/`lazbuild`) | Saya bisa menulis seluruh source code, tetapi **kompilasi & uji harus dilakukan setelah Delphi terpasang** |

---

## 3. Stack Teknologi (Semua Bawaan Delphi/Windows, Tanpa Library Pihak Ketiga)

| Kebutuhan | Python (sekarang) | Delphi (rencana) | Tambahan ukuran |
|---|---|---|---|
| GUI | CustomTkinter | **VCL** + kontrol kustom owner-draw (GDI+) | ~3–4 MB (baseline VCL) |
| Database | `sqlite3` | **FireDAC** + SQLite **static link** (`FireDAC.Phys.SQLiteWrapper.Stat`), tanpa `sqlite3.dll` | ~3–4 MB |
| Webcam / Live View | OpenCV `CAP_DSHOW` | **DirectShow** (`Winapi.DirectShow9`) + Sample Grabber | ~0.1 MB |
| Enumerasi nama kamera | PowerShell `Get-PnpDevice` | `ICreateDevEnum` (nama asli perangkat, lebih cepat, tanpa PowerShell) | 0 |
| DSLR USB | `win32com` → `WIA.DeviceManager` | COM late binding `CreateOleObject('WIA.DeviceManager')` (sama persis) | 0 |
| Decode/crop/resize/encode | Pillow + numpy | **WIC** (Windows Imaging Component): decoder, `IWICBitmapScaler`, encoder JPEG dengan `ImageQuality` | ~0.1 MB |
| RAW DSLR | `rawpy` (LibRaw) | WIC + Raw Image Extension (lihat §5.6) | 0 |
| EXIF | Pillow `ExifTags` | WIC Metadata Query Reader (`/app1/ifd/...`) | 0 |
| Folder watcher | `watchdog` | `ReadDirectoryChangesW` di `TThread` | 0 |
| Probe IP kamera | `socket` | Winsock `connect` dengan timeout (non-blocking + `select`) | 0 |
| MD5 | `hashlib` | `System.Hash.THashMD5` | 0 |
| JSON | `json` | `System.JSON` + writer kustom (agar format indent identik) | ~0.2 MB |
| Regex sanitasi | `re` | `System.RegularExpressions` | ~0.3 MB |
| Unit test | pytest | **DUnitX** (bawaan Delphi) | — (proyek terpisah) |

### Anggaran Ukuran (perkiraan, Win64 Release)

| Komponen | Perkiraan |
|---|---|
| VCL RTL + Forms | 3.0 – 4.0 MB |
| FireDAC core + SQLite static | 3.0 – 4.0 MB |
| Logika aplikasi + kontrol kustom | 1.0 – 1.5 MB |
| Resource (ikon, dikompres ulang) | ~0.15 MB |
| **Total tanpa kompresi** | **~7.5 – 9.5 MB** |
| Dengan UPX (opsional) | ~3 – 4 MB |

> [!WARNING]
> Angka di atas **perkiraan** dan akan diverifikasi di **Fase 0** sebelum pekerjaan besar dimulai. Untuk Win64 margin-nya tipis. Rencana cadangan jika lewat 10 MB: (a) build Win32 (~20% lebih kecil), (b) ganti FireDAC dengan wrapper SQLite tipis + static object (hemat ~2–3 MB), (c) UPX. Perlu dicatat UPX kadang memicu *false positive* antivirus.

> [!TIP]
> `assets/icon.png` saat ini berukuran **902 KB**. File ini akan diganti dengan PNG 64 px (~10 KB) untuk logo header. `icon.ico` (122 KB) tetap dipakai sebagai ikon aplikasi.

---

## 4. Struktur Folder Proyek

```text
corephoto bd/
├── PLAN_COREPHOTO_DELPHI.md        ← dokumen ini
├── README.md
├── CorePhoto.dpr / .dproj          ← proyek utama
├── CorePhoto.res                   ← ikon + manifest (Per-Monitor V2 DPI, Common Controls v6)
├── assets/
│   ├── icon.ico
│   └── logo_64.png
├── config/
│   └── settings.json               ← default, kunci sama persis dengan versi Python
├── src/
│   ├── core/
│   │   ├── CP.Core.AppContext.pas
│   │   ├── CP.Core.Logger.pas
│   │   └── CP.Core.PyFormat.pas    ← helper format angka/tanggal identik Python (§6)
│   ├── config/CP.Config.Manager.pas
│   ├── storage/CP.Storage.Manager.pas
│   ├── database/
│   │   ├── CP.DB.Manager.pas       ← koneksi, WAL, migrasi
│   │   ├── CP.DB.Models.pas
│   │   └── CP.DB.Repositories.pas
│   ├── camera/
│   │   ├── CP.Camera.Intf.pas      ← ICameraAdapter, TCameraState, TCameraInfo, TCaptureResult
│   │   ├── CP.Camera.Capabilities.pas
│   │   ├── CP.Camera.Manager.pas
│   │   ├── CP.Camera.DShow.pas     ← enumerasi & grabber DirectShow
│   │   └── adapters/
│   │       ├── CP.Camera.Webcam.pas
│   │       ├── CP.Camera.DirectUsb.pas
│   │       ├── CP.Camera.HotFolder.pas
│   │       └── CP.Camera.WiFiDslr.pas
│   ├── imaging/
│   │   ├── CP.Imaging.WIC.pas      ← wrapper decode/scale/encode/EXIF
│   │   ├── CP.Imaging.Crop.pas
│   │   ├── CP.Imaging.Raw.pas
│   │   ├── CP.Imaging.Thumbnail.pas
│   │   └── CP.Imaging.Processor.pas
│   ├── validation/
│   │   ├── CP.Validation.Interval.pas
│   │   ├── CP.Validation.Filename.pas
│   │   ├── CP.Validation.Metadata.pas
│   │   ├── CP.Validation.Preflight.pas
│   │   └── CP.Validation.Runner.pas
│   ├── diagnostics/CP.Diagnostics.pas
│   └── ui/
│       ├── CP.UI.Theme.pas         ← token warna & font dari theme.py
│       ├── controls/               ← kontrol kustom bergaya CustomTkinter
│       │   ├── CP.Ctl.Button.pas       (rounded, hover, border, state aktif)
│       │   ├── CP.Ctl.Panel.pas        (rounded + border 1px)
│       │   ├── CP.Ctl.Entry.pas        (TEdit dengan border kustom)
│       │   ├── CP.Ctl.TabView.pas      (segmented button seperti CTkTabview)
│       │   ├── CP.Ctl.ScrollPanel.pas  (CTkScrollableFrame)
│       │   ├── CP.Ctl.ComboBox.pas
│       │   └── CP.Ctl.CheckBox.pas
│       ├── CP.UI.MainForm.pas/.dfm     ← app.py (TopBar, Content, BottomBar, navigasi)
│       ├── CP.UI.Capture.pas/.dfm      ← ui/capture.py
│       ├── CP.UI.Review.pas/.dfm       ← ui/review.py
│       ├── CP.UI.DataHub.pas/.dfm      ← ui/data_hub.py (+ EditSessionModal)
│       ├── CP.UI.Settings.pas/.dfm     ← ui/settings.py
│       └── CP.UI.DatePicker.pas/.dfm   ← ui/date_picker.py
└── tests/
    ├── CorePhotoTests.dpr          ← DUnitX
    └── (12 unit test, mirror dari tests/*.py)
```

---

## 5. Pemetaan Modul dan Detail Teknis

### 5.1 Pemetaan File Python ke Delphi

| Python | Baris | Delphi | Catatan |
|---|---:|---|---|
| `app.py` | 465 | `CP.UI.MainForm` | Window 1340×840, min 1120×720, routing alias (`diagnostics`→settings, `browser`→review/catalog, dst.) |
| `core/app_context.py` | 484 | `CP.Core.AppContext` | Singleton; auto-restore sesi aktif terbaru; transfer & sync server folder |
| `core/logger.py` | 75 | `CP.Core.Logger` | Format `%Y-%m-%d %H:%M:%S [LEVEL] [name] msg`, rotasi 10 MB × 5, `corephoto.log` |
| `config/config_manager.py` | 173 | `CP.Config.Manager` | `settings.json` di samping exe, deep-merge dengan default |
| `storage/manager.py` | 175 | `CP.Storage.Manager` | Sanitasi regex identik, proteksi path traversal, suffix `_01`, `_02` |
| `database/db.py` | 256 | `CP.DB.Manager` | Skema migrasi v1 identik (8 tabel + 6 index), `WAL`, `foreign_keys=ON`, `synchronous=NORMAL` |
| `database/models.py` | 142 | `CP.DB.Models` | Record + enum string (`DRAFT`…`SUPERSEDED`) |
| `database/repositories.py` | ~500 | `CP.DB.Repositories` | Query parameterized saja |
| `camera/*` | ~2.000 | `CP.Camera.*` | Lihat §5.4 |
| `imaging/*` | ~520 | `CP.Imaging.*` | Lihat §5.5 |
| `validation/*` | ~350 | `CP.Validation.*` | 10 pre-flight check + 7 aturan audit, dengan pesan Indonesia yang sama |
| `diagnostics/diagnostics.py` | 178 | `CP.Diagnostics` | 5 suite cek, export JSON, resume capture yang belum selesai |
| `ui/capture.py` | 2.619 | `CP.UI.Capture` | Layar terbesar (§5.7) |
| `ui/review.py` | ~1.050 | `CP.UI.Review` | Tab TRAY INSPECTION + PHOTO BROWSER |
| `ui/data_hub.py` | ~700 | `CP.UI.DataHub` | Active session card, form sesi baru, arsip, modal edit |
| `ui/settings.py` | ~880 | `CP.UI.Settings` | Hardware, diagnostics, recovery, log, storage & server |
| `ui/date_picker.py` | ~280 | `CP.UI.DatePicker` | Kalender kustom (bukan `TMonthCalendar`, agar tampilan sama) |

### 5.2 Database
- Skema SQL **disalin apa adanya** dari `MIGRATIONS[1]`, termasuk tabel `schema_migrations`.
- Koneksi FireDAC per thread (setara `threading.local`), memakai PRAGMA yang sama.
- `execute_write` mengembalikan `last_insert_rowid()` atau rowcount, sesuai perilaku Python.
- **Uji kompatibilitas:** buka `session.db` yang dibuat Python, lalu baca/tulis dari Delphi, lalu buka lagi di Python.

### 5.3 Storage & Config
- Struktur sesi identik: `CorePhotoData/Sessions/<SITE>_<YYYYMMDD>[_NN]/{jpg,raw,thumbs}/session.db` + `<HoleID>.csv`.
- Base dir relatif terhadap lokasi exe (sama dengan perilaku `sys.frozen`).
- Ruang disk bebas: `GetDiskFreeSpaceEx`.

### 5.4 Subsistem Kamera
Antarmuka `ICameraAdapter` mengikuti `AbstractCameraAdapter` (connect, disconnect, state, info, capabilities, live view, capture, get/set setting).

| Adapter | Implementasi Delphi |
|---|---|
| **Webcam** | DirectShow filter graph: `CaptureFilter → SampleGrabber (RGB24) → NullRenderer`. Thread grabber mengirim frame ke UI lewat `TThread.Queue`. Atur resolusi dengan `IAMStreamConfig`. Mode **simulator/standby** menggambar frame tray simulasi (lingkaran + teks) seperti `_generate_standby_frame`. |
| **Direct USB** | Probe WIA (`DeviceInfos`, `Connect`), lalu live stream UVC dengan prioritas nama vendor ("EOS Webcam Utility"), lalu fallback frame standby, sama seperti Python. |
| **Hot Folder** | `ReadDirectoryChangesW` (FILE_NOTIFY_CHANGE_FILE_NAME/LAST_WRITE), tunggu file stabil, lalu ingest. |
| **Wi-Fi DSLR** | Watcher folder tether + auto-detect folder vendor (`Pictures\EOS Utility`, `Imaging Edge`, `Nikon`, …) + probe TCP port 8080/80/15740 dengan timeout 0.8 detik + parser EXIF (Make/Model/Serial/ISO/Lens). |

**Manager:** registry alias adapter, rantai fallback startup (`webcam → direct_usb → webcam 0 → sim`), auto-fallback index webcam yang sudah tidak valid, serta menyimpan `preferred_index`/`device_id` ke config.

### 5.5 Pipeline Imaging (urutan sama dengan `ImageProcessor.process_capture`)
1. Simpan RAW bytes ke `raw/` **lebih dulu**, lalu hitung MD5 (crash-safe).
2. Insert record `CAPTURED`, lalu ubah ke `PROCESSING`.
3. Decode via WIC ke bitmap 24-bit.
4. Crop (default tengah 3:2 jika region kosong); resize hanya jika `crop_w`/`crop_h` > 500.
5. **Banner metadata** di bagian bawah: tinggi `max(18, 8% h)`, latar putih, garis `RGB(210,215,220)`, font Segoe UI `max(8, 45% banner)`, teks kiri `HOLE ID … TO …`, teks kanan `OPERATOR … TIMESTAMP mm/dd/yyyy hh:mm:ss AM/PM`.
6. Encode JPEG dengan kualitas 95. Jika > `max_photo_size_mb`: turunkan kualitas 5 poin per langkah sampai minimal 35, lalu kecilkan dimensi 0.9× per langkah sampai lebar minimal 600 px.
7. Thumbnail 150×100 di `thumbs/<base>_thumb.jpg` (logika aspect sama dengan `thumbnail.py`).
8. Sidecar `jpg/<base>.json` (kunci & urutan identik), lalu append `<HoleID>.csv` (15 kolom), lalu update ke `PROCESSED`.
9. Jika gagal: status `INVALID` dan exception diteruskan.

### 5.6 Keputusan RAW DSLR
| Opsi | Ukuran exe | Kelebihan | Kekurangan |
|---|---|---|---|
| **A. WIC + Raw Image Extension** *(rekomendasi)* | +0 KB | Tetap single-exe; berbasis LibRaw, sama dengan rawpy | Extension harus terpasang di tiap PC lapangan |
| B. `libraw.dll` disertakan | +1.5–2 MB (file terpisah) | Tidak bergantung pada Store | Tidak lagi single-file |
| C. Ambil JPEG preview yang tertanam di RAW | +~20 KB | Tanpa dependensi apa pun | Hasil warna dari kamera, bukan demosaic LibRaw (beda dengan versi Python) |

Rencana: **A sebagai jalur utama, C sebagai fallback otomatis** jika WIC gagal decode. Aplikasi tetap jalan dan pengguna mendapat peringatan di Diagnostics.

### 5.7 UI — Strategi Paritas Visual
- **Token warna** disalin 1:1 dari `theme.py` (`#D9531E` accent, `#F4F5F7` canvas, dst.).
- **Font:** CTk memakai ukuran dalam piksel, jadi di VCL dipakai `Font.Height := -Size` dengan skala DPI otomatis.
- **Kontrol kustom** (owner-draw GDI+): rounded corner radius 4/6, border 1px, warna hover, state aktif oranye, tab segmented.
- **Layar Capture** (paling kompleks):
  - Panel kiri 350 px, tab "Tray Data" dan "Camera Settings" (scrollable).
  - Canvas Live View: fit aspect ratio; **grid rule-of-thirds** garis putus-putus `#0284C7` (pen `PS_USERSTYLE` 3-3); **crop box 88% rasio 3:2**; area luar diarsir dengan **pattern brush checker 50%** (setara `stipple="gray50"`, hasilnya identik); garis pembagi baris sesuai `Tray Rows`; watermark Hole ID kuning `#FEF08A` 20pt bold; label `[ ZOOM 2X ACTIVE ]`.
  - Koordinat crop ternormalisasi diperbarui live ke field "Tray Crop Area".
  - Checklist pre-flight, tombol Capture/Retake/Save/Finish, kartu Capture Details, efek shutter flash, preview foto beku.
  - `advance_to_next_tray`: tray +1, `From = To lama`, `To = From + selisih` (default 2.0), comment dikosongkan.
- Render dengan double-buffering (`TBitmap` offscreen) supaya ~30 FPS tanpa flicker.

---

## 6. Jebakan Kompatibilitas Data (Wajib Ditangani)

| # | Masalah | Solusi |
|---|---|---|
| 1 | **Locale Indonesia memakai koma desimal** (`2,6`), sedangkan Python selalu titik (`2.6`) | Semua format angka memakai `TFormatSettings.Invariant` |
| 2 | Python `f"{x:06.2f}"` → `000.00`, `002.60` | Helper `PyFmtZeroPad(x, 6, 2)`; `Format('%6.2f')` di Delphi justru memberi padding spasi |
| 3 | Python `f"{x:g}"` → `2`, `2.6` (6 digit signifikan, tanpa trailing zero) | Helper `PyFmtG(x)` + unit test kasus tepi |
| 4 | `datetime.isoformat()` → mikrodetik 6 digit | Format `yyyy-mm-ddThh:nn:ss.zzz` + `000` |
| 5 | CSV Python: UTF-8 **tanpa BOM**, baris `\r\n`, quoting minimal | `TUTF8Encoding.Create(False)` (default Delphi menulis BOM!) + fungsi quote kustom |
| 6 | JSON sidecar `indent=2`, `ensure_ascii=True`; `settings.json` `ensure_ascii=False` | Writer JSON kustom dengan dua mode escape |
| 7 | MD5 hex huruf kecil | Normalisasi `LowerCase()` |
| 8 | Nama file `Hole_Tray_000.00_2.60` (spasi diganti `_`) | Port `format_core_filename` + uji dengan regex validator |

---

## 7. Fase Pengerjaan

| Fase | Isi | Estimasi* | Gerbang (gate) |
|---|---|---|---|
| **0. Setup & Spike** | Instal Delphi, skeleton proyek, prototipe: FireDAC+SQLite static + preview DirectShow + encode JPEG WIC | 2–3 hari | **Ukuran exe prototipe terukur dan masih masuk anggaran < 10 MB** |
| **1. Fondasi** | PyFormat, Logger, Config, Storage, DB + migrasi, Models, Repositories | 3–4 hari | Test storage/database/validation lulus; `session.db` Python terbaca |
| **2. Imaging** | WIC wrapper, crop, banner, kompresi progresif, thumbnail, JSON, CSV, MD5 | 4–5 hari | Output dibandingkan dengan hasil Python untuk input yang sama (nama, dimensi, kolom, kunci) |
| **3. Validasi & Diagnostics** | Preflight 10 cek, Runner 7 aturan, Diagnostics, Recovery | 2 hari | Test validation lulus |
| **4. Kamera** | Interface, Manager + fallback, Webcam DirectShow, Simulator, Direct USB (WIA), Hot Folder, Wi-Fi DSLR | 6–8 hari | Test camera/wifi lulus; uji fisik dengan webcam internal + eksternal |
| **5. Design System** | Theme + 7 kontrol kustom | 4–5 hari | Screenshot komponen dibandingkan dengan CTk |
| **6. Layar** | MainForm, Capture, Review, DataHub (+modal), Settings, DatePicker | 8–10 hari | Seluruh alur end-to-end berjalan |
| **7. QA Paritas & Rilis** | Screenshot berdampingan, uji silang data dua arah, optimasi ukuran, README, build Release | 3–4 hari | Semua kriteria §1 terpenuhi |
| | **Total** | **~32–41 hari kerja (±7–9 minggu)** | |

\* Estimasi untuk 1 developer yang terbiasa dengan Delphi.

---

## 8. Rencana Verifikasi

1. **Unit test (DUnitX):** port 1:1 dari `test_camera`, `test_capture_workflow`, `test_data_hub_and_review`, `test_database`, `test_imaging`, `test_review_transfer`, `test_server_folder`, `test_storage`, `test_validation`, `test_wifi_dslr`, ditambah test baru untuk `PyFormat` & CSV/JSON writer.
2. **Uji silang data:** sesi Python dibuka di Delphi → capture tambahan → dibuka kembali di Python, lalu validasi ulang harus PASS.
3. **Golden file:** untuk input PNG yang sama, bandingkan nama file, dimensi, isi CSV (kecuali MD5/timestamp), dan kunci JSON.
4. **Paritas visual:** screenshot setiap layar (Capture/Review/DataHub/Settings/modal) berdampingan di resolusi 1340×840.
5. **Ukuran & performa:** catat ukuran exe tiap fase; target startup < 0.5 detik, RAM idle < 60 MB.
6. **Uji hardware:** webcam internal, webcam USB eksternal, DSLR USB (WIA), folder tether Wi-Fi.

---

## 9. Risiko

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Ukuran Win64 melewati 10 MB | Tinggi | Gate Fase 0; cadangan Win32 / wrapper SQLite tipis / UPX |
| Sample Grabber DirectShow berstatus *deprecated* (`qedit.dll`) | Sedang | Masih ada di Windows 10/11; cadangan: Media Foundation `IMFSourceReader` |
| Raw Image Extension tidak terpasang di PC lapangan | Sedang | Fallback JPEG tertanam + peringatan di Diagnostics |
| WIA "Take Picture" tidak didukung banyak DSLR modern (MTP) | Sedang | Perilakunya sama dengan versi Python (fallback stream UVC); tidak memperburuk |
| Lisensi Community Edition tidak memenuhi syarat untuk perusahaan | Tinggi (legal) | Pastikan edisi lisensi sebelum Fase 0 |
| Rewrite 2.600 baris UI Capture memakan waktu | Sedang | Dipecah per panel; review screenshot bertahap |

---

## 10. Pertanyaan Terbuka (Perlu Dijawab Sebelum Eksekusi)

1. **Versi & lisensi Delphi:** Apakah sudah punya lisensi Delphi Professional/Enterprise (versi berapa)? Atau memakai Community Edition (syarat pendapatan < USD 5.000/tahun)?
   - *Alternatif:* **Lazarus / Free Pascal** (gratis tanpa batas pendapatan, sintaks ~95% kompatibel Delphi). Kelebihan tambahannya: saya bisa memasang dan **mengompilasi + menguji langsung** di mesin ini.
2. **Target arsitektur:** Win64 (disarankan untuk foto resolusi tinggi) atau Win32 (lebih kecil)?
3. **RAW DSLR:** Setuju dengan Opsi A + fallback C (§5.6)? Apakah file RAW benar-benar dipakai di lapangan, atau tether biasanya mengirim JPG?
4. **UPX:** Boleh dipakai (exe ~3–4 MB, risiko false positive antivirus) atau tidak?
5. **"Server API URL":** Di kode Python field ini hanya disimpan ke config, tanpa panggilan HTTP. Cukup direplikasi seperti itu?
6. **Paritas visual:** Cukup "sangat mirip" (layout, warna, font, teks identik) atau perlu pengecekan piksel per piksel?

---

## 11. Langkah Setelah Disetujui

1. Jawab pertanyaan di §10.
2. Pasang Delphi (atau Lazarus) di mesin ini.
3. Eksekusi **Fase 0** dan laporkan ukuran exe prototipe sebelum lanjut ke fase berikutnya.
