unit uDrawingCommand;

interface

uses uBase, uBaseCommand, Graphics, uExceptions, Variants, uDrawingPrimitive,
  uVarArrays;

type
  TDrawingCommandType = ( dctMoveFigure );

  TDrawingCommandClass = class of TBaseDrawingCommand;
  TBaseDrawingCommand = class( TBaseCommand )
  public
    procedure Execute( const aFigure : TFigure; const aData : Variant ); virtual; abstract;
  end;

  TMoveDrawingCommand = class ( TBaseDrawingCommand )
    procedure Execute( const aFigure : TFigure; const aData : Variant ); override;
  end;

  function DrawingCommandFactory ( const aType : TDrawingCommandType ) : TBaseDrawingCommand;

implementation

const
  CommandClasses : array[ TDrawingCommandType ] of TDrawingCommandClass = (
    TMoveDrawingCommand
  );

function DrawingCommandFactory ( const aType : TDrawingCommandType ) : TBaseDrawingCommand;
begin
  Result := CommandClasses[ aType ].Create;
end;

{ TMoveDrawingCommand }

procedure TMoveDrawingCommand.Execute(const aFigure: TFigure;
  const aData: Variant);
var
  Dx, Dy : Extended;
begin
  Dx := VA_Get( aData, 0 );
  Dy := VA_Get( aData, 1 );

  aFigure.Move( Dx, Dy );
end;

end.
