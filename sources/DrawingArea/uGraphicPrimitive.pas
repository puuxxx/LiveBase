unit uGraphicPrimitive;

interface

  uses uBase, uEventModel, Graphics, Windows, uExceptions, uExceptionCodes,
    SysUtils, GdiPlus, uDrawingSupport, Classes, System.Generics.Collections;


  {$M+}

  type
    TPrimitiveType = ( ptNone, ptBox ); // примитивы
    TPrimitiveDrawMode = ( pdmNormal, pdmIndex ); // режим рисования примитива

    TGraphicPrimitiveClass = class of TGraphicPrimitive;
    TGraphicPrimitive = class ( TBaseSubscriber )
    strict private
      FParentPrimitive : TGraphicPrimitive;
      FChilds : TObjectList<TGraphicPrimitive>;
      FDrawingBox, FIndexDrawingBox : TDrawingBox;
      FIndexColor : TColor;
      FDrawMode : TPrimitiveDrawMode;
      FPoints : TPoints;
      FName : string;
      FSelected : boolean;

      function GetChild(aIndex: integer): TGraphicPrimitive;
      function GetChildCount: integer;

      function GetbackgroundColor: TColor;
      procedure SetBackgroundColor(const Value: TColor);
      function GetBorderColor: TColor;
      procedure SetBorderColor(const Value: TColor);
      function GetBorderWidth: byte;
      procedure SetBorderWidth(const Value: byte);
    protected
      procedure AddChild( const aPrimitive : TGraphicPrimitive );
      function GetDrawingBox : TDrawingBox;
      procedure Draw( const aGraphics : IGPGraphics ); virtual;

      // точки описанного вокруг прямоугольника
      function GetTopLeftPoint : TPoint; virtual;
      function GetBottomRightPoint : TPoint; virtual;

      property NormalDrawingBox : TDrawingBox read FDrawingBox;
    public
      constructor Create( const aParent : TGraphicPrimitive ); virtual;
      destructor Destroy; override;

      // рисование
      procedure DrawNormal( const aGraphics : IGPGraphics );
      procedure DrawIndex( const aGraphics : IGPGraphics );

      // работа с патомками
      procedure RemoveAllChildren;
      procedure DelChild( const aIndex : integer ); overload;
      procedure DelChild( const aPrimitive : TGraphicPrimitive ); overload;

      // положение
      procedure ChangePos( const aNewX, aNewY : integer ); virtual;
      procedure InitCoord( const aCenterX, aCenterY : integer ); virtual;

      property Child[ aIndex : integer ] : TGraphicPrimitive read GetChild;
      property ChildCount : integer read GetChildCount;

      // точки
      property Points : TPoints read FPoints;

      property Parent : TGraphicPrimitive read FParentPrimitive;
      property IndexColor : TColor read FIndexColor;
      property Selected : boolean read FSelected write FSelected;

      // графические свойства примитива
      property BackgroundColor : TColor read GetbackgroundColor write SetBackgroundColor;
      property BorderColor : TColor read GetBorderColor write SetBorderColor;
      property BorderWidth : byte read GetBorderWidth write SetBorderWidth;
    published
      property Name : string read FName write FName;
    end;

    TGraphicPrimitives = array of TGraphicPrimitive;

    // фон
    TBackground = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
      function GetTopLeftPoint : TPoint; override;
      function GetBottomRightPoint : TPoint; override;
    published
      property BackgroundColor;
    end;

    TSelectArea = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
      function GetTopLeftPoint : TPoint; override;
      function GetBottomRightPoint : TPoint; override;
    public
      constructor Create( const aParent : TGraphicPrimitive ); override;
    published
      property BorderColor;
    end;

    TBox = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
      function GetTopLeftPoint : TPoint; override;
      function GetBottomRightPoint : TPoint; override;
    public
      procedure ChangePos( const aNewX, aNewY : integer ); override;
      procedure InitCoord( const aCenterX, aCenterY : integer ); override;
    published
      property BorderColor;
      property BackgroundColor;
      property BorderWidth;
    end;

    TBorder = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
      function GetTopLeftPoint : TPoint; override;
      function GetBottomRightPoint : TPoint; override;
    end;

implementation

