unit TestFirebirdDatabaseUpgraderQuery;

interface

uses
  TestFramework,
  FireDAC.Comp.Client,
  CommonDatabaseUpgraderRunner,
  CommonDatabaseUpgraderQuery, FirebirdDatabaseUpgraderQuery;

type
  TestTFirebirdDatabaseUpgraderQuery = class(TTestCase)
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
//    FFirebirdDatabaseUpgraderQuery: ICommonDatabaseUpgraderQuery;
    function CreateQuery: ICommonDatabaseUpgraderQuery; overload;
    function GetTestNonSelectQuery: string;
  public
    procedure SetUp; override;
//    procedure TearDown; override;
    class function CreateQuery(
      const ADatabaseConnection: TFDConnection
    ): ICommonDatabaseUpgraderQuery; overload;
  published
    procedure TestSqlProperty;
    procedure TestExecuteSelectQuery;
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
  TestSetupFirebirdDatabaseUpgraderRunner.SetTestDbLocation;
//  FFirebirdDatabaseUpgraderQuery := TFirebirdDatabaseUpgraderQuery.Create(
//    FFirebirdDatabaseUpgraderRunner.GetDatabaseConnection as TFDConnection);
end;

//procedure TestTFirebirdDatabaseUpgraderQuery.TearDown;
//begin
//  FFirebirdDatabaseUpgraderQuery := nil;
//end;

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
  CheckEquals('', LQuery.Sql);
  LQuery.Sql := CTestSelectQuery;
  CheckEquals(CTestSelectQuery, LQuery.Sql);
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

  CheckTrue(not LDatabaseTransaction.Active,
    'Initially, it is expected that database transaction is NOT active, '
        + 'the select query has to be able to start a database transaction by itself.');

  LQueryResult := LQuery.ExecuteSelectQuery([CInitialDbVersionAsString]);
  CheckEquals(1, LQueryResult.RecordCount);
  CheckTrue(LQueryResult.FieldByName(CTestSqlFieldName).Value >= CInitialDbVersionAsString,
    'Test database version should be at least:' + CInitialDbVersionAsString);

  CheckTrue(not LDatabaseTransaction.Active,
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
  CheckEquals(1, LQueryResult.RecordCount);
  CheckEquals(CDummyUpdateValue, LQueryResult.FieldByName(CTestSqlFieldName).Value);

  FFirebirdDatabaseUpgraderRunner.StartTransaction;
  LNonSelectQuery.ExecuteNonSelectQuery([CInitialDbVersionAsString]);
  FFirebirdDatabaseUpgraderRunner.CommitTransaction;
  LQueryResult := LSelectQueryForCheckingResult.ExecuteSelectQuery([CInitialDbVersionAsString]);
  CheckEquals(1, LQueryResult.RecordCount);
  CheckEquals(CInitialDbVersionAsString, LQueryResult.FieldByName(CTestSqlFieldName).Value);

  // Test with transaction rollback:
  FFirebirdDatabaseUpgraderRunner.StartTransaction;
  LNonSelectQuery.ExecuteNonSelectQuery([CDummyUpdateValue]);
  FFirebirdDatabaseUpgraderRunner.RollbackTransaction;
  LQueryResult := LSelectQueryForCheckingResult.ExecuteSelectQuery([CInitialDbVersionAsString]);
  CheckEquals(1, LQueryResult.RecordCount);
  CheckEquals(CInitialDbVersionAsString, LQueryResult.FieldByName(CTestSqlFieldName).Value);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFirebirdDatabaseUpgraderQuery.Suite);
end.

