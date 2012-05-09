unit uDrawingArea;

interface
  uses {$IFDEF DEBUG} CodeSiteLogging, {$ENDIF}
    SysUtils, uBase, uEventModel, Graphics, System.UITypes,
    uDrawingCommand, System.Generics.Collections,
    uDrawingEvent, Classes, System.Types, uDrawingPrimitive, uDrawingPage,
    uVarArrays;


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
      FStartMoveX, FStartMoveY : integer;
      FCurX, FCurY : integer;

      function GetBitmap: TBitmap;

      procedure AddState ( const aState : TAreaState );
      procedure DelState ( const aState : TAreaState );
      function HasState ( const aState : TAreaState ) : boolean;

      function GetFigureByCoord( const aX, aY : integer ) : TFigure;
      procedure SelectFigure( const aFigure : TFigure );
      procedure ExecuteCommand( const aCommandType : TDrawingCommandType;
        const aFigure : TFigure; const aData : Variant );
    public
      constructor Create( const aEventModel : TEventModel );
      destructor Destroy; override;

      procedure OnNewSize( const aWidth, aHeight : integer );
      procedure OnMouseMove( const aX, aY : integer );
      procedure OnMouseDown( Button: TMouseButton; X, Y: Integer );
      procedure OnMouseUp( Button: TMouseButton; aX, aY: Integer );

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
begin
  ExecuteCommand( dctCreateFigure, nil, VA_Of( [ aType,
    FCoordConverter.ScreenToLog( aX ), FCoordConverter.ScreenToLog( aY ) ] ) );
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

procedure TDrawingArea.ExecuteCommand(const aCommandType: TDrawingCommandType;
  const aFigure: TFigure; const aData: Variant);
var
  Cmd : TBaseDrawingCommand;
begin
  Cmd := DrawingCommandFactory( aCommandType, FRoot );
  Cmd.Execute( aFigure, aData );

  if FCommands.Count > COMMANDS_LIST_MAX_SIZE then begin
    FCommands.Delete( FCommands.Count - 1 );
  end;

  FCommands.Add( Cmd );
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

  F := nil;
  if Color <> BAD_COLOR then begin
    FRoot.ByPassChilds( procedure( const aFigure : TFigure; var aStop : boolean ) begin
      aStop := aFigure.IndexColor = Color;
      if aStop then F := aFigure;
    end );
  end;

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

  if CanFigureMove( Fig ) then begin
    AddState( asPrimMove );
    FStartMoveX := X;
    FStartMoveY := Y;
  end;

  FCurX := X;
  FCurY := Y;
end;

procedure TDrawingArea.OnMouseMove( const aX, aY: integer );
begin
  FHighlighted := GetFigureByCoord( aX, aY );

  // ���������� ���������� ������
  if HasState( asPrimMove ) and Assigned( FSelectedFigure ) then begin
    FSelectedFigure.Move( FCoordConverter.ScreenToLog( aX - FCurX ),
      FCoordConverter.ScreenToLog( aY - FCurY ) );
    FEventModel.Event( EVENT_PLEASE_REPAINT );
  end;

  FCurX := aX;
  FCurY := aY;
end;

procedure TDrawingArea.OnMouseUp(Button: TMouseButton; aX, aY: Integer);
begin
  if HasState( asPrimMove ) then begin
    ExecuteCommand( dctMoveFigure, FSelectedFigure,
      VA_Of( [ FCoordConverter.ScreenToLog( aX - FStartMoveX ),
               FCoordConverter.ScreenToLog( aY - FStartMoveY ) ] ) );
    DelState( asPrimMove );
  end;
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
