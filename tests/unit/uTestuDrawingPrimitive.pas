unit uTestuDrawingPrimitive;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, System.SysUtils, uExceptions, uDrawingSupport, uDrawingPrimitive,
  Graphics, GdiPlus, uBase, uEventModel;

type
  // Test methods for class TFigure

  TestTFigure = class(TTestCase)
  strict private
    FFigure: TFigure;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDraw;
    procedure TestDrawIndex;
    procedure TestAddChildFigure;
    procedure TestRemoveChildFigure;
    procedure TestClearChildrensFigure;
    procedure TestByPassChilds;
  end;

implementation

procedure TestTFigure.SetUp;
begin
  FFigure := TFigure.Create;
end;

procedure TestTFigure.TearDown;
begin
  FreeAndNil( FFigure );
  FFigure := nil;
end;

procedure TestTFigure.TestDraw;
var
  aPage: IDrawingPage;
begin
  // TODO: Setup method call parameters
  aPage := nil;
  FFigure.Draw(aPage);
  // TODO: Validate method results
end;

procedure TestTFigure.TestDrawIndex;
var
  aPage: IDrawingPage;
begin
  // TODO: Setup method call parameters
  aPage := nil;
  FFigure.DrawIndex(aPage);
  // TODO: Validate method results
end;

procedure TestTFigure.TestAddChildFigure;
var
  aFigure: TFigure;
begin
  aFigure := TFigure.Create;
  FFigure.AddChildFigure(aFigure);
  Check( FFigure.FirstChildFigure = aFigure );
end;

procedure TestTFigure.TestRemoveChildFigure;
var
  aFigure: TFigure;
begin
  // TODO: Setup method call parameters
  aFigure := TFigure.Create;
  FFigure.AddChildFigure( aFigure );
  FFigure.RemoveChildFigure(aFigure);
  // TODO: Validate method results
  Check( FFigure.FirstChildFigure <> aFigure );
end;

procedure TestTFigure.TestClearChildrensFigure;
begin
  FFigure.AddChildFigure( TFigure.Create );
  FFigure.AddChildFigure( TFigure.Create );
  FFigure.AddChildFigure( TFigure.Create );

  FFigure.ClearChildrensFigure;
  // TODO: Validate method results

  CheckNull( FFigure.FirstChildFigure );
end;

procedure TestTFigure.TestByPassChilds;
var
  aProc: TFigureProc;
  i : integer;
begin
  aProc := procedure ( aFigure : TFigure ) begin
    inc(i );
  end;
  i := 0;

  FFigure.AddChildFigure( TFigure.Create );
  FFigure.AddChildFigure( TFigure.Create );
  FFigure.AddChildFigure( TFigure.Create );

  FFigure.ByPassChilds(aProc);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTFigure.Suite);
end.
