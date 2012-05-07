unit uDrawingPrimitive;

interface
  uses uBase, uEventModel, uDrawingSupport, Graphics, GdiPlus, uExceptions,
    System.SysUtils, uDrawingPage;

  {$M+}

  type
    TFigureType = ( ftNone, ftBackground, ftBox );

    TFigure = class;
    TFigureClass = class of TFigure;
    TFigureProc = reference to procedure ( aFigure : TFigure );
    TFigure = class( TBaseSubscriber )
    strict private
      // Координатные точки. Содержат основные координаты фигуры
      FPoints : TPoints;

      FParent,     // Родитель
      FFirstChild, // Первый потомок
      FNext,       // Следующая фигура в списке
      FPrev        // Предыдущая фигура в списке
            : TFigure;

      // Цвета
      FIndexColor,
      FBorderColor,
      FBackgroundColor : TColor;

      // Толщина рамки
      FBorderWidth : byte;

      //
      procedure SetBackgroundColor( aValue : TColor );
      function GetBackgroundColor : TColor;
      procedure SetBorderColor( aValue : TColor );
      function GetBorderColor : TColor;
      procedure SetBorderWidth( aValue : byte );
      function GetBorderWidth : byte;
      procedure SetIndexColor( aValue : TColor );
      function GetIndexColor : TColor;
      function GetNextFigure : TFigure;
      procedure SetNextFigure ( aValue : TFigure );
      function GetPrevFigure : TFigure;
      procedure SetPrevFigure ( aValue : TFigure );
      function GetParentFigure : TFigure;
      procedure SetParentFigure ( aValue : TFigure );
      function GetFirstChildFigure : TFigure;
      function GetLastChildFigure : TFigure;
    protected
      property BackgroundColor : TColor read GetBackgroundColor write SetBackgroundColor;
      property BorderColor : TColor read GetBorderColor write SetBorderColor;
      property BorderWidth : byte read GetBorderWidth write SetBorderWidth;

      // Дополнительные действия после создания
      procedure AfterCreate; virtual;
      procedure SetInitialCoord( const aX, aY : Extended ); virtual;
    public
      constructor Create;
      destructor Destroy; override;

      // Нормальное рисование и рисование индексным цветом
      procedure Draw( const aPage: TDrawingPage; const aIndexPage: TDrawingPage ); virtual;

      // Работа с потомками
      procedure AddChildFigure( const aFigure : TFigure );
      procedure RemoveChildFigure( aFigure : TFigure );
      procedure ClearChildrensFigure;

      // Обход всех элементов
      procedure ByPassChilds( const aProc : TFigureProc );

      // Положение среди списка фигур
      property ParentFigure : TFigure read GetParentFigure write SetParentFigure;
      property NextFigure : TFigure read GetNextFigure write SetNextFigure;
      property PrevFigure : TFigure read GetPrevFigure write SetPrevFigure;

      property FirstChildFigure : TFigure read GetFirstChildFigure;
      property LastChildFigure : TFigure read GetLastChildFigure;
      //
      property IndexColor : TColor read GetIndexColor write SetIndexColor;
      property Points : TPoints read FPoints;
    end;


    // Фон
    TBackground = class( TFigure )
    public
      procedure Draw( const aPage: TDrawingPage; const aIndexPage: TDrawingPage ); override;
    published
      property BackgroundColor;
    end;

    // Закрашенный квадрат
    TBox = class( TFigure )
    protected
      procedure SetInitialCoord( const aX, aY : Extended ); override;
      procedure AfterCreate; override;
    public
      procedure Draw( const aPage: TDrawingPage; const aIndexPage: TDrawingPage ); override;
    published
      property BackgroundColor;
      property BorderColor;
      property BorderWidth;
    end;

    function FigureFactory( const aFigureType : TFigureType ) : TFigure; overload;
    function FigureFactory( const aFigureType : TFigureType; const aX, aY : Extended ) : TFigure; overload;

implementation

uses
  uVertexPoint;

const
  DEFAULT_FIGURE_WIDTH = 100;
  DEFAULT_FIGURE_HEIGHT = 100;

function FigureFactory( const aFigureType : TFigureType ) : TFigure;
begin
  Result := FigureFactory( aFigureType, 0, 0 );
end;

function FigureFactory( const aFigureType : TFigureType; const aX, aY : Extended ) : TFigure;
const
  FigureClasses : array[TFigureType] of TFigureClass = (
    nil, TBackground, TBox
  );
var
  C : TFigureClass;
  F : TFigure;
begin
  F := nil;
  C := FigureClasses[ aFigureType ];
  if Assigned( C ) then begin
    F := C.Create;
    try
      F.AfterCreate;
      F.SetInitialCoord( aX, aY );
    except
      FreeAndNil( F );
      raise;
    end;
  end;

  Result := F;
end;

{ TFigure }

procedure TFigure.AddChildFigure(const aFigure: TFigure);
var
  Last : TFigure;
begin
  if not Assigned( aFigure ) then ContractFailure;
  if aFigure.ParentFigure <> nil then ContractFailure;

  aFigure.ParentFigure := Self;
  Last := LastChildFigure;
  if Assigned( Last ) then begin
    Last.NextFigure := aFigure;
    aFigure.PrevFigure := Last;
  end else begin
    FFirstChild := aFigure;
  end;

  aFigure.NextFigure := nil;
