unit uGraphicPrimitive;

interface

  uses uBase, uEventModel, Graphics, Windows, uExceptions, uExceptionCodes,
    SysUtils, GdiPlus, uDrawingSupport, Classes, System.Generics.Collections;


  {$M+}

  type

    TPrimitiveDrawMode = ( pdmNormal, pdmIndex ); // режим рисования примитива

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
    protected
      procedure AddChild( const aPrimitive : TGraphicPrimitive );
      function GetDrawingBox : TDrawingBox;
      procedure Draw( const aGraphics : IGPGraphics ); virtual;
      property NormalDrawingBox : TDrawingBox read FDrawingBox;
    public
      constructor Create( const aParent : TGraphicPrimitive );
      destructor Destroy; override;

      // рисование
      procedure DrawNormal( const aGraphics : IGPGraphics );
      procedure DrawIndex( const aGraphics : IGPGraphics );

      // работа с патомками
      procedure RemoveAllChildren;
      procedure DelChild( const aIndex : integer ); overload;
      procedure DelChild( const aPrimitive : TGraphicPrimitive ); overload;

      property Child[ aIndex : integer ] : TGraphicPrimitive read GetChild;
      property ChildCount : integer read GetChildCount;

      // точки
      property FirstPoint : TPoint read GetFirstPoint write SetFirstPoint;
      property SecondPoint : TPoint read GetSecondPoint write SetSecondPoint;
      property Points : TPoints read FPoints;

      property Parent : TGraphicPrimitive read FParentPrimitive;
      property IndexColor : TColor read FIndexColor;

      // графические свойства примитива
      property BackgroundColor : TColor read GetbackgroundColor write SetBackgroundColor;
    published
      property Name : string read FName write FName;
    end;

    // фон
    TBackground = class( TGraphicPrimitive )
    protected
      procedure Draw( const aGraphics : IGPGraphics ); override;
    published
      property BackgroundColor;
    end;

implementation

{ TGraphicPrimitive }

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

procedure TGraphicPrimitive.AddChild(const aPrimitive: TGraphicPrimitive);
begin
  if aPrimitive = nil then ContractFailure;

  FChilds.Add( aPrimitive );
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

procedure TGraphicPrimitive.RemoveAllChildren;
begin
  FChilds.Clear;
end;

procedure TGraphicPrimitive.SetBackgroundColor(const Value: TColor);
begin
  NormalDrawingBox.BackgroundColor := Value;
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

initialization
  GlobalIndexColor := 1;

end.
