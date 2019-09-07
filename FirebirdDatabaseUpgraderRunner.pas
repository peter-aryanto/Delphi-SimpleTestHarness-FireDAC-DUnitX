unit FirebirdDatabaseUpgraderRunner;

interface

uses
  CommonDatabaseUpgraderRunner,
  FireDAC.Comp.Client,
  FireDAC.Phys.FB;

type
  TFirebirdDatabaseUpgraderRunner = class(TCommonDatabaseUpgraderRunner,
    ICommonDatabaseUpgraderRunner)
  private
    FFirebirdEmbeddedDriverLink: TFDPhysFBDriverLink;
    FDatabaseConnection: TFDConnection;
  protected {Interface methods}
    {For property DatabaseLocation:}
      function GetDatabaseLocation: string; reintroduce;
      procedure SetDatabaseLocation(const ADatabaseLocation: string); override;
  public
    constructor Create(const AFbEmbedFile: string);
    destructor Destroy; override;
  public {Interface methods}
    function RunUpgrade: Boolean; override;
  end;

implementation

uses
  System.SysUtils,
  FireDAC.Stan.Consts,
  FireDAC.Stan.Def,
  FireDAC.Phys.FBDef;

constructor TFirebirdDatabaseUpgraderRunner.Create(const AFbEmbedFile: string);
begin
  if not FileExists(AFbEmbedFile) then
    raise Exception.Create('Cannot access Firebird Embedded driver file: ' + AFbEmbedFile);

  FFirebirdEmbeddedDriverLink := TFDPhysFBDriverLink.Create(nil);
  FFirebirdEmbeddedDriverLink.Embedded := True;
  FFirebirdEmbeddedDriverLink.VendorLib := AFbEmbedFile;

  FDatabaseConnection := TFDConnection.Create(nil);
  FDatabaseConnection.DriverName := S_FD_FBId;
  (FDatabaseConnection.Params as TFDPhysFBConnectionDefParams).SQLDialect := 1;
  FDatabaseConnection.Params.UserName := 'SYSDBA';
end;

destructor TFirebirdDatabaseUpgraderRunner.Destroy;
begin
  FDatabaseConnection.Free;
  FFirebirdEmbeddedDriverLink.Free;
  inherited;
end;

function TFirebirdDatabaseUpgraderRunner.RunUpgrade: Boolean;
begin
  Result := inherited RunUpgrade;
end;

function TFirebirdDatabaseUpgraderRunner.GetDatabaseLocation;
begin
  Result := FDatabaseConnection.Params.Database;
end;

procedure TFirebirdDatabaseUpgraderRunner.SetDatabaseLocation(const ADatabaseLocation: string);
begin
  inherited SetDatabaseLocation(ADatabaseLocation);
  FDatabaseConnection.Params.Database := inherited GetDatabaseLocation;
end;

end.

