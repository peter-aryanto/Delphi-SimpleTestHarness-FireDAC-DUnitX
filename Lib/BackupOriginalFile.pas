unit BackupOriginalFile;

interface

function CreateWorkFile(const AOriginalFile: string): string;

implementation

uses
  System.SysUtils,
  System.IOUtils;

function CreateWorkFile(const AOriginalFile: string): string;
var
  LCopyDbFile: string;
begin
  if not FileExists(AOriginalFile) then
    raise Exception.Create('Missing file: ' + AOriginalFile);

  LCopyDbFile := ChangeFileExt(AOriginalFile, '.$$$');
  TFile.Copy(AOriginalFile, LCopyDbFile, True);
  Result := LCopyDbFile;
end;

end.
