unit CommonDatabaseUpgraderQuery;

interface

uses
  Data.DB;

type
  IInternalCommonDatabaseUpgraderQuery = interface
    ['{0175248F-748B-46A3-8547-2EAB5D9CF618}']
    function GetSql: string;
    procedure SetSql(const ASql: string);
  end;

  ICommonDatabaseUpgraderQuery = interface(IInternalCommonDatabaseUpgraderQuery)
    ['{4ECA7C8D-FA2A-4FFF-B712-3C07D2F18B65}']
    property Sql: string read GetSql write SetSql;
    function ExecuteSelectQuery(const AParams: array of Variant): TDataSet;
    procedure ExecuteNonSelectQuery(const AParams: array of Variant);
  end;

(*
  // Early design that is no longer needed since all methods are abstract (no real implementation).
  TCommonDatabaseUpgraderQuery = class abstract(TInterfacedObject, ICommonDatabaseUpgraderQuery)
  protected {Interface methods}
    function GetSql: string; virtual; abstract;
    procedure SetSql(const ASql: string); virtual; abstract;
  public {Interface methods}
    function ExecuteSelectQuery(const AParams: array of Variant): TDataSet; virtual; abstract;
    procedure ExecuteNonSelectQuery(const AParams: array of Variant); virtual; abstract;
  end;
*)

implementation

end.
