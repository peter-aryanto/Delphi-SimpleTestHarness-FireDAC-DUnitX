unit CommonDatabaseUpgraderRunner;

interface

uses
  Data.DB;

type
  TDatabaseUpgraderRunnerOnMessage = reference to procedure(const AMessage: string);

  IInternalCommonDatabaseUpgraderRunner = interface
    ['{7EA27605-27C6-4D83-9B8B-010AC6B7FAE4}']
    procedure SetOnMessage(const AOnMessage: TDatabaseUpgraderRunnerOnMessage);
    {For property DatabaseLocation:}
      function GetDatabaseLocation: string;
      procedure SetDatabaseLocation(const ADatabaseLocation: string);
    function GetErrorMessage: string;
    function GetErrorDetails: string;
  end;

  ICommonDatabaseUpgraderRunner = interface(IInternalCommonDatabaseUpgraderRunner)
    ['{E158FA99-2A4D-4D7C-99BF-A19CAB0C67FA}']
    property OnMessage: TDatabaseUpgraderRunnerOnMessage write SetOnMessage;
    property DatabaseLocation: string read GetDatabaseLocation write SetDatabaseLocation;
    function GetDatabaseConnection: TCustomConnection;
    function GetDatabaseVersionAsInteger: Integer;
    function GetDatabaseVersionAsString(const AVersion: Integer): string;
    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    function RunUpgrade: Boolean;
    property ErrorMessage: string read GetErrorMessage;
    property ErrorDetails: string read GetErrorDetails;
  end;

  TCommonDatabaseUpgraderRunner = class abstract(TInterfacedObject, ICommonDatabaseUpgraderRunner)
  private
    FOnMessage: TDatabaseUpgraderRunnerOnMessage;
    FDatabaseLocation: string;
    FErrorMessage: string;
    FErrorDetails: string;
  private {Interface methods}
    procedure SetOnMessage(const AOnMessage: TDatabaseUpgraderRunnerOnMessage);
    function GetErrorMessage: string;
    function GetErrorDetails: string;
  private
    procedure ResetError;
  protected {Interface methods}
    {For property DatabaseLocation:}
      function GetDatabaseLocation: string; virtual;
      procedure SetDatabaseLocation(const ADatabaseLocation: string); virtual;
  public {Interface methods}
    function GetDatabaseConnection: TCustomConnection; virtual; abstract;
    function GetDatabaseVersionAsInteger: Integer; virtual; abstract;
    function GetDatabaseVersionAsString(const AVersion: Integer): string; virtual; abstract;
    procedure StartTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;
    procedure RollbackTransaction; virtual; abstract;
    function RunUpgrade: Boolean; virtual;
  end;

implementation

uses
  System.SysUtils;

function TCommonDatabaseUpgraderRunner.RunUpgrade: Boolean;
begin
  ResetError;
  Result := False;
end;

procedure TCommonDatabaseUpgraderRunner.SetOnMessage(
  const AOnMessage: TDatabaseUpgraderRunnerOnMessage);
begin
  FOnMessage := AOnMessage;
end;

function TCommonDatabaseUpgraderRunner.GetDatabaseLocation;
begin
  Result := FDatabaseLocation;
end;

procedure TCommonDatabaseUpgraderRunner.SetDatabaseLocation(const ADatabaseLocation: string);
var
  LDatabaseLocation: string;
begin
  LDatabaseLocation := Trim(ADatabaseLocation);
  if LDatabaseLocation = '' then
    raise Exception.Create('Database location cannot be blank.');

  FDatabaseLocation := ADatabaseLocation;
  ResetError;
end;

function TCommonDatabaseUpgraderRunner.GetErrorMessage: string;
begin
  Result := FErrorMessage;
end;

function TCommonDatabaseUpgraderRunner.GetErrorDetails: string;
begin
  Result := FErrorDetails;
end;

procedure TCommonDatabaseUpgraderRunner.ResetError;
begin
  FErrorMessage := '';
  FErrorDetails := '';
end;

end.
