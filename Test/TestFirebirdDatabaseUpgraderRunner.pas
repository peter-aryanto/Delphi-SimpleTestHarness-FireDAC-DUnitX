unit TestFirebirdDatabaseUpgraderRunner;

interface

uses
  TestFramework, TestExtensions,
  CommonDatabaseUpgraderRunner, FirebirdDatabaseUpgraderRunner;

type
  TestSetupFirebirdDatabaseUpgraderRunner = class(TTestSetup)
  strict private
    class var FCurrentApplicationPath: string;
    class var FFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner;
  protected
    procedure SetUp; override;
  public
    class property CurrentApplicationPath: string read FCurrentApplicationPath;
    class property FirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner
      read FFirebirdDatabaseUpgraderRunner;
  end;

  TestTFirebirdDatabaseUpgraderRunner = class(TTestCase)
  strict private
    function TestSetup: ICommonDatabaseUpgraderRunner;
    procedure SetTestDbLocation;
  published
    procedure TestGetDbLocation;
    procedure TestSetDbLocation;
    procedure TestRunUpgrade;
  end;

implementation

uses
  TestConstants,
  System.SysUtils,
  FireDAC.Comp.Client;

procedure TestSetupFirebirdDatabaseUpgraderRunner.SetUp;
begin
  inherited;

  FCurrentApplicationPath := ExtractFilePath(ParamStr(0));

  FFirebirdDatabaseUpgraderRunner := nil;
  FFirebirdDatabaseUpgraderRunner := TFirebirdDatabaseUpgraderRunner.Create(FCurrentApplicationPath
      + CTestFbEmbeddedFile);
end;

function TestTFirebirdDatabaseUpgraderRunner.TestSetup: ICommonDatabaseUpgraderRunner;
begin
  Result := TestSetupFirebirdDatabaseUpgraderRunner.FirebirdDatabaseUpgraderRunner;
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestGetDbLocation;
begin
  CheckEquals('', TestSetup.DatabaseLocation);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestSetDbLocation;
begin
  SetTestDbLocation;
  CheckEquals(TestSetupFirebirdDatabaseUpgraderRunner.CurrentApplicationPath + CTestDbFile,
    TestSetup.DatabaseLocation);
end;

procedure TestTFirebirdDatabaseUpgraderRunner.SetTestDbLocation;
begin
  TestSetup.DatabaseLocation := TestSetupFirebirdDatabaseUpgraderRunner.CurrentApplicationPath
      + CTestDbFile;
end;

procedure TestTFirebirdDatabaseUpgraderRunner.TestRunUpgrade;
begin
  CheckTrue(TestSetup.RunUpgrade);
end;

initialization
  RegisterTest(TestSetupFirebirdDatabaseUpgraderRunner.Create(
    TestTFirebirdDatabaseUpgraderRunner.Suite));
end.
