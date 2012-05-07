unit uDrawingSupport;

interface

  uses uBase, GdiPlus, Graphics, Windows, uExceptions;

  const
    DefColor = clRed;
    GPDefColor = TGPColor.Red;

  type
    // Точки
    TDrawingPoint = record
    public
      X : Extended;
      Y : Extended;
      constructor Create(const aX, aY : Extended);
    end;
    TPoints = class( TObject )
    strict private
      FPoints : array of TDrawingPoint;
      FCount : integer;
      function GetPount( aIndex : integer ): TDrawingPoint;
      procedure SetPoint(aIndex: integer; const Value: TDrawingPoint);
    public
      constructor Create;
      destructor Destroy; override;
      procedure Add( const aX, aY : Extended ); overload;
      procedure Add( const aPoint : TDrawingPoint ); overload;
      procedure Clear;
      property Count : integer read FCount;
      property Point[ aIndex : integer ] : TDrawingPoint read GetPount write SetPoint; default;
    end;

    // Вспмогательные функции для рисования
    TDrawingFunc = class
    public
      class function GPColor( const aColor : TColor ) : TGPColor;
      class function GetNextIndexColor : TColor;
      class procedure GetXYHW( const aX1, aY1, aX2, aY2 : integer;
        const aCorrectZeroValue : boolean; var aX, aY, aH, aW : integer );
    end;

implementation

var
  GlobalIndexColor : TColor;

{ TPoints }

procedure TPoints.Add( const aX, aY: Extended );
begin
  Add( TDrawingPoint.Create( aX, aY ) );
end;

procedure TPoints.Add(const aPoint: TDrawingPoint);
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

function TPoints.GetPount(aIndex: integer): TDrawingPoint;
begin
  if ( aIndex >= 0 ) and ( aIndex < Count ) then begin
    Result := FPoints[ aIndex ];
  end else begin
    ContractFailure;
  end;
end;


procedure TPoints.SetPoint(aIndex: integer; const Value: TDrawingPoint);
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

class procedure TDrawingFunc.GetXYHW( const aX1, aY1, aX2, aY2 : integer;
  const aCorrectZeroValue: boolean; var aX, aY, aH, aW: integer );
begin
 if aX2 < aX1 then begin
    aX := aX2;
    aW := aX1 - aX2;
  end else begin
    aX := aX1;
    aW := aX2 - aX1;
  end;

  if aY2 < aY2 then begin
    aY := aY2;
    aH := aY1 - aY2;
  end else begin
    aY := aY1;
    aH := aY2 - aY1;
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

{ TDrawingPoint }

constructor TDrawingPoint.Create(const aX, aY: Extended);
begin
  Self.X := aX;
  Self.Y := aY;
end;

initialization
  GlobalIndexColor := 1;


end.
