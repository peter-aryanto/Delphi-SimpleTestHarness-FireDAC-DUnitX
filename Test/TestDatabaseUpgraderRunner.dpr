program TestDatabaseUpgraderRunner;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

//{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
//{$ENDIF}

{$R *.RES}

uses
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  System.SysUtils,
  BackupOriginalFile,
  TestConstants,
  TestFirebirdDatabaseUpgraderRunner in 'TestFirebirdDatabaseUpgraderRunner.pas',
  TestFirebirdDatabaseUpgraderQuery in 'TestFirebirdDatabaseUpgraderQuery.pas',
  TestFirebirdDatabaseUpgraderScript in 'TestFirebirdDatabaseUpgraderScript.pas',
  TestDatabaseUpgraderProcessCollection in 'TestDatabaseUpgraderProcessCollection.pas';

const
  CTestDbFile = {.\bin\}'..\Resource\TestDatabase.fdb';

var
  GCurrentApplicationPath: string = '';
  GTestDbFileBackup: IBackupOriginalFile = nil;
  GTestDbFile: string = '';
  GTestRunner: ITestRunner = nil;
  GTestResult: IRunResults = nil;

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  GCurrentApplicationPath := ExtractFilePath(ParamStr(0));
  GTestDbFileBackup := TBackupOriginalFile.Create;
  try
    GTestDbFile := GTestDbFileBackup.CreateBackup(GCurrentApplicationPath + COriginalTestDbFile,
      CTestDbFileExtension);

    GTestRunner := TDUnitX.CreateRunner;
    GTestRunner.AddLogger(TDUnitXConsoleLogger.Create(True {quietMode}));
    GTestResult := GTestRunner.Execute;

  finally

  {$IFDEF DEBUG}
    Write('Press ENTER ... ');
    Readln;
  {$ENDIF}

    if not GTestResult.AllPassed then
      ExitCode := EXIT_ERRORS;
  end;

end.

