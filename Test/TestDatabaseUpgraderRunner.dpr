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
  {DUnitTestRunner}TextTestRunner,
  TestFramework,
  System.SysUtils,
  BackupOriginalFile,
  TestConstants,
  TestFirebirdDatabaseUpgraderRunner in 'TestFirebirdDatabaseUpgraderRunner.pas',
  TestFirebirdDatabaseUpgraderQuery in 'TestFirebirdDatabaseUpgraderQuery.pas',
  TestFirebirdDatabaseUpgraderScript in 'TestFirebirdDatabaseUpgraderScript.pas';

const
  CTestDbFile = {.\bin\}'..\Resource\TestDatabase.fdb';

var
  GCurrentApplicationPath: string = '';
  GTestDbFileBackup: IBackupOriginalFile = nil;
  GTestDbFile: string = '';
  GTestResult: TTestResult = nil;
  GIsEveryTestPassed: Boolean = False;

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  GCurrentApplicationPath := ExtractFilePath(ParamStr(0));
  GTestDbFileBackup := TBackupOriginalFile.Create;
  try
    GTestDbFile := GTestDbFileBackup.CreateBackup(GCurrentApplicationPath + COriginalTestDbFile,
      CTestDbFileExtension);

    GTestResult := {DUnitTestRunner}TextTestRunner.RunRegisteredTests;

    GIsEveryTestPassed := GTestResult.ErrorCount + GTestResult.FailureCount = 0;
  finally
    GTestResult.Free;

  {$IFDEF DEBUG}
    Write('Press ENTER ... ');
    Readln;
  {$ENDIF}

    if not GIsEveryTestPassed then
      ExitCode := 1;
  end;

end.

