unit uDrawingEvent;

interface

  uses uEventModel, uGraphicPrimitive, Graphics, uDrawingCommand, uVarArrays,
    uExceptions;

  const
    EVENT_BACKGROUND_COLOR = 'BACKGROUND_COLOR';

  type

    TDrawingCommandData = class
    public
      class function CreateData( const aPrimitive: TGraphicPrimitive; const aData : Variant ) : Variant; overload;
      class function CreateData( const aPrimitive: TGraphicPrimitive; const aData : array of variant ) : Variant; overload;

      class function ExtractPrimitive( const aData : Variant ) : TGraphicPrimitive;
      class function ExtractColor( const aData : Variant ) : TColor;
    end;

implementation


class function TDrawingCommandData.CreateData(
  const aPrimitive: TGraphicPrimitive; const aData: Variant): Variant;
begin
  if aPrimitive = nil then ContractFailure;

  Result := VA_Of( [ Integer( aPrimitive ), aData ] );
end;

class function TDrawingCommandData.CreateData(
  const aPrimitive: TGraphicPrimitive; const aData: array of variant): Variant;
begin
  Result := TDrawingCommandData.CreateData( aPrimitive, VA_Of( aData ) );
end;

class function TDrawingCommandData.ExtractColor(const aData: Variant): TColor;
begin
  Result := TColor( VA_Get( aData, 1, clRed ) );
end;

class function TDrawingCommandData.ExtractPrimitive(
  const aData: Variant): TGraphicPrimitive;
begin
  Result := TGraphicPrimitive( Integer( VA_Get( aData, 0, 0 ) ) );
  if Result = nil then ContractFailure;
end;

end.
