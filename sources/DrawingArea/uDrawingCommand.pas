unit uDrawingCommand;

interface

  uses uBase, uBaseCommand, uGraphicPrimitive, Graphics, uExceptions;

  type
    TBaseDrawingCommand = class( TBaseCommand )
    end;

    TChangeBackgroundColorCommand = class( TBaseDrawingCommand )
    private
      PrimitiveID : TGuid;
      OldBackgroundColor : TColor;
    public
      procedure Execute( const aData : variant ); override;
    end;


    function DrawingCommandFactory : TBaseDrawingCommand;
    function DrawingCommandDataFactory : Variant;

implementation

function DrawingCommandFactory : TBaseDrawingCommand;
begin
  //
end;

function DrawingCommandDataFactory : Variant;
begin
  //
end;

{ TChangeBackgroundColorCommand }

procedure TChangeBackgroundColorCommand.Execute( const aData :  Variant );
var
  Color : TColor;
  Primitive : TGraphicPrimitive;
begin

{
  if aData = nil then ContractFailure;
  if not ( aData is TColorCommandData ) then ContractFailure;

  Data := aData as TColorCommandData;

  PrimitiveID := Data.Primitive.ID;
  OldBackgroundColor := Data.Primitive.BackgroundColor;

  Data.Primitive.BackgroundColor := Data.Color;
}
end;

end.
