unit uDrawingPage;

interface

uses uBase, uGraphicPrimitive, Windows, Graphics, GdiPlus, SysUtils, uExceptions;

type
  TDrawingPage = class(TBaseObject)
  private
    FRoot: TBackground;

    // рамка выделения
    FSelect : TSelect;
    FNeedToDrawSelect : boolean;

    // нормальная битмапка
    FBitMap: TBitMap;
    FGraphics: IGPGraphics;

    // битмапка для быстрого поиска примитивов по координатам мыши
    FFakeBitMap : TBitMap;
    FFakeGraphics : IGPGraphics;

    function GetPrimitiveByIndexColor( const aIndexColor : TColor ) : TGraphicPrimitive;
  public
    constructor Create;
    destructor Destroy; override;

    procedure NewSize(const aWidth, aHeight: integer);

    function GetBitmap: TBitMap;
    function GetPrimitiveByCoord( const aX, aY : integer ) : TGraphicPrimitive;
    function GetPrimitiveByID( const aID : string ) : TGraphicPrimitive;
    function IsRootPrimitiveCord( const aX, aY : integer ) : boolean;
    function AddPrimitive( const aX, aY : integer; const aType : TPrimitiveType ) : TGraphicPrimitive;
    property RootPrimitive: TBackground read FRoot;
    property SelectPrimitive : TSelect read FSelect;
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
  FSelect := TSelect.Create(nil);
  FNeedToDrawSelect := false;
  FSelect.FirstPoint := TPoint.Create( 0, 0 );

end;

destructor TDrawingPage.Destroy;
begin
  FGraphics := nil;
  FreeAndNil(FBitMap);
  FreeAndNil(FRoot);
  FreeAndNil(FSelect);
  
  inherited;
end;

function TDrawingPage.GetBitmap: TBitMap;

  procedure DrawPrimitive( const aGraphics: IGPGraphics;
    const aPrimitive: TGraphicPrimitive; const aIndexDraw : boolean );
  var
    i: integer;
    Prim: TGraphicPrimitive;
  begin
    if aIndexDraw then begin
      for i := 0 to aPrimitive.ChildCount - 1 do begin
        Prim := aPrimitive.Child[i];
        Prim.DrawIndex(aGraphics);
        if Prim.ChildCount > 0 then DrawPrimitive( aGraphics, Prim, aIndexDraw );
      end;
    end else begin
      for i := 0 to aPrimitive.ChildCount - 1 do begin
        Prim := aPrimitive.Child[i];
        Prim.DrawNormal(aGraphics);
        if Prim.ChildCount > 0 then DrawPrimitive( aGraphics, Prim, aIndexDraw );
      end;
    end;
  end;

begin
  FRoot.FirstPoint := TPoint.Create(FBitMap.Width, FBitMap.Height);

  FRoot.DrawNormal(FGraphics);
  DrawPrimitive( FGraphics, FRoot, false );

  FRoot.DrawIndex( FFakeGraphics );
  DrawPrimitive( FFakeGraphics, FRoot, true );

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

function TDrawingPage.IsRootPrimitiveCord(const aX, aY: integer): boolean;
begin
  Result := GetPrimitiveByCoord( aX, aY ) = FRoot;
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

end.
