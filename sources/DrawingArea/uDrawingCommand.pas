unit uDrawingCommand;

interface

uses uBase, uBaseCommand, uGraphicPrimitive, Graphics, uExceptions, Variants;

type
  TDrawingCommandType = (dctBackground);

  TBaseDrawingCommand = class
  public
    procedure Execute(const aPrimitive: TGraphicPrimitive;
      const aData: variant); virtual; abstract;
  end;

  TChangeBackgroundColorCommand = class(TBaseDrawingCommand)
  private
    PrimitiveID: TGuid;
    OldBackgroundColor: TColor;
  public
    procedure Execute(const aPrimitive: TGraphicPrimitive; const aData: variant); override;
  end;

function DrawingCommandFactory(const aCommandType: TDrawingCommandType) : TBaseDrawingCommand;

implementation

const
  DrawingCommandsClasses: array [TDrawingCommandType] of TClass =
    (TChangeBackgroundColorCommand);

function DrawingCommandFactory(const aCommandType: TDrawingCommandType) : TBaseDrawingCommand;
begin
  Result := DrawingCommandsClasses[aCommandType].Create as TBaseDrawingCommand;
end;

{ TChangeBackgroundColorCommand }

procedure TChangeBackgroundColorCommand.Execute(const aPrimitive : TGraphicPrimitive; const aData: variant);
begin
  if VarIsClear( aData ) then ContractFailure;
  if aPrimitive = nil then ContractFailure;

  PrimitiveID := aPrimitive.ID;
  OldBackgroundColor := aPrimitive.BackgroundColor;

  aPrimitive.BackgroundColor := TColor( aData );
end;

end.
