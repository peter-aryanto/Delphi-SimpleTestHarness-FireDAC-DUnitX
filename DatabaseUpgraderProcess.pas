unit DatabaseUpgraderProcess;

interface

uses
  CommonDatabaseUpgraderRunner;

type
  TDatabaseUpgraderProcessClass = class of TDatabaseUpgraderProcess;
  TDatabaseUpgraderProcess = class abstract(TObject)
  private
    procedure ValidateRunner(const ARunner: ICommonDatabaseUpgraderRunner);
  public
    // The Compare method below is used for sorting TList<TDatabaseUpgraderProcessClass>.
    class function Compare(const ALeft, ARight: TDatabaseUpgraderProcessClass): Integer;

    procedure RunBeforeUpgraderScript(const ARunner: ICommonDatabaseUpgraderRunner); virtual;
    procedure RunAfterUpgraderScript(const ARunner: ICommonDatabaseUpgraderRunner); virtual;
  end;


implementation

uses
  System.SysUtils;

{ TDatabaseUpgraderProcess }

class function TDatabaseUpgraderProcess.Compare(
  const ALeft, ARight: TDatabaseUpgraderProcessClass
): Integer;
begin
  Result := CompareText(ALeft.ClassName, ARight.ClassName);
end;

procedure TDatabaseUpgraderProcess.ValidateRunner(const ARunner: ICommonDatabaseUpgraderRunner);
begin
  if not Assigned(ARunner) then
    raise Exception.Create('Missing database upgrader runner for ' + Self.ClassName + '.');
end;

procedure TDatabaseUpgraderProcess.RunAfterUpgraderScript(
  const ARunner: ICommonDatabaseUpgraderRunner);
begin
  ValidateRunner(ARunner);
end;

procedure TDatabaseUpgraderProcess.RunBeforeUpgraderScript(
  const ARunner: ICommonDatabaseUpgraderRunner);
begin
  ValidateRunner(ARunner);
end;

end.

