unit FirebirdDatabaseUpgraderScript;

interface

uses
  CommonDatabaseUpgraderScript,
  FireDAC.Comp.Client,
  FireDAC.Comp.Script,
  System.SysUtils;

type
  TFirebirdDatabaseUpgraderScript = class abstract(TInterfacedObject, ICommonDatabaseUpgraderScript)
  private
    FScript: TFDScript;
    procedure HandleScriptError(ASender, AInitiator: TObject;
      var AException: Exception);
  public
    constructor Create(const ADatabaseConnection: TFDConnection);
    destructor Destroy; override;
  public {Interface methods}
    procedure ExecuteScript(const ASqlStatements: string);
  end;

implementation

uses
  System.RegularExpressions,
  FireDAC.Phys.IBWrapper,
  FireDAC.Comp.ScriptCommands;

{ TFirebirdDatabaseUpgraderScript }

constructor TFirebirdDatabaseUpgraderScript.Create(const ADatabaseConnection: TFDConnection);
begin
  FScript := TFDScript.Create(nil);
  FScript.Connection := ADatabaseConnection;
  FScript.ScriptOptions.CommitEachNCommands := 1;
  FScript.ScriptOptions.BreakOnError := True;
  FScript.OnError := HandleScriptError;
end;

destructor TFirebirdDatabaseUpgraderScript.Destroy;
begin
  FScript.Free;
  inherited;
end;

procedure TFirebirdDatabaseUpgraderScript.ExecuteScript(const ASqlStatements: string);
var
  LOriginalDatabaseConnectionTransaction: TFDTransaction;
begin
  if Trim(ASqlStatements) = '' then
    raise Exception.Create('Found EMPTY database upgrader script.');

  if FScript.Connection.Transaction.Active then
    raise Exception.Create('Found active database transaction, '
        + 'please close it to be used for the database upgrader scripts.');

//  Log.Debug('Running upgrader script.');

  FScript.SQLScripts.Clear;
  FScript.SQLScripts.Add;
  FScript.SQLScripts[0].SQL.Text := ASqlStatements;

  // TFDScript needs .Connection property to be a TFDConnection that does not own any transaction.
  LOriginalDatabaseConnectionTransaction := FScript.Connection.Transaction as TFDTransaction;
  FScript.Connection.Transaction := nil;
  try
    try
      FScript.ExecuteAll;
//      FScript.Connection.Commit; // Not needed because <Script>.CommitEachNCommands is set to 1.
    finally
      FScript.Connection.Transaction := LOriginalDatabaseConnectionTransaction;
    end;

  except
    on E: Exception do
    begin
//      Log.Error('ERROR when running upgrader script.');
//      Log.Debug(E.Message);
      raise Exception.Create('Database upgrader scripts execution failed.');
    end;
  end;
end;

procedure TFirebirdDatabaseUpgraderScript.HandleScriptError(ASender, AInitiator: TObject;
  var AException: Exception);
var
  LRegEx: TRegEx;
  LMatch: TMatch;
  LOptionalLineNumber: string;
begin
  if Assigned(FScript.CurrentCommand) then
  begin

    if AException is EIBNativeException then
    begin
      LRegEx.Create('line (\d*),');
      LMatch := LRegEx.Match(AException.Message);

      if LMatch.Success then
        LOptionalLineNumber := LMatch.Groups[1].Value;

      if LOptionalLineNumber <> '' then
        LOptionalLineNumber := #13#10 + 'Script line #' + LOptionalLineNumber + #13#10;
    end;

    AException.Message := AException.Message
        + LOptionalLineNumber
        + FScript.CurrentCommand.Dump;
  end;
end;

end.

