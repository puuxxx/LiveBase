﻿unit uDrawingArea;

interface
  uses SysUtils, uBase, uEventModel, Graphics, System.UITypes, uDrawingPage,
    uDrawingCommand, uGraphicPrimitive, System.Generics.Collections,
    uDrawingEvent, Classes, System.Types;


  type
    TAreaState = ( asDrawSelect );
    TAreaStates = set of TAreaState;

    TDrawingArea = class ( TBaseSubscriber )
    strict private
      FEventModel : TEventModel;
      FPage : TDrawingPage;
      FCommands : TObjectList<TBaseDrawingCommand>;
      FLightedPrimitive : TGraphicPrimitive;   // примитив под курсором
      FStates : TAreaStates;

      procedure ExecuteCommand( const aCommandType : TDrawingCommandType;
        aPrimitive : TGraphicPrimitive; const aValue : variant );

      function GetBitmap: TBitmap;
      function GetBackgroundColor: TColor;
      procedure SetBackgroundColor(const Value: TColor);

      procedure AddState ( const aState : TAreaState );
      procedure DelState ( const aState : TAreaState );
      function HasState ( const aState : TAreaState ) : boolean;
    public
      constructor Create( const aEventModel : TEventModel );
      destructor Destroy; override;

      procedure OnNewSize( const aWidth, aHeight : integer );
      procedure OnMouseMove( const aX, aY : integer );
      procedure OnMouseDown( Button: TMouseButton; X, Y: Integer );
      procedure OnMouseUp( Button: TMouseButton; Shift: TShiftState; X, Y: Integer );

      function FindPrimitive( const aID : string ) : TGraphicPrimitive;

      property BackgroundColor : TColor read GetBackgroundColor write SetBackgroundColor;
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
  FPage := TDrawingPage.Create;
  FCommands := TObjectList<TBaseDrawingCommand>.Create;
  FLightedPrimitive := FPage.RootPrimitive;
  FStates := [];
end;

procedure TDrawingArea.DelState(const aState: TAreaState);
begin
  FStates := FStates - [ aState ];
end;

destructor TDrawingArea.Destroy;
begin
  FreeANdNil( FPage );
  inherited;
end;

procedure TDrawingArea.ExecuteCommand( const aCommandType : TDrawingCommandType;
  aPrimitive : TGraphicPrimitive; const aValue : variant );
var
  Command : TBaseDrawingCommand;

begin
  Command := DrawingCommandFactory( aCommandType );
  Command.Execute( aPrimitive, aValue );

  FCommands.Insert( 0, Command );
  if FCommands.Count > COMMANDS_LIST_MAX_SIZE then begin
    FCommands.Delete( FCommands.Count - 1 );
  end;
end;

function TDrawingArea.FindPrimitive(const aID: string): TGraphicPrimitive;
begin
  Result := FPage.GetPrimitiveByID( aID );
end;

function TDrawingArea.GetBackgroundColor: TColor;
begin
  Result := FPage.RootPrimitive.BackgroundColor;
end;

function TDrawingArea.GetBitmap: TBitmap;
begin
  Result := FPage.GetBitmap;
end;

function TDrawingArea.HasState(const aState: TAreaState): boolean;
begin
  Result := aState in FStates;
end;

procedure TDrawingArea.OnMouseDown(Button: TMouseButton; X, Y: Integer);
begin
  if Button = CONTROL_MOUSE_BUTTON then begin
    if FPage.IsRootPrimitiveCord( X, Y ) then begin
      AddState( asDrawSelect );
      FPage.NeedToDrawSelect := true;
      FPage.SelectPrimitive.FirstPoint := TPoint.Create( X, Y );
      FPage.SelectPrimitive.SecondPoint := FPage.SelectPrimitive.FirstPoint;
    end;
  end;
end;

procedure TDrawingArea.OnMouseMove(const aX, aY: integer);
begin
  FLightedPrimitive := FPage.GetPrimitiveByCoord( aX, aY );
  if HasState( asDrawSelect ) then begin
    FPage.SelectPrimitive.SecondPoint := TPoint.Create( aX, aY );
    FEventModel.Event( EVENT_PLEASE_REPAINT );
  end;
end;

procedure TDrawingArea.OnMouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if HasState( asDrawSelect ) then begin
    DelState( asDrawSelect );
    FPage.NeedToDrawSelect := false;
    FEventModel.Event( EVENT_PLEASE_REPAINT );
  end;
end;

procedure TDrawingArea.OnNewSize(const aWidth, aHeight: integer);
begin
  FPage.NewSize( aWidth, aHeight );
end;

procedure TDrawingArea.SetBackgroundColor(const Value: TColor);
begin
  ExecuteCommand( dctBackground, FPage.RootPrimitive, Value );

  // информируем о изменении цвета фона
  FEventModel.Event( EVENT_BACKGROUND_COLOR,
    TDrawingCommandData.CreateData( FPage.RootPrimitive.IDAsStr, Value ) );
end;


end.
