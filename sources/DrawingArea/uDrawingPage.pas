unit uDrawingPage;

interface

uses uBase, uGraphicPrimitive, Windows, Graphics, GdiPlus, SysUtils,
  uExceptions, System.Generics.Collections;

type
  TDrawingPage = class(TBaseObject)
  private
    FRoot: TBackground;

    // рамка выделения мышкой
    FSelect : TSelectArea;
    FNeedToDrawSelect : boolean;

    // нормальная битмапка
    FBitMap: TBitMap;
    FGraphics: IGPGraphics;

    // битмапка для быстрого поиска примитивов по координатам мыши
    FFakeBitMap : TBitMap;
    FFakeGraphics : IGPGraphics;

    FSelectedPrimitivs : TList<TGraphicPrimitive>;

    function GetPrimitiveByIndexColor( const aIndexColor : TColor ) : TGraphicPrimitive;
    procedure GetPrimitives( var aPrimitives : TGraphicPrimitives );

  public
    constructor Create;
    destructor Destroy; override;

    procedure NewSize(const aWidth, aHeight: integer);

    function GetBitmap: TBitMap;
    function GetPrimitiveByCoord( const aX, aY : integer ) : TGraphicPrimitive;
    function GetPrimitiveByID( const aID : string ) : TGraphicPrimitive;
    function AddPrimitive( const aX, aY : integer; const aType : TPrimitiveType ) : TGraphicPrimitive;
    procedure SelectOnePrimitive( const aPrim : TGraphicPrimitive );
    procedure UnSelectAll;
    procedure ChangeSelectedPos( const aDX, aDY : integer );

    property RootPrimitive: TBackground read FRoot;
    property SelectAreaPrimitive : TSelectArea read FSelect;
    property NeedToDrawSelect : boolean read FNeedToDrawSelect write FNeedToDrawSelect;
  end;

  function PrimitiveFactory( const aPage : TDrawingPage; const aType : TPrimitiveType ) : TGraphicPrimitive;

implementation

const
  PrimitivesClasses : array [ TPrimitiveType ] of TGraphicPrimitiveClass = (
    nil, TBox
  );

function PrimitiveFactory( const aPage : TDrawingPage; const aType : TPrimitiveType ) : TGraphicPrimitive;
begin
  if not Assigned( PrimitivesClasses[ aType ] ) then ContractFailure;

  Result := PrimitivesClasses[ aType ].Create( aPage.RootPrimitive );
end;


{ TDrawingPage }

function TDrawingPage.AddPrimitive( const aX, aY : integer; const aType : TPrimitiveType ): TGraphicPrimitive;
begin
  Result := PrimitiveFactory( Self, aType );
end;

procedure TDrawingPage.ChangeSelectedPos(const aDX, aDY: integer);
var
  i : integer;
begin
  for I := 0 to FSelectedPrimitivs.Count - 1 do begin
    FSelectedPrimitivs[i].ChangePos( aDX, aDY );
  end;
end;

constructor TDrawingPage.Create;
begin
  inherited Create;

  FBitMap := TBitMap.Create;
  FBitMap.PixelFormat := pf24bit;

  FFakeBitMap := TBitmap.Create;
  FFakeBitMap.PixelFormat := pf24bit;

  FGraphics := nil;
  FFakeGraphics := nil;

  NewSize(0, 0); // создадим Graphics

  FRoot := TBackground.Create(nil);
  FRoot.Points.Add( 0, 0 );
  FSelect := TSelectArea.Create(nil);
  FNeedToDrawSelect := false;

  FSelectedPrimitivs := TList<TGraphicPrimitive>.Create;
end;

destructor TDrawingPage.Destroy;
begin
  FGraphics := nil;
  FreeAndNil(FBitMap);
  FreeAndNil(FRoot);
  FreeAndNil(FSelect);
  FreeAndNil(FSelectedPrimitivs);
  
  inherited;
end;

function TDrawingPage.GetBitmap: TBitMap;
var
  Prims : TGraphicPrimitives;
  i : integer;
