unit CP.DB.Manager;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.SyncObjs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TCPDatabaseManager = class
  private
    FDbPath: string;
    FConnPool: TFDConnection;
    FLock: TCriticalSection;
    procedure ApplyMigrations;
  public
    constructor Create(const ADbPath: string);
    destructor Destroy; override;

    function GetConnection: TFDConnection;
    procedure ExecuteScript(const Script: string);
    function ExecuteWrite(const SQL: string; const Params: array of Variant): Int64;
    function OpenQuery(const SQL: string; const Params: array of Variant): TFDQuery;
    procedure Close;

    property DbPath: string read FDbPath;
  end;

function GetDB(const ADbPath: string = ''): TCPDatabaseManager;

implementation

uses
  CP.Core.Logger, CP.Storage.Manager;

var
  GActiveDBManager: TCPDatabaseManager = nil;

function GetDB(const ADbPath: string): TCPDatabaseManager;
var
  DefaultDb: string;
begin
  if ADbPath <> '' then
  begin
    GActiveDBManager.Free;
    GActiveDBManager := TCPDatabaseManager.Create(ADbPath);
  end
  else if GActiveDBManager = nil then
  begin
    DefaultDb := TPath.Combine(GetStorageManager.BaseDir, 'default.db');
    GActiveDBManager := TCPDatabaseManager.Create(DefaultDb);
  end;
  Result := GActiveDBManager;
end;

constructor TCPDatabaseManager.Create(const ADbPath: string);
var
  Dir: string;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FDbPath := TPath.GetFullPath(ADbPath);
  Dir := ExtractFilePath(FDbPath);
  if not TDirectory.Exists(Dir) then
    TDirectory.CreateDirectory(Dir);

  FConnPool := TFDConnection.Create(nil);
  FConnPool.Params.DriverID := 'SQLite';
  FConnPool.Params.Database := FDbPath;
  FConnPool.Params.Add('ForeignKeys=ON');
  FConnPool.Params.Add('JournalMode=WAL');
  FConnPool.Params.Add('Synchronous=Normal');
  FConnPool.Params.Add('LockingMode=Normal');
  FConnPool.LoginPrompt := False;
  FConnPool.Connected := True;

  ApplyMigrations;
end;

destructor TCPDatabaseManager.Destroy;
begin
  Close;
  FConnPool.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TCPDatabaseManager.Close;
begin
  if Assigned(FConnPool) and FConnPool.Connected then
    FConnPool.Connected := False;
end;

function TCPDatabaseManager.GetConnection: TFDConnection;
begin
  Result := FConnPool;
end;

procedure TCPDatabaseManager.ApplyMigrations;
var
  Q: TFDQuery;
  Applied: Boolean;
