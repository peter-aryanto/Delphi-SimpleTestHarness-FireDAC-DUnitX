program DatabaseUpgraderRunner;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  BackupOriginalFile in 'Lib\BackupOriginalFile.pas',
  CommonDatabaseUpgraderRunner in 'CommonDatabaseUpgraderRunner.pas',
  FirebirdDatabaseUpgraderRunner in 'FirebirdDatabaseUpgraderRunner.pas';

{ The main process needs to be contained using a method (this method) so that its anonymous method
  for OnMessage does not cause a memory leak.
}
function RunUpgrader(const ADbFile: string): Boolean;
var
  LDbFileBackup: IBackupOriginalFile;
  LTestDbFile: string;
  LRunner: ICommonDatabaseUpgraderRunner;
begin
  LDbFileBackup := TBackupOriginalFile.Create;
  try
    { Ideally, after backing up the original database file (by just 1 call to CreateBackup method
      without having to store the return), the original database file is upgraded.

      However, for this experiment, in order to keep the original database file, a "test" copy file
      will be created by the 2nd call to CreateBackup, and will then be upgraded (further down, by
      setting DatabaseLocation to LTestDbFile instead of ADbFile).
    }
    LTestDbFile := LDbFileBackup.CreateBackup(ADbFile, FormatDateTime('yyyymmddhhnnss', Now));
    LDbFileBackup.CreateBackup(LTestDbFile, 'test');

    LRunner := TCommonDatabaseUpgraderRunner.Create;
    LRunner.OnMessage := procedure (const AMessage: string)
      begin
        Writeln(AMessage);
      end;

    LRunner.DatabaseLocation := LTestDbFile;

    Result := LRunner.RunUpgrade;

    if Result then
      Writeln('Successfully completed upgrading database file: ' + LRunner.DatabaseLocation)
    else
    begin
      LDbFileBackup.Rollback;
      Writeln('Failed to upgrade database file: ' + LRunner.DatabaseLocation);
    end;

  except
    on E: Exception do
    begin
      LDbFileBackup.Rollback;

      if Assigned(LRunner) then
      begin
        if LRunner.ErrorMessage <> '' then
          {Log.Error}Writeln(LRunner.ErrorMessage);
        if LRunner.ErrorDetails <> '' then
          {Log.Debug}Writeln(LRunner.ErrorDetails);
      end
      else
        {Log.Error}Writeln(E.Message);
    end;
  end;
end;

var
  GIsSuccessful: Boolean = False;

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  try
    if ParamCount <> 1 then
      raise Exception.Create('Please run using the format: '
          + ExtractFileName(ParamStr(0)) + ' <a database file>');

    GIsSuccessful := RunUpgrader(ParamStr(1));

  except
    on E: Exception do
    begin
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
