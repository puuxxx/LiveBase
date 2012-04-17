unit uDrawingArea;

interface
uses SysUtils, uBase, uEventModel, Graphics, System.UITypes;

type
  TDrawingArea = class ( TBaseSubscriber )
  strict private
    FWidth, FHeight : integer;
    FEventModel : TEventModel;
    FActive : boolean;
    FLastAreaBitmap : TBitMap;

  private
    function GetBitmap: TBitmap;
  public
    constructor Create( const aEventModel : TEventModel; const aInitW, aInitH : integer );
    destructor Destroy; override;

    procedure OnMouseMove( const aX, aY : integer );
    procedure OnMouseLeave;
    procedure OnMouseDown( const aButton: TMouseButton; const aX, aY: Integer);
    procedure OnMouseUp ( const aButton: TMouseButton; aX, aY: Integer );
    procedure OnMouseClick( const aX, aY : integer );
    procedure OnMouseDblClick( const aX, aY : integer );

    property AreaBitmap : TBitmap read GetBitmap;
  end;

implementation

{ TDrawingArea }

constructor TDrawingArea.Create( const aEventModel : TEventModel; const aInitW, aInitH: integer );
begin
  inherited Create;
  FWidth := aInitW;
  FHeight := aInitH;
  FActive := false;
  FEventModel := aEventModel;
  FLastAreaBitmap := nil;
end;

destructor TDrawingArea.Destroy;
begin

  inherited;
end;

function TDrawingArea.GetBitmap: TBitmap;
begin
  Result := nil;
end;

procedure TDrawingArea.OnMouseClick(const aX, aY: integer);
begin
//
end;

procedure TDrawingArea.OnMouseDblClick(const aX, aY: integer);
begin
//
end;

procedure TDrawingArea.OnMouseDown(const aButton: TMouseButton; const aX,
  aY: Integer);
begin
//
end;

procedure TDrawingArea.OnMouseLeave;
begin
//
end;

procedure TDrawingArea.OnMouseMove(const aX, aY: integer);
begin
//
end;

procedure TDrawingArea.OnMouseUp(const aButton: TMouseButton; aX, aY: Integer);
begin
//
end;

end.