begin
  FRoot.Points.Point[0] := TPoint.Create( FBitMap.Width, FBitMap.Height );

  GetPrimitives( Prims );
  try
    for I := 0 to length( Prims ) - 1 do begin
      Prims[i].DrawNormal( FGraphics );
      Prims[i].DrawIndex( FFakeGraphics );
    end;
  finally
    Setlength( Prims, 0 );
  end;

  if FNeedToDrawSelect then FSelect.DrawNormal( FGraphics );

  Result := FBitMap;
end;

function TDrawingPage.GetPrimitiveByCoord(const aX,
  aY: integer): TGraphicPrimitive;
begin
  if ( aX > FFakeBitMap.Width ) or ( aY > FFakeBitMap.Height ) then begin
    Result := FRoot;
    exit;
  end;

  Result := GetPrimitiveByIndexColor( FFakeBitMap.Canvas.Pixels[ aX, aY ] );

  if Result = nil then Result := FRoot;
end;

function TDrawingPage.GetPrimitiveByID(const aID: string): TGraphicPrimitive;

  function FindPrimitive ( const aParent : TGraphicPrimitive; const aID : string ) : TGraphicPrimitive;
  var
    i : integer;
    Child : TGraphicPrimitive;
  begin
    Result := nil;
    for I := 0 to aParent.ChildCount-1 do begin
      Child := aParent.Child[i];
      if SameStr( Child.IDAsStr, aID ) then begin
        Result := Child;
        exit;
      end;

      if Child.ChildCount > 0 then begin
        Result := FindPrimitive( Child, aID );
      end;
    end;
  end;

begin
  if SameStr( FRoot.IDAsStr, aID ) then Result := FRoot
                                   else Result := FindPrimitive( FRoot, aID );
end;

function TDrawingPage.GetPrimitiveByIndexColor(
  const aIndexColor: TColor): TGraphicPrimitive;

  function FindByColor( const aPrimitive : TGraphicPrimitive; const aColor : TColor ) : TGraphicPrimitive;
  var
    i : integer;
    Prim : TGraphicPrimitive;
  begin
    Result := nil;
    for i := 0 to aPrimitive.ChildCount - 1 do begin
      Prim := aPrimitive.Child[i];
      if Prim.IndexColor = aColor then begin
        Result := Prim;
        exit;
      end;
      if Prim.ChildCount > 0 then Result := FindByColor( Prim, aColor );
    end;
  end;

begin
  if FRoot.IndexColor = aIndexColor then begin
    Result := FRoot;
  end else begin
    Result := FindByColor( FRoot, aIndexColor );
  end;
end;

procedure TDrawingPage.GetPrimitives( var aPrimitives : TGraphicPrimitives );

type
  TByPassProc = reference to procedure ( const aPrim : TGraphicPrimitive;
    var aList : TGraphicPrimitives );

var
  Proc : TByPassProc;
  i : integer;
begin
  i := 0;
  Proc := procedure ( const aPrim : TGraphicPrimitive; var aList : TGraphicPrimitives )
  var
    j : integer;
  begin
    if length( aList ) >= i then begin
      Setlength( aList, i + 10 );
    end;
    aList[i] := aPrim;
    inc( i );

    if aPrim.ChildCount > 0 then begin
      for j := 0 to aPrim.ChildCount - 1 do Proc( aPrim.Child[j], aList );
    end;
  end;
  Proc( FRoot, aPrimitives );
  Setlength( aPrimitives, i );
end;

procedure TDrawingPage.NewSize(const aWidth, aHeight: integer);
begin
  FBitMap.Width := aWidth;
  FBitMap.Height := aHeight;

  FGraphics := TGPGraphics.FromHDC( FBitMap.Canvas.Handle );

  FFakeBitMap.Width := aWidth;
  FFakeBitMap.Height := aHeight;

  FFakeGraphics := TGPGraphics.FromHDC( FFakeBitMap.Canvas.Handle );
end;

procedure TDrawingPage.SelectOnePrimitive(const aPrim: TGraphicPrimitive);
begin
  UnSelectAll;
  FSelectedPrimitivs.Add( aPrim );
  TBorder.Create( aPrim );
end;

procedure TDrawingPage.UnSelectAll;
var
  i : integer;
  Prim : TGraphicPrimitive;
begin
  for I := 0 to FSelectedPrimitivs.Count-1 do begin
    Prim := FSelectedPrimitivs[i];
    Prim.RemoveAllChildren;
  end;
  FSelectedPrimitivs.Clear;
end;

end.
