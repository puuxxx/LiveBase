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
      FCoordConverter : ICoordConverter;

      function GetBitmap: TBitmap;

      procedure AddState ( const aState : TAreaState );
      procedure DelState ( const aState : TAreaState );
      function HasState ( const aState : TAreaState ) : boolean;
    public
      constructor Create( const aEventModel : TEventModel );
      destructor Destroy; override;

      procedure OnNewSize( const aWidth, aHeight : integer );
      procedure OnMouseMove( const aX, aY : integer );
      procedure OnMouseDown( Button: TMouseButton; X, Y: Integer );
      procedure OnMouseUp( Button: TMouseButton; X, Y: Integer );

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

  FRoot := TBackground.Create;
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
  inherited;
end;

function TDrawingArea.GetBitmap: TBitmap;
begin
  FRoot.ByPassChilds( procedure( aFigure : TFigure ) begin
    aFigure.Draw( FPage );
    aFigure.DrawIndex( FIndexPage );
  end );

  Result := FPage.GetBitMap;
end;

function TDrawingArea.HasState(const aState: TAreaState): boolean;
begin
  Result := aState in FStates;
end;

procedure TDrawingArea.OnMouseDown(Button: TMouseButton; X, Y: Integer);
begin
 //
end;

procedure TDrawingArea.OnMouseMove( const aX, aY: integer );
begin
//
end;

procedure TDrawingArea.OnMouseUp(Button: TMouseButton; X, Y: Integer);
begin
//
end;

procedure TDrawingArea.OnNewSize(const aWidth, aHeight: integer);
begin
  FPage.SetScreenSize( aWidth, aHeight );
end;


end.
