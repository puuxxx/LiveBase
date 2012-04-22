unit uDrawingPage;

interface

  uses uBase, uGraphicPrimitive, Windows, Graphics, GdiPlus, SysUtils;

  type
    TDrawingPage = class( TBaseObject )
    private
      FRoot : TBackground;
      FBitMap : TBitMap;
      FGraphics : IGPGraphics;

    public
      constructor Create;
      destructor Destroy; override;

      procedure NewSize( const aWidth, aHeight : integer );

      function GetBitmap : TBitMap;

      property BackgroundPrimitive : TBackground read FRoot;
    end;
implementation

{ TDrawingPage }

constructor TDrawingPage.Create;
begin
  inherited Create;


  FBitMap := TBitMap.Create;
  FBitmap.PixelFormat := pf24bit;

  FGraphics := nil;
  NewSize( 0, 0 ); // создадим Graphics

  FRoot := TBackground.Create( nil );
end;

destructor TDrawingPage.Destroy;
begin
  FGraphics := nil;
  FreeAndNil( FBitMap );
  FreeAndNil( FRoot );

  inherited;
end;

function TDrawingPage.GetBitmap: TBitMap;

  procedure DrawNormal( const aGraphics : IGPGraphics; const aPrimitive : TGraphicPrimitive );
  var
    i : integer;
    Prim : TGraphicPrimitive;
  begin
    for I := 0 to aPrimitive.ChildCount - 1 do begin
      Prim := aPrimitive.Child[i];
      Prim.DrawNormal( aGraphics );
      if Prim.ChildCount > 0 then DrawNormal( aGraphics, Prim );
    end;
  end;

begin
  FRoot.FirstPoint := TPoint.Create( FBitMap.Width, FBitMap.Height );
  FRoot.DrawNormal( FGraphics );
  DrawNormal( FGraphics, FRoot );

  Result := FBitMap;
end;

procedure TDrawingPage.NewSize(const aWidth, aHeight: integer);
begin
  FBitMap.Width := aWidth;
  FBitMap.Height := aHeight;
  FGraphics := TGPGraphics.FromHDC( FBitMap.Canvas.Handle );
end;

end.
