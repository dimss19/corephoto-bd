unit CP.DB.Repositories;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  FireDAC.Comp.Client,
  CP.DB.Models, CP.DB.Manager;

type
  TSessionRepository = class
  private
    FDB: TCPDatabaseManager;
    function RowToModel(Q: TFDQuery): TSessionModel;
  public
    constructor Create(ADB: TCPDatabaseManager);
    function CreateSession(const Model: TSessionModel): TSessionModel;
    function GetActive: TSessionModel;
    function HasActive: Boolean;
    function ListAll: TList<TSessionModel>;
    function UpdateSession(const Model: TSessionModel): Boolean;
    function SetActive(const Id: string): Boolean;
  end;

  TTrayRepository = class
  private
    FDB: TCPDatabaseManager;
    function RowToModel(Q: TFDQuery): TTrayModel;
  public
    constructor Create(ADB: TCPDatabaseManager);
    function CreateTray(const Model: TTrayModel): TTrayModel;
    function GetByHoleAndTray(const SessionId, HoleId, TrayId: string): TTrayModel;
    function HasHoleAndTray(const SessionId, HoleId, TrayId: string): Boolean;
    function GetById(Id: Integer): TTrayModel;
    function ListBySession(const SessionId: string): TList<TTrayModel>;
  end;

  TPhotoRepository = class
  private
    FDB: TCPDatabaseManager;
    function RowToModel(Q: TFDQuery): TPhotoModel;
  public
    constructor Create(ADB: TCPDatabaseManager);
    function CreatePhoto(const Model: TPhotoModel): TPhotoModel;
    function UpdateStatus(Id: Integer; Status: TPhotoStatus): Boolean;
    function UpdateProcessedData(Id: Integer; const JpgPath, ThumbPath, Md5Raw, Md5Jpg: string; Status: TPhotoStatus): Boolean;
    function MarkAsSuperseded(Id: Integer): Boolean;
    function GetById(Id: Integer): TPhotoModel;
    function ListBySession(const SessionId: string): TList<TPhotoModel>;
    function GetIncompletePhotos: TList<TPhotoModel>;
  end;

  TTransferRepository = class
  private
    FDB: TCPDatabaseManager;
    function RowToModel(Q: TFDQuery): TTransferModel;
  public
    constructor Create(ADB: TCPDatabaseManager);
    function CreateTransfer(const Model: TTransferModel): TTransferModel;
    function GetByPhotoId(PhotoId: Integer): TTransferModel;
    function HasByPhotoId(PhotoId: Integer): Boolean;
    function UpdateStatus(Id: Integer; Status: TTransferStatus; ResponseCode: Integer = 0; const ErrorMsg: string = ''): Boolean;
  end;

  TValidationRepository = class
  private
    FDB: TCPDatabaseManager;
  public
    constructor Create(ADB: TCPDatabaseManager);
    procedure AddResult(const Model: TValidationResultModel);
    procedure ClearForTarget(const TargetType, TargetId: string);
    function GetByTarget(const TargetType, TargetId: string): TList<TValidationResultModel>;
  end;

  TEventRepository = class
  private
    FDB: TCPDatabaseManager;
  public
    constructor Create(ADB: TCPDatabaseManager);
    procedure LogEvent(const SessionId, EventType, Description: string; const DetailsJson: string = '{}');
  end;

implementation

{ TSessionRepository }
constructor TSessionRepository.Create(ADB: TCPDatabaseManager);
begin
  inherited Create;
  FDB := ADB;
end;

function TSessionRepository.RowToModel(Q: TFDQuery): TSessionModel;
begin
  Result.Id := Q.FieldByName('id').AsString;
  Result.Site := Q.FieldByName('site').AsString;
  Result.DateStr := Q.FieldByName('date').AsString;
  Result.OperatorName := Q.FieldByName('operator').AsString;
  Result.Status := Q.FieldByName('status').AsString;
  Result.CreatedAt := Q.FieldByName('created_at').AsString;
  Result.UpdatedAt := Q.FieldByName('updated_at').AsString;
end;

function TSessionRepository.CreateSession(const Model: TSessionModel): TSessionModel;
begin
  FDB.ExecuteWrite(
    'INSERT INTO sessions (id, site, date, operator, status) VALUES (?, ?, ?, ?, ?)',
    [Model.Id, Model.Site, Model.DateStr, Model.OperatorName, Model.Status]
  );
  Result := Model;
end;

function TSessionRepository.HasActive: Boolean;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT id FROM sessions WHERE status = ''ACTIVE'' LIMIT 1', []);
  try
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TSessionRepository.GetActive: TSessionModel;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT * FROM sessions WHERE status = ''ACTIVE'' ORDER BY created_at DESC LIMIT 1', []);
  try
    if not Q.IsEmpty then
      Result := RowToModel(Q)
    else
      Result.Id := '';
  finally
    Q.Free;
  end;
