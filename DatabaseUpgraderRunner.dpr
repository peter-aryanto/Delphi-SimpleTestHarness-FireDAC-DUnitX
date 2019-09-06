program DatabaseUpgraderRunner;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  BackupOriginalFile in 'Lib\BackupOriginalFile.pas',
  CommonDatabaseUpgraderRunner in 'CommonDatabaseUpgraderRunner.pas';

var
  GDbFileBackup: IBackupOriginalFile = nil;
  GIsSuccessful: Boolean = False;
  Runner: ICommonDatabaseUpgraderRunner = nil;

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  try
    if ParamCount <> 1 then
      raise Exception.Create('Please run using the format: '
          + ExtractFileName(ParamStr(0)) + ' <a database file>');

    GDbFileBackup := TBackupOriginalFile.Create;
    GDbFileBackup.CreateBackup(ParamStr(1), FormatDateTime('yyyymmddhhnnss', Now));

    Runner := TCommonDatabaseUpgraderRunner.Create;
    Runner.OnMessage := procedure (const AMessage: string)
      begin
        Writeln(AMessage);
      end;
    // Upgrade DB ...

    GIsSuccessful := True;

  except
    on E: Exception do
    begin
      if Assigned(GDbFileBackup) then
        GDbFileBackup.Rollback;

      if Assigned(Runner) then
      begin
        if Runner.ErrorMessage <> '' then
          {Log.Error}Writeln(Runner.ErrorMessage);
        if Runner.ErrorDetails <> '' then
          {Log.Debug}Writeln(Runner.ErrorDetails);
      end
      else
        {Log.Error}Writeln(E.Message);
    end;
  end;

{$IFDEF DEBUG}
  Write('Press ENTER ... ');
  Readln;
{$ENDIF}

  if not GIsSuccessful then
    ExitCode := 1;
end.
