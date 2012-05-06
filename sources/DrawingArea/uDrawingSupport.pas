unit uDrawingSupport;

interface

  uses uBase, GdiPlus, Graphics, Windows, uExceptions;

  const
    DefColor = clRed;
    PGDefColor = TGPColor.Red;

  type
    ICoordConverter = interface;
    IDrawingPage = interface;

    // Конвертер логических координат в экранные
    ICoordConverter = interface
      function LogToScreen( aValue : Extended ) : integer; overload;
      function ScreenToLog( aValue : integer ) : Extended; overload;

      procedure LogToScreen( aLogVal1, aLogVal2 : Extended; var aScrVal1, aScrVal2 : integer ); overload;
      procedure ScreenToLog( aScrVal1, aScrVal2 : integer; aLogVal1, aLogVal2 : Extended ); overload;
    end;

    // Виртуальный холст
    IDrawingPage = interface
      procedure DrawWhat;
    end;

    // Точки
    TPoints = class( TObject )
    strict private
      FPoints : array of TPoint;
      FCount : integer;
      function GetPount( aIndex : integer ): TPoint;
      procedure SetPoint(aIndex: integer; const Value: TPoint);
    public
      constructor Create;
      destructor Destroy; override;
      procedure Add( const aX, aY : integer ); overload;
      procedure Add( const aPoint : TPoint ); overload;
      procedure Clear;
      property Count : integer read FCount;
      property Point[ aIndex : integer ] : TPoint read GetPount write SetPoint; default;
    end;

    // Вспмогательные функции для рисования
    TDrawingFunc = class
    public
      class function GPColor( const aColor : TColor ) : TGPColor;
      class function GetNextIndexColor : TColor;
      class procedure GetXYHW( const aFirstPoint, aSecondPoint : TPoint;
        const aCorrectZeroValue : boolean; var aX, aY, aH, aW : integer );
    end;

implementation

var
  GlobalIndexColor : TColor;

{ TPoints }

procedure TPoints.Add(const aX, aY: integer);
begin
  Add( TPoint.Create( aX, aY ) );
end;

procedure TPoints.Add(const aPoint: TPoint);
const
  AddCount = 5;
begin
   if FCount >= length( FPoints ) then begin
    SetLength( FPoints, FCount + AddCount );
  end;
  FPoints[ FCount ] := aPoint;
  inc( FCount );
end;

procedure TPoints.Clear;
begin
  SetLength( FPoints, 0 );
  FPoints := nil;
  FCount := 0;
end;

constructor TPoints.Create;
begin
  inherited Create;
  Clear;
end;

destructor TPoints.Destroy;
begin
  Clear;
  inherited;
end;

function TPoints.GetPount(aIndex: integer): TPoint;
begin
  if ( aIndex >= 0 ) and ( aIndex < Count ) then begin
    Result := FPoints[ aIndex ];
  end else begin
    ContractFailure;
  end;
end;


procedure TPoints.SetPoint(aIndex: integer; const Value: TPoint);
begin
  if ( aIndex >= 0 ) and ( aIndex < Count ) then begin
    FPoints[ aIndex ] := Value;
  end else begin
    ContractFailure;
  end;
end;

{ TDrawingFunc }

class function TDrawingFunc.GetNextIndexColor: TColor;
var
  r, g, b : Byte;
begin
  r := GetRValue( GlobalIndexColor );
  g := GetGValue( GlobalIndexColor );
  b := GetBValue( GlobalIndexColor );

  if r >= 254 then begin
    r := 1;
    if g >= 254 then begin
      g := 1;
      if b >= 254 then begin
        b := 1;
      end else begin
        b := b + 1;
      end;
    end else begin
      g := g + 1;
    end;
  end else begin
    r := r + 1;
  end;

  GlobalIndexColor := RGB( r, g, b );
  Result := GlobalIndexColor;
end;

class procedure TDrawingFunc.GetXYHW(const aFirstPoint, aSecondPoint: TPoint;
  const aCorrectZeroValue: boolean; var aX, aY, aH, aW: integer);
begin
 if aSecondPoint.X < aFirstPoint.X then begin
    aX := aSecondPoint.X;
    aW := aFirstPoint.X - aSecondPoint.X;
  end else begin
    aX := aFirstPoint.X;
    aW := aSecondPoint.X - aFirstPoint.X;
  end;

  if aSecondPoint.Y < aFirstPoint.Y then begin
    aY := aSecondPoint.Y;
    aH := aFirstPoint.Y - aSecondPoint.Y;
  end else begin
    aY := aFirstPoint.Y;
    aH := aSecondPoint.Y - aFirstPoint.Y;
  end;

  if aCorrectZeroValue then begin
    if aH = 0 then aH := 1;
    if aW = 0 then aW := 1;
  end;
end;

class function TDrawingFunc.GPColor(const aColor: TColor): TGPColor;
begin
  Result := TGPColor.Create( Byte( aColor), Byte( aColor shr 8 ), Byte( aColor shr 16) );
end;

initialization
  GlobalIndexColor := 1;


end.
