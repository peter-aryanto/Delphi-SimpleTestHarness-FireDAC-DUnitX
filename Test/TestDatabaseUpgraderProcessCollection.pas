unit TestDatabaseUpgraderProcessCollection;

interface

uses
  DUnitX.TestFramework, DUnitX.Assert,
  DatabaseUpgraderProcessCollection;

type
  TestTDatabaseUpgraderProcessCollection = class
  strict private
    FDatabaseUpgraderProcessCollection: IDatabaseUpgraderProcessCollection;
    procedure RegisterTestProcess;
  public
    [Setup]
    procedure SetUp;
    [Test]
    procedure TestGetProcess;
    [Test]
    procedure TestRegisterProcess;
    [Test]
    procedure TestGetTargetDatabaseVersion;
//    procedure TestGetIndexOfNextProcess;
  end;

implementation

uses
  SampleDatabaseUpgraderProcess1111,
  SampleDatabaseUpgraderProcess9999;

procedure TestTDatabaseUpgraderProcessCollection.SetUp;
begin
  FDatabaseUpgraderProcessCollection :=
    TDatabaseUpgraderProcessCollection.Create('SampleDatabaseUpgraderProcess');
end;

procedure TestTDatabaseUpgraderProcessCollection.RegisterTestProcess;
begin
  // The .RegisterProcess is called in the order as below to proof that sorting (ascending) works.
  FDatabaseUpgraderProcessCollection.RegisterProcess(TSampleDatabaseUpgraderProcess9999);
  FDatabaseUpgraderProcessCollection.RegisterProcess(TSampleDatabaseUpgraderProcess1111);
end;

procedure TestTDatabaseUpgraderProcessCollection.TestGetProcess;
begin
  Assert.IsNull(FDatabaseUpgraderProcessCollection.GetProcess(0));
  FDatabaseUpgraderProcessCollection.RegisterProcess(TSampleDatabaseUpgraderProcess1111);
  Assert.AreEqual(FDatabaseUpgraderProcessCollection.GetProcess(0).ClassName,
    TSampleDatabaseUpgraderProcess1111.ClassName);
end;

procedure TestTDatabaseUpgraderProcessCollection.TestRegisterProcess;
begin
  RegisterTestProcess;
  Assert.AreEqual(FDatabaseUpgraderProcessCollection.GetProcess(0).ClassName,
    TSampleDatabaseUpgraderProcess1111.ClassName);
  Assert.AreEqual(FDatabaseUpgraderProcessCollection.GetProcess(1).ClassName,
    TSampleDatabaseUpgraderProcess9999.ClassName);
  Assert.IsNull(FDatabaseUpgraderProcessCollection.GetProcess(2));
end;

procedure TestTDatabaseUpgraderProcessCollection.TestGetTargetDatabaseVersion;
begin
  RegisterTestProcess;
  Assert.AreEqual(1111,
    FDatabaseUpgraderProcessCollection.GetTargetDatabaseVersion(
      TSampleDatabaseUpgraderProcess1111));
  Assert.AreEqual(9999,
    FDatabaseUpgraderProcessCollection.GetTargetDatabaseVersion(
      TSampleDatabaseUpgraderProcess9999));
end;

{
procedure TestTDatabaseUpgraderProcessCollection.TestGetIndexOfNextProcess;
var
  LIndexOfNextProcess: Integer;
begin
  RegisterTestProcess;
  LIndexOfNextProcess := FDatabaseUpgraderProcessCollection.GetIndexOfNextProcess(1110);
  Check(FDatabaseUpgraderProcessCollection.GetProcess(LIndexOfNextProcess) =
    TSampleDatabaseUpgraderProcess1111);
  LIndexOfNextProcess := FDatabaseUpgraderProcessCollection.GetIndexOfNextProcess(1111);
  Check(FDatabaseUpgraderProcessCollection.GetProcess(LIndexOfNextProcess) =
    TSampleDatabaseUpgraderProcess9999);
end;
}

initialization
  // Register any test cases with the test runner
  TDUnitX.RegisterTestFixture(TestTDatabaseUpgraderProcessCollection);
end.

