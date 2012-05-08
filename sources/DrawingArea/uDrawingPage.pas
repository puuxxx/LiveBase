unit uDrawingPage;

interface

  uses uBase, System.SysUtils, Graphics, GDIPlus, uDrawingSupport;
  type

    // Конвертер логических координат в экранные
    ICoordConverter = interface
      function LogToScreen( aValue : Extended ) : integer; overload;
      function ScreenToLog( aValue : integer ) : Extended; overload;

      procedure LogToScreen( aLogVal1, aLogVal2 : Extended; var aScrVal1, aScrVal2 : integer ); overload;
      procedure ScreenToLog( aScrVal1, aScrVal2 : integer; var aLogVal1, aLogVal2 : Extended ); overload;
    end;

    TCoordConverter = class ( TInterfacedObject, ICoordConverter )
    public
      function LogToScreen( aValue : Extended ) : integer; overload;
      function ScreenToLog( aValue : integer ) : Extended; overload;
      procedure LogToScreen( aLogVal1, aLogVal2 : Extended; var aScrVal1, aScrVal2 : integer ); overload;
      procedure ScreenToLog( aScrVal1, aScrVal2 : integer; var aLogVal1, aLogVal2 : Extended ); overload;
    end;


    // Виртуальный холст
    TDrawingPage = class
    strict private
      FBitMap : TBitMap;
      FCoordConverter : ICoordConverter;
      FGraphics : IGPGraphics;
      FPen : IGPPen;
      FBrush : IGPSolidBrush;
    public
      constructor Create( const aCoordConverter : ICoordConverter );
      destructor Destroy; override;

      // закрашиваем всю страницу заданным цветом
      procedure Clear( const aColor : TColor );

      // рисуем квадрат
      procedure DrawFillRect( const aP1, aP2 : TDrawingPoint;
        const aBackgroundColor, aBorderColor : TColor; const aBorderWidth : Extended );
      // рисуем рамку
      procedure DrawRect( const aP1, aP2 : TDrawingPoint; const aBorderColor : TColor;
        const aBorderWidth : Extended );

      procedure SetScreenSize( const aWidth, aHeight : integer );
      function GetBitMap : TBitMap;
    end;

implementation

{ TCoordConverter }

procedure TCoordConverter.LogToScreen(aLogVal1, aLogVal2: Extended;
  var aScrVal1, aScrVal2: integer);
begin
  aScrVal1 :=  Round( aLogVal1 );
  aScRVal2 := Round( aLogVal2 );
end;

function TCoordConverter.LogToScreen(aValue: Extended): integer;
begin
  Result := Round( aValue );
end;

procedure TCoordConverter.ScreenToLog(aScrVal1, aScrVal2: integer; var aLogVal1,
  aLogVal2: Extended);
begin
  aLogVal1 := aScrVal1;
  aLogVal2 := aScrVal2;
end;

function TCoordConverter.ScreenToLog(aValue: integer): Extended;
begin
  Result := aValue;
end;

{ TDrawingPage }

constructor TDrawingPage.Create ( const aCoordConverter : ICoordConverter );
begin
  inherited Create;
  FBitMap := TBitmap.Create;
  FBitMap.PixelFormat := pf24bit;
  FCoordConverter := aCoordConverter;
  FPen := TGPPen.Create( GpDefColor );
  FBrush := TGPSolidBrush.Create( GPDefColor );
  SetScreenSize( 100, 100 );
end;

destructor TDrawingPage.Destroy;
begin
  FBitMap.FreeImage;
  FreeAndNil( FBitmap );
  FGraphics := nil;
  FPen := nil;
  FBrush := nil;
  inherited;
end;

procedure TDrawingPage.DrawFillRect( const aP1, aP2 : TDrawingPoint;
  const aBackgroundColor, aBorderColor: TColor; const aBorderWidth: Extended);
var
  X1, Y1, X2, Y2,
  X, Y, H, W, BW : integer;
begin
  FBrush.Color := TDrawingFunc.GPColor( aBackgroundColor );

  FCoordConverter.LogToScreen( aP1.X, aP1.Y, X1, Y1 );
  FCoordConverter.LogToScreen( aP2.X, aP2.Y, X2, Y2 );
  BW := FCoordConverter.LogToScreen( aBorderWidth );
  TDrawingFunc.GetXYHW( X1, Y1, X2, Y2, true, X, Y, W, H );

  FGraphics.FillRectangle( FBrush, X, Y, W, H );

  FPen.Color := TDrawingFunc.GPColor( aBorderColor );
  FPen.Alignment := PenAlignmentInset;
  FPen.Width := aBorderWidth;
  FGraphics.DrawRectangle( FPen, X, Y, W, H );
end;

procedure TDrawingPage.DrawRect(const aP1, aP2: TDrawingPoint;
  const aBorderColor: TColor; const aBorderWidth: Extended );
var
  X1, X2, Y1, Y2, X, Y, W, H, BW : integer;
begin
  FPen.Color := TDrawingFunc.GPColor( aBorderColor );

  FCoordConverter.LogToScreen( aP1.X, aP1.Y, X1, Y1 );
  FCoordConverter.LogToScreen( aP2.X, aP2.Y, X2, Y2 );
  BW := FCoordConverter.LogToScreen( aBorderWidth );

  TDrawingFunc.GetXYHW( X1, Y1, X2, Y2, false, X, Y, W, H );

  FPen.Width := BW;
  FGraphics.DrawRectangle( FPen, X, Y, W, H );
end;

procedure TDrawingPage.Clear(const aColor: TColor);
begin
  FGraphics.Clear( TDrawingFunc.GPColor( aColor ) );
end;

function TDrawingPage.GetBitMap: TBitMap;
begin
  Result := FBitMap;
end;

procedure TDrawingPage.SetScreenSize(const aWidth, aHeight: integer);
begin
  FBitMap.Width := aWidth;
  FBitMap.Height := aHeight;
  FGraphics := TGPGraphics.FromHDC( FBitMap.Canvas.Handle  );
end;

end.
