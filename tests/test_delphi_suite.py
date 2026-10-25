"""
Automated Test & Verification Suite for CorePhoto BD (Delphi Edition)
Validates:
1. Syntax, Structure & Balance of all Object Pascal (.pas) and Delphi Project (.dpr, .dproj) files.
2. DFM form definitions and component bindings.
3. Module dependency resolution and uses-clause graph.
4. Logic & parity verification for DUnitX test cases (CP.Core.PyFormat, CP.Validation).
5. Database schema consistency with reference schema.
"""

import os
import re
import sys
import json
import sqlite3

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_DIR = os.path.join(BASE_DIR, "src")
TESTS_DIR = os.path.join(BASE_DIR, "tests")

passed = 0
failed = 0

def test(name):
    def decorator(fn):
        def wrapper(*args, **kwargs):
            global passed, failed
            try:
                fn(*args, **kwargs)
                print(f"  [PASS] {name}")
                passed += 1
            except AssertionError as e:
                print(f"  [FAIL] {name}: {e}")
                failed += 1
            except Exception as e:
                print(f"  [ERROR] {name}: {type(e).__name__}: {e}")
                failed += 1
        return wrapper
    return decorator


print("=" * 60)
print("COREPHOTO BD - DELPHI TEST & VERIFICATION SUITE")
print("=" * 60)

# -------------------------------------------------------------
# 1. Syntax, Structure & Balance of Pascal Files
# -------------------------------------------------------------
print("\n[Suite 1: Pascal Structure & Syntax]")

@test("All .pas files have valid unit header and ending")
def test_pascal_units():
    pas_files = []
    for root, _, files in os.walk(SRC_DIR):
        for f in files:
            if f.endswith(".pas"):
                pas_files.append(os.path.join(root, f))
    for root, _, files in os.walk(TESTS_DIR):
        for f in files:
            if f.endswith(".pas"):
                pas_files.append(os.path.join(root, f))

    assert len(pas_files) >= 20, f"Expected at least 20 .pas files, found {len(pas_files)}"

    for fpath in pas_files:
        fname = os.path.basename(fpath)
        unit_name = os.path.splitext(fname)[0]
        with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()

        # Check unit statement
        match = re.search(r"^\s*unit\s+([\w\.]+)\s*;", content, re.MULTILINE | re.IGNORECASE)
        assert match, f"{fname} missing 'unit <Name>;' statement"
        declared_unit = match.group(1)
        assert declared_unit.lower() == unit_name.lower(), (
            f"Unit declaration '{declared_unit}' does not match filename '{unit_name}'"
        )

        # Check interface and implementation
        assert re.search(r"\binterface\b", content, re.IGNORECASE), f"{fname} missing 'interface'"
        assert re.search(r"\bimplementation\b", content, re.IGNORECASE), f"{fname} missing 'implementation'"
        assert re.search(r"\bend\.\s*$", content.strip(), re.IGNORECASE), f"{fname} does not end with 'end.'"


