unit TestDatabaseUpgraderProcessCollection;

interface

uses
  TestFramework,
  DatabaseUpgraderProcessCollection;

type
  TestTDatabaseUpgraderProcessCollection = class(TTestCase)
  strict private
    FDatabaseUpgraderProcessCollection: IDatabaseUpgraderProcessCollection;
    procedure RegisterTestProcess;
  public
    procedure SetUp; override;
  published
    procedure TestGetProcess;
    procedure TestRegisterProcess;
    procedure TestGetTargetDatabaseVersion;
    procedure TestGetIndexOfNextProcess;
  end;

implementation

uses
  TestDatabaseUpgraderProcess1111,
  TestDatabaseUpgraderProcess9999;

procedure TestTDatabaseUpgraderProcessCollection.SetUp;
begin
  FDatabaseUpgraderProcessCollection :=
    TDatabaseUpgraderProcessCollection.Create('TestDatabaseUpgraderProcess');
end;

procedure TestTDatabaseUpgraderProcessCollection.RegisterTestProcess;
begin
  // The .RegisterProcess is called in the order as below to proof that sorting (ascending) works.
  FDatabaseUpgraderProcessCollection.RegisterProcess(TTestDatabaseUpgraderProcess9999);
  FDatabaseUpgraderProcessCollection.RegisterProcess(TTestDatabaseUpgraderProcess1111);
end;

procedure TestTDatabaseUpgraderProcessCollection.TestGetProcess;
begin
  Check(FDatabaseUpgraderProcessCollection.GetProcess(0) = nil);
  FDatabaseUpgraderProcessCollection.RegisterProcess(TTestDatabaseUpgraderProcess1111);
  Check(FDatabaseUpgraderProcessCollection.GetProcess(0) = TTestDatabaseUpgraderProcess1111);
end;

procedure TestTDatabaseUpgraderProcessCollection.TestRegisterProcess;
begin
  RegisterTestProcess;
  Check(FDatabaseUpgraderProcessCollection.GetProcess(0) = TTestDatabaseUpgraderProcess1111);
  Check(FDatabaseUpgraderProcessCollection.GetProcess(1) = TTestDatabaseUpgraderProcess9999);
  CHeck(FDatabaseUpgraderProcessCollection.GetProcess(2) = nil);
end;

procedure TestTDatabaseUpgraderProcessCollection.TestGetTargetDatabaseVersion;
begin
  RegisterTestProcess;
  CheckEquals(1111,
    FDatabaseUpgraderProcessCollection.GetTargetDatabaseVersion(TTestDatabaseUpgraderProcess1111));
  CheckEquals(9999,
    FDatabaseUpgraderProcessCollection.GetTargetDatabaseVersion(TTestDatabaseUpgraderProcess9999));
end;

procedure TestTDatabaseUpgraderProcessCollection.TestGetIndexOfNextProcess;
var
  LIndexOfNextProcess: Integer;
begin
  RegisterTestProcess;
  LIndexOfNextProcess := FDatabaseUpgraderProcessCollection.GetIndexOfNextProcess(1110);
  Check(FDatabaseUpgraderProcessCollection.GetProcess(LIndexOfNextProcess) =
    TTestDatabaseUpgraderProcess1111);
  LIndexOfNextProcess := FDatabaseUpgraderProcessCollection.GetIndexOfNextProcess(1111);
  Check(FDatabaseUpgraderProcessCollection.GetProcess(LIndexOfNextProcess) =
    TTestDatabaseUpgraderProcess9999);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTDatabaseUpgraderProcessCollection.Suite);
end.

