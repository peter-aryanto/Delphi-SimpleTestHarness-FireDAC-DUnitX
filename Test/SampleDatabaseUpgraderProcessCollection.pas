unit SampleDatabaseUpgraderProcessCollection;

interface

uses
  DatabaseUpgraderProcessCollection;

function SampleUpgraderProcessCollection: IDatabaseUpgraderProcessCollection;

implementation

uses // This section triggers the registration of individual upgrader process.
  SampleDatabaseUpgraderProcess1111,
  SampleDatabaseUpgraderProcess9999;

var
  MSampleUpgraderProcessCollection: IDatabaseUpgraderProcessCollection = nil;

function SampleUpgraderProcessCollection: IDatabaseUpgraderProcessCollection;
begin
  if not Assigned(MSampleUpgraderProcessCollection) then
    MSampleUpgraderProcessCollection :=
      TDatabaseUpgraderProcessCollection.Create('SampleDatabaseUpgraderProcess');

  Result := MSampleUpgraderProcessCollection;
end;

end.