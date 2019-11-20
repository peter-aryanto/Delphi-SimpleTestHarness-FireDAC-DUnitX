unit TestFirebirdDatabaseUpgraderQuery;

interface

uses
  DUnitX.TestFramework, DUnitX.Assert,
  FireDAC.Comp.Client,
  CommonDatabaseUpgraderRunner,
  CommonDatabaseUpgraderQuery, FirebirdDatabaseUpgraderQuery;

type
  TestTFirebirdDatabaseUpgraderQuery = class
  strict private const
    CTestSqlTableName = 'version';
    CTestSqlFieldName = 'version_number';
    CTestSqlParamName = 'VersionNumber';
    CTestSelectQuery = ' select '
      + #13#10 +     CTestSqlFieldName
      + #13#10 + ' from '
      + #13#10 +     CTestSqlTableName
      + #13#10 + ' where '
      + #13#10 +     CTestSqlFieldName + ' >= :' + CTestSqlParamName;
    CDummyUpdateValue = 'DUMMY';
  strict private
    FFirebirdDatabaseUpgraderRunner: ICommonDatabaseUpgraderRunner;
    function CreateQuery: ICommonDatabaseUpgraderQuery; overload;
    function GetTestNonSelectQuery: string;
  public
    [SetupFixture]
    procedure SetUp;
    class function CreateQuery(
      const ADatabaseConnection: TFDConnection
    ): ICommonDatabaseUpgraderQuery; overload;
    [Test]
    procedure TestSqlProperty;
    [Test]
    procedure TestExecuteSelectQuery;
    [Test]
    procedure TestExecuteNonSelectQuery;
  end;

implementation

uses
  TestFirebirdDatabaseUpgraderRunner,
  Data.DB,
  TestConstants;

procedure TestTFirebirdDatabaseUpgraderQuery.SetUp;
begin
  FFirebirdDatabaseUpgraderRunner := TestSetupFirebirdDatabaseUpgraderRunner.CreateRunner;
  TestSetupFirebirdDatabaseUpgraderRunner.AssignTestDatabaseLocation(
    FFirebirdDatabaseUpgraderRunner);
end;

function TestTFirebirdDatabaseUpgraderQuery.CreateQuery: ICommonDatabaseUpgraderQuery;
begin
  Result := TFirebirdDatabaseUpgraderQuery.Create(
    FFirebirdDatabaseUpgraderRunner.GetDatabaseConnection as TFDConnection);
end;

class function TestTFirebirdDatabaseUpgraderQuery.CreateQuery(
  const ADatabaseConnection: TFDConnection
): ICommonDatabaseUpgraderQuery;
begin
  Result := TFirebirdDatabaseUpgraderQuery.Create(ADatabaseConnection);
end;

procedure TestTFirebirdDatabaseUpgraderQuery.TestSqlProperty;
var
  LQuery: ICommonDatabaseUpgraderQuery;
begin
  LQuery := CreateQuery;
  Assert.AreEqual('', LQuery.Sql);
  LQuery.Sql := CTestSelectQuery;
  Assert.AreEqual(CTestSelectQuery, LQuery.Sql);
end;

procedure TestTFirebirdDatabaseUpgraderQuery.TestExecuteSelectQuery;
var
  LQuery: ICommonDatabaseUpgraderQuery;
  LDatabaseTransaction: TFDTransaction;
  LQueryResult: TDataSet;
begin
  LQuery := CreateQuery;
  LQuery.Sql := CTestSelectQuery;

  LDatabaseTransaction := (FFirebirdDatabaseUpgraderRunner.GetDatabaseConnection as TFDConnection)
    .Transaction as TFDTransaction;

  Assert.IsTrue(not LDatabaseTransaction.Active,
    'Initially, it is expected that database transaction is NOT active, '
        + 'the select query has to be able to start a database transaction by itself.');

  LQueryResult := LQuery.ExecuteSelectQuery([CInitialDbVersionAsString]);
  Assert.AreEqual(1, LQueryResult.RecordCount);
  Assert.IsTrue(LQueryResult.FieldByName(CTestSqlFieldName).Value >= CInitialDbVersionAsString,
    'Test database version should be at least:' + CInitialDbVersionAsString);

  Assert.IsTrue(not LDatabaseTransaction.Active,
    'After the select query finished running, it has to stop/close database transaction.');
end;

function TestTFirebirdDatabaseUpgraderQuery.GetTestNonSelectQuery: string;
begin
  Result := ' update ' + CTestSqlTableName
      + ' set ' + CTestSqlFieldName + ' = :' + CTestSqlParamName;
end;

procedure TestTFirebirdDatabaseUpgraderQuery.TestExecuteNonSelectQuery;
var
  LNonSelectQuery: ICommonDatabaseUpgraderQuery;
  LSelectQueryForCheckingResult: ICommonDatabaseUpgraderQuery;
  LQueryResult: TDataSet;
begin
  LNonSelectQuery := CreateQuery;
  LNonSelectQuery.Sql := GetTestNonSelectQuery;

  LSelectQueryForCheckingResult := CreateQuery;
  LSelectQueryForCheckingResult.Sql := CTestSelectQuery;

  // Test with transaction commit:
  FFirebirdDatabaseUpgraderRunner.StartTransaction;
  LNonSelectQuery.ExecuteNonSelectQuery([CDummyUpdateValue]);
  FFirebirdDatabaseUpgraderRunner.CommitTransaction;
  LQueryResult := LSelectQueryForCheckingResult.ExecuteSelectQuery([CDummyUpdateValue]);
  Assert.AreEqual(1, LQueryResult.RecordCount);
  Assert.AreEqual(CDummyUpdateValue, LQueryResult.FieldByName(CTestSqlFieldName).AsString);

  FFirebirdDatabaseUpgraderRunner.StartTransaction;
  LNonSelectQuery.ExecuteNonSelectQuery([CInitialDbVersionAsString]);
  FFirebirdDatabaseUpgraderRunner.CommitTransaction;
  LQueryResult := LSelectQueryForCheckingResult.ExecuteSelectQuery([CInitialDbVersionAsString]);
  Assert.AreEqual(1, LQueryResult.RecordCount);
  Assert.AreEqual(CInitialDbVersionAsString, LQueryResult.FieldByName(CTestSqlFieldName).AsString);

  // Test with transaction rollback:
  FFirebirdDatabaseUpgraderRunner.StartTransaction;
  LNonSelectQuery.ExecuteNonSelectQuery([CDummyUpdateValue]);
  FFirebirdDatabaseUpgraderRunner.RollbackTransaction;
  LQueryResult := LSelectQueryForCheckingResult.ExecuteSelectQuery([CInitialDbVersionAsString]);
  Assert.AreEqual(1, LQueryResult.RecordCount);
  Assert.AreEqual(CInitialDbVersionAsString, LQueryResult.FieldByName(CTestSqlFieldName).AsString);
end;

initialization
  // Register any test cases with the test runner
  TDUnitX.RegisterTestFixture(TestTFirebirdDatabaseUpgraderQuery);
end.

