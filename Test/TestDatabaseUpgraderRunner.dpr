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
  BackupOriginalFile;

const
  CTestDbFile = {.\bin\}'..\Resource\TestDatabase.fdb';

var
  GCurrentApplicationPath: string = '';
  GTestDbFile: IBackupOriginalFile;
  GTestResult: TTestResult = nil;
  GIsEveryTestPassed: Boolean = False;

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}

  GCurrentApplicationPath := ExtractFilePath(ParamStr(0));
  GTestDbFile := TBackupOriginalFile.Create;
  try
    GTestDbFile.CreateCopy(GCurrentApplicationPath + CTestDbFile);

    GTestResult := {DUnitTestRunner}TextTestRunner.RunRegisteredTests;

    GIsEveryTestPassed := GTestResult.ErrorCount + GTestResult.FailureCount = 0;
  finally
    GTestResult.Free;

  {$IFDEF DEBUG}
    Write('Press any key ... ');
    Readln;
  {$ENDIF}

    if not GIsEveryTestPassed then
      Halt(1);
  end;

end.
