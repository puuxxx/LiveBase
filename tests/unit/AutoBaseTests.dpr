program AutoBaseTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  uTestBaseObj in 'uTestBaseObj.pas',
  uTestEventModel in 'uTestEventModel.pas',
  uEventModel in '..\..\sources\uEventModel.pas',
  uTestuBaseCommand in 'uTestuBaseCommand.pas',
  uBaseCommand in '..\..\sources\Commands\uBaseCommand.pas',
  uTestuGenericCommands in 'uTestuGenericCommands.pas',
  uGenericCommands in '..\..\sources\Commands\uGenericCommands.pas',
  uEnvironment in '..\..\sources\uEnvironment.pas',
  uTestuDrawingArea in 'uTestuDrawingArea.pas',
  uDrawingArea in '..\..\sources\uDrawingArea.pas',
  uTestuGraphicPrimitive in 'uTestuGraphicPrimitive.pas',
  uGraphicPrimitive in '..\..\sources\DrawingArea\uGraphicPrimitive.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.
