unit uDrawingSupport;

interface

  uses uBase, GdiPlus, Graphics, Windows;

  const
    DefColor = clRed;
    PGDefColor = TGPColor.Red;

  type
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
      property Point[ aIndex : integer ] : TPoint read GetPount write SetPoint;
    end;

    TDrawingBox = class( TObject )
    strict private
      FSolidBrush : IGPSolidBrush;
      FPen : IGPPen;
      FBackGroundColor : TColor;
      FBorderColor : TColor;
      FBorderWidth : byte;

      function GetPen: IGPPen;
      function GetSolidBrush: IGPSolidBrush;
    public
      constructor Create;
      procedure SetColor( const aColor : TColor );
      property SolidBrush : IGPSolidBrush read GetSolidBrush;
      property Pen : IGPPen read GetPen;

      property BackgroundColor : TColor read FBackgroundColor write FBackgroundColor;
      property BorderColor : TColor read FBorderColor write FBorderColor;
      property BorderWidth : byte read FBorderWidth write FBorderWidth;
    end;


    function GPColor( const aColor : TColor ) : TGPColor;

implementation

function GPColor( const aColor : TColor ) : TGPColor;
begin
  Result := TGPColor.Create( Byte( aColor), Byte( aColor shr 8 ), Byte( aColor shr 16) );
end;

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
    Result := TPoint.Create( 0, 0 );
  end;
end;


procedure TPoints.SetPoint(aIndex: integer; const Value: TPoint);
begin
  if ( aIndex >= 0 ) and ( aIndex < Count ) then begin
    FPoints[ aIndex ] := Value;
  end else begin
    //
  end;
end;

{ TDrawingBox }

constructor TDrawingBox.Create;
begin
  inherited Create;

  FPen := nil;
  FSolidBrush := nil;
  BackGroundColor := DefColor;
  BorderColor := DefColor;
  BorderWidth := 1;
end;

function TDrawingBox.GetPen: IGPPen;
begin
  if FPen = nil then FPen := TGPPen.Create( PGDefColor );
  Result := FPen;
end;

function TDrawingBox.GetSolidBrush: IGPSolidBrush;
begin
  if FSolidBrush = nil then FSolidBrush := TGPSolidBrush.Create( PGDefColor );
  Result := FSolidBrush;
end;

procedure TDrawingBox.SetColor(const aColor: TColor);
begin
  BackgroundColor := aColor;
  BorderColor := aColor;
end;

end.
