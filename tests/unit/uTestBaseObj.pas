unit uTestBaseObj;

interface

uses TestFrameWork, SysUtils, uBase;

type
  TTestBaseObj = class( TTestCase )
  published
    procedure TestID;
  end;

implementation


{ TTestBaseObj }

procedure TTestBaseObj.TestID;
const
  NullGuid = '{00000000-0000-0000-0000-000000000000}';
var
  BaseObj : TBaseObject;
begin
  BaseObj := TBaseObject.Create;
  try
    CheckNotEqualsString( NullGuid, GUIDToString( BaseObj.ID ), 'Guid' );
    CheckNotEqualsString( NullGuid, BaseObj.IDAsStr, 'Guid str' );
  finally
    FreeAndNil( BaseObj );
  end;
end;

initialization
  TestFramework.RegisterTest( TTestBaseObj.Suite );

end.
