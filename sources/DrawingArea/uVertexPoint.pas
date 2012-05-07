unit uVertexPoint;

interface

  uses uDrawingSupport, uDrawingPrimitive, uDrawingPage, uExceptions;

  type
    TVertextPointClass = class of TVertexPoint;
    TVertexPoint = class( TFigure )
    protected
      function GetPoint : TDrawingPoint; virtual; abstract;
      procedure SetInitialCoord( const aX, aY : Extended ); override;
    public
      procedure Draw( const aPage: TDrawingPage; const aIndexPage: TDrawingPage ); override;
    published
      property BackgroundColor;
      property BorderColor;
      property BorderWidth;
    end;

    TTopLeftVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;

    TTopCenterVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;

    TTopRightVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;

    TBottomLeftVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;

    TBottomCenterVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;

    TBottomRightVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;

    TLeftCenterVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;

    TRightRightVertexPoint = class( TVertexPoint )
    protected
      function GetPoint : TDrawingPoint; override;
    end;


    procedure AddVertextPoints( const aFigure : TFigure );

implementation

const
  DEFAULT_POINT_WIDTH = 3;
  DEFAULT_POINT_HEIGHT = 3;

procedure AddVertextPoints( const aFigure : TFigure );
const
  PointClasses : array[0..3] of TVertextPointClass = (
    TTopLeftVertexPoint, TTopRightVertexPoint, TBottomLeftVertexPoint, TBottomRightVertexPoint
  );
var
  i : integer;
begin
  if not Assigned( aFigure ) then ContractFailure;

  for I := 0 to length( PointClasses ) - 1 do begin
    aFigure.AddChildFigure( PointClasses[i].Create );
  end;
end;


{ TVertextPoint }

procedure TVertexPoint.Draw(const aPage: TDrawingPage; const aIndexPage: TDrawingPage);
var
  P : TDrawingPoint;
begin
  if not Assigned( ParentFigure ) then ContractFailure;
  if ParentFigure.Points.Count <> 2 then ContractFailure;

  P := GetPoint;
  SetInitialCoord( P.X, P.Y );

  aPage.DrawFillRect( Points[0], Points[1], BackgroundColor, BorderColor, 1 );
  aPage.DrawFillRect( Points[0], Points[1], IndexColor, IndexColor, 1 );
end;

procedure TVertexPoint.SetInitialCoord(const aX, aY: Extended);
begin
  Points.Clear;
  Points.Add( aX - DEFAULT_POINT_WIDTH div 2, aY - DEFAULT_POINT_HEIGHT div 2 );
  Points.Add( aX + DEFAULT_POINT_WIDTH div 2, aY + DEFAULT_POINT_HEIGHT div 2 );
end;

{ TTopLeftVertexPoint }

function TTopLeftVertexPoint.GetPoint: TDrawingPoint;
begin
  Result := ParentFigure.Points[0];
end;

{ TTopCenterVertexPoint }

function TTopCenterVertexPoint.GetPoint: TDrawingPoint;
begin
  //Result := TDrawingPoint.Create( ParentFigure.Points[0].X div 2, ParentFigure.Points[0].Y );
end;

{ TTopRightVertexPoint }

function TTopRightVertexPoint.GetPoint: TDrawingPoint;
begin
  Result := TDrawingPoint.Create( ParentFigure.Points[1].X, ParentFigure.Points[0].Y );
end;

{ TBottomLeftVertexPoint }

function TBottomLeftVertexPoint.GetPoint: TDrawingPoint;
begin
  Result := TDrawingPoint.Create( ParentFigure.Points[0].X, ParentFigure.Points[1].Y );
end;

{ TBottomCenterVertexPoint }

function TBottomCenterVertexPoint.GetPoint: TDrawingPoint;
begin
  //Result := TDrawingPoint.Create( ParentFigure.Points[].X, ParentFigure.Points[1].Y );
end;

{ TBottomRightVertexPoint }

function TBottomRightVertexPoint.GetPoint: TDrawingPoint;
begin
  Result := ParentFigure.Points[1];
end;

{ TLeftCenterVertexPoint }

function TLeftCenterVertexPoint.GetPoint: TDrawingPoint;
begin
//
end;

{ TRightRightVertexPoint }

function TRightRightVertexPoint.GetPoint: TDrawingPoint;
begin
//
end;

end.
