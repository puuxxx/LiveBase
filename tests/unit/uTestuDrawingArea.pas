unit uTestuDrawingArea;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, uDrawingArea, uBase, SysUtils, uEventModel, Graphics;

type
  // Test methods for class TDrawingArea

  TestTDrawingArea = class(TTestCase)
  strict private
    FDrawingArea: TDrawingArea;
    FEventModel : TEventModel;
  public
    procedure SetUp; override;
    procedure TearDown; override;

    procedure TestOne;
  end;

implementation

procedure TestTDrawingArea.SetUp;
begin
  FEventModel := TEventModel.Create;
end;

procedure TestTDrawingArea.TearDown;
begin
  FDrawingArea.Free;
  FDrawingArea := nil;
  FreeAndNil( FEventModel );
end;

procedure TestTDrawingArea.TestOne;
var
  i : integer;
begin

  FDrawingArea.OnNewSize( Low(Integer), 1 );
  FDrawingArea.AreaBitmap;
  FDrawingArea.OnNewSize( 1, Low(Integer) );
  FDrawingArea.AreaBitmap;

  FDrawingArea.OnNewSize( High(Integer), 1 );
  FDrawingArea.AreaBitmap;
  FDrawingArea.OnNewSize( 1, High(Integer) );
  FDrawingArea.AreaBitmap;

  for I := -100 to 100 do begin
    FDrawingArea.OnNewSize( i, abs( i ) );
    FDrawingArea.AreaBitmap;
  end;

end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTDrawingArea.Suite);
end.

