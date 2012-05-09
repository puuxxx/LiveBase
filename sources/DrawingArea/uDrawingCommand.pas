unit uDrawingCommand;

interface

uses uBase, uBaseCommand, Graphics, uExceptions, Variants, uDrawingPrimitive,
  uVarArrays;

type
  TDrawingCommandType = ( dctMoveFigure, dctCreateFigure );

  TDrawingCommandClass = class of TBaseDrawingCommand;
  TBaseDrawingCommand = class( TBaseCommand )
  strict private
    FRoot : TFigure;
  protected
    FFigureID : string;
    FData : variant;
    property Root : TFigure read FRoot;
  public
    constructor Create( const aRoot : TFigure );
    procedure Execute(  const aFigure : TFigure; const aData : Variant ); virtual;
  end;

  // Команда перемещения фигуры. В execute ничего не делаем, только запоминаем данные
  TMoveDrawingCommand = class ( TBaseDrawingCommand )
  end;

  TCreateFigureDrawingCommad = class( TBaseDrawingCommand )
  public
    procedure Execute( const aFigure : TFigure; const aData : Variant ); override;
  end;



  function DrawingCommandFactory ( const aType : TDrawingCommandType; const aRoot : TFigure ) : TBaseDrawingCommand;

implementation

const
  CommandClasses : array[ TDrawingCommandType ] of TDrawingCommandClass = (
    TMoveDrawingCommand, TCreateFigureDrawingCommad
  );

function DrawingCommandFactory ( const aType : TDrawingCommandType; const aRoot : TFigure ) : TBaseDrawingCommand;
begin
  if aRoot = nil then ContractFailure;
  Result := CommandClasses[ aType ].Create( aRoot );
end;

{ TBaseDrawingCommand }

constructor TBaseDrawingCommand.Create(const aRoot: TFigure);
begin
  inherited Create;
  FRoot := aRoot;
  FFigureID := '';
  FData := unassigned;
end;

procedure TBaseDrawingCommand.Execute(const aFigure: TFigure;
  const aData: Variant);
begin
  if Assigned( aFigure ) then FFigureID := aFigure.IDAsStr;
  FData := aData;
end;

{ TCreateFigureDrawingCommad }

procedure TCreateFigureDrawingCommad.Execute( const aFigure : TFigure; const aData : Variant );
var
  F : TFigure;
begin
  inherited;
  F := FigureFactory( VA_Get( aData, 0 ) , Va_Get( aData, 1 ), Va_Get( aData, 2 ) );
  if Assigned( F ) then Root.AddChildFigure( F );
  FFigureID := F.IDAsStr;
end;

end.
