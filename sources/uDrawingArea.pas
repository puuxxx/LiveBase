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
      FStates : TAreaStates; // ��������� ������� ���������
      FRoot : TFigure;       // �������� ������
      FPage,                 // ����� ��� ���������
      FIndexPage             // ����� ��� ��������� ���������� �������
                   : TDrawingPage;
      // ��������� ���������
      FCoordConverter : ICoordConverter;

      // ���������� ������ � �����
      FSelectBorder,
      FSelectedFigure : TFigure;

      // ������ ��� ��������
      FHighlighted : TFigure;

      // ���������� ��� ����������� �������
      FX, FY : integer;

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

  // ������ �����, ������� ����� ��������
  AllowSelectFigureClasses : array[0..1] of TFigureClass = (
    TBox, TBackground
  );

  // ������ ����� ��� ������� ��������� �����
  AllowFigureBorderClasses : array[0..0] of TFigureClass = (
    TBox
  );

  // ������ �����, ������� ����� ����������
  AllowFigureMoveClasses : array[0..0] of TFigureClass = (
    TBox
  );

// ��������������� ��������� ��� ����������� �������������

function CanFigureMove ( const aFigure : TFigure ) : boolean;
var
  i : integer;
begin
  Result := false;
  for I := 0 to length( AllowFigureMoveClasses ) - 1 do begin
    if aFigure is AllowFigureMoveClasses[i] then begin
      Result := true;
      exit;
    end;
  end;
end;

function CanFigureSelect ( const aFigure : TFigure ) : boolean;
var
  i : integer;
begin
  Result := false;
  for I := 0 to length( AllowSelectFigureClasses ) - 1 do begin
    if aFigure is AllowSelectFigureClasses[i] then begin
      Result := true;
      exit;
    end;
  end;
end;

function CanFigureBorder ( const aFigure : TFigure ) : boolean;
var
  i : integer;
begin
  Result := false;
  for I := 0 to length( AllowFigureBorderClasses ) - 1 do begin
    if aFigure is AllowFigureBorderClasses[i] then begin
      Result := true;
      exit;
    end;
  end;
end;


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
  // ���������� ������ ��� ��������
  Fig := GetFigureByCoord( X, Y );

  // ��������� �������� ������
  SelectFigure( Fig );

  if CanFigureMove( Fig ) then AddState( asPrimMove );

  FX := X;
  FY := Y;
end;

procedure TDrawingArea.OnMouseMove( const aX, aY: integer );
begin
  FHighlighted := GetFigureByCoord( aX, aY );

  // ���������� ���������� ������
  if HasState( asPrimMove ) and Assigned( FSelectedFigure ) then begin
    FSelectedFigure.Move( FCoordConverter.ScreenToLog( aX - FX ),
      FCoordConverter.ScreenToLog( aY - FY ) );
    FEventModel.Event( EVENT_PLEASE_REPAINT );
  end;

  FX := aX;
  FY := aY;
end;

procedure TDrawingArea.OnMouseUp(Button: TMouseButton; X, Y: Integer);
begin
  DelState( asPrimMove );
end;

procedure TDrawingArea.OnNewSize(const aWidth, aHeight: integer);
begin
  FPage.SetScreenSize( aWidth, aHeight );
  FIndexPage.SetScreenSize( aWidth, aHeight );
end;


procedure TDrawingArea.SelectFigure(const aFigure: TFigure);
begin

  if not CanFigureSelect( aFigure ) then exit;

  // ������� ����� �� ���. ������
  if Assigned( FSelectedFigure ) then FSelectedFigure.TakeOutChild( FSelectBorder );
  FSelectedFigure := aFigure;
  // ��������� �����
  if CanFigureBorder( aFigure ) then aFigure.AddChildFigure( FSelectBorder );

  // �������� ��� ������������
  FEventModel.Event( EVENT_PLEASE_REPAINT );
end;

end.
