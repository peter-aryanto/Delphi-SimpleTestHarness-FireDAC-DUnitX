program DatabaseUpgraderRunner;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  BackupOriginalFile in 'Lib\BackupOriginalFile.pas';

var
  GDbFileBackup: IBackupOriginalFile = nil;
  GIsSuccessful: Boolean = False;

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

    // Upgrade DB ...

    GIsSuccessful := True;

  except
    on E: Exception do
    begin
      GDbFileBackup.Rollback;

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
