unit DatabaseUpgraderProcess;

interface

uses
  Data.DB,
  FireDAC.Comp.Client;

type
  TDatabaseUpgraderProcessClass = class of TDatabaseUpgraderProcess;
  TDatabaseUpgraderProcess = class abstract(TObject)
  private
    FDatabaseConnection: TFDConnection;
  public
    constructor Create(const ADatabaseConnection: TCustomConnection);

    // The Compare method below is used for sorting TList<TDatabaseUpgraderProcessClass>.
    class function Compare(const ALeft, ARight: TDatabaseUpgraderProcessClass): Integer;

    procedure RunBeforeUpgraderScript; virtual;
    procedure RunUpgraderScript; virtual;
    procedure RunAfterUpgraderScript; virtual;
  end;


implementation

uses
  System.SysUtils;

{ TDatabaseUpgraderProcess }

constructor TDatabaseUpgraderProcess.Create(const ADatabaseConnection: TCustomConnection);
begin
  if not (Assigned(ADatabaseConnection) and (ADatabaseConnection is TFDConnection)) then
    raise Exception.Create('Missing database connection for creating ' + Self.ClassName + '.');

  FDatabaseConnection := TFDConnection(ADatabaseConnection);
end;

class function TDatabaseUpgraderProcess.Compare(
  const ALeft, ARight: TDatabaseUpgraderProcessClass
): Integer;
begin
  Result := CompareText(ALeft.ClassName, ARight.ClassName);
end;

procedure TDatabaseUpgraderProcess.RunBeforeUpgraderScript;
begin
  // Do nothing. Sub-class will override as needed.
end;

procedure TDatabaseUpgraderProcess.RunAfterUpgraderScript;
begin
  // Do nothing. Sub-class will override as needed.
end;

procedure TDatabaseUpgraderProcess.RunUpgraderScript;
begin
  // Do nothing. Sub-class will override as needed.
end;

end.

