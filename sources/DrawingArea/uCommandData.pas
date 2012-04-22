unit uCommandData;

interface

uses Variants, Graphics, uGraphicPrimitive;

function CreateCommandData(const aPrimitive: TGraphicPrimitive;
  const aColor: TColor): Variant;
function ExtractPrimitive(const aData: Variant): TGraphicPrimitive;
function ExtractColor(const aData: Variant): TColor;

implementation

function CreateCommandData(const aPrimitive: TGraphicPrimitive;
  const aColor: TColor): Variant;
var
  V: Variant;
begin
  V := Integer(aPrimitive);
  Result := VarArrayOf([V, aColor]);
end;

function ExtractPrimitive(const aData: Variant): TGraphicPrimitive;
begin
  Result := nil;
end;

function ExtractColor(const aData: Variant): TColor;
begin
  Result := clRed;
end;

end.
