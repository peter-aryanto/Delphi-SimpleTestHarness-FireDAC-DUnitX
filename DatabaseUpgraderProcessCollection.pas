unit DatabaseUpgraderProcessCollection;

interface

uses
  System.Generics.Collections,
  DatabaseUpgraderProcess;

type
  IDatabaseUpgraderProcessCollection = interface
    ['{84E2B957-1D07-435D-A5F5-6FDB55C02E78}']
    function GetProcess(const AIndex: Integer): TDatabaseUpgraderProcessClass;
    procedure RegisterProcess(const AProcess: TDatabaseUpgraderProcessClass);
    function GetTargetDatabaseVersion(const AProcess: TDatabaseUpgraderProcessClass): Integer;
    function GetIndexOfNextProcess(const ACurrentDatabaseVersion: Integer;
      const AIndexToStartSearch: Integer = 0
    ): Integer;
  end;

  TDatabaseUpgraderProcessCollection = class(TInterfacedObject, IDatabaseUpgraderProcessCollection)
  private const
    CDatabaseVersionDigitsAsString = '4';
  public const
    CIndexNotFound = -1;
  private
    FProcessNamePrefix: string;
    FSortedProcessList: TList<TDatabaseUpgraderProcessClass>;
  public
    constructor Create(const AProcessNamePrefix: string);
    destructor Destroy; override;
    function GetProcess(const AIndex: Integer): TDatabaseUpgraderProcessClass;
    procedure RegisterProcess(const AProcess: TDatabaseUpgraderProcessClass);
    function GetTargetDatabaseVersion(const AProcess: TDatabaseUpgraderProcessClass): Integer;
    function GetIndexOfNextProcess(const ACurrentDatabaseVersion: Integer;
      const AIndexToStartSearch: Integer = 0
    ): Integer;
  end;

implementation

uses
  System.RegularExpressions,
  System.Generics.Defaults,
  System.SysUtils,
  DatabaseUpgraderRunnerConstants;

{ TDatabaseUpgraderProcessCollection }

constructor TDatabaseUpgraderProcessCollection.Create(const AProcessNamePrefix: string);
begin
  FProcessNamePrefix := AProcessNamePrefix;
  FSortedProcessList := TList<TDatabaseUpgraderProcessClass>.Create(
    TComparer<TDatabaseUpgraderProcessClass>.Construct(TDatabaseUpgraderProcess.Compare));
end;

destructor TDatabaseUpgraderProcessCollection.Destroy;
begin
  FSortedProcessList.Free;
  inherited;
end;

function TDatabaseUpgraderProcessCollection.GetProcess(
  const AIndex: Integer
): TDatabaseUpgraderProcessClass;
begin
  if (AIndex >= 0) and (AIndex < FSortedProcessList.Count) then
    Result := FSortedProcessList[AIndex]
  else
    Result := nil;
end;

procedure TDatabaseUpgraderProcessCollection.RegisterProcess(
  const AProcess: TDatabaseUpgraderProcessClass);
const
  CProcessNameDatabaseVersionFormat = '([0-9]{' + CDatabaseVersionDigitsAsString + '})$';
var
  LRegEx: TRegEx;
  LProcessName: string;
  LRegExMatch: TMatch;
begin
  LRegEx := TRegEx.Create(FProcessNamePrefix + CProcessNameDatabaseVersionFormat, [roIgnoreCase]);
  LProcessName := AProcess.ClassName;
  LRegExMatch := LRegEx.Match(LProcessName);

  if not LRegExMatch.Success then
    raise Exception.Create('Please use process class name format: '
        + FProcessNamePrefix + CProcessNameDatabaseVersionFormat);

  if FSortedProcessList.Contains(AProcess) then
    raise Exception.Create('Found duplicate process class name: ' + LProcessName);

  FSortedProcessList.Add(AProcess);
  FSortedProcessList.Sort;
end;

function TDatabaseUpgraderProcessCollection.GetTargetDatabaseVersion(
  const AProcess: TDatabaseUpgraderProcessClass
): Integer;
var
  LProcessName: string;
  LDatabaseVersionDigits: Integer;
begin
  Result := CInvalidDatabaseVersion;

  LProcessName := '<nil>';

  if AProcess <> nil then
  begin
    LProcessName := AProcess.ClassName;
    LDatabaseVersionDigits := StrToInt(CDatabaseVersionDigitsAsString);
    Result := StrToIntDef(Copy(LProcessName,
      Length(LProcessName) - LDatabaseVersionDigits + 1, LDatabaseVersionDigits), CInvalidDatabaseVersion);
  end;
end;

function TDatabaseUpgraderProcessCollection.GetIndexOfNextProcess(
  const ACurrentDatabaseVersion: Integer;
  const AIndexToStartSearch: Integer = 0
): Integer;
var
  LIndex: Integer;
begin
  Result := CIndexNotFound;

  if AIndexToStartSearch = CIndexNotFound then
    Exit;

  if AIndexToStartSearch < CIndexNotFound then
    raise Exception.Create('Invalid Index to start searching for database upgrader process.');

  for LIndex := AIndexToStartSearch to FSortedProcessList.Count - 1 do begin
    if GetTargetDatabaseVersion(FSortedProcessList[LIndex]) > ACurrentDatabaseVersion then
    begin
      Result := LIndex;
      Exit;
    end;
  end;
end;

end.

