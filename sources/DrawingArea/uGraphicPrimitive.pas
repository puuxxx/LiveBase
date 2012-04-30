unit uGraphicPrimitive;

interface

  uses uBase, uEventModel, Graphics, Windows, uExceptions, uExceptionCodes,
    SysUtils, GdiPlus, uDrawingSupport, Classes, System.Generics.Collections;


  {$M+}

  type
    TPrimitiveType = ( ptNone, ptBox ); // ���������
    TPrimitiveDrawMode = ( pdmNormal, pdmIndex ); // ����� ��������� ���������

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

      function GetChild(aIndex: integer): TGraphicPrimitive;
      function GetChildCount: integer;

      function GetFirstPoint: TPoint;
      function GetSecondPoint: TPoint;
      procedure SetFirstPoint(const Value: TPoint);
      procedure SetSecondPoint(const Value: TPoint);

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
      property NormalDrawingBox : TDrawingBox read FDrawingBox;
    public
      constructor Create( const aParent : TGraphicPrimitive ); virtual;
      destructor Destroy; override;

      // ���������
      procedure DrawNormal( const aGraphics : IGPGraphics );
      procedure DrawIndex( const aGraphics : IGPGraphics );

      // ������ � ���������
      procedure RemoveAllChildren;
      procedure DelChild( const aIndex : integer ); overload;
      procedure DelChild( const aPrimitive : TGraphicPrimitive ); overload;

      // ���������
      procedure ChangePos( const aNewX, aNewY : integer ); virtual;
      procedure InitCoord( const aCenterX, aCenterY : integer ); virtual;

      property Child[ aIndex : integer ] : TGraphicPrimitive read GetChild;
      property ChildCount : integer read GetChildCount;

      // �����
      property FirstPoint : TPoint read GetFirstPoint write SetFirstPoint;
      property SecondPoint : TPoint read GetSecondPoint write SetSecondPoint;
      property Points : TPoints read FPoints;

      property Parent : TGraphicPrimitive read FParentPrimitive;
      property IndexColor : TColor read FIndexColor;

      // ����������� �������� ���������
      property BackgroundColor : TColor read GetbackgroundColor write SetBackgroundColor;
      property BorderColor : TColor read GetBorderColor write SetBorderColor;
      property BorderWidth : byte read GetBorderWidth write SetBorderWidth;
    published
      property Name : string read FName write FName;
    end;

    // ���
    TBackground = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
    published
      property BackgroundColor;
    end;

    TSelect = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
    public
      constructor Create( const aParent : TGraphicPrimitive ); override;
    published
      property BorderColor;
    end;

    TBox = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
    public
      procedure ChangePos( const aNewX, aNewY : integer ); override;
      procedure InitCoord( const aCenterX, aCenterY : integer ); override;
    published
      property BorderColor;
      property BackgroundColor;
      property BorderWidth;
    end;

implementation

const
  SELECT_DASHES_PATTERN : array [0..1] of single = ( 1, 1 );
  DEFAULT_WIDTH = 100;
  DEFAULT_HEIGHT = 100;

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
  if Assigned( aParent ) then aParent.AddChild( Self ); // ���� �� ����

  FDrawMode := pdmNormal;
  FDrawingBox := TDrawingBox.Create;
  FIndexDrawingBox := TDrawingBox.Create;
  FIndexColor := GetNextIndexColor;
  FIndexDrawingBox.SetColor( FIndexColor );

  FPoints := TPoints.Create;

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

function TGraphicPrimitive.GetFirstPoint: TPoint;
begin
  if FPoints.Count <= 0 then begin
    ContractFailure;
  end;

  Result := FPoints.Point[0];
end;

function TGraphicPrimitive.GetSecondPoint: TPoint;
begin
  if FPoints.Count <= 1 then begin
    ContractFailure;
  end;

  Result := FPoints.Point[1];

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

procedure TGraphicPrimitive.SetFirstPoint(const Value: TPoint);
begin
  if FPoints.Count <= 0 then begin
    FPoints.Add( Value );
  end else begin
    FPoints.Point[0] := Value;
  end;
end;

procedure TGraphicPrimitive.SetSecondPoint(const Value: TPoint);
var
  Count : integer;
begin
  Count := FPoints.Count;

  if Count <= 0 then begin
    ContractFailure
  end;

  if ( Count = 1 ) then begin
    FPoints.Add( Value );
  end else begin
    FPoints.Point[1] := Value;
  end;
end;

{ TBackground }

procedure TBackground.Draw(const aGraphics: IGPGraphics);
var
  DBox : TDrawingBox;
begin
  DBox := GetDrawingBox;
  DBox.SolidBrush.Color := GPColor( DBox.BackgroundColor );
  aGraphics.FillRectangle( DBox.SolidBrush, 0, 0, FirstPoint.X, FirstPoint.Y );
end;

{ TSelect }

constructor TSelect.Create(const aParent: TGraphicPrimitive);
begin
  inherited;
  NormalDrawingBox.Pen.SetDashPattern( SELECT_DASHES_PATTERN );
  FirstPoint := TPoint.Create( 0, 0 );
  SecondPoint := FirstPoint;
end;

procedure TSelect.Draw(const aGraphics: IGPGraphics);
var
  DBox : TDrawingBox;

  X, Y, W, H : integer;
begin
  if Points.Count < 2 then ContractFailure;

  DBox := GetDrawingBox;
  DBox.Pen.Color := GPColor( DBox.BorderColor );
  DBox.Pen.Width := 1;

  if SecondPoint.X < FirstPoint.X then begin
    X := SecondPoint.X;
    W := FirstPoint.X - SecondPoint.X;
  end else begin
    X := FirstPoint.X;
    W := SecondPoint.X - FirstPoint.X;
  end;

  if SecondPoint.Y < FirstPoint.Y then begin
    Y := SecondPoint.Y;
    H := FirstPoint.Y - SecondPoint.Y;
  end else begin
    Y := FirstPoint.Y;
    H := SecondPoint.Y - FirstPoint.Y;
  end;

  if W = 0 then W := 1;
  if H = 0 then H := 1;

  aGraphics.DrawRectangle( DBox.Pen, X, Y, W, H );
end;

{ TBox }

procedure TBox.ChangePos(const aNewX, aNewY: integer);
begin
//
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

  if SecondPoint.X < FirstPoint.X then begin
    X := SecondPoint.X;
    W := FirstPoint.X - SecondPoint.X;
  end else begin
    X := FirstPoint.X;
    W := SecondPoint.X - FirstPoint.X;
  end;

  if SecondPoint.Y < FirstPoint.Y then begin
    Y := SecondPoint.Y;
    H := FirstPoint.Y - SecondPoint.Y;
  end else begin
    Y := FirstPoint.Y;
    H := SecondPoint.Y - FirstPoint.Y;
  end;

  if W = 0 then W := 1;
  if H = 0 then H := 1;

  aGraphics.FillRectangle( DBox.SolidBrush, X, Y, W, H );
  aGraphics.DrawRectangle( DBOx.Pen, X, Y, W, H );
end;

procedure TBox.InitCoord(const aCenterX, aCenterY: integer);
begin
  FirstPoint := TPoint.Create(
    aCenterX - DEFAULT_WIDTH div 2, aCenterY - DEFAULT_HEIGHT div 2 );

  SecondPoint := TPoint.Create(
    aCenterX + DEFAULT_WIDTH div 2, aCenterY + DEFAULT_HEIGHT div 2 );
end;

initialization
  GlobalIndexColor := 1;

end.
