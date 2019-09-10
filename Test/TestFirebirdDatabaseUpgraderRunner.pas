unit TestFirebirdDatabaseUpgraderRunner;

interface

uses
  TestFramework, TestExtensions,
  CommonDatabaseUpgraderRunner, FirebirdDatabaseUpgraderRunner,
  FireDAC.Comp.Client;

type
  TestSetupFirebirdDatabaseUpgraderRunner = class(TTestSetup)
  strict private
    class var FCurrentApplicationPath: string;
    class var FFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner;
  protected
    procedure SetUp; override;
  public
    class function CreateFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner;
    class procedure SetTestDbLocation;
    class property CurrentApplicationPath: string read FCurrentApplicationPath;
    class property FirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner
      read FFirebirdDatabaseUpgraderRunner;
  end;

  TestTFirebirdDatabaseUpgraderRunner = class(TTestCase)
  strict private
    function TestSetup: ICommonDatabaseUpgraderRunner;
    function GetTestDatabaseTransaction: TFDTransaction;
  published
    procedure TestGetDatabaseLocation;
    procedure TestSetDatabaseLocation;
    procedure TestGetDatabaseVersionAsInteger;
    procedure TestGetDatabaseVersionAsString;
    procedure TestStartTransaction;
    procedure TestCommitTransaction;
    procedure TestRollbackTransaction;
    procedure TestRunUpgrade;
  end;

implementation

uses
  TestConstants,
  System.SysUtils;

procedure TestSetupFirebirdDatabaseUpgraderRunner.SetUp;
begin
  TestSetupFirebirdDatabaseUpgraderRunner.CreateFirebirdDatabaseUpgraderRunner;
end;

class function TestSetupFirebirdDatabaseUpgraderRunner.CreateFirebirdDatabaseUpgraderRunner:
  ICommonDatabaseUpgraderRunner;
begin
  FCurrentApplicationPath := ExtractFilePath(ParamStr(0));

  FFirebirdDatabaseUpgraderRunner := nil;
  FFirebirdDatabaseUpgraderRunner := TFirebirdDatabaseUpgraderRunner.Create(FCurrentApplicationPath
      + CTestFbEmbeddedFile);

  Result := FFirebirdDatabaseUpgraderRunner;
end;

class procedure TestSetupFirebirdDatabaseUpgraderRunner.SetTestDbLocation;
begin
  FFirebirdDatabaseUpgraderRunner.DatabaseLocation :=
    TestSetupFirebirdDatabaseUpgraderRunner.CurrentApplicationPath + CTestDbFile;
end;

function TestTFirebirdDatabaseUpgraderRunner.TestSetup: ICommonDatabaseUpgraderRunner;
begin
  Result := TestSetupFirebirdDatabaseUpgraderRunner.FirebirdDatabaseUpgraderRunner;
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestGetDatabaseLocation;
begin
  CheckEquals('', TestSetup.DatabaseLocation);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestSetDatabaseLocation;
begin
  TestSetupFirebirdDatabaseUpgraderRunner.SetTestDbLocation;
  CheckEquals(TestSetupFirebirdDatabaseUpgraderRunner.CurrentApplicationPath + CTestDbFile,
    TestSetup.DatabaseLocation);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestGetDatabaseVersionAsInteger;
begin
  CheckEquals(TestSetup.GetDatabaseVersionAsInteger, CInitialDbVersionAsInteger);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestGetDatabaseVersionAsString;
begin
  CheckEquals(TestSetup.GetDatabaseVersionAsString(TestSetup.GetDatabaseVersionAsInteger),
    CInitialDbVersionAsString);
end;

function TestTFirebirdDatabaseUpgraderRunner.GetTestDatabaseTransaction: TFDTransaction;
begin
  Result := (TestSetup.GetDatabaseConnection as TFDConnection).Transaction as TFDTransaction;
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestStartTransaction;
begin
  CheckTrue(not GetTestDatabaseTransaction.Active,
    'Initially, it is expected that database transaction is NOT active.');
  TestSetup.StartTransaction;
  CheckTrue(GetTestDatabaseTransaction.Active,
    'After being started, database transaction should be active.');
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestCommitTransaction;
begin
  if not GetTestDatabaseTransaction.Active then
    TestStartTransaction;

  TestSetup.CommitTransaction;
  CheckTrue(not GetTestDatabaseTransaction.Active,
    'After commit, it is expected that database transaction is NO longer active.');
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestRollbackTransaction;
begin
  if not GetTestDatabaseTransaction.Active then
    TestStartTransaction;

  TestSetup.RollbackTransaction;
  CheckTrue(not GetTestDatabaseTransaction.Active,
    'After rollback, it is expected that database transaction is NO longer active.');
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestRunUpgrade;
begin
  CheckTrue(TestSetup.RunUpgrade);
end;

initialization
  RegisterTest(TestSetupFirebirdDatabaseUpgraderRunner.Create(
    TestTFirebirdDatabaseUpgraderRunner.Suite));
end.
