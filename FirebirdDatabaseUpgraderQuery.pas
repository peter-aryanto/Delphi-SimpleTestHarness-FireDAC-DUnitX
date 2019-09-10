unit FirebirdDatabaseUpgraderQuery;

interface

uses
  CommonDatabaseUpgraderQuery,
  FireDAC.Comp.Client,
  Data.DB;

type
  TFirebirdDatabaseUpgraderQuery = class abstract(TInterfacedObject, ICommonDatabaseUpgraderQuery)
  private
    FQuery: TFDQuery;
    procedure SetParams(const AParams: array of Variant);
  protected {Interface methods}
    function GetSql: string;
    procedure SetSql(const ASql: string);
  public
    constructor Create(const ADatabaseConnection: TFDConnection);
    destructor Destroy; override;
  public {Interface methods}
    function ExecuteSelectQuery(const AParams: array of Variant): TDataSet;
    procedure ExecuteNonSelectQuery(const AParams: array of Variant);
  end;

implementation

uses
  FireDAC.Stan.Option,
  FireDAC.DApt,
  FireDAC.Stan.Async,
  FireDAC.Stan.Param,
  System.Classes,
  System.SysUtils;

{ TFirebirdDatabaseUpgraderQuery }

constructor TFirebirdDatabaseUpgraderQuery.Create(const ADatabaseConnection: TFDConnection);
begin
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := ADatabaseConnection;
  FQuery.FetchOptions.Unidirectional := False;
  FQuery.FetchOptions.Mode := fmAll;
end;

destructor TFirebirdDatabaseUpgraderQuery.Destroy;
begin
  FQuery.Free;
  inherited;
end;

function TFirebirdDatabaseUpgraderQuery.GetSql: string;
begin
  Result := FQuery.SQL.Text;
end;

procedure TFirebirdDatabaseUpgraderQuery.SetSql(const ASql: string);
begin
  FQuery.SQL.Text := ASql;
end;

procedure TFirebirdDatabaseUpgraderQuery.SetParams(const AParams: array of Variant);
var
  LQueryParamCount: Integer;
  LIndex: Integer;
begin
  LQueryParamCount := FQuery.Params.Count;
  if LQueryParamCount <> Length(AParams) then
    raise Exception.CreateFmt('Expecting %d parameter(s) but found %d.',
      [LQueryParamCount, Length(AParams)]);

  for LIndex := 0 to LQueryParamCount - 1 do
  begin
    FQuery.Params[LIndex].Value := AParams[LIndex];
  end;
end;

function TFirebirdDatabaseUpgraderQuery.ExecuteSelectQuery(
  const AParams: array of Variant
): TDataSet;
var
  LIsUsingPrivateTransaction: Boolean;
begin
  LIsUsingPrivateTransaction := False;
  if not FQuery.Connection.Transaction.Active then
  begin
    FQuery.Connection.StartTransaction;
    LIsUsingPrivateTransaction := True;
  end;

  try
    FQuery.Close;
    SetParams(AParams);
    FQuery.Open;
    Result := FQuery;
  finally
    if LIsUsingPrivateTransaction then
      FQuery.Connection.Rollback;
  end;
end;

procedure TFirebirdDatabaseUpgraderQuery.ExecuteNonSelectQuery(const AParams: array of Variant);
begin
  if not FQuery.Connection.Transaction.Active then
    raise Exception.Create('Please start database transaction first.');

  SetParams(AParams);
  FQuery.ExecSQL;
end;

end.

