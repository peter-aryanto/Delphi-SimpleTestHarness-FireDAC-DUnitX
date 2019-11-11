unit DatabaseUpgraderProcess;

interface

uses
  Data.DB,
  FireDAC.Comp.Client;

type
  TDatabaseUpgraderProcessClass = class of TDatabaseUpgraderProcess;
  TDatabaseUpgraderProcess = class abstract(TObject)
  protected type
    TDatabaseUpgraderProcessProcedure = procedure of object;
  private
    FDatabaseConnection: TFDConnection;
    FOnBeforeUpgraderScript: TDatabaseUpgraderProcessProcedure;
    FOnUpgraderScript: TDatabaseUpgraderProcessProcedure;
    FOnAfterUpgraderScript: TDatabaseUpgraderProcessProcedure;
  public
    constructor Create(const ADatabaseConnection: TCustomConnection); virtual;

    // The Compare method below is used for sorting TList<TDatabaseUpgraderProcessClass>.
    class function Compare(const ALeft, ARight: TDatabaseUpgraderProcessClass): Integer;

    property OnBeforeUpgraderScript: TDatabaseUpgraderProcessProcedure
      read FOnBeforeUpgraderScript;
    property OnUpgraderScript: TDatabaseUpgraderProcessProcedure
      read FOnUpgraderScript;
    property OnAfterUpgraderScript: TDatabaseUpgraderProcessProcedure
      read FOnAfterUpgraderScript;
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

end.