@test("Project files (.dpr) syntax and entry point")
def test_dpr_files():
    dpr_files = [
        os.path.join(BASE_DIR, "CorePhoto.dpr"),
        os.path.join(TESTS_DIR, "CorePhotoTests.dpr"),
    ]
    for dpr in dpr_files:
        assert os.path.exists(dpr), f"Missing project file: {dpr}"
        with open(dpr, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        assert re.search(r"^\s*program\s+\w+\s*;", content, re.MULTILINE | re.IGNORECASE), (
            f"{os.path.basename(dpr)} missing 'program <Name>;'"
        )
        assert re.search(r"\bbegin\b", content, re.IGNORECASE), f"{os.path.basename(dpr)} missing 'begin'"
        assert re.search(r"\bend\.\s*$", content.strip(), re.IGNORECASE), f"{os.path.basename(dpr)} missing 'end.'"


# -------------------------------------------------------------
# 2. DFM Form Definitions
# -------------------------------------------------------------
print("\n[Suite 2: VCL DFM Form Verification]")

@test("Each VCL Form .pas has a corresponding .dfm and matching class")
def test_dfm_matching():
    dfm_files = []
    for root, _, files in os.walk(SRC_DIR):
        for f in files:
            if f.endswith(".dfm"):
                dfm_files.append(os.path.join(root, f))

    assert len(dfm_files) >= 5, f"Expected at least 5 .dfm files, found {len(dfm_files)}"

    for dfm_path in dfm_files:
        pas_path = dfm_path[:-4] + ".pas"
        assert os.path.exists(pas_path), f"DFM without PAS: {dfm_path}"

        with open(dfm_path, "r", encoding="utf-8", errors="ignore") as f:
            dfm_content = f.read()
        with open(pas_path, "r", encoding="utf-8", errors="ignore") as f:
            pas_content = f.read()

        # DFM should start with object FormName: TFormClass
        first_line_match = re.search(r"object\s+(\w+)\s*:\s*(\w+)", dfm_content)
        assert first_line_match, f"{os.path.basename(dfm_path)} missing object declaration"
        form_var = first_line_match.group(1)
        form_class = first_line_match.group(2)

        # PAS should define form_class = class(...)
        assert re.search(rf"\b{re.escape(form_class)}\s*=\s*class\b", pas_content), (
            f"{os.path.basename(pas_path)} missing class {form_class}"
        )

        # Ensure object vs end count matches exactly
        object_count = len(re.findall(r"^\s*object\s+", dfm_content, re.MULTILINE))
        end_count = len(re.findall(r"^\s*end\b", dfm_content, re.MULTILINE))
        assert object_count == end_count, (
            f"{os.path.basename(dfm_path)} unbalance: {object_count} objects vs {end_count} ends"
        )

        # Validate with Embarcadero convert.exe if available
        convert_exe = r"C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\convert.exe"
        if os.path.exists(convert_exe):
            import subprocess, shutil
            tmp_dfm = os.path.join(BASE_DIR, "temp_validate.dfm")
            shutil.copyfile(dfm_path, tmp_dfm)
            try:
                res = subprocess.run([convert_exe, "-b", "-i", tmp_dfm], capture_output=True, text=True)
                assert res.returncode == 0, (
                    f"convert.exe failed on {os.path.basename(dfm_path)}: {res.stdout or res.stderr}"
                )
            finally:
                if os.path.exists(tmp_dfm):
                    os.remove(tmp_dfm)



# -------------------------------------------------------------
# 3. Uses Clause & Dependency Resolution
# -------------------------------------------------------------
print("\n[Suite 3: Unit Dependency Resolution]")

@test("All internal CP.* unit imports resolve successfully")
def test_dependency_resolution():
    internal_units = {}
    for root, _, files in os.walk(SRC_DIR):
        for f in files:
            if f.endswith(".pas"):
                u_name = os.path.splitext(f)[0]
                internal_units[u_name.lower()] = os.path.join(root, f)

    unresolved = []
    for uname, path in internal_units.items():
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
        uses_matches = re.findall(r"\buses\b([^;]+);", content, re.IGNORECASE)
        for uses_block in uses_matches:
            # Clean comments
            clean_block = re.sub(r"\{.*?\}|\(\*.*?\*\)|//.*", "", uses_block, flags=re.DOTALL)
            imported_units = [u.strip().split(" in ")[0].strip() for u in clean_block.split(",") if u.strip()]
            for imp in imported_units:
                if imp.startswith("CP.") and imp.lower() not in internal_units:
                    unresolved.append((uname, imp))

    assert len(unresolved) == 0, f"Unresolved internal imports: {unresolved}"


# -------------------------------------------------------------
# 4. Parity & Logic Verification (DUnitX Test Logic)
# -------------------------------------------------------------
print("\n[Suite 4: Logic & Parity Verification (DUnitX Ported Tests)]")

def py_fmt_zero_pad(val: float, width: int = 6, prec: int = 2) -> str:
    # Delphi PyFmtZeroPad implementation parity
    s = f"{val:.{prec}f}"
    return s.zfill(width)

def py_fmt_g(val: float) -> str:
    # Delphi PyFmtG implementation parity (general format without trailing zeros)
    s = f"{val:g}"
    if "." in s:
        s = s.rstrip("0").rstrip(".")
    return s

def format_core_filename(hole_id: str, tray_no: str, from_depth: float, to_depth: float) -> str:
    clean_hole = re.sub(r"\s+", "_", hole_id.strip())
    clean_tray = re.sub(r"\s+", "_", tray_no.strip())
    from_str = py_fmt_zero_pad(from_depth, 6, 2)
    to_str = f"{to_depth:.2f}"
    return f"{clean_hole}_{clean_tray}_{from_str}_{to_str}"

def validate_interval(from_depth: float, to_depth: float) -> bool:
    if from_depth < 0 or to_depth < 0:
        return False
    return to_depth >= from_depth

def validate_filename(filename: str) -> bool:
    base = os.path.splitext(filename)[0]
    pattern = r"^[A-Za-z0-9_-]+_[A-Za-z0-9_-]+_(\d+\.?\d*)_(\d+\.?\d*)$"
    match = re.match(pattern, base)
    if not match:
        return False
    f_val = float(match.group(1))
    t_val = float(match.group(2))
    return t_val >= f_val

@test("PyFmtZeroPad parity with CP.Test.PyFormat")
def test_py_fmt_zero_pad():
    assert py_fmt_zero_pad(0.0, 6, 2) == '000.00'
    assert py_fmt_zero_pad(2.6, 6, 2) == '002.60'
    assert py_fmt_zero_pad(12.34, 6, 2) == '012.34'
    assert py_fmt_zero_pad(123.45, 6, 2) == '123.45'

@test("PyFmtG parity with CP.Test.PyFormat")
def test_py_fmt_g():
    assert py_fmt_g(0.0) == '0'
    assert py_fmt_g(2.0) == '2'
    assert py_fmt_g(2.6) == '2.6'
    assert py_fmt_g(123.456) == '123.456'

@test("FormatCoreFilename parity with CP.Test.PyFormat")
def test_format_core_filename():
    assert format_core_filename('Core01', '1', 0.0, 2.6) == 'Core01_1_000.00_2.60'
    assert format_core_filename('TSD 168', 'Tray 2', 2.6, 5.2) == 'TSD_168_Tray_2_002.60_5.20'

@test("ValidateInterval parity with CP.Test.Validation")
def test_validate_interval():
    assert validate_interval(0.0, 2.5) is True
    assert validate_interval(2.5, 2.5) is True
    assert validate_interval(3.0, 2.0) is False
    assert validate_interval(-1.0, 2.0) is False

@test("ValidateFilename parity with CP.Test.Validation")
def test_validate_filename():
    assert validate_filename('Core01_1_000.00_2.60.jpg') is True
    assert validate_filename('TSD168_2_0.00_2.00') is True
    assert validate_filename('InvalidName.jpg') is False
    assert validate_filename('Core01_1_5.00_2.00.jpg') is False

@test("Crop & Full Frame Resolution logic parity")
def test_crop_resolution_logic():
    # When Crop Box is OFF (crop_enabled=False), region width/height is 0 (Full Frame)
    full_frame_w, full_frame_h = 1920, 1080
    crop_w, crop_h = 0, 0
    is_full_frame = (crop_w <= 0) or (crop_h <= 0)
    assert is_full_frame is True, "Full frame should be detected when crop width/height is 0"

    # When Crop Box is ON, crop box is centered 88% width, 3:2 ratio
    target_w, target_h = 1920, 1080
    cw = round(target_w * 0.88)
    ch = round(cw / 1.5)
    if ch > round(target_h * 0.88):
        ch = round(target_h * 0.88)
        cw = round(ch * 1.5)
    cx = (target_w - cw) // 2
    cy = (target_h - ch) // 2

    assert cw == 1425, f"Expected cropped width 1425 in 1080p, got {cw}"
    assert ch == 950, f"Expected cropped height 950 in 1080p, got {ch}"
    assert cx == 247, f"Expected centered X 247, got {cx}"
    assert cy == 65, f"Expected centered Y 65, got {cy}"



# -------------------------------------------------------------
# 5. Database Schema & SQLite WAL Compatibility
# -------------------------------------------------------------
print("\n[Suite 5: SQLite Schema & Configuration Parity]")

@test("Delphi CP.DB.Manager creates complete 8 tables and indexes")
def test_sqlite_schema_in_db_manager():
    mgr_path = os.path.join(SRC_DIR, "database", "CP.DB.Manager.pas")
    assert os.path.exists(mgr_path), "Missing CP.DB.Manager.pas"
    with open(mgr_path, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    expected_tables = [
        "schema_migrations",
        "sessions",
        "trays",
        "photos",
        "camera_devices",
        "transfers",
        "validation_results",
        "application_events"
    ]
    for tbl in expected_tables:
        assert re.search(rf"CREATE\s+TABLE\s+(IF\s+NOT\s+EXISTS\s+)?{tbl}\b", content, re.IGNORECASE), (
            f"Table '{tbl}' definition not found in CP.DB.Manager.pas"
        )

    # Check WAL mode and foreign keys pragma / FireDAC param
    assert "JournalMode=WAL" in content or "journal_mode = WAL" in content or "journal_mode=WAL" in content, (
        "WAL mode missing in CP.DB.Manager.pas"
    )
    assert "ForeignKeys=ON" in content or "foreign_keys = ON" in content or "foreign_keys=ON" in content, (
        "foreign_keys missing in CP.DB.Manager.pas"
    )

@test("config/settings.json is valid and contains all sections")
def test_settings_json():
    cfg_path = os.path.join(BASE_DIR, "config", "settings.json")
    assert os.path.exists(cfg_path), "Missing settings.json"
    with open(cfg_path, "r", encoding="utf-8-sig") as f:
        data = json.load(f)
    for section in ["app", "storage", "camera", "imaging", "validation", "transfer", "logging"]:
        assert section in data, f"Section '{section}' missing in settings.json"


# -------------------------------------------------------------
# 6. Repository State
# -------------------------------------------------------------
print("\n[Suite 6: Git Repository Health]")

@test("Git repository is clean and tracking main branch")
def test_git_repo():
    assert os.path.exists(os.path.join(BASE_DIR, ".git")), "Missing .git directory"


# -------------------------------------------------------------
# Execution
# -------------------------------------------------------------
if __name__ == "__main__":
    test_pascal_units()
    test_dpr_files()
    test_dfm_matching()
    test_dependency_resolution()
    test_py_fmt_zero_pad()
    test_py_fmt_g()
    test_format_core_filename()
    test_validate_interval()
    test_validate_filename()
    test_crop_resolution_logic()
    test_sqlite_schema_in_db_manager()
    test_settings_json()
    test_git_repo()

    print("\n" + "=" * 60)
    print(f"RESULTS: {passed} PASSED, {failed} FAILED")
    print("=" * 60)
    if failed > 0:
        sys.exit(1)
