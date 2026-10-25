@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo   COREPHOTO BD - PETUNJUK BUILD (DELPHI COMMUNITY EDITION)
echo ============================================================
echo.
echo Catatan: Embarcadero Delphi Community Edition menonaktifkan
echo kompilasi lewat command-line (MSBuild/dcc64).
echo.
echo LANGKAH BUILD APLIKASI DI DELPHI IDE:
echo ------------------------------------------------------------
echo 1. Double-click file: CorePhoto.dproj
echo    (Proyek akan terbuka di Embarcadero RAD Studio / Delphi IDE).
echo.
echo 2. Di panel sebelah kanan (Project Manager):
echo    - Target Platforms : Windows 64-bit
echo    - Build Config     : Release
echo.
echo 3. Tekan kombinasi tombol: Shift + F9 (Project -^> Build CorePhoto)
echo.
echo 4. Selesai! File executable standalone akan langsung terbentuk di:
echo    bin\CorePhoto.exe
echo.
echo 5. Tekan F9 untuk langsung menjalankan aplikasi.
echo ============================================================
echo.
pause
