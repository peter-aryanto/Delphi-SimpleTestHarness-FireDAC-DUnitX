unit BackupOriginalFile;

interface

type
  IBackupOriginalFile = interface
    ['{B25F67D8-799A-4013-B578-952B7C2A5587}']
    function CreateBackup(const AOriginalFile: string;
      const ABackupExtension: string = 'bak'
    ): string;
    procedure Rollback;
  end;

  TBackupOriginalFile = class(TInterfacedObject, IBackupOriginalFile)
  private
    FOriginalFile: string;
    FCopyFile: string;
  public
    function CreateBackup(const AOriginalFile: string;
      const ABackupExtension: string = 'bak'
    ): string;
    procedure Rollback;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

function TBackupOriginalFile.CreateBackup(const AOriginalFile: string;
  const ABackupExtension: string = 'bak'
): string;
var
  LCopyFile: string;
begin
  if not FileExists(AOriginalFile) then
    raise Exception.Create('Missing original file: ' + AOriginalFile);

  LCopyFile := ChangeFileExt(AOriginalFile, '.' + ABackupExtension);
  TFile.Copy(AOriginalFile, LCopyFile, True);

  if not FileExists(LCopyFile) then
    raise Exception('Failed to create backup copy from original file: ' + AOriginalFile);

  FOriginalFile := AOriginalFile;
  FCopyFile := LCopyFile;
  Result := LCopyFile;
end;

procedure TBackupOriginalFile.Rollback;
begin
  if not FileExists(FCopyFile) then
    raise Exception.Create('Missing backup/copy file: ' + FCopyFile);

  TFile.Copy(FCopyFile, FOriginalFile, True);
end;

end.
