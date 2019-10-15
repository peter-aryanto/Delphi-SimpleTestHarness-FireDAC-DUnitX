unit CommonDatabaseUpgraderRunner;

interface

uses
  Data.DB,
  DatabaseUpgraderProcessCollection;

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
    procedure UpdateDatabaseVersion(const ANewDatabaseVersionAsString: string);
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
    function RunUpgrade(
      const AProcessCollection: IDatabaseUpgraderProcessCollection
    ): Boolean;
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

    procedure UpdateDatabaseVersion(const ANewDatabaseVersionAsString: string); virtual; abstract;
  public {Interface methods}
    function GetDatabaseConnection: TCustomConnection; virtual; abstract;
    function GetDatabaseVersionAsInteger: Integer; virtual; abstract;
    function GetDatabaseVersionAsString(const AVersion: Integer): string; virtual; abstract;
    procedure StartTransaction; virtual; abstract;
    procedure CommitTransaction; virtual; abstract;
    procedure RollbackTransaction; virtual; abstract;
    function RunUpgrade(
      const AProcessCollection: IDatabaseUpgraderProcessCollection
    ): Boolean; virtual; final;
  end;

implementation

uses
  System.SysUtils,
  DatabaseUpgraderProcess;

function TCommonDatabaseUpgraderRunner.RunUpgrade(
  const AProcessCollection: IDatabaseUpgraderProcessCollection
): Boolean;
var
  LCurrentDatabaseVersion: Integer;
  LMaxProcessIndex: Integer;
  LIndex: Integer;
  LProcessClass: TDatabaseUpgraderProcessClass;
  LTargetDatabaseVersion: Integer;
  LTargetDatabaseVersionAsString: string;
  LProcessObject: TDatabaseUpgraderProcess;
begin
  if not Assigned(AProcessCollection) then
    raise Exception.Create('Database upgrader process collection is required but missing.');

  ResetError;

  LCurrentDatabaseVersion := GetDatabaseVersionAsInteger;
  LMaxProcessIndex := AProcessCollection.GetProcessCount - 1;
  for LIndex := 0 to LMaxProcessIndex do
  begin
    LProcessClass := AProcessCollection.GetProcess(LIndex);
    LTargetDatabaseVersion := AProcessCollection.GetTargetDatabaseVersion(LProcessClass);

    if LCurrentDatabaseVersion >= LTargetDatabaseVersion then
      Continue;

    LTargetDatabaseVersionAsString := GetDatabaseVersionAsString(LTargetDatabaseVersion);
    LProcessObject := LProcessClass.Create(GetDatabaseConnection);
    try
      //Plan for: Log.Info('Running upgrader process before script for version ' + LTargetDatabaseVersionAsString);
      LProcessObject.RunBeforeUpgraderScript;

      //Plan for: Log.Info('Running upgrader script for version ' + LTargetDatabaseVersionAsString);
      LProcessObject.RunUpgraderScript;

      //Plan for: Log.Info('Running upgrader process after script for version ' + LTargetDatabaseVersionAsString);
      LProcessObject.RunAfterUpgraderScript;

      //Plan for: Log.Info('Updating database version to ' + LTargetDatabaseVersionAsString);
      UpdateDatabaseVersion(LTargetDatabaseVersionAsString);
      //Plan for: Log.Info('Successfully upgraded database to version ' + LTargetDatabaseVersionAsString);

      LCurrentDatabaseVersion := GetDatabaseVersionAsInteger;
      if LCurrentDatabaseVersion <> LTargetDatabaseVersion then
        raise Exception.CreateFmt('Upgrade process from version %s to %s has been completed, '
            + 'but the database version cannot be updated.',
          [ GetDatabaseVersionAsString(LCurrentDatabaseVersion),
            LTargetDatabaseVersionAsString,
            GetDatabaseLocation ]);

    finally
      LProcessObject.Free;
    end;

  end;

  Result := FErrorMessage + FErrorDetails = '';
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
