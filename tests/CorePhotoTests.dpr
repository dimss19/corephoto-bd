program CorePhotoTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  CP.Core.PyFormat in '..\src\core\CP.Core.PyFormat.pas',
  CP.Validation.Interval in '..\src\validation\CP.Validation.Interval.pas',
  CP.Validation.Filename in '..\src\validation\CP.Validation.Filename.pas',
  CP.Test.PyFormat in 'CP.Test.PyFormat.pas',
  CP.Test.Validation in 'CP.Test.Validation.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
begin
  try
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);

    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    WriteLn('All tests completed.');
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