end;

procedure TFigure.AfterCreate;
begin
//
end;

procedure TFigure.ByPassChilds(const aProc: TFigureProc);

  procedure ByPass( const aFigure : TFigure );
  var
    F : TFigure;
  begin
    aProc( aFigure );
    F := aFigure.FirstChildFigure;
    while Assigned( F ) do begin
      if Assigned( F.FirstChildFigure ) then ByPass( F ) else aProc( F );
      F := F.NextFigure;
    end;
  end;

begin
  ByPass( Self );
end;

procedure TFigure.ClearChildrensFigure;
begin
  while Assigned( FirstChildFigure ) do begin
    RemoveChildFigure( FirstChildFigure );
  end;
end;

constructor TFigure.Create;
begin
  inherited;
  FPoints := TPoints.Create;
  FIndexColor := TDrawingFunc.GetNextIndexColor;
  FParent := nil;
  FFirstChild := nil;
  FNext := nil;
  FPrev := nil;
  FBackgroundColor := DefColor;
  FBorderColor := DefColor;
  FBorderWidth := 1;
end;

destructor TFigure.Destroy;
begin
  FreeANdNil( FPoints );
  ClearChildrensFigure;
  inherited;
end;

procedure TFigure.Draw(const aPage: TDrawingPage; const aIndexPage: TDrawingPage);
begin
//
end;

function TFigure.GetBackgroundColor: TColor;
begin
  Result := FBackgroundColor;
end;

function TFigure.GetBorderColor: TColor;
begin
  Result := FBorderColor;
end;

function TFigure.GetBorderWidth: byte;
begin
  Result := FBorderWidth;
end;

function TFigure.GetFirstChildFigure: TFigure;
begin
  Result := FFirstChild;
end;

function TFigure.GetIndexColor: TColor;
begin
  Result := FIndexColor;
end;

function TFigure.GetLastChildFigure: TFigure;
var
  F : TFigure;
begin
  F := FirstChildFigure;
  if Assigned( F ) then begin
    while Assigned( F.NextFigure ) do begin
      F := F.NextFigure;
    end;
  end;

  Result := F;
end;

function TFigure.GetNextFigure: TFigure;
begin
  Result := FNext;
end;

function TFigure.GetParentFigure: TFigure;
begin
  Result := FParent;
end;

function TFigure.GetPrevFigure: TFigure;
begin
  Result := FPrev;
end;

procedure TFigure.SetInitialCoord( const aX, aY: Extended );
begin
//
end;

procedure TFigure.RemoveChildFigure( aFigure: TFigure );
var
  Prev, Next : TFigure;
begin
  if not Assigned( aFigure ) then ContractFailure;
  if aFigure.ParentFigure <> Self then ContractFailure;

  Prev := aFigure.PrevFigure;
  Next := aFigure.NextFigure;
  if Assigned( Prev ) then Prev.NextFigure := Next;
  if Assigned( Next ) then Next.PrevFigure := Prev;

  if aFigure = FFirstChild then FFirstChild := Next;
  aFigure.Free;
end;

procedure TFigure.SetBackgroundColor(aValue: TColor);
begin
  FBackgroundColor := aValue;
end;

procedure TFigure.SetBorderColor(aValue: TColor);
begin
  FBorderColor := aValue;
end;

procedure TFigure.SetBorderWidth(aValue: byte);
begin
  FBorderWidth := aValue;
end;

procedure TFigure.SetIndexColor(aValue: TColor);
begin
  FIndexColor := aValue;
end;


procedure TFigure.SetNextFigure(aValue: TFigure);
begin
  FNext := aValue;
end;

procedure TFigure.SetParentFigure(aValue: TFigure);
begin
  if not Assigned( aValue ) then ContractFailure;

  FParent := aValue;
end;

procedure TFigure.SetPrevFigure(aValue: TFigure);
begin
  FPrev := aValue;
end;

{ TBackground }

procedure TBackground.Draw(const aPage: TDrawingPage; const aIndexPage: TDrawingPage);
begin
  aPage.Clear( BackgroundColor );
  aIndexPage.Clear( IndexColor );
end;

{ TBox }

procedure TBox.AfterCreate;
begin
  inherited;
  AddVertextPoints( Self );
end;

procedure TBox.Draw(const aPage: TDrawingPage; const aIndexPage: TDrawingPage);
begin
  if Points.Count <> 2 then ContractFailure;

  aPage.DrawFillRect( Points[0], Points[1], BackgroundColor, BorderColor, BorderWidth );
  aPage.DrawFillRect( Points[0], Points[1], IndexColor, IndexColor, BorderWidth );
end;

procedure TBox.SetInitialCoord( const aX, aY: Extended );
begin
  Points.Clear;
  Points.Add( aX - DEFAULT_FIGURE_WIDTH div 2, aY - DEFAULT_FIGURE_HEIGHT div 2 );
  Points.Add( aX + DEFAULT_FIGURE_WIDTH div 2, aY + DEFAULT_FIGURE_HEIGHT div 2 );
end;

end.
