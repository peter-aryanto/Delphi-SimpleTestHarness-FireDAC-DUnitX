unit TestFirebirdDatabaseUpgraderRunner;

interface

uses
  DUnitX.TestFramework, DUnitX.Assert,
  CommonDatabaseUpgraderRunner, FirebirdDatabaseUpgraderRunner,
  FireDAC.Comp.Client;

type
  TestSetupFirebirdDatabaseUpgraderRunner = class
  strict private
    class function GetCurrentApplicationPath: string;
  protected
  public
    class function CreateRunner: ICommonDatabaseUpgraderRunner;
    class procedure AssignTestDatabaseLocation(
      const AFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner);
    class function GetTestDatabaseLocation: string;
  end;

  TestTFirebirdDatabaseUpgraderRunner = class
  strict private
    FFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner;
    function GetTestDatabaseTransaction: TFDTransaction;
  public
    [SetupFixture]
    procedure SetUp;
    [Test]
    procedure TestGetDatabaseLocation;
    [Test]
    procedure TestSetDatabaseLocation;
    [Test]
    procedure TestGetDatabaseVersionAsInteger;
    [Test]
    procedure TestGetDatabaseVersionAsString;
    [Test]
    procedure TestStartTransaction;
    [Test]
    procedure TestCommitTransaction;
    [Test]
    procedure TestRollbackTransaction;
    [Test]
    procedure TestRunUpgrade;
  end;

implementation

uses
  TestConstants,
  System.SysUtils,
  SampleDatabaseUpgraderProcessCollection,
  Winapi.Windows;

class function TestSetupFirebirdDatabaseUpgraderRunner.CreateRunner: ICommonDatabaseUpgraderRunner;
begin
  Result := TFirebirdDatabaseUpgraderRunner.Create(GetCurrentApplicationPath + CTestFbEmbeddedFile);
end;

class function TestSetupFirebirdDatabaseUpgraderRunner.GetCurrentApplicationPath;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

class procedure TestSetupFirebirdDatabaseUpgraderRunner.AssignTestDatabaseLocation(
  const AFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner);
begin
  AFirebirdDatabaseUpgraderRunner.DatabaseLocation := GetTestDatabaseLocation;
end;

class function TestSetupFirebirdDatabaseUpgraderRunner.GetTestDatabaseLocation: string;
begin
  Result := GetCurrentApplicationPath + CTestDbFile;
end;

procedure TestTFirebirdDatabaseUpgraderRunner.SetUp;
var
  LConsoleInfo: TConsoleScreenBufferInfo;
begin
  FFirebirdDatabaseUpgraderRunner := TestSetupFirebirdDatabaseUpgraderRunner.CreateRunner;

  FFirebirdDatabaseUpgraderRunner.OnMessage := procedure (const AMessage: string)
    begin
      GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), LConsoleInfo);
      if LConsoleInfo.dwCursorPosition.X > 0 then System.Writeln;
      System.Writeln('>>>>>> [Ouput]:  ' + AMessage);
    end;
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestGetDatabaseLocation;
begin
  Assert.AreEqual('', FFirebirdDatabaseUpgraderRunner.DatabaseLocation);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestSetDatabaseLocation;
begin
  TestSetupFirebirdDatabaseUpgraderRunner.AssignTestDatabaseLocation(
    FFirebirdDatabaseUpgraderRunner);
  Assert.AreEqual(TestSetupFirebirdDatabaseUpgraderRunner.GetTestDatabaseLocation,
    FFirebirdDatabaseUpgraderRunner.DatabaseLocation);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestGetDatabaseVersionAsInteger;
begin
  Assert.AreEqual(CInitialDbVersionAsInteger,
    FFirebirdDatabaseUpgraderRunner.GetDatabaseVersionAsInteger);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestGetDatabaseVersionAsString;
begin
  Assert.AreEqual(CInitialDbVersionAsString,
    FFirebirdDatabaseUpgraderRunner.GetDatabaseVersionAsString(
      FFirebirdDatabaseUpgraderRunner.GetDatabaseVersionAsInteger));
end;

function TestTFirebirdDatabaseUpgraderRunner.GetTestDatabaseTransaction: TFDTransaction;
begin
  Result := (FFirebirdDatabaseUpgraderRunner.GetDatabaseConnection as TFDConnection)
    .Transaction as TFDTransaction;
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestStartTransaction;
begin
  Assert.IsTrue(not GetTestDatabaseTransaction.Active,
    'Initially, it is expected that database transaction is NOT active.');
  FFirebirdDatabaseUpgraderRunner.StartTransaction;
  Assert.IsTrue(GetTestDatabaseTransaction.Active,
    'After being started, database transaction should be active.');
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestCommitTransaction;
begin
  if not GetTestDatabaseTransaction.Active then
    TestStartTransaction;

  FFirebirdDatabaseUpgraderRunner.CommitTransaction;
  Assert.IsTrue(not GetTestDatabaseTransaction.Active,
    'After commit, it is expected that database transaction is NO longer active.');
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestRollbackTransaction;
begin
  if not GetTestDatabaseTransaction.Active then
    TestStartTransaction;

  FFirebirdDatabaseUpgraderRunner.RollbackTransaction;
  Assert.IsTrue(not GetTestDatabaseTransaction.Active,
    'After rollback, it is expected that database transaction is NO longer active.');
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestRunUpgrade;
begin
  Assert.IsTrue(FFirebirdDatabaseUpgraderRunner.RunUpgrade(SampleUpgraderProcessCollection));
end;

initialization
  TDUnitX.RegisterTestFixture(TestTFirebirdDatabaseUpgraderRunner);
end.
