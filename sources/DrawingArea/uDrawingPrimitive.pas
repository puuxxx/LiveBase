unit uDrawingPrimitive;

interface
  uses uBase, uEventModel, uDrawingSupport, Graphics, GdiPlus, uExceptions,
    System.SysUtils, uDrawingPage;

  {$M+}

  type
    TFigureType = ( ftNone, ftBackground, ftBox, ftSelectBorder );

    TFigure = class;
    TFigureClass = class of TFigure;
    TFigureProc = reference to procedure ( const aFigure : TFigure );
    TByPassProc = reference to procedure( const aFigure : TFigure; var aStop : boolean );

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

      // Признак выделенного объекта
      FSelected : boolean;

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
      function GetSelected: boolean;
      procedure SetSelected(const Value: boolean);
    protected
      property BackgroundColor : TColor read GetBackgroundColor write SetBackgroundColor;
      property BorderColor : TColor read GetBorderColor write SetBorderColor;
      property BorderWidth : byte read GetBorderWidth write SetBorderWidth;

      // Дополнительные действия после создания
      procedure AfterCreate; virtual;
      procedure SetInitialCoord( const aX, aY : Extended ); virtual;
      // Полезные события
      procedure OnSelect; virtual;
      procedure OnUnSelect; virtual;
      procedure OnSetParent( const aParent : TFigure ); virtual;
    public
      constructor Create;
      destructor Destroy; override;

      // Нормальное рисование и рисование индексным цветом
      procedure Draw( const aPage: TDrawingPage; const aIndexPage: TDrawingPage ); virtual;

      // Работа с потомками
      procedure AddChildFigure( const aFigure : TFigure );
      procedure RemoveChildFigure( const aFigure : TFigure );
      procedure ClearChildrensFigure;
      procedure TakeOutChild( const aFigure : TFigure );

      // Обход всех элементов
      procedure ByPassChilds( const aProc : TFigureProc ); overload;
      procedure ByPassChilds( const aProc : TByPassProc ); overload;

      // Получаем крайнюю левую и икрайнюю правую точку фигуры для рисования рамки
      procedure GetRectPoints( var aP1, aP2 : TDrawingPoint ); virtual;

      // Положение среди списка фигур
      property ParentFigure : TFigure read GetParentFigure write SetParentFigure;
      property NextFigure : TFigure read GetNextFigure write SetNextFigure;
      property PrevFigure : TFigure read GetPrevFigure write SetPrevFigure;

      property FirstChildFigure : TFigure read GetFirstChildFigure;
      property LastChildFigure : TFigure read GetLastChildFigure;

      //
      property IndexColor : TColor read GetIndexColor write SetIndexColor;
      property Points : TPoints read FPoints;

      property Selected : boolean read GetSelected write SetSelected;
    end;


    // Фон
    TBackground = class( TFigure )
    public
      procedure Draw( const aPage: TDrawingPage; const aIndexPage: TDrawingPage ); override;
    published
      property BackgroundColor;
    end;

    // Рамка фигуры с квадратной рамкой выделения
    TSelectBorder = class( TFigure )
    strict private
      procedure CalcMyCoord;
    protected
      procedure AfterCreate ; override;
    public
      procedure GetRectPoints( var aP1, aP2 : TDrawingPoint ); override;
      procedure Draw( const aPage: TDrawingPage; const aIndexPage: TDrawingPage ); override;
    end;

    // Закрашенный квадрат
    TBox = class( TFigure )
    protected
      procedure SetInitialCoord( const aX, aY : Extended ); override;
    public
      procedure GetRectPoints( var aP1, aP2 : TDrawingPoint ); override;
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
  BORDER_IDENT = 6;

function FigureFactory( const aFigureType : TFigureType ) : TFigure;
begin
  Result := FigureFactory( aFigureType, 0, 0 );
end;

