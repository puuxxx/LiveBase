unit uDrawingArea;

interface
  uses SysUtils, uBase, uEventModel, Graphics, System.UITypes, uDrawingPage,
    uDrawingCommand, uGraphicPrimitive, System.Generics.Collections,
    uDrawingEvent;


  type
    TDrawingArea = class ( TBaseSubscriber )
    strict private
      FEventModel : TEventModel;
      FPage : TDrawingPage;
      FCommands : TObjectList<TBaseDrawingCommand>;

      procedure ExecuteCommand( const aCommandType : TDrawingCommandType;
        aPrimitive : TGraphicPrimitive; const aValue : variant );

      function GetBitmap: TBitmap;
      function GetBackgroundColor: TColor;
      procedure SetBackgroundColor(const Value: TColor);
    public
      constructor Create( const aEventModel : TEventModel );
      destructor Destroy; override;

      procedure OnNewSize( const aWidth, aHeight : integer );

      property BackgroundColor : TColor read GetBackgroundColor write SetBackgroundColor;
      property AreaBitmap : TBitmap read GetBitmap;
    end;

implementation

const
  COMMANDS_LIST_MAX_SIZE = 10;

{ TDrawingArea }

constructor TDrawingArea.Create( const aEventModel : TEventModel );
begin
  inherited Create;
  FEventModel := aEventModel;
  FPage := TDrawingPage.Create;
  FCommands := TObjectList<TBaseDrawingCommand>.Create;
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
  EventData : TDrawingEventData;
begin
  Command := DrawingCommandFactory( aCommandType );
  Command.Execute( aPrimitive, [ aValue ] );

  FCommands.Insert( 0, Command );
  if FCommands.Count > COMMANDS_LIST_MAX_SIZE then begin
    FCommands.Delete( FCommands.Count - 1 );
  end;

  EventData := TDrawingEventData.Create;
  EventData.Primitive := aPrimitive;
  EventData.Color := TColor( aValue );
  try
    FEventModel.Event( CHANGE_BACKGROUND_COLOR, EventData );
  finally
    FreeANdNil( EventData );
  end;
end;

function TDrawingArea.GetBackgroundColor: TColor;
begin
  Result := FPage.BackgroundPrimitive.BackgroundColor;
end;

function TDrawingArea.GetBitmap: TBitmap;
begin
  Result := FPage.GetBitmap;
end;

procedure TDrawingArea.OnNewSize(const aWidth, aHeight: integer);
begin
  FPage.NewSize( aWidth, aHeight );
end;

procedure TDrawingArea.SetBackgroundColor(const Value: TColor);
begin
  ExecuteCommand( dctBackground, FPage.BackgroundPrimitive, Value );
end;


end.
