unit CP.Imaging.Exif;

interface

uses
  System.SysUtils, System.Classes, System.Math, System.IOUtils;

type
  TExifMetadata = record
    Make: string;             // e.g. 'Canon'
    Model: string;            // e.g. 'Canon EOS 60D'
    Software: string;         // e.g. 'CorePhoto BD 1.0.0'
    DateTime: TDateTime;      // Date taken
    Comments: string;         // e.g. 'Site: GOSOWONG Hole: GND140'
    XResolution: Cardinal;    // 72
    YResolution: Cardinal;    // 72
    ResolutionUnit: Word;     // 2 (inches)
    FNumberNum: Cardinal;     // 10
    FNumberDen: Cardinal;     // 1 (f/10)
    ExposureTimeNum: Cardinal;// 1
    ExposureTimeDen: Cardinal;// 3 (1/3 sec)
    ISOSpeed: Word;           // 200
    class function DefaultCanon60D: TExifMetadata; static;
  end;

function BuildExifApp1Payload(const Meta: TExifMetadata): TBytes;
function BuildJpegCommentSegment(const Comment: string): TBytes;
function InjectExifAndEnforceFileSize(
  const JpgFilePath: string;
  const Meta: TExifMetadata;
  MinSizeMB: Double = 5.0;
  MaxSizeMB: Double = 10.0
): Boolean;

implementation

uses
  CP.Core.Logger;

class function TExifMetadata.DefaultCanon60D: TExifMetadata;
begin
  Result.Make := 'Canon';
  Result.Model := 'Canon EOS 60D';
  Result.Software := 'CorePhoto BD 1.0.0';
  Result.DateTime := Now;
  Result.Comments := 'Site: GOSOWONG Hole: GND140';
  Result.XResolution := 72;
  Result.YResolution := 72;
  Result.ResolutionUnit := 2;
  Result.FNumberNum := 10;
  Result.FNumberDen := 1;
  Result.ExposureTimeNum := 1;
  Result.ExposureTimeDen := 3;
  Result.ISOSpeed := 200;
end;

procedure WriteWordLE(Stream: TStream; W: Word);
begin
  Stream.WriteBuffer(W, 2);
end;

procedure WriteDWordLE(Stream: TStream; D: Cardinal);
begin
  Stream.WriteBuffer(D, 4);
end;

procedure WriteWordBE(Stream: TStream; W: Word);
var
  BE: Word;
begin
  BE := ((W and $FF) shl 8) or ((W shr 8) and $FF);
  Stream.WriteBuffer(BE, 2);
end;

function BuildExifApp1Payload(const Meta: TExifMetadata): TBytes;
var
  MS, DataStream: TMemoryStream;
  MakeBytes, ModelBytes, SoftBytes, DateBytes, XpBytes: TBytes;
  DateStr: string;
  NumIfd0, NumSubIfd: Word;
  Ifd0Size, SubIfdOffset, SubIfdSize, DataOffset: Cardinal;
  OffMake, OffModel, OffXRes, OffYRes, OffSoft, OffDate, OffXP: Cardinal;
  OffExpTime, OffFNum, OffOrigDate: Cardinal;
  procedure WriteTag(Tag, Typ: Word; Count, ValOrOffset: Cardinal);
  begin
    WriteWordLE(MS, Tag);
    WriteWordLE(MS, Typ);
    WriteDWordLE(MS, Count);
    if (Typ = 3) and (Count = 1) then
    begin
      WriteWordLE(MS, Word(ValOrOffset));
      WriteWordLE(MS, 0);
    end
    else
      WriteDWordLE(MS, ValOrOffset);
  end;
  function AppendData(const B: TBytes): Cardinal;
  begin
    Result := DataOffset + DataStream.Size;
    if Length(B) > 0 then
      DataStream.WriteBuffer(B[0], Length(B));
  end;
  function AppendRational(Num, Den: Cardinal): Cardinal;
  begin
    Result := DataOffset + DataStream.Size;
    WriteDWordLE(DataStream, Num);
    WriteDWordLE(DataStream, Den);
  end;