const
  SELECT_DASHES_PATTERN : array [0..1] of single = ( 1, 1 );
  DEFAULT_WIDTH = 100;
  DEFAULT_HEIGHT = 100;

{ TGraphicPrimitive }

procedure TGraphicPrimitive.AddChild(const aPrimitive: TGraphicPrimitive);
begin
  if aPrimitive = nil then ContractFailure;

  FChilds.Add( aPrimitive );
end;

procedure TGraphicPrimitive.ChangePos(const aNewX, aNewY: integer);
begin
//
end;

constructor TGraphicPrimitive.Create(const aParent: TGraphicPrimitive);
begin
  inherited Create;

  FChilds := TObjectList<TGraphicPrimitive>.Create;
  FParentPrimitive := aParent;
  if Assigned( aParent ) then aParent.AddChild( Self ); // Идем на риск

  FDrawMode := pdmNormal;
  FDrawingBox := TDrawingBox.Create;
  FIndexDrawingBox := TDrawingBox.Create;
  FIndexColor := GetNextIndexColor;
  FIndexDrawingBox.SetColor( FIndexColor );

  FPoints := TPoints.Create;
  FSelected := false;

  FName := '';
end;

procedure TGraphicPrimitive.DelChild(const aPrimitive: TGraphicPrimitive);
var
  i : integer;
begin
  i := FChilds.IndexOf( aPrimitive );
  if i >= 0 then DelChild( i );
end;

procedure TGraphicPrimitive.DelChild(const aIndex: integer);
begin
  if ( aIndex < 0 ) or ( aIndex >= FChilds.Count ) then ContractFailure;

  FChilds.Delete( aIndex );
end;

destructor TGraphicPrimitive.Destroy;
begin
  FreeAndNil( FChilds );
  FreeAndNil( FPoints );
  inherited;
end;

procedure TGraphicPrimitive.Draw(const aGraphics: IGPGraphics);
begin
  //
end;

procedure TGraphicPrimitive.DrawIndex(const aGraphics: IGPGraphics);
begin
  FDrawMode := pdmIndex;
  Draw( aGraphics );
end;

procedure TGraphicPrimitive.DrawNormal(const aGraphics: IGPGraphics);
begin
  FDrawMode := pdmNormal;
  Draw( aGraphics );
end;

function TGraphicPrimitive.GetbackgroundColor: TColor;
begin
  Result := NormalDrawingBox.BackgroundColor
end;

function TGraphicPrimitive.GetBorderColor: TColor;
begin
  Result := NormalDrawingBox.BorderColor
end;

function TGraphicPrimitive.GetBorderWidth: byte;
begin
  Result := NormalDrawingBox.BorderWidth
end;

function TGraphicPrimitive.GetBottomRightPoint: TPoint;
begin
//
end;

function TGraphicPrimitive.GetChild(aIndex: integer): TGraphicPrimitive;
begin
  if ( aIndex < 0 ) or ( aIndex >= FChilds.Count ) then ContractFailure;

  Result := FChilds[ aIndex ];
end;

function TGraphicPrimitive.GetChildCount: integer;
begin
  Result := FChilds.Count;
end;

function TGraphicPrimitive.GetDrawingBox: TDrawingBox;
begin
  if FDrawMode = pdmNormal then Result := FDrawingBox
                           else Result := FIndexDrawingBox;
end;

function TGraphicPrimitive.GetTopLeftPoint: TPoint;
begin
//
end;

procedure TGraphicPrimitive.InitCoord(const aCenterX, aCenterY: integer);
begin
//
end;

procedure TGraphicPrimitive.RemoveAllChildren;
begin
  FChilds.Clear;
end;

procedure TGraphicPrimitive.SetBackgroundColor(const Value: TColor);
begin
  NormalDrawingBox.BackgroundColor := Value;
end;

procedure TGraphicPrimitive.SetBorderColor(const Value: TColor);
begin
  NormalDrawingBox.BorderColor := Value;
end;

procedure TGraphicPrimitive.SetBorderWidth(const Value: byte);
begin
  NormalDrawingBox.BorderWidth := Value;
end;

{ TBackground }

procedure TBackground.Draw(const aGraphics: IGPGraphics);
var
  DBox : TDrawingBox;
  PTL, PBR : TPoint;
