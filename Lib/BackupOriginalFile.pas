unit BackupOriginalFile;

interface

type
  IBackupOriginalFile = interface
    ['{B25F67D8-799A-4013-B578-952B7C2A5587}']
    function CreateCopy(const AOriginalFile: string;
      const ABackupExtension: string = '$$$'
    ): string;
    procedure UpdateOriginalWithLatestCopy;
  end;

  TBackupOriginalFile = class(TInterfacedObject, IBackupOriginalFile)
  private
    FOriginalFile: string;
    FCopyFile: string;
  public
    function CreateCopy(const AOriginalFile: string;
      const ABackupExtension: string = '$$$'
    ): string;
    procedure UpdateOriginalWithLatestCopy;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

function TBackupOriginalFile.CreateCopy(const AOriginalFile: string;
  const ABackupExtension: string = '$$$'
): string;
var
  LCopyFile: string;
begin
  if not FileExists(AOriginalFile) then
    raise Exception.Create('Missing original file: ' + AOriginalFile);

  FOriginalFile := AOriginalFile;

  LCopyFile := ChangeFileExt(FOriginalFile, '.' + ABackupExtension);
  TFile.Copy(FOriginalFile, LCopyFile, True);
  FCopyFile := LCopyFile;

  Result := LCopyFile;
end;

procedure TBackupOriginalFile.UpdateOriginalWithLatestCopy;
begin
  if not FileExists(FCopyFile) then
    raise Exception.Create('Missing backup/copy file: ' + FCopyFile);

  TFile.Copy(FCopyFile, FOriginalFile, True);
end;

end.
