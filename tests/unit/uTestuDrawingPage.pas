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
  private
    procedure CreateManyPrimitives( var aLastPrim : TGraphicPrimitive );
  published
    procedure TestNewSize;
    procedure TestGetBitmap;
    procedure TestBackgroundPrimitive;
    procedure TestGetPrimitiveByCoord;
    procedure TestGetPrimitiveByID;
    procedure TestSelect;
  end;

implementation

procedure TestTDrawingPage.CreateManyPrimitives(
  var aLastPrim: TGraphicPrimitive);
var
  i : integer;
begin
  for I := 0 to 100 do begin
    aLastPrim := TGraphicPrimitive.Create( FDrawingPage.RootPrimitive );
  end;
end;

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

procedure TestTDrawingPage.TestSelect;
begin
  Check( FDrawingPage.SelectPrimitive <> nil );
  Check( FDrawingPage.SelectPrimitive is TSelect );
end;

procedure TestTDrawingPage.TestBackgroundPrimitive;
begin
  Check( FDrawingPage.RootPrimitive <> nil );
end;

procedure TestTDrawingPage.TestGetBitmap;
var
  ReturnValue: TBitmap;
begin
  FDrawingPage.NewSize( 0, 10000 );
  ReturnValue := FDrawingPage.GetBitmap;
  Check( ReturnValue <> nil );
end;

procedure TestTDrawingPage.TestGetPrimitiveByCoord;
var
  i : integer;
begin
  FDrawingPage.NewSize( 100, 100 );
  FDrawingPage.GetBitmap;

  for I := 4 to 50 do begin
    Check( FDrawingPage.RootPrimitive = FDrawingPage.GetPrimitiveByCoord( 10, i ) );
  end;
end;

procedure TestTDrawingPage.TestGetPrimitiveByID;
var
  Prim, LastPrim : TGraphicPrimitive;
  id : string;
begin
  LastPrim := nil;
  CreateManyPrimitives( LastPrim );
  Prim := TGraphicPrimitive.Create( LastPrim );
  CreateManyPrimitives( LastPrim );
  id := Prim.IDAsStr;
  Check( Prim = FDrawingPage.GetPrimitiveByID( id ) );

  Prim := TGraphicPrimitive.Create( FDrawingPage.RootPrimitive );
  id := Prim.IDAsStr;
  Check( Prim = FDrawingPage.GetPrimitiveByID( id ) );

end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTDrawingPage.Suite);
end.

