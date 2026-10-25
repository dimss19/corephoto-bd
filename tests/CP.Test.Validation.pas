unit CP.Test.Validation;

interface

uses
  DUnitX.TestFramework,
  CP.Validation.Interval, CP.Validation.Filename;

type
  [TestFixture]
  TCPValidationTests = class
  public
    [Test]
    procedure TestIntervalValidation;
    [Test]
    procedure TestFilenameValidation;
  end;

implementation

procedure TCPValidationTests.TestIntervalValidation;
var
  Err: string;
begin
  Assert.IsTrue(ValidateInterval(0.0, 2.5, Err));
  Assert.IsTrue(ValidateInterval(2.5, 2.5, Err));
  Assert.IsFalse(ValidateInterval(3.0, 2.0, Err));
  Assert.IsFalse(ValidateInterval(-1.0, 2.0, Err));
end;

procedure TCPValidationTests.TestFilenameValidation;
var
  Err: string;
begin
  Assert.IsTrue(ValidateFilename('Core01_1_000.00_2.60.jpg', Err));
  Assert.IsTrue(ValidateFilename('TSD168_2_0.00_2.00', Err));
  Assert.IsFalse(ValidateFilename('InvalidName.jpg', Err));
  Assert.IsFalse(ValidateFilename('Core01_1_5.00_2.00.jpg', Err)); // To < From
end;

initialization
  TDUnitX.RegisterTestFixture(TCPValidationTests);

end.
