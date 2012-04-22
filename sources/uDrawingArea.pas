unit uDrawingArea;

interface
  uses SysUtils, uBase, uEventModel, Graphics, System.UITypes, uDrawingPage;


  type
    TDrawingArea = class ( TBaseSubscriber )
    strict private
      FEventModel : TEventModel;
      FPage : TDrawingPage;
    private
      function GetBitmap: TBitmap;
    public
      constructor Create( const aEventModel : TEventModel );
      destructor Destroy; override;

      procedure OnNewSize( const aWidth, aHeight : integer );

      property AreaBitmap : TBitmap read GetBitmap;
    end;

implementation



{ TDrawingArea }

constructor TDrawingArea.Create( const aEventModel : TEventModel );
begin
  inherited Create;
  FEventModel := aEventModel;
  FPage := TDrawingPage.Create;
end;

destructor TDrawingArea.Destroy;
begin
  FreeANdNil( FPage );
  inherited;
end;

function TDrawingArea.GetBitmap: TBitmap;
begin
  Result := FPage.GetBitmap;
end;

procedure TDrawingArea.OnNewSize(const aWidth, aHeight: integer);
begin
  FPage.NewSize( aWidth, aHeight );
end;

end.
