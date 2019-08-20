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
    GDbFileBackup.CreateCopy(ParamStr(1));

    // Upgrade DB ...

    GDbFileBackup.UpdateOriginalWithLatestCopy;
    GIsSuccessful := True;

  except
    on E: Exception do
    begin
      {Log.Error}Writeln(E.Message);

      if Assigned(E.InnerException) then
        {Log.Debug}Writeln(E.InnerException.Message);
    end;
  end;

{$IFDEF DEBUG}
  Write('Press any key ... ');
  Readln;
{$ENDIF}

  if not GIsSuccessful then
    Halt(1);
end.
