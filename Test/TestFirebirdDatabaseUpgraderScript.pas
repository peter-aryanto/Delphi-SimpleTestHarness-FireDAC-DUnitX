unit TestFirebirdDatabaseUpgraderScript;

interface

uses
  DUnitX.TestFramework, DUnitX.Assert,
  CommonDatabaseUpgraderRunner,
  CommonDatabaseUpgraderScript, FirebirdDatabaseUpgraderScript;

type
  TestTFirebirdDatabaseUpgraderScript = class
  strict private const
    CTestNewTableField = 'NEW_TABLE_FIELD';
  strict private
    FFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner;
    function CreateScript: ICommonDatabaseUpgraderScript;
    function GetTestDdlScriptStatement(const ATableName: string): string;
    function GetTestDmlScriptStatement(const ATableName: string): string;
  public
    [SetupFixture]
    procedure SetUp;
    [Test]
    procedure TestExecuteScript;
  end;

implementation

uses
  TestFirebirdDatabaseUpgraderRunner,
  CommonDatabaseUpgraderQuery, TestFirebirdDatabaseUpgraderQuery,
  FireDAC.Comp.Client,
  Data.DB,
  TestConstants;

procedure TestTFirebirdDatabaseUpgraderScript.SetUp;
begin
  FFirebirdDatabaseUpgraderRunner := TestSetupFirebirdDatabaseUpgraderRunner.CreateRunner;
  TestSetupFirebirdDatabaseUpgraderRunner.AssignTestDatabaseLocation(
    FFirebirdDatabaseUpgraderRunner);
end;

function TestTFirebirdDatabaseUpgraderScript.CreateScript: ICommonDatabaseUpgraderScript;
begin
  Result := TFirebirdDatabaseUpgraderScript.Create(
    FFirebirdDatabaseUpgraderRunner.GetDatabaseConnection as TFDConnection);
end;

function TestTFirebirdDatabaseUpgraderScript.GetTestDdlScriptStatement(
  const ATableName: string
): string;
begin
  Result :=
    ' SET TERM ^ ; ' + #13#10 +
    '  ' + #13#10 +
    ' execute block as ' + #13#10 +
    ' begin ' + #13#10 +
    '   if ( not exists( ' + #13#10 +
    '     select 1 ' + #13#10 +
    '     from rdb$relations ' + #13#10 +
    '     where rdb$relation_name = ''' + ATableName + ''' ' + #13#10 +
    '   ) ) ' + #13#10 +
    '   then execute statement '' create table ' +
            ATableName + ' ( ' + CTestNewTableField + ' VARCHAR(3) ); ''; ' + #13#10 +
    ' end^ ' + #13#10 +
    '  ' + #13#10 +
    ' SET TERM ; ^ ';
end;

function TestTFirebirdDatabaseUpgraderScript.GetTestDmlScriptStatement(
  const ATableName: string
): string;
begin
  Result := ' insert into ' + ATableName + '(' + CTestNewTableField + ') ' + #13#10
      + '   values (''XYZ''); ';
end;

procedure TestTFirebirdDatabaseUpgraderScript.TestExecuteScript;
const
  CNewTableName1 = 'NEW_TABLE_1';
  CNewTableName2 = 'NEW_TABLE_2';
var
  LTestScriptStatements: string;
  LSelectQueryForCheckingScriptRunResult: ICommonDatabaseUpgraderQuery;
  LQueryResult: TDataSet;
begin
  LTestScriptStatements := GetTestDdlScriptStatement(CNewTableName1) + #13#10 
      + GetTestDdlScriptStatement(CNewTableName2);
  CreateScript.ExecuteScript(LTestScriptStatements);

  LSelectQueryForCheckingScriptRunResult := TestTFirebirdDatabaseUpgraderQuery.CreateQuery(
    FFirebirdDatabaseUpgraderRunner.GetDatabaseConnection as TFDConnection);
  LSelectQueryForCheckingScriptRunResult.Sql := ' select 1 from ' + CNewTableName1 + ' union all '
      + ' select 1 from ' + CNewTableName2;
  LQueryResult := LSelectQueryForCheckingScriptRunResult.ExecuteSelectQuery([]);
  Assert.AreEqual(0, LQueryResult.RecordCount);

  LTestScriptStatements := GetTestDmlScriptStatement(CNewTableName1) + #13#10
      + GetTestDmlScriptStatement(CNewTableName2);
  CreateScript.ExecuteScript(LTestScriptStatements);

  LQueryResult := LSelectQueryForCheckingScriptRunResult.ExecuteSelectQuery([]);
  Assert.AreEqual(2, LQueryResult.RecordCount);
end;

initialization
  // Register any test cases with the test runner
  TDUnitX.RegisterTestFixture(TestTFirebirdDatabaseUpgraderScript);
end.

