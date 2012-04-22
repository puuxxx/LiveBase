unit uTestuDrawingPage;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Windows, uGraphicPrimitive, GdiPlus, SysUtils, Graphics, uBase,
  uDrawingPage;

type
  // Test methods for class TDrawingPage

  TestTDrawingPage = class(TTestCase)
  strict private
    FDrawingPage: TDrawingPage;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestNewSize;
    procedure TestGetBitmap;
  end;

implementation

procedure TestTDrawingPage.SetUp;
begin
  FDrawingPage := TDrawingPage.Create;
end;

procedure TestTDrawingPage.TearDown;
begin
  FDrawingPage.Free;
  FDrawingPage := nil;
end;

procedure TestTDrawingPage.TestNewSize;
var
  L, H : integer;
begin
  L := 0;
  H := 100000;

  FDrawingPage.NewSize(  H, L );
  FDrawingPage.NewSize(  L, H );
end;

procedure TestTDrawingPage.TestGetBitmap;
var
  ReturnValue: TBitmap;
begin
  FDrawingPage.NewSize( 0, 10000 );
  ReturnValue := FDrawingPage.GetBitmap;
  Check( ReturnValue <> nil );
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTDrawingPage.Suite);
end.
