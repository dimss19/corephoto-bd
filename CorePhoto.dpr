program CorePhoto;

uses
  Vcl.Forms,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.DApt,
  FireDAC.DatS,
  CP.UI.Theme in 'src\ui\CP.UI.Theme.pas',
  CP.Ctl.Base in 'src\ui\controls\CP.Ctl.Base.pas',
  CP.Core.PyFormat in 'src\core\CP.Core.PyFormat.pas',
  CP.Core.Logger in 'src\core\CP.Core.Logger.pas',
  CP.DB.Models in 'src\database\CP.DB.Models.pas',
  CP.Config.Manager in 'src\config\CP.Config.Manager.pas',
  CP.Storage.Manager in 'src\storage\CP.Storage.Manager.pas',
  CP.DB.Manager in 'src\database\CP.DB.Manager.pas',
  CP.DB.Repositories in 'src\database\CP.DB.Repositories.pas',
  CP.Imaging.Crop in 'src\imaging\CP.Imaging.Crop.pas',
  CP.Imaging.Raw in 'src\imaging\CP.Imaging.Raw.pas',
  CP.Imaging.Thumbnail in 'src\imaging\CP.Imaging.Thumbnail.pas',
  CP.Imaging.Exif in 'src\imaging\CP.Imaging.Exif.pas',
  CP.Imaging.Processor in 'src\imaging\CP.Imaging.Processor.pas',
  CP.Validation.Interval in 'src\validation\CP.Validation.Interval.pas',
  CP.Validation.Filename in 'src\validation\CP.Validation.Filename.pas',
  CP.Validation.Preflight in 'src\validation\CP.Validation.Preflight.pas',
  CP.Validation.Runner in 'src\validation\CP.Validation.Runner.pas',
  CP.Diagnostics in 'src\diagnostics\CP.Diagnostics.pas',
  CP.Camera.Capabilities in 'src\camera\CP.Camera.Capabilities.pas',
  CP.Camera.Intf in 'src\camera\CP.Camera.Intf.pas',
  CP.Camera.Webcam in 'src\camera\adapters\CP.Camera.Webcam.pas',
  CP.Camera.DirectUsb in 'src\camera\adapters\CP.Camera.DirectUsb.pas',
  CP.Camera.HotFolder in 'src\camera\adapters\CP.Camera.HotFolder.pas',
  CP.Camera.WiFiDslr in 'src\camera\adapters\CP.Camera.WiFiDslr.pas',
  CP.Camera.Manager in 'src\camera\CP.Camera.Manager.pas',
  CP.Core.AppContext in 'src\core\CP.Core.AppContext.pas',
  CP.UI.DatePicker in 'src\ui\CP.UI.DatePicker.pas' {DatePickerModal},
  CP.UI.DataHub in 'src\ui\CP.UI.DataHub.pas' {DataHubView: TFrame},
  CP.UI.Review in 'src\ui\CP.UI.Review.pas' {ReviewView: TFrame},
  CP.UI.Settings in 'src\ui\CP.UI.Settings.pas' {SettingsView: TFrame},
  CP.UI.Capture in 'src\ui\CP.UI.Capture.pas' {CaptureView: TFrame},
  CP.UI.MainForm in 'src\ui\CP.UI.MainForm.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Core Photo';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
