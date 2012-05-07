unit uDrawingPage;

interface

  uses uBase, System.SysUtils, Graphics, GDIPlus, uDrawingSupport;
  type

    // ��������� ���������� ��������� � ��������
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


    // ����������� �����
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

      // ����������� ��� �������� �������� ������
      procedure Clear( const aColor : TColor );

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
  FGraphics := TGPGraphics.Create( FBitMap.Canvas.Handle );
  FPen := TGPPen.Create( GpDefColor );
  FBrush := TGPSolidBrush.Create( GPDefColor );
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

procedure TDrawingPage.Clear(const aColor: TColor);
begin
  FGraphics.Clear( TDrawingFunc.GPColor( clRed ) );
end;

function TDrawingPage.GetBitMap: TBitMap;
begin
  Result := FBitMap;
end;

procedure TDrawingPage.SetScreenSize(const aWidth, aHeight: integer);
begin
  FBitMap.Width := aWidth;
  FBitMap.Height := aHeight;
end;

end.