end;

function TSessionRepository.ListAll: TList<TSessionModel>;
var
  Q: TFDQuery;
begin
  Result := TList<TSessionModel>.Create;
  Q := FDB.OpenQuery('SELECT * FROM sessions ORDER BY created_at DESC', []);
  try
    while not Q.Eof do
    begin
      Result.Add(RowToModel(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TSessionRepository.UpdateSession(const Model: TSessionModel): Boolean;
begin
  Result := FDB.ExecuteWrite(
    'UPDATE sessions SET site = ?, operator = ?, date = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [Model.Site, Model.OperatorName, Model.DateStr, Model.Status, Model.Id]
  ) > 0;
end;

function TSessionRepository.SetActive(const Id: string): Boolean;
begin
  FDB.ExecuteWrite('UPDATE sessions SET status = ''PAUSED'' WHERE status = ''ACTIVE''', []);
  Result := FDB.ExecuteWrite('UPDATE sessions SET status = ''ACTIVE'' WHERE id = ?', [Id]) > 0;
end;

{ TTrayRepository }
constructor TTrayRepository.Create(ADB: TCPDatabaseManager);
begin
  inherited Create;
  FDB := ADB;
end;

function TTrayRepository.RowToModel(Q: TFDQuery): TTrayModel;
begin
  Result.Id := Q.FieldByName('id').AsInteger;
  Result.SessionId := Q.FieldByName('session_id').AsString;
  Result.HoleId := Q.FieldByName('hole_id').AsString;
  Result.TrayId := Q.FieldByName('tray_id').AsString;
  Result.IntervalFrom := Q.FieldByName('interval_from').AsFloat;
  Result.IntervalTo := Q.FieldByName('interval_to').AsFloat;
  Result.TrayRows := Q.FieldByName('tray_rows').AsInteger;
  Result.TrayLength := Q.FieldByName('tray_length').AsFloat;
  Result.TrayWidth := Q.FieldByName('tray_width').AsFloat;
  Result.Comments := Q.FieldByName('comments').AsString;
  Result.Status := Q.FieldByName('status').AsString;
  Result.CreatedAt := Q.FieldByName('created_at').AsString;
end;

function TTrayRepository.CreateTray(const Model: TTrayModel): TTrayModel;
var
  NewId: Int64;
begin
  NewId := FDB.ExecuteWrite(
    'INSERT INTO trays (session_id, hole_id, tray_id, interval_from, interval_to, tray_rows, tray_length, tray_width, comments, status) ' +
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [Model.SessionId, Model.HoleId, Model.TrayId, Model.IntervalFrom, Model.IntervalTo, Model.TrayRows, Model.TrayLength, Model.TrayWidth, Model.Comments, Model.Status]
  );
  Result := Model;
  Result.Id := NewId;
end;

function TTrayRepository.HasHoleAndTray(const SessionId, HoleId, TrayId: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT id FROM trays WHERE session_id = ? AND hole_id = ? AND tray_id = ? LIMIT 1', [SessionId, HoleId, TrayId]);
  try
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TTrayRepository.GetByHoleAndTray(const SessionId, HoleId, TrayId: string): TTrayModel;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT * FROM trays WHERE session_id = ? AND hole_id = ? AND tray_id = ? LIMIT 1', [SessionId, HoleId, TrayId]);
  try
    if not Q.IsEmpty then
      Result := RowToModel(Q)
    else
      Result.Id := 0;
  finally
    Q.Free;
  end;
end;

function TTrayRepository.GetById(Id: Integer): TTrayModel;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT * FROM trays WHERE id = ? LIMIT 1', [Id]);
  try
    if not Q.IsEmpty then
      Result := RowToModel(Q)
    else
      Result.Id := 0;
  finally
    Q.Free;
  end;
end;

function TTrayRepository.ListBySession(const SessionId: string): TList<TTrayModel>;
var
  Q: TFDQuery;
begin
  Result := TList<TTrayModel>.Create;
  Q := FDB.OpenQuery('SELECT * FROM trays WHERE session_id = ? ORDER BY id ASC', [SessionId]);
  try
    while not Q.Eof do
    begin
      Result.Add(RowToModel(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

{ TPhotoRepository }
constructor TPhotoRepository.Create(ADB: TCPDatabaseManager);
begin
  inherited Create;
  FDB := ADB;
end;

function TPhotoRepository.RowToModel(Q: TFDQuery): TPhotoModel;
begin
  Result.Id := Q.FieldByName('id').AsInteger;
  Result.SessionId := Q.FieldByName('session_id').AsString;
  Result.TrayId := Q.FieldByName('tray_id').AsInteger;
  Result.HoleId := Q.FieldByName('hole_id').AsString;
  Result.TrayNumber := Q.FieldByName('tray_number').AsString;
  Result.IntervalFrom := Q.FieldByName('interval_from').AsFloat;
  Result.IntervalTo := Q.FieldByName('interval_to').AsFloat;
  Result.FilenameBase := Q.FieldByName('filename_base').AsString;
  Result.RawPath := Q.FieldByName('raw_path').AsString;
  Result.JpgPath := Q.FieldByName('jpg_path').AsString;
  Result.ThumbnailPath := Q.FieldByName('thumbnail_path').AsString;
  Result.Md5Raw := Q.FieldByName('md5_raw').AsString;
  Result.Md5Jpg := Q.FieldByName('md5_jpg').AsString;
  Result.CropX := Q.FieldByName('crop_x').AsInteger;
  Result.CropY := Q.FieldByName('crop_y').AsInteger;
  Result.CropW := Q.FieldByName('crop_w').AsInteger;
  Result.CropH := Q.FieldByName('crop_h').AsInteger;
  Result.CameraModel := Q.FieldByName('camera_model').AsString;
  Result.CameraSerial := Q.FieldByName('camera_serial').AsString;
  Result.Status := Q.FieldByName('status').AsString;
  Result.IsActive := Q.FieldByName('is_active').AsInteger;
  Result.CapturedAt := Q.FieldByName('captured_at').AsString;
  Result.CreatedAt := Q.FieldByName('created_at').AsString;
  Result.UpdatedAt := Q.FieldByName('updated_at').AsString;
end;

function TPhotoRepository.CreatePhoto(const Model: TPhotoModel): TPhotoModel;
var
  NewId: Int64;
begin
  NewId := FDB.ExecuteWrite(
    'INSERT INTO photos (session_id, tray_id, hole_id, tray_number, interval_from, interval_to, filename_base, ' +
    'raw_path, jpg_path, thumbnail_path, md5_raw, md5_jpg, crop_x, crop_y, crop_w, crop_h, camera_model, camera_serial, status, is_active, captured_at) ' +
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [Model.SessionId, Model.TrayId, Model.HoleId, Model.TrayNumber, Model.IntervalFrom, Model.IntervalTo, Model.FilenameBase,
     Model.RawPath, Model.JpgPath, Model.ThumbnailPath, Model.Md5Raw, Model.Md5Jpg, Model.CropX, Model.CropY, Model.CropW, Model.CropH,
     Model.CameraModel, Model.CameraSerial, Model.Status, Model.IsActive, Model.CapturedAt]
  );
  Result := Model;
  Result.Id := NewId;
end;

function TPhotoRepository.UpdateStatus(Id: Integer; Status: TPhotoStatus): Boolean;
begin
  Result := FDB.ExecuteWrite(
    'UPDATE photos SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [PhotoStatusToString(Status), Id]
  ) > 0;
end;

function TPhotoRepository.UpdateProcessedData(Id: Integer; const JpgPath, ThumbPath, Md5Raw, Md5Jpg: string; Status: TPhotoStatus): Boolean;
begin
  Result := FDB.ExecuteWrite(
    'UPDATE photos SET jpg_path = ?, thumbnail_path = ?, md5_raw = ?, md5_jpg = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [JpgPath, ThumbPath, Md5Raw, Md5Jpg, PhotoStatusToString(Status), Id]
  ) > 0;
end;

function TPhotoRepository.MarkAsSuperseded(Id: Integer): Boolean;
begin
  Result := FDB.ExecuteWrite(
    'UPDATE photos SET is_active = 0, status = ''SUPERSEDED'', updated_at = CURRENT_TIMESTAMP WHERE id = ?',
    [Id]
  ) > 0;
end;

function TPhotoRepository.GetById(Id: Integer): TPhotoModel;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT * FROM photos WHERE id = ? LIMIT 1', [Id]);
  try
    if not Q.IsEmpty then
      Result := RowToModel(Q)
    else
      Result.Id := 0;
  finally
    Q.Free;
  end;
end;

function TPhotoRepository.ListBySession(const SessionId: string): TList<TPhotoModel>;
var
  Q: TFDQuery;
begin
  Result := TList<TPhotoModel>.Create;
  Q := FDB.OpenQuery('SELECT * FROM photos WHERE session_id = ? ORDER BY id ASC', [SessionId]);
  try
    while not Q.Eof do
    begin
      Result.Add(RowToModel(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TPhotoRepository.GetIncompletePhotos: TList<TPhotoModel>;
var
  Q: TFDQuery;
begin
  Result := TList<TPhotoModel>.Create;
  Q := FDB.OpenQuery('SELECT * FROM photos WHERE status IN (''CAPTURED'', ''PROCESSING'') AND is_active = 1', []);
  try
    while not Q.Eof do
    begin
      Result.Add(RowToModel(Q));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

{ TTransferRepository }
constructor TTransferRepository.Create(ADB: TCPDatabaseManager);
begin
  inherited Create;
  FDB := ADB;
end;

function TTransferRepository.RowToModel(Q: TFDQuery): TTransferModel;
begin
  Result.Id := Q.FieldByName('id').AsInteger;
  Result.PhotoId := Q.FieldByName('photo_id').AsInteger;
  Result.ServerUrl := Q.FieldByName('server_url').AsString;
  Result.Status := Q.FieldByName('status').AsString;
  Result.AttemptCount := Q.FieldByName('attempt_count').AsInteger;
  Result.LastAttemptAt := Q.FieldByName('last_attempt_at').AsString;
  Result.ResponseCode := Q.FieldByName('response_code').AsInteger;
  Result.ResponseBody := Q.FieldByName('response_body').AsString;
  Result.ErrorMessage := Q.FieldByName('error_message').AsString;
  Result.TransferredAt := Q.FieldByName('transferred_at').AsString;
end;

function TTransferRepository.CreateTransfer(const Model: TTransferModel): TTransferModel;
var
  NewId: Int64;
begin
  NewId := FDB.ExecuteWrite(
    'INSERT INTO transfers (photo_id, server_url, status) VALUES (?, ?, ?)',
    [Model.PhotoId, Model.ServerUrl, Model.Status]
  );
  Result := Model;
  Result.Id := NewId;
end;

function TTransferRepository.HasByPhotoId(PhotoId: Integer): Boolean;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT id FROM transfers WHERE photo_id = ? LIMIT 1', [PhotoId]);
  try
    Result := not Q.IsEmpty;
  finally
    Q.Free;
  end;
end;

function TTransferRepository.GetByPhotoId(PhotoId: Integer): TTransferModel;
var
  Q: TFDQuery;
begin
  Q := FDB.OpenQuery('SELECT * FROM transfers WHERE photo_id = ? LIMIT 1', [PhotoId]);
  try
    if not Q.IsEmpty then
      Result := RowToModel(Q)
    else
      Result.Id := 0;
  finally
    Q.Free;
  end;
end;

function TTransferRepository.UpdateStatus(Id: Integer; Status: TTransferStatus; ResponseCode: Integer; const ErrorMsg: string): Boolean;
begin
  Result := FDB.ExecuteWrite(
    'UPDATE transfers SET status = ?, response_code = ?, error_message = ?, transferred_at = CURRENT_TIMESTAMP WHERE id = ?',
    [TransferStatusToString(Status), ResponseCode, ErrorMsg, Id]
  ) > 0;
end;

{ TValidationRepository }
constructor TValidationRepository.Create(ADB: TCPDatabaseManager);
begin
  inherited Create;
  FDB := ADB;
end;

procedure TValidationRepository.AddResult(const Model: TValidationResultModel);
begin
  FDB.ExecuteWrite(
    'INSERT INTO validation_results (target_type, target_id, is_valid, rule_name, message) VALUES (?, ?, ?, ?, ?)',
    [Model.TargetType, Model.TargetId, Model.IsValid, Model.RuleName, Model.Message]
  );
end;

procedure TValidationRepository.ClearForTarget(const TargetType, TargetId: string);
begin
  FDB.ExecuteWrite('DELETE FROM validation_results WHERE target_type = ? AND target_id = ?', [TargetType, TargetId]);
end;

function TValidationRepository.GetByTarget(const TargetType, TargetId: string): TList<TValidationResultModel>;
var
  Q: TFDQuery;
  M: TValidationResultModel;
begin
  Result := TList<TValidationResultModel>.Create;
  Q := FDB.OpenQuery('SELECT * FROM validation_results WHERE target_type = ? AND target_id = ? ORDER BY id ASC', [TargetType, TargetId]);
  try
    while not Q.Eof do
    begin
      M.Id := Q.FieldByName('id').AsInteger;
      M.TargetType := Q.FieldByName('target_type').AsString;
      M.TargetId := Q.FieldByName('target_id').AsString;
      M.IsValid := Q.FieldByName('is_valid').AsInteger;
      M.RuleName := Q.FieldByName('rule_name').AsString;
      M.Message := Q.FieldByName('message').AsString;
      M.CheckedAt := Q.FieldByName('checked_at').AsString;
      Result.Add(M);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

{ TEventRepository }
constructor TEventRepository.Create(ADB: TCPDatabaseManager);
begin
  inherited Create;
  FDB := ADB;
end;

procedure TEventRepository.LogEvent(const SessionId, EventType, Description: string; const DetailsJson: string);
begin
  FDB.ExecuteWrite(
    'INSERT INTO application_events (session_id, event_type, description, details_json) VALUES (?, ?, ?, ?)',
    [SessionId, EventType, Description, DetailsJson]
  );
end;

end.
