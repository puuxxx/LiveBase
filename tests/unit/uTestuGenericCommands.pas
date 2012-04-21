unit uTestuGenericCommands;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, uGenericCommands, uExceptionCodes, uStrings, uExceptions, Forms,
  SysUtils, uEnvironment, uRootForm, uBaseCommand, uBase, uEventModel;

type
  // Test methods for class TLaunchCommand

  TestTLaunchCommand = class(TTestCase)
  strict private
    FLaunchCommand: TLaunchCommand;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExecute;
    procedure TestUnExecute;
  end;

implementation

procedure TestTLaunchCommand.SetUp;
begin
  FLaunchCommand := TLaunchCommand.Create;
end;

procedure TestTLaunchCommand.TearDown;
begin
  FLaunchCommand.Free;
  FLaunchCommand := nil;
end;

procedure TestTLaunchCommand.TestExecute;
begin
  Check( Env = nil, 'LaunchCommanExecute Envirement 1' );
  FLaunchCommand.Execute;

  Check( Env <> nil, 'LaunchCommanExecute Envirement 2' );
  Check( Env.EventModel <> nil, 'LaunchCommanExecute Env.EventModel' );
  Check( Env.RootForm <> nil, 'LaunchCommanExecute Env.RootForm' );
end;

procedure TestTLaunchCommand.TestUnExecute;
begin
  Check( Env <> nil, 'LaunchCommandUnexecute 1' );
  FLaunchCommand.UnExecute;
  Check( Env = nil, 'LaunchCommandUnexecute 2' );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTLaunchCommand.Suite);
end.