begin
  ExecuteScript(
    'CREATE TABLE IF NOT EXISTS schema_migrations (' +
    '  version INTEGER PRIMARY KEY,' +
    '  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP' +
    ');'
  );

  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConnPool;
    Q.SQL.Text := 'SELECT version FROM schema_migrations WHERE version = 1';
    Q.Open;
    Applied := not Q.IsEmpty;
  finally
    Q.Free;
  end;

  if not Applied then
  begin
    Log.Info('Applying SQLite migration version 1 for ' + ExtractFileName(FDbPath));
    FConnPool.StartTransaction;
    try
      // Sessions
      FConnPool.ExecSQL(
        'CREATE TABLE IF NOT EXISTS sessions (' +
        '  id TEXT PRIMARY KEY,' +
        '  site TEXT NOT NULL,' +
        '  date TEXT NOT NULL,' +
        '  operator TEXT NOT NULL,' +
        '  status TEXT NOT NULL DEFAULT ''ACTIVE'',' +
        '  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,' +
        '  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP' +
        ');'
      );
      // Trays
      FConnPool.ExecSQL(
        'CREATE TABLE IF NOT EXISTS trays (' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        '  session_id TEXT NOT NULL,' +
        '  hole_id TEXT NOT NULL,' +
        '  tray_id TEXT NOT NULL,' +
        '  interval_from REAL NOT NULL,' +
        '  interval_to REAL NOT NULL,' +
        '  tray_rows INTEGER DEFAULT 1,' +
        '  tray_length REAL DEFAULT 0.0,' +
        '  tray_width REAL DEFAULT 0.0,' +
        '  comments TEXT,' +
        '  status TEXT NOT NULL DEFAULT ''IN_PROGRESS'',' +
        '  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,' +
        '  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE' +
        ');'
      );
      // Photos
      FConnPool.ExecSQL(
        'CREATE TABLE IF NOT EXISTS photos (' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        '  session_id TEXT NOT NULL,' +
        '  tray_id INTEGER,' +
        '  hole_id TEXT NOT NULL,' +
        '  tray_number TEXT NOT NULL,' +
        '  interval_from REAL NOT NULL,' +
        '  interval_to REAL NOT NULL,' +
        '  filename_base TEXT NOT NULL,' +
        '  raw_path TEXT,' +
        '  jpg_path TEXT,' +
        '  thumbnail_path TEXT,' +
        '  md5_raw TEXT,' +
        '  md5_jpg TEXT,' +
        '  crop_x INTEGER DEFAULT 0,' +
        '  crop_y INTEGER DEFAULT 0,' +
        '  crop_w INTEGER DEFAULT 300,' +
        '  crop_h INTEGER DEFAULT 200,' +
        '  camera_model TEXT,' +
        '  camera_serial TEXT,' +
        '  status TEXT NOT NULL DEFAULT ''DRAFT'',' +
        '  is_active INTEGER NOT NULL DEFAULT 1,' +
        '  captured_at TIMESTAMP,' +
        '  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,' +
        '  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,' +
        '  FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE,' +
        '  FOREIGN KEY (tray_id) REFERENCES trays(id) ON DELETE SET NULL' +
        ');'
      );
      // Camera Devices
      FConnPool.ExecSQL(
        'CREATE TABLE IF NOT EXISTS camera_devices (' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        '  name TEXT NOT NULL,' +
        '  adapter_type TEXT NOT NULL,' +
        '  vendor_info TEXT,' +
        '  serial_number TEXT,' +
        '  capabilities_json TEXT DEFAULT ''{}'',' +
        '  last_connected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP' +
        ');'
      );
      // Transfers
      FConnPool.ExecSQL(
        'CREATE TABLE IF NOT EXISTS transfers (' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        '  photo_id INTEGER NOT NULL,' +
        '  server_url TEXT NOT NULL,' +
        '  status TEXT NOT NULL DEFAULT ''PENDING'',' +
        '  attempt_count INTEGER DEFAULT 0,' +
        '  last_attempt_at TIMESTAMP,' +
        '  response_code INTEGER,' +
        '  response_body TEXT,' +
        '  error_message TEXT,' +
        '  transferred_at TIMESTAMP,' +
        '  FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE' +
        ');'
      );
      // Validation Results
      FConnPool.ExecSQL(
        'CREATE TABLE IF NOT EXISTS validation_results (' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        '  target_type TEXT NOT NULL,' +
        '  target_id TEXT NOT NULL,' +
        '  is_valid INTEGER NOT NULL,' +
        '  rule_name TEXT NOT NULL,' +
        '  message TEXT NOT NULL,' +
        '  checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP' +
        ');'
      );
      // Application Events
      FConnPool.ExecSQL(
        'CREATE TABLE IF NOT EXISTS application_events (' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' +
        '  session_id TEXT,' +
        '  event_type TEXT NOT NULL,' +
        '  description TEXT NOT NULL,' +
        '  details_json TEXT DEFAULT ''{}'',' +
        '  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP' +
        ');'
      );
      // Indexes matching PRD Section 21
      FConnPool.ExecSQL('CREATE INDEX IF NOT EXISTS idx_photos_hole ON photos(hole_id);');
      FConnPool.ExecSQL('CREATE INDEX IF NOT EXISTS idx_photos_tray ON photos(tray_number);');
      FConnPool.ExecSQL('CREATE INDEX IF NOT EXISTS idx_photos_status ON photos(status);');
      FConnPool.ExecSQL('CREATE INDEX IF NOT EXISTS idx_photos_active ON photos(is_active);');
      FConnPool.ExecSQL('CREATE INDEX IF NOT EXISTS idx_trays_session ON trays(session_id);');
      FConnPool.ExecSQL('CREATE INDEX IF NOT EXISTS idx_transfers_status ON transfers(status);');

      FConnPool.ExecSQL('INSERT INTO schema_migrations (version) VALUES (1);');
      FConnPool.Commit;
      Log.Info('Migration version 1 applied successfully.');
    except
      on E: Exception do
      begin
        FConnPool.Rollback;
        Log.Error('Database migration failed: ' + E.Message);
        raise;
      end;
    end;
  end;
end;

procedure TCPDatabaseManager.ExecuteScript(const Script: string);
begin
  FLock.Enter;
  try
    FConnPool.ExecSQL(Script);
  finally
    FLock.Leave;
  end;
end;

function TCPDatabaseManager.ExecuteWrite(const SQL: string; const Params: array of Variant): Int64;
var
  Q: TFDQuery;
  I: Integer;
begin
  FLock.Enter;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := FConnPool;
      Q.SQL.Text := SQL;
      for I := 0 to High(Params) do
        Q.Params[I].Value := Params[I];
      Q.ExecSQL;
      Result := FConnPool.GetLastAutoGenValue('');
      if Result = 0 then
        Result := Q.RowsAffected;
    finally
      Q.Free;
    end;
  finally
    FLock.Leave;
  end;
end;

function TCPDatabaseManager.OpenQuery(const SQL: string; const Params: array of Variant): TFDQuery;
var
  I: Integer;
begin
  FLock.Enter;
  try
    Result := TFDQuery.Create(nil);
    Result.Connection := FConnPool;
    Result.SQL.Text := SQL;
    for I := 0 to High(Params) do
      Result.Params[I].Value := Params[I];
    Result.Open;
  finally
    FLock.Leave;
  end;
end;

initialization
finalization
  GActiveDBManager.Free;
end.
