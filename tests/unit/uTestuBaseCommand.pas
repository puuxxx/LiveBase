unit uTestuBaseCommand;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, uExceptions, uBase, SysUtils, uBaseCommand, uExceptionCodes;

type
  // Test methods for class TBaseCommand

  TestTBaseCommand = class(TTestCase)
  strict private
    FBaseCommand: TBaseCommand;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExecute;
    procedure TestExecute1;
    procedure TestUnExecute;
  end;

implementation

procedure TestTBaseCommand.SetUp;
begin
  FBaseCommand := TBaseCommand.Create;
end;

procedure TestTBaseCommand.TearDown;
begin
  FBaseCommand.Free;
  FBaseCommand := nil;
end;

procedure TestTBaseCommand.TestExecute;
begin
  SetUp;
  try
    FBaseCommand.Execute;
  finally
    TearDown;
  end;
  // TODO: Validate method results
end;

procedure TestTBaseCommand.TestExecute1;
var
  aData: Variant;
begin
  SetUp;
  aData := 111;
  try
    FBaseCommand.Execute(aData);
  finally
    TearDown;
  end;
end;

procedure TestTBaseCommand.TestUnExecute;
begin
  SetUp;
  try
    FBaseCommand.UnExecute;
  finally
    TearDown;
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTBaseCommand.Suite);
end.