begin
  DBox := GetDrawingBox;
  DBox.SolidBrush.Color := GPColor( DBox.BackgroundColor );

  PTL := GetTopLeftPoint;
  PBR := GetBottomRightPoint;
  aGraphics.FillRectangle( DBox.SolidBrush, PTL.X , PTL.Y, PBR.X, PBR.Y );
end;

function TBackground.GetBottomRightPoint: TPoint;
begin
  Result := Points.Point[0];
end;

function TBackground.GetTopLeftPoint: TPoint;
begin
  Result := TPoint.Create( 0, 0 );
end;

{ TSelect }

constructor TSelectArea.Create(const aParent: TGraphicPrimitive);
begin
  inherited;
  NormalDrawingBox.Pen.SetDashPattern( SELECT_DASHES_PATTERN );
  Points.Add( 0, 0 );
  Points.Add( 0, 0 );
end;

procedure TSelectArea.Draw(const aGraphics: IGPGraphics);
var
  DBox : TDrawingBox;
  X, Y, W, H : integer;
begin
  if Points.Count < 2 then ContractFailure;

  DBox := GetDrawingBox;
  DBox.Pen.Color := GPColor( DBox.BorderColor );
  DBox.Pen.Width := 1;

  GetXYHW( GetTopLeftPoint, GetBottomRightPoint, true, X, Y, H, W);

  aGraphics.DrawRectangle( DBox.Pen, X, Y, W, H );
end;

function TSelectArea.GetBottomRightPoint: TPoint;
begin
  Result := Points.Point[1];
end;

function TSelectArea.GetTopLeftPoint: TPoint;
begin
  Result := Points.Point[0];
end;

{ TBox }

procedure TBox.ChangePos(const aNewX, aNewY: integer);
var
  P : TPoint;
begin
  P := Points.Point[0];
  P.X := P.X + aNewX;
  P.Y := P.Y + aNewY;
  Points.Point[0] := P;

  P := Points.Point[1];
  P.X := P.X + aNewX;
  P.Y := P.Y + aNewY;

  Points.Point[1] := P;
end;

procedure TBox.Draw( const aGraphics: IGPGraphics );
var
  DBox : TDrawingBox;
  X, Y, H, W : integer;
begin
  DBox := GetDrawingBox;

  DBox.Pen.Alignment := PenAlignmentInset;
  DBox.Pen.Width := DBox.BorderWidth;
  DBox.Pen.Color := GPColor( DBox.BorderColor );
  DBox.SolidBrush.Color := GPColor( DBox.BackgroundColor );

  GetXYHW( GetTopLeftPoint, GetBottomRightPoint, true, X, Y, H, W );

  aGraphics.FillRectangle( DBox.SolidBrush, X, Y, W, H );
  aGraphics.DrawRectangle( DBOx.Pen, X, Y, W, H );
end;

function TBox.GetBottomRightPoint: TPoint;
begin
  Result := Points.Point[1];
end;

function TBox.GetTopLeftPoint: TPoint;
begin
  Result := Points.Point[0];
end;

procedure TBox.InitCoord(const aCenterX, aCenterY: integer);
begin
  Points.Clear;
  Points.Add( aCenterX - DEFAULT_WIDTH div 2, aCenterY - DEFAULT_HEIGHT div 2 );
  Points.Add( aCenterX + DEFAULT_WIDTH div 2, aCenterY + DEFAULT_HEIGHT div 2 );
end;

{ TBorder }

procedure TBorder.Draw(const aGraphics: IGPGraphics);
var
  X, Y, H, W : integer;
  DBox : TDrawingBox;
begin
  GetXYHW( GetTopLeftPoint, GetBottomRightPoint, false, X, Y, H, W );

  DBox := GetDrawingBox;
  DBox.Pen.Color := GPColor( DBox.BorderColor );
  DBox.Pen.Width := 1;

  aGraphics.DrawRectangle( DBox.Pen, X - 5, Y - 5, W + 10, H + 10 );
end;

function TBorder.GetBottomRightPoint: TPoint;
begin
  Result := Parent.GetBottomRightPoint;
end;

function TBorder.GetTopLeftPoint: TPoint;
begin
  Result := Parent.GetTopLeftPoint;
end;

end.
