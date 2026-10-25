unit CP.Test.PyFormat;

interface

uses
  DUnitX.TestFramework, CP.Core.PyFormat;

type
  [TestFixture]
  TCPPyFormatTests = class
  public
    [Test]
    procedure TestZeroPadding;
    [Test]
    procedure TestPyFmtG;
    [Test]
    procedure TestFormatCoreFilename;
  end;

implementation

procedure TCPPyFormatTests.TestZeroPadding;
begin
  Assert.AreEqual('000.00', PyFmtZeroPad(0.0, 6, 2));
  Assert.AreEqual('002.60', PyFmtZeroPad(2.6, 6, 2));
  Assert.AreEqual('012.34', PyFmtZeroPad(12.34, 6, 2));
  Assert.AreEqual('123.45', PyFmtZeroPad(123.45, 6, 2));
end;

procedure TCPPyFormatTests.TestPyFmtG;
begin
  Assert.AreEqual('0', PyFmtG(0.0));
  Assert.AreEqual('2', PyFmtG(2.0));
  Assert.AreEqual('2.6', PyFmtG(2.6));
  Assert.AreEqual('123.456', PyFmtG(123.456));
end;

procedure TCPPyFormatTests.TestFormatCoreFilename;
begin
  Assert.AreEqual('Core01_1_000.00_2.60', FormatCoreFilename('Core01', '1', 0.0, 2.6));
  Assert.AreEqual('TSD_168_Tray_2_002.60_5.20', FormatCoreFilename('TSD 168', 'Tray 2', 2.6, 5.2));
end;

initialization
  TDUnitX.RegisterTestFixture(TCPPyFormatTests);

end.
