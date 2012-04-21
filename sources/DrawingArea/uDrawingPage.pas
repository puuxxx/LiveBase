unit uDrawingPage;

interface

  uses uBase, uGraphicPrimitive, Graphics, GdiPlus, SysUtils;

  type
    TDrawingPage = class( TBaseObject )
    private
      FBitMap : TBitMap;
      FGraphics : IGPGraphics;
    public
      constructor Create;
      destructor Destroy; override;

      procedure NewSize( const aWidth, aHeight : integer );

      function GetBitmap : TBitMap;
    end;
implementation

{ TDrawingPage }

constructor TDrawingPage.Create;
begin
  inherited Create;

  
  FBitMap := TBitmap.Create;
  FBitmap.Width := 0;
  FBitmap.Height := 0;
  FBitmap.PixelFormat := pf24bit;

  FGraphics := TGPGraphics.Create( FBitmap.Canvas.Handle );
end;

destructor TDrawingPage.Destroy;
begin
  FGraphics := nil;
  FreeAndNil( FBitMap );


  inherited;
end;

function TDrawingPage.GetBitmap: TBitMap;
begin
  // ширина и высота страницы


  Result := FBitMap;
end;

procedure TDrawingPage.NewSize(const aWidth, aHeight: integer);
begin
  FBitMap.Width := aWidth;
  FBitMap.Height := aHeight;
end;

end.
