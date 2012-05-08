unit uDrawingArea;

interface
  uses {$IFDEF DEBUG} CodeSiteLogging, {$ENDIF}
    SysUtils, uBase, uEventModel, Graphics, System.UITypes,
    uDrawingCommand, System.Generics.Collections,
    uDrawingEvent, Classes, System.Types, uDrawingPrimitive, uDrawingPage;


  type
    TAreaState = ( asDrawSelect, asPrimMove );
    TAreaStates = set of TAreaState;

    TDrawingArea = class ( TBaseSubscriber )
    strict private
      FEventModel : TEventModel;
      FCommands : TObjectList<TBaseDrawingCommand>;
      FStates : TAreaStates; // состояния области рисования
      FRoot : TFigure;       // корневая фигурв
      FPage,                 // Холст для рисования
      FIndexPage             // Холст для рисования индексными цветами
                   : TDrawingPage;
      // конвертер координат
      FCoordConverter : ICoordConverter;

      // выделенная фигура и рамка
      FSelectBorder,
      FSelectedFigure : TFigure;

      // Фигура под курсором
      FHighlighted : TFigure;

      function GetBitmap: TBitmap;

      procedure AddState ( const aState : TAreaState );
      procedure DelState ( const aState : TAreaState );
      function HasState ( const aState : TAreaState ) : boolean;

      function GetFigureByCoord( const aX, aY : integer ) : TFigure;
      procedure SelectFigure( const aFigure : TFigure );
    public
      constructor Create( const aEventModel : TEventModel );
      destructor Destroy; override;

      procedure OnNewSize( const aWidth, aHeight : integer );
      procedure OnMouseMove( const aX, aY : integer );
      procedure OnMouseDown( Button: TMouseButton; X, Y: Integer );
      procedure OnMouseUp( Button: TMouseButton; X, Y: Integer );

      procedure CreateFigure( const aType : TFigureType; const aX, aY : integer );

      property AreaBitmap : TBitmap read GetBitmap;
    end;

implementation

const
  COMMANDS_LIST_MAX_SIZE = 10;
  CONTROL_MOUSE_BUTTON : TMouseButton = TMouseButton.mbLeft;

{ TDrawingArea }

procedure TDrawingArea.AddState(const aState: TAreaState);
begin
  FStates := FStates + [ aState ];
end;

constructor TDrawingArea.Create( const aEventModel : TEventModel );
begin
  inherited Create;
  FEventModel := aEventModel;
  FCommands := TObjectList<TBaseDrawingCommand>.Create;
  FStates := [];

  FCoordConverter := TCoordConverter.Create;

  FPage := TDrawingPage.Create( FCoordConverter );
  FIndexPage := TDrawingPage.Create( FCoordConverter );

  OnNewSize( 10, 10 );

  FRoot := FigureFactory( ftBackground );
  FSelectBorder := FigureFactory( ftSelectBorder );
  FHighlighted := nil;
end;

procedure TDrawingArea.CreateFigure( const aType: TFigureType;
  const aX, aY: integer );
var
  F : TFigure;
begin
  F := FigureFactory( aType, FCoordConverter.ScreenToLog( aX ),
    FCoordConverter.ScreenToLog( aY ) );
  if Assigned( F ) then FRoot.AddChildFigure( F );
end;

procedure TDrawingArea.DelState(const aState: TAreaState);
begin
  FStates := FStates - [ aState ];
end;

destructor TDrawingArea.Destroy;
begin
  FreeAndNil( FPage );
  FreeANdNil( FIndexPage );
  FCoordConverter := nil;
  FreeAndNil( FSelectBorder );
  inherited;
end;

function TDrawingArea.GetBitmap: TBitmap;
begin
  FRoot.ByPassChilds( procedure( const aFigure : TFigure ) begin
    aFigure.Draw( FPage, FIndexPage );
  end );

  Result := FPage.GetBitMap;
end;

function TDrawingArea.GetFigureByCoord(const aX, aY: integer): TFigure;
var
  Color : TColor;
  F : TFigure;
begin
  Color := FIndexPage.GetScreenColor( aX, aY );
  if Color = BAD_COLOR then exit;

  F := nil;
  FRoot.ByPassChilds( procedure( const aFigure : TFigure; var aStop : boolean ) begin
    aStop := aFigure.IndexColor = Color;
    if aStop then F := aFigure;
  end );

  if F = nil then F := FRoot;

  Result := F;
end;

function TDrawingArea.HasState(const aState: TAreaState): boolean;
begin
  Result := aState in FStates;
end;

procedure TDrawingArea.OnMouseDown(Button: TMouseButton; X, Y: Integer);
var
  Fig : TFigure;
begin
  // определяем фигуру под курсором
  Fig := GetFigureByCoord( X, Y );

  // попробуем выделить фигуру
  SelectFigure( Fig );

end;

procedure TDrawingArea.OnMouseMove( const aX, aY: integer );
begin
  FHighlighted := GetFigureByCoord( aX, aY );
end;

procedure TDrawingArea.OnMouseUp(Button: TMouseButton; X, Y: Integer);
begin
//
end;

procedure TDrawingArea.OnNewSize(const aWidth, aHeight: integer);
begin
  FPage.SetScreenSize( aWidth, aHeight );
  FIndexPage.SetScreenSize( aWidth, aHeight );
end;


procedure TDrawingArea.SelectFigure(const aFigure: TFigure);
const
  // классы фигур, которые можно выделять
  AllowSelectFigureClasses : array[0..1] of TFigureClass = (
    TBox, TBackground
  );

  // классы фигур для которых разрешены рамки
  AllowFigureBorderClasses : array[0..0] of TFigureClass = (
    TBox
  );

var
  i : integer;
  AllowSelect, AllowBorder : boolean;
begin
  // можно ли выделять тек. фигуру
  for I := 0 to length( AllowSelectFigureClasses )-1 do begin
    AllowSelect := aFigure is AllowSelectFigureClasses[i];
    if AllowSelect then break;
  end;

  if not AllowSelect then exit;

  // можно ли фигуре устанавливать рамку
  for I := 0 to length( AllowFigureBorderClasses )-1 do begin
    AllowBorder := aFigure is AllowFigureBorderClasses[i];
    if AllowBorder then break;
  end;

  // убираем рамку из тек. фигуры
  if Assigned( FSelectedFigure ) then FSelectedFigure.TakeOutChild( FSelectBorder );
  FSelectedFigure := aFigure;
  if AllowBorder then aFigure.AddChildFigure( FSelectBorder );

  // попросим нас перерисовать
  FEventModel.Event( EVENT_PLEASE_REPAINT );
end;

end.
