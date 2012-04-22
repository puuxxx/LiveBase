unit uBase;

interface

uses WinApi.ActiveX, SysUtils, uExceptions, uExceptionCodes;

type
  TBaseObject = class(TInterfacedObject)
  strict private
    FGuid: TGuid;
    function GetGuid: TGuid;
    function GetGuidAsStr: string;
  public
    constructor Create;
    property ID: TGuid read GetGuid;
    property IDAsStr: string read GetGuidAsStr;
  end;

implementation

{ TBaseObject }

var
  NullGuid: TGuid;

constructor TBaseObject.Create;
begin
  inherited Create;
  FGuid := NullGuid;
end;

function TBaseObject.GetGuid: TGuid;
begin
  if IsEqualGuid(FGuid, NullGuid) then
  begin
    if CreateGuid(FGuid) <> 0 then
      RaiseFatalException(SYS_EXCEPT);
  end;

  Result := FGuid;
end;

function TBaseObject.GetGuidAsStr: string;
begin
  Result := GUIDToString(ID)
end;

initialization

NullGuid := StringToGuid('{00000000-0000-0000-0000-000000000000}');

end.
