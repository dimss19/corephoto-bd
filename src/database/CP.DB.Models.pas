unit CP.DB.Models;

interface

uses
  System.SysUtils;

type
  TPhotoStatus = (
    psDraft,
    psCaptured,
    psProcessing,
    psProcessed,
    psValid,
    psInvalid,
    psReadyToTransfer,
    psTransferring,
    psTransferred,
    psTransferFailed,
    psSuperseded
  );

  TSessionStatus = (
    ssActive,
    ssPaused,
    ssCompleted,
    ssArchived
  );

  TTransferStatus = (
    tsPending,
    tsUploading,
    tsSuccess,
    tsFailed
  );

  TSessionModel = record
    Id: string;
    Site: string;
    DateStr: string;
    OperatorName: string;
    Status: string;
    CreatedAt: string;
    UpdatedAt: string;
  end;

  TTrayModel = record
    Id: Integer;
    SessionId: string;
    HoleId: string;
    TrayId: string;
    IntervalFrom: Double;
    IntervalTo: Double;
    TrayRows: Integer;
    TrayLength: Double;
    TrayWidth: Double;
    Comments: string;
    Status: string;
    CreatedAt: string;
  end;

  TPhotoModel = record
    Id: Integer;
    SessionId: string;
    TrayId: Integer;
    HoleId: string;
    TrayNumber: string;
    IntervalFrom: Double;
    IntervalTo: Double;
    FilenameBase: string;
    RawPath: string;
    JpgPath: string;
    ThumbnailPath: string;
    Md5Raw: string;
    Md5Jpg: string;
    CropX: Integer;
    CropY: Integer;
    CropW: Integer;
    CropH: Integer;
    CameraModel: string;
    CameraSerial: string;
    Status: string;
    IsActive: Integer;
    CapturedAt: string;
    CreatedAt: string;
    UpdatedAt: string;
  end;

  TCameraDeviceModel = record
    Id: Integer;
    Name: string;
    AdapterType: string;
    VendorInfo: string;
    SerialNumber: string;
    CapabilitiesJson: string;
    LastConnectedAt: string;
  end;

  TTransferModel = record
    Id: Integer;
    PhotoId: Integer;
    ServerUrl: string;
    Status: string;
    AttemptCount: Integer;
    LastAttemptAt: string;
    ResponseCode: Integer;
    ResponseBody: string;
    ErrorMessage: string;
    TransferredAt: string;
  end;

  TValidationResultModel = record
    Id: Integer;
    TargetType: string;
    TargetId: string;
    IsValid: Integer;
    RuleName: string;
    Message: string;
    CheckedAt: string;
  end;

  TApplicationEventModel = record
    Id: Integer;
    SessionId: string;
    EventType: string;
    Description: string;
    DetailsJson: string;
    CreatedAt: string;
  end;

function PhotoStatusToString(Status: TPhotoStatus): string;
function StringToPhotoStatus(const S: string): TPhotoStatus;

function SessionStatusToString(Status: TSessionStatus): string;
function StringToSessionStatus(const S: string): TSessionStatus;

function TransferStatusToString(Status: TTransferStatus): string;
function StringToTransferStatus(const S: string): TTransferStatus;

implementation

function PhotoStatusToString(Status: TPhotoStatus): string;
begin
  case Status of
    psDraft: Result := 'DRAFT';
    psCaptured: Result := 'CAPTURED';
    psProcessing: Result := 'PROCESSING';
    psProcessed: Result := 'PROCESSED';
    psValid: Result := 'VALID';
    psInvalid: Result := 'INVALID';
    psReadyToTransfer: Result := 'READY_TO_TRANSFER';
    psTransferring: Result := 'TRANSFERRING';
    psTransferred: Result := 'TRANSFERRED';
    psTransferFailed: Result := 'TRANSFER_FAILED';
    psSuperseded: Result := 'SUPERSEDED';
  else
    Result := 'DRAFT';
  end;
end;

function StringToPhotoStatus(const S: string): TPhotoStatus;
var
  U: string;
begin
  U := UpperCase(Trim(S));
  if U = 'CAPTURED' then Result := psCaptured
  else if U = 'PROCESSING' then Result := psProcessing
  else if U = 'PROCESSED' then Result := psProcessed
  else if U = 'VALID' then Result := psValid
  else if U = 'INVALID' then Result := psInvalid
  else if U = 'READY_TO_TRANSFER' then Result := psReadyToTransfer
  else if U = 'TRANSFERRING' then Result := psTransferring
  else if U = 'TRANSFERRED' then Result := psTransferred
  else if U = 'TRANSFER_FAILED' then Result := psTransferFailed
  else if U = 'SUPERSEDED' then Result := psSuperseded
  else Result := psDraft;
end;

function SessionStatusToString(Status: TSessionStatus): string;
begin
  case Status of
    ssActive: Result := 'ACTIVE';
    ssPaused: Result := 'PAUSED';
    ssCompleted: Result := 'COMPLETED';
    ssArchived: Result := 'ARCHIVED';
  else
    Result := 'ACTIVE';
  end;
end;

function StringToSessionStatus(const S: string): TSessionStatus;
var
  U: string;
begin
  U := UpperCase(Trim(S));
  if U = 'PAUSED' then Result := ssPaused
  else if U = 'COMPLETED' then Result := ssCompleted
  else if U = 'ARCHIVED' then Result := ssArchived
  else Result := ssActive;
end;

function TransferStatusToString(Status: TTransferStatus): string;
begin
  case Status of
    tsPending: Result := 'PENDING';
    tsUploading: Result := 'UPLOADING';
    tsSuccess: Result := 'SUCCESS';
    tsFailed: Result := 'FAILED';
  else
    Result := 'PENDING';
  end;
end;

function StringToTransferStatus(const S: string): TTransferStatus;
var
  U: string;
begin
  U := UpperCase(Trim(S));
  if U = 'UPLOADING' then Result := tsUploading
  else if U = 'SUCCESS' then Result := tsSuccess
  else if U = 'FAILED' then Result := tsFailed
  else Result := tsPending;
end;

end.
