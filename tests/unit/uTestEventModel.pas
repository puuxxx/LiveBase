unit uTestEventModel;

interface
  uses TestFrameWork, SysUtils, uBase, uEventModel;

  type
    TTestObjectName = class( TTestCase )
    published
      procedure TestCommon;
    end;


implementation

{ TTestObjectName }

const
  VAL_OK = 1;
  VAL_FAIL = 2;
  EVENT_ID = 'TEST_EVENT_ID';

var
  EventDataID : string = '';

type
  TTestSubscriber = class ( TBaseSubscriber )
  public
    Val : integer;
    procedure ProcessEvent( const aEventID : TEventID; const aEventData : Variant ); override;
  end;


procedure TTestObjectName.TestCommon;
var
  EventModel : TEventModel;
  Subscriber : TTestSubscriber;
  EventData : Variant;
begin
  Subscriber := TTestSubscriber.Create;

  Subscriber.Val := VAL_FAIL;

  EventData := 111;
  EventModel := TEventModel.Create;
  try
    EventModel.RegisterSubscriber( EVENT_ID, Subscriber );
    EventModel.Event( EVENT_ID, EventData );
    CheckEquals( Subscriber.Val, VAL_OK, 'Check Event' );
    EventModel.UnRegister( EVENT_ID, Subscriber );


    Subscriber.Val := VAL_FAIL;
    EventModel.Event( EVENT_ID, EventData );
    CheckNotEquals( Subscriber.Val, VAL_OK, 'Check Event Unregister');


    Subscriber := TTestSubscriber.Create;
    Subscriber.Val := VAL_FAIL;
    EventModel.RegisterSubscriber( EVENT_ID,  Subscriber );
    EventModel.UnRegister( Subscriber );
    Subscriber.Val := VAL_FAIL;
    EventModel.Event( EVENT_ID, EventData );
    CheckNotEquals( Subscriber.Val, VAL_OK, 'Check Event Unregister V2 ');
  finally
    EventModel.Free;
  end;


end;

{ TTestSubscriber }

procedure TTestSubscriber.ProcessEvent(const aEventID: TEventID;
  const aEventData: Variant );
begin
  Val := VAL_OK;
end;

initialization
  TestFramework.RegisterTest( TTestObjectName.Suite );

end.