function FigureFactory( const aFigureType : TFigureType; const aX, aY : Extended ) : TFigure;
const
  FigureClasses : array[TFigureType] of TFigureClass = (
    nil, TBackground, TBox, TSelectBorder
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

procedure TFigure.ByPassChilds(const aProc: TByPassProc);

  procedure ByPass( const aFigure : TFigure; var aStop : boolean );
  var
    F : TFigure;
  begin
    aProc( aFigure, aStop );
    if aStop then exit;

    F := aFigure.FirstChildFigure;
    while Assigned( F ) do begin
      if Assigned( F.FirstChildFigure ) then begin
        ByPass( F, aStop )
      end else begin
        aProc( F, aStop );
      end;
      if aStop then exit;
      F := F.NextFigure;
    end;
  end;

  var
    Stop : boolean;
begin
  Stop := false;
  ByPass( Self, Stop );
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
  FSelected := false;
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

procedure TFigure.GetRectPoints(var aP1, aP2: TDrawingPoint);
begin
  //
end;

function TFigure.GetSelected: boolean;
begin
  Result := FSelected;
end;

procedure TFigure.OnSelect;
begin
//
end;

procedure TFigure.OnSetParent(const aParent: TFigure);
begin
//
end;

procedure TFigure.OnUnSelect;
begin
//
end;

procedure TFigure.SetInitialCoord( const aX, aY: Extended );
begin
//
end;

procedure TFigure.RemoveChildFigure( const aFigure: TFigure );
begin
  TakeOutChild( aFigure );
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
  FParent := aValue;
  OnSetParent( aValue );
end;

procedure TFigure.SetPrevFigure(aValue: TFigure);
begin
  FPrev := aValue;
end;

procedure TFigure.SetSelected(const Value: boolean);
begin
  FSelected := Value;
  if Value then OnSelect else OnUnSelect;
end;

procedure TFigure.TakeOutChild(const aFigure: TFigure);
var
  Prev, Next : TFigure;
begin
  if not Assigned( aFigure ) then ContractFailure;

  // aFigure нет в дочерних элементах Self
  if aFigure.ParentFigure <> Self then exit;

  Prev := aFigure.PrevFigure;
  Next := aFigure.NextFigure;
  if Assigned( Prev ) then Prev.NextFigure := Next;
  if Assigned( Next ) then Next.PrevFigure := Prev;

  if aFigure = FFirstChild then FFirstChild := Next;
  aFigure.ParentFigure := nil;
end;

{ TBackground }

procedure TBackground.Draw(const aPage: TDrawingPage; const aIndexPage: TDrawingPage);
begin
  BackgroundColor := clBlue;
  aPage.Clear( BackgroundColor );
  aIndexPage.Clear( IndexColor );
end;

{ TBox }

procedure TBox.Draw(const aPage: TDrawingPage; const aIndexPage: TDrawingPage);
begin
  if Points.Count <> 2 then ContractFailure;

  aPage.DrawFillRect( Points[0], Points[1], BackgroundColor, BorderColor, BorderWidth );
  aIndexPage.DrawFillRect( Points[0], Points[1], IndexColor, IndexColor, BorderWidth );
end;

procedure TBox.GetRectPoints(var aP1, aP2: TDrawingPoint);
begin
  aP1 := Points[0];
  aP2 := Points[1];
end;

procedure TBox.SetInitialCoord( const aX, aY: Extended );
begin
  Points.Clear;
  Points.Add( aX - DEFAULT_FIGURE_WIDTH div 2, aY - DEFAULT_FIGURE_HEIGHT div 2 );
  Points.Add( aX + DEFAULT_FIGURE_WIDTH div 2, aY + DEFAULT_FIGURE_HEIGHT div 2 );
end;

{ TSelectBorder }

procedure TSelectBorder.CalcMyCoord;
var
  P1, P2 : TDrawingPoint;
begin
  GetRectPoints( P1, P2 );
  Points.Clear;
  Points.Add( P1 );
  Points.Add( P2 );
end;

procedure TSelectBorder.Draw(const aPage, aIndexPage: TDrawingPage);
begin
  if ParentFigure = nil then ContractFailure;

  CalcMyCoord;

  aPage.DrawRect( Points[0], Points[1], BorderColor, BorderWidth );
end;

procedure TSelectBorder.GetRectPoints(var aP1, aP2: TDrawingPoint);
var
  P1, P2 : TDrawingPoint;
begin
  ParentFigure.GetRectPoints( p1, p2 );

  P1.X := P1.X - BORDER_IDENT;
  P1.Y := P1.Y - BORDER_IDENT;
  P2.X := P2.X + BORDER_IDENT;
  P2.Y := P2.Y + BORDER_IDENT;

  aP1 := P1; aP2 := P2;
end;

procedure TSelectBorder.AfterCreate;
begin
  AddVertextPoints( Self );
end;

end.
