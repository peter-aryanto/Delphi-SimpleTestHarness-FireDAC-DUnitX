unit CommonDatabaseUpgraderScript;

interface

type
  ICommonDatabaseUpgraderScript = interface
    ['{DC262EA6-ABCF-4E50-8EA3-FBBD8B3CEF35}']
    procedure ExecuteScript(const ASqlStatements: string);
  end;

implementation

end.