begin
  MS := TMemoryStream.Create;
  DataStream := TMemoryStream.Create;
  try
    DateStr := FormatDateTime('yyyy:mm:dd hh:nn:ss', Meta.DateTime);
    MakeBytes := TEncoding.ASCII.GetBytes(Meta.Make + #0);
    ModelBytes := TEncoding.ASCII.GetBytes(Meta.Model + #0);
    SoftBytes := TEncoding.ASCII.GetBytes(Meta.Software + #0);
    DateBytes := TEncoding.ASCII.GetBytes(DateStr + #0);
    XpBytes := TEncoding.Unicode.GetBytes(Meta.Comments + #0);

    NumIfd0 := 10;
    Ifd0Size := 2 + (NumIfd0 * 12) + 4;
    SubIfdOffset := 8 + Ifd0Size;

    NumSubIfd := 5;
    SubIfdSize := 2 + (NumSubIfd * 12) + 4;
    DataOffset := SubIfdOffset + SubIfdSize;

    OffMake := AppendData(MakeBytes);
    OffModel := AppendData(ModelBytes);
    OffXRes := AppendRational(Meta.XResolution, 1);
    OffYRes := AppendRational(Meta.YResolution, 1);
    OffSoft := AppendData(SoftBytes);
    OffDate := AppendData(DateBytes);
    OffXP := AppendData(XpBytes);

    OffExpTime := AppendRational(Meta.ExposureTimeNum, Meta.ExposureTimeDen);
    OffFNum := AppendRational(Meta.FNumberNum, Meta.FNumberDen);
    OffOrigDate := AppendData(DateBytes);

    // 1. Exif Header
    MS.WriteBuffer(PAnsiChar('Exif'#0#0)^, 6);

    // 2. TIFF Header (Little Endian: 'II', 42, offset 8)
    MS.WriteBuffer(PAnsiChar('II')^, 2);
    WriteWordLE(MS, 42);
    WriteDWordLE(MS, 8);

    // 3. IFD0 Entries (must be sorted by Tag ID ascending)
    WriteWordLE(MS, NumIfd0);
    WriteTag($010F, 2, Length(MakeBytes), OffMake);       // Make
    WriteTag($0110, 2, Length(ModelBytes), OffModel);     // Model
    WriteTag($0112, 3, 1, 1);                             // Orientation: Normal (1)
    WriteTag($011A, 5, 1, OffXRes);                       // XResolution
    WriteTag($011B, 5, 1, OffYRes);                       // YResolution
    WriteTag($0128, 3, 1, Meta.ResolutionUnit);           // ResolutionUnit: inches (2)
    WriteTag($0131, 2, Length(SoftBytes), OffSoft);       // Software
    WriteTag($0132, 2, Length(DateBytes), OffDate);       // DateTime
    WriteTag($8769, 4, 1, SubIfdOffset);                  // ExifOffset -> SubIFD
    WriteTag($9C9B, 1, Length(XpBytes), OffXP);           // XPComment (Windows Comments)
    WriteDWordLE(MS, 0);                                  // Next IFD offset = 0

    // 4. SubIFD Entries (sorted by Tag ID)
    WriteWordLE(MS, NumSubIfd);
    WriteTag($829A, 5, 1, OffExpTime);                    // ExposureTime
    WriteTag($829D, 5, 1, OffFNum);                       // FNumber
    WriteTag($8827, 3, 1, Meta.ISOSpeed);                 // ISOSpeedRatings
    WriteTag($9003, 2, Length(DateBytes), OffOrigDate);   // DateTimeOriginal
    WriteTag($A001, 3, 1, 1);                             // ColorSpace: sRGB (1)
    WriteDWordLE(MS, 0);                                  // Next SubIFD offset = 0

    // 5. Append all data payload
    if DataStream.Size > 0 then
    begin
      DataStream.Position := 0;
      MS.CopyFrom(DataStream, DataStream.Size);
    end;

    SetLength(Result, MS.Size);
    MS.Position := 0;
    MS.ReadBuffer(Result[0], MS.Size);
  finally
    DataStream.Free;
    MS.Free;
  end;
end;

function BuildJpegCommentSegment(const Comment: string): TBytes;
var
  TextBytes: TBytes;
  Len: Word;
begin
  TextBytes := TEncoding.UTF8.GetBytes(Comment);
  Len := Length(TextBytes) + 2;
  SetLength(Result, 2 + Len);
  Result[0] := $FF;
  Result[1] := $FE;
  Result[2] := (Len shr 8) and $FF;
  Result[3] := Len and $FF;
  if Length(TextBytes) > 0 then
    Move(TextBytes[0], Result[4], Length(TextBytes));
end;

function InjectExifAndEnforceFileSize(
  const JpgFilePath: string;
  const Meta: TExifMetadata;
  MinSizeMB: Double;
  MaxSizeMB: Double
): Boolean;
var
  InputBytes, ExifPayload, App1Seg, ComSeg: TBytes;
  PosIdx, TotalLen, ScanStart, SegTotal: Integer;
  Marker, LengthBE: Word;
  OutStream: TMemoryStream;
  MinBytes, CurrentSize, PadNeeded, Chunk: Int64;
  PadHeader: array[0..3] of Byte;
  ZeroBuf: array[0..65535] of Byte;
begin
  Result := False;
  if not TFile.Exists(JpgFilePath) then
    Exit;

  InputBytes := TFile.ReadAllBytes(JpgFilePath);
  TotalLen := Length(InputBytes);
  if (TotalLen < 4) or (InputBytes[0] <> $FF) or (InputBytes[1] <> $D8) then
    Exit;

  ExifPayload := BuildExifApp1Payload(Meta);
  SetLength(App1Seg, 4 + Length(ExifPayload));
  App1Seg[0] := $FF;
  App1Seg[1] := $E1;
  LengthBE := Length(ExifPayload) + 2;
  App1Seg[2] := (LengthBE shr 8) and $FF;
  App1Seg[3] := LengthBE and $FF;
  if Length(ExifPayload) > 0 then
    Move(ExifPayload[0], App1Seg[4], Length(ExifPayload));

  ComSeg := BuildJpegCommentSegment(Meta.Comments);

  // Scan segments to find scan data start and drop existing APP1/COM/APP15 padding
  PosIdx := 2;
  ScanStart := TotalLen;
  OutStream := TMemoryStream.Create;
  try
    // Write SOI
    OutStream.WriteBuffer(InputBytes[0], 2);
    // Write our new APP1 & COM segments
    OutStream.WriteBuffer(App1Seg[0], Length(App1Seg));
    OutStream.WriteBuffer(ComSeg[0], Length(ComSeg));

    while PosIdx < TotalLen do
    begin
      if InputBytes[PosIdx] <> $FF then
      begin
        ScanStart := PosIdx;
        Break;
      end;
      Marker := InputBytes[PosIdx + 1];
      if (Marker = $D9) or (Marker = $DA) then // EOI or SOS
      begin
        ScanStart := PosIdx;
        Break;
      end;
      if Marker in [$D0..$D7, $00, $01] then
      begin
        Inc(PosIdx, 2);
        Continue;
      end;
      if PosIdx + 3 >= TotalLen then
      begin
        ScanStart := PosIdx;
        Break;
      end;
      LengthBE := (InputBytes[PosIdx + 2] shl 8) or InputBytes[PosIdx + 3];
      SegTotal := 2 + LengthBE;
      if PosIdx + SegTotal > TotalLen then
      begin
        ScanStart := PosIdx;
        Break;
      end;

      // Filter out previous APP1 ($E1), COM ($FE), and APP15 padding ($EF)
      if not (Marker in [$E1, $FE, $EF]) then
      begin
        OutStream.WriteBuffer(InputBytes[PosIdx], SegTotal);
      end;
      Inc(PosIdx, SegTotal);
    end;

    // Check padding needed to meet MinSizeMB
    MinBytes := Round(MinSizeMB * 1024.0 * 1024.0);
    CurrentSize := OutStream.Size + (TotalLen - ScanStart);

    if (MinBytes > 0) and (CurrentSize < MinBytes) then
    begin
      PadNeeded := MinBytes - CurrentSize;
      FillChar(ZeroBuf, SizeOf(ZeroBuf), 0);

      while PadNeeded > 0 do
      begin
        Chunk := Min(PadNeeded - 4, 65530);
        if Chunk <= 0 then
          Chunk := 1;
        LengthBE := Chunk + 2;
        PadHeader[0] := $FF;
        PadHeader[1] := $EF; // APP15 Padding marker
        PadHeader[2] := (LengthBE shr 8) and $FF;
        PadHeader[3] := LengthBE and $FF;
        OutStream.WriteBuffer(PadHeader[0], 4);
        OutStream.WriteBuffer(ZeroBuf[0], Chunk);
        Dec(PadNeeded, Chunk + 4);
      end;
    end;

    // Write remainder of scan data
    if ScanStart < TotalLen then
    begin
      OutStream.WriteBuffer(InputBytes[ScanStart], TotalLen - ScanStart);
    end;

    OutStream.SaveToFile(JpgFilePath);
    Result := True;
    Log.Info(Format('Injected EXIF metadata into %s (Final size: %.2f MB)',
      [ExtractFileName(JpgFilePath), OutStream.Size / (1024.0 * 1024.0)]));
  finally
    OutStream.Free;
  end;
end;

end.
