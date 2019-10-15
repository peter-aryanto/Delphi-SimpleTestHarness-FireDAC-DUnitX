unit SampleDatabaseUpgraderProcess9999;

interface

uses
  DatabaseUpgraderProcess;

type
  TSampleDatabaseUpgraderProcess9999 = class(TDatabaseUpgraderProcess)
  end;

implementation

uses
  SampleDatabaseUpgraderProcessCollection;

initialization
  SampleUpgraderProcessCollection.RegisterProcess(TSampleDatabaseUpgraderProcess9999);
end.

