unit uDrawingEvent;

interface

  uses uEventModel, Graphics, uDrawingCommand, uVarArrays,
    uExceptions, Variants;

  const
    EVENT_PLEASE_REPAINT   = 'PLEASE_REPAINT';
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
  if aPrimitiveID = '' then ContractFailure;

  Result := VA_Of( [ aPrimitiveID, aData ] );
end;

class function TDrawingCommandData.CreateData(
  const aPrimitiveID: string; const aData: array of variant): Variant;
var
  R : Variant;
begin
  R := VA_Of( [ aPrimitiveID ] );
  VA_AddOf( R, aData );
  Result := R;
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
