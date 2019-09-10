unit FirebirdDatabaseUpgraderRunner;

interface

uses
  CommonDatabaseUpgraderRunner,
  FireDAC.Comp.Client,
  FireDAC.Phys.FB,
  CommonDatabaseUpgraderQuery,
  Data.DB;

type
  TFirebirdDatabaseUpgraderRunner = class(TCommonDatabaseUpgraderRunner)
  private
    FFirebirdEmbeddedDriverLink: TFDPhysFBDriverLink;
    FDatabaseConnection: TFDConnection;
    function CreateQuery(const ASql: string): ICommonDatabaseUpgraderQuery;
    procedure VerifyTransactionIsActive;
  protected {Interface methods}
    {For property DatabaseLocation:}
      function GetDatabaseLocation: string; reintroduce;
      procedure SetDatabaseLocation(const ADatabaseLocation: string); override;
  public
    constructor Create(const AFbEmbedFile: string);
    destructor Destroy; override;
  public {Interface methods}
    function GetDatabaseConnection: TCustomConnection; override;
    function GetDatabaseVersionAsInteger: Integer; override;
    function GetDatabaseVersionAsString(const AVersion: Integer): string; override;
    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;
    function RunUpgrade: Boolean; override;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Stan.Consts,
  FireDAC.Stan.Def,
  FireDAC.Phys.FBDef,
  FirebirdDatabaseUpgraderQuery,
  DatabaseUpgraderRunnerConstants,
  System.Math,
  FireDAC.Stan.Option;

constructor TFirebirdDatabaseUpgraderRunner.Create(const AFbEmbedFile: string);
begin
  if not FileExists(AFbEmbedFile) then
    raise Exception.Create('Cannot access Firebird Embedded driver file: ' + AFbEmbedFile);

  FFirebirdEmbeddedDriverLink := TFDPhysFBDriverLink.Create(nil);
  FFirebirdEmbeddedDriverLink.Embedded := True;
  FFirebirdEmbeddedDriverLink.VendorLib := AFbEmbedFile;

  FDatabaseConnection := TFDConnection.Create(nil);
  FDatabaseConnection.DriverName := S_FD_FBId;
  (FDatabaseConnection.Params as TFDPhysFBConnectionDefParams).SQLDialect := 1;
  FDatabaseConnection.Params.UserName := 'SYSDBA';

  FDatabaseConnection.Transaction := TFDTransaction.Create(FDatabaseConnection);
  FDatabaseConnection.Transaction.Options.AutoStart := False;
  FDatabaseConnection.Transaction.Options.AutoStop := False;
  FDatabaseConnection.Transaction.Options.AutoCommit := False;
  FDatabaseConnection.Transaction.Options.DisconnectAction := xdRollback;
end;

destructor TFirebirdDatabaseUpgraderRunner.Destroy;
begin
  FDatabaseConnection.Free;
  FFirebirdEmbeddedDriverLink.Free;
  inherited;
end;

function TFirebirdDatabaseUpgraderRunner.CreateQuery(
  const ASql: string
): ICommonDatabaseUpgraderQuery;
var
  LQuery: ICommonDatabaseUpgraderQuery;
begin
  Result := nil;

  if GetDatabaseLocation = '' then
    raise Exception.Create('Please specify database location.');

  if not FDatabaseConnection.Connected then
    FDatabaseConnection.Open;

  LQuery := TFirebirdDatabaseUpgraderQuery.Create(FDatabaseConnection);
  LQuery.Sql := ASql;

  Result := LQuery;
{
  // Future plan for running SQL upgrader scripts.
  FScript := TFDScript.Create(nil);
  FScript.Connection := FDbConnection;
  FScript.ScriptOptions.CommitEachNCommands := 1;
  FScript.ScriptOptions.BreakOnError := True;
  FScript.OnError := ScriptError;
  // Usage with the actual script as below.
  FScript.SQLScripts.Clear;
  FScript.SQLScripts.Add;
  FScript.SQLScripts[0].SQL.Text := AScriptCollection;
}
end;

function TFirebirdDatabaseUpgraderRunner.GetDatabaseConnection: TCustomConnection;
begin
  Result := FDatabaseConnection;
end;

function TFirebirdDatabaseUpgraderRunner.GetDatabaseVersionAsInteger: Integer;
const
  CVersionNumberField = 'version_number';
  CSql = ' select ' + CVersionNumberField + ' from version ';
var
  LVersionAsString: string;
  LVersionAsInteger: Integer;
begin
  LVersionAsString := CreateQuery(CSql)
    .ExecuteSelectQuery([])
    .FieldByName(CVersionNumberField).AsString;

  LVersionAsInteger := StrToIntDef(StringReplace(LVersionAsString, '.', '', []),
    CInvalidDatabaseVersion);

  if LVersionAsInteger = CInvalidDatabaseVersion then
    raise Exception.Create('Invalid Database Version: ' + LVersionAsString);

  Result := LVersionAsInteger;
end;

function TFirebirdDatabaseUpgraderRunner.GetDatabaseVersionAsString(
  const AVersion: Integer
): string;
const
  CMinorVersionDigits = 2;
var
  LDivider: Integer;
begin
  if (AVersion < 0) then
    raise Exception.Create('Invalid database version number: ' + IntToStr(AVersion));

  LDivider := Trunc(Power(10, CMinorVersionDigits));
  Result := FormatFloat('00.00', AVersion/LDivider);
end;

procedure TFirebirdDatabaseUpgraderRunner.StartTransaction;
begin
  if FDatabaseConnection.Transaction.Active then
    Exit;

  FDatabaseConnection.Transaction.StartTransaction;

  if not FDatabaseConnection.Transaction.Active then
    raise Exception.Create('Failed to start database transaction.');
end;

procedure TFirebirdDatabaseUpgraderRunner.VerifyTransactionIsActive;
begin
  if not FDatabaseConnection.Transaction.Active then
    raise Exception.Create('Please start database transaction first.');
end;

procedure TFirebirdDatabaseUpgraderRunner.CommitTransaction;
begin
  VerifyTransactionIsActive;
  FDatabaseConnection.Transaction.Commit;
end;

procedure TFirebirdDatabaseUpgraderRunner.RollbackTransaction;
begin
  VerifyTransactionIsActive;
  FDatabaseConnection.Transaction.Rollback;
end;

function TFirebirdDatabaseUpgraderRunner.RunUpgrade: Boolean;
begin
  Result := inherited RunUpgrade;
end;

function TFirebirdDatabaseUpgraderRunner.GetDatabaseLocation;
begin
  Result := FDatabaseConnection.Params.Database;
end;

procedure TFirebirdDatabaseUpgraderRunner.SetDatabaseLocation(const ADatabaseLocation: string);
begin
  inherited SetDatabaseLocation(ADatabaseLocation);
  FDatabaseConnection.Params.Database := inherited GetDatabaseLocation;
end;

end.

