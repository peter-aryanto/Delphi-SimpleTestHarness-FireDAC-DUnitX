unit SampleDatabaseUpgraderProcess1111;

interface

uses
  DatabaseUpgraderProcess;

type
  TSampleDatabaseUpgraderProcess1111 = class(TDatabaseUpgraderProcess)
  end;

implementation

uses
  SampleDatabaseUpgraderProcessCollection;

initialization
  SampleUpgraderProcessCollection.RegisterProcess(TSampleDatabaseUpgraderProcess1111);
end.

