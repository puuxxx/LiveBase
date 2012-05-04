unit uDrawingSupport;

interface

  uses uBase, GdiPlus, Graphics, Windows;

  const
    DefColor = clRed;
    PGDefColor = TGPColor.Red;

  type

    ICoordConverter = interface
      function LogToScreen( aValue : Extended ) : integer; overload;
      function ScreenToLog( aValue : integer ) : Extended; overload;

      procedure LogToScreen( aLogVal1, aLogVal2 : Extended; var aScrVal1, aScrVal2 : integer ); overload;
      procedure ScreenToLog( aScrVal1, aScrVal2 : integer; aLogVal1, aLogVal2 : Extended ); overload;
    end;

    IDrawingPage = interface
      procedure DrawWhat;
    end;

    IFigure = interface
      procedure SetBackgroundColor( aValue : TColor );
      function GetBackgroundColor : TColor;
      procedure SetBorderColor( aValue : TColor );
      function GetBorderColor : TColor;
      procedure SetBorderWidth( aValue : byte );
      function GetBorderWidth : byte;
      procedure SetIndexColor( aValue : TColor );
      function GetIndexColor : TColor;
      function GetNextFigure : IFigure;
      procedure SetNextFigure ( aValue : IFigure );
      function GetPrevFigure : IFigure;
      procedure SetPrevFigure ( aValue : IFigure );
      function GetParentFigure : IFigure;
      procedure SetParentFigure ( aValue : IFigure );
      procedure SetFirstChildFigure( aValue : IFigure );
      function GetFirstChildFigure : IFigure;

      procedure Draw( const aPage : IDrawingPage );
      procedure DrawIndex( const aPage : IDrawingPage );

      property BackgroundColor : TColor read GetBackgroundColor write SetBackgroundColor;
      property BorderColor : TColor read GetBorderColor write SetBorderColor;
      property BorderWidth : byte read GetBorderWidth write SetBorderWidth;
      property IndexColor : TColor read GetIndexColor write SetIndexColor;

      procedure AddChildFigure( const aFigure : IFigure );
      procedure RemoveChildFigure( const aFigure : IFigure );
      procedure ClearChildrensFigure;

      property ParentFigure : IFigure read GetParentFigure write SetParentFigure;
      property NextFigure : IFigure read GetNextFigure write SetNextFigure;
      property PrevFigure : IFigure read GetPrevFigure write SetPrevFigure;
      property FirstChildFigure : IFigure read GetFirstChildFigure write SetFirstChildFigure;
    end;

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
    function GetNextIndexColor : TColor;
    procedure GetXYHW( const aFirstPoint, aSecondPoint : TPoint;
      const aCorrectZeroValue : boolean; var aX, aY, aH, aW : integer );

implementation

procedure GetXYHW( const aFirstPoint, aSecondPoint : TPoint;
  const aCorrectZeroValue : boolean; var aX, aY, aH, aW : integer );
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

function GPColor( const aColor : TColor ) : TGPColor;
begin
  Result := TGPColor.Create( Byte( aColor), Byte( aColor shr 8 ), Byte( aColor shr 16) );
end;

var
  GlobalIndexColor : TColor;

function GetNextIndexColor : TColor;
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

initialization
  GlobalIndexColor := 1;


end.
