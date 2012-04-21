unit uGraphicPrimitive;

interface

  uses uBase, uEventModel, Graphics, Windows, uExceptions, uExceptionCodes,
    SysUtils, GdiPlus, uDrawingSupport, Classes, System.Generics.Collections;

  type

    TPrimitiveDrawMode = ( pdmNormal, pdmIndex ); // режим рисования примитива

    TGraphicPrimitive = class ( TBaseSubscriber )
    strict private
      FParentPrimitive : TGraphicPrimitive;
      FChilds : TObjectList<TGraphicPrimitive>;
      FDrawingBox, FIndexDrawingBox : TDrawingBox;
      FIndexColor : TColor;
      FDrawMode : TPrimitiveDrawMode;

      function GetChild(aIndex: integer): TGraphicPrimitive;
      function GetChildCount: integer;
    protected
      procedure AddChild( const aPrimitive : TGraphicPrimitive );
      function GetDrawingBox : TDrawingBox;
      procedure Draw( const aGraphics : IGPGraphics ); virtual;
    public
      constructor Create( const aParent : TGraphicPrimitive );
      destructor Destroy; override;

      procedure DrawNormal( const aGraphics : IGPGraphics );
      procedure DrawIndex( const aGraphics : IGPGraphics );

      procedure RemoveAllChildren;
      procedure DelChild( const aIndex : integer ); overload;
      procedure DelChild( const aPrimitive : TGraphicPrimitive ); overload;

      property Child[ aIndex : integer ] : TGraphicPrimitive read GetChild;
      property ChildCount : integer read GetChildCount;
      property Parent : TGraphicPrimitive read FParentPrimitive;

      property IndexColor : TColor read FIndexColor;
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

procedure TGraphicPrimitive.RemoveAllChildren;
begin
  FChilds.Clear;
end;

end.
