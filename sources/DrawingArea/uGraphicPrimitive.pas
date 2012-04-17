unit uGraphicPrimitive;

interface

  uses uBase, uEventModel, Graphics, Windows, uExceptions, uExceptionCodes,
    SysUtils;

  type
    TPoints = class( TBaseObject )
    strict private
      FPoints : array of TPoint;
      FCount : integer;
      function GetPount( aIndex : integer ): TPoint;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Add( const aX, aY : integer );
      procedure Clear;
      property Count : integer read FCount;
      property Point[ aIndex : integer ] : TPoint read GetPount;
    end;

    TGraphicPrimitive = class ( TBaseSubscriber )
    strict private
      FBackgroundColor : TColor;
      FBorderColor : TColor;
      FName : string;
      FSelected : boolean;
      FParentPrimitive : TGraphicPrimitive;
      FNextPrimitive : TGraphicPrimitive;
      FPoints : TPoints;
    public
      constructor Create( const aParentPrimitive : TGraphicPrimitive );
      destructor Destroy; override;
      procedure Draw( const aBitmap : TBitMap ); virtual;

      property ParentPrimitive : TGraphicPrimitive read FParentPrimitive write FParentPrimitive;
      property NextPrimitive : TGraphicPrimitive read FNextPrimitive write FNextPrimitive;
      property BackGroundColor : TColor read FBackgroundColor write FBackgroundColor;
      property BorderColor : TColor read FBorderColor write FBorderColor;
      property ObjectName : string read FName write FName;
      property Selected : boolean read FSelected write FSelected;
    end;

    TSquare = class( TGraphicPrimitive )
    end;

    TCircle = class( TGraphicPrimitive )
    end;

implementation



{ TGraphicsPrimitive }

constructor TGraphicPrimitive.Create ( const aParentPrimitive : TGraphicPrimitive );
begin
  inherited Create;
  FBackgroundColor := clWhite;
  FBackgroundColor := clGray;
  FName := '';
  FSelected := false;
  FParentPrimitive := aParentPrimitive;
  FNextPrimitive := nil;
  FPoints := TPoints.Create;
end;

{ TPoints }

procedure TPoints.Add(const aX, aY: integer);
const
  AddCount = 5;
begin
  if FCount >= length( FPoints ) then begin
    SetLength( FPoints, FCount + AddCount );
  end;
  FPoints[ FCount ].X := aX;
  FPoints[ FCount ].Y := aY;
  Inc( FCount );
end;

procedure TPoints.Clear;
begin
  SetLength( FPoints, 0 );
  FPoints := nil;
  FCount := 0;
end;

constructor TPoints.Create;
begin
  inherited Create;
  Clear;
end;

destructor TPoints.Destroy;
begin
  Clear;
  inherited;
end;

function TPoints.GetPount(aIndex: integer): TPoint;
begin
  if ( aIndex >= 0 ) and ( aIndex < Count ) then begin
    Result := FPoints[ aIndex ];
  end else begin
    RaiseExeption( SYS_EXCEPT );
  end;
end;

destructor TGraphicPrimitive.Destroy;
begin
  FreeAndNil( FPoints );
  inherited;
end;

procedure TGraphicPrimitive.Draw(const aBitmap: TBitMap);
begin
//
end;

end.
