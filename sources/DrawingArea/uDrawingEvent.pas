unit uDrawingEvent;

interface

  uses uEventModel, uGraphicPrimitive, Graphics, uDrawingCommand, uVarArrays,
    uExceptions, Variants;

  const
    EVENT_BACKGROUND_COLOR = 'BACKGROUND_COLOR';

  type

    TDrawingCommandData = class
    public
      class function CreateData( const aPrimitiveID: string; const aData : Variant ) : Variant; overload;
      class function CreateData( const aPrimitiveID: string; const aData : array of variant ) : Variant; overload;

      class function ExtractPrimitiveID( const aData : Variant ) : string;
      class function ExtractColor( const aData : Variant ) : TColor;
    end;

implementation


class function TDrawingCommandData.CreateData(
  const aPrimitiveID: string; const aData: Variant): Variant;
begin
  Result := VA_Of( [ aPrimitiveID, aData ] );
end;

class function TDrawingCommandData.CreateData(
  const aPrimitiveID: string; const aData: array of variant): Variant;
begin
  Result := TDrawingCommandData.CreateData( aPrimitiveID, VA_Of( aData ) );
end;

class function TDrawingCommandData.ExtractColor(const aData: Variant): TColor;
begin
  Result := TColor( VA_Get( aData, 1, clRed ) );
end;

class function TDrawingCommandData.ExtractPrimitiveID(
  const aData: Variant): string;
begin
  Result := VA_Get( aData, 0, 0 );
end;

end.
