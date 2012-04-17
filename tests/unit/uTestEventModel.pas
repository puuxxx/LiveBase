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
    procedure ProcessEvent( const aEventID : TEventID; const aEventData : TObject ); override;
  end;


procedure TTestObjectName.TestCommon;
var
  EventModel : TEventModel;
  Subscriber : TTestSubscriber;
  EventData : TEventData;
begin
  Subscriber := TTestSubscriber.Create;
  Check( Subscriber.Me <> nil , 'Subscriber.Me not NULL' );
  Check( Subscriber.Me = Subscriber , 'Subscriber = Subscriber.Me' );

  Subscriber.Val := VAL_FAIL;

  EventData := TEventData.Create;
  EventDataID := EventData.IDAsStr;

  EventModel := TEventModel.Create;
  try
    EventModel.RegisterSubscriber( EVENT_ID, Subscriber );
    EventModel.Event( EVENT_ID, EventData );
    CheckEquals( Subscriber.Val, VAL_OK, 'Check Event' );
    CheckEquals( EventData.IDAsStr, EventDataID, 'Check Event Data' );

    EventModel.UnRegister( EVENT_ID, Subscriber );
    Subscriber.Val := VAL_FAIL;
    EventModel.Event( EVENT_ID, EventData );
    CheckNotEquals( Subscriber.Val, VAL_OK, 'Check Event Unregister');

    EventModel.RegisterSubscriber( EVENT_ID, Subscriber );
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
  const aEventData: TObject);
begin
  Val := VAL_OK;
  if aEventData is TBaseObject then begin
    EventDataID := TBaseObject( aEventData ).IDAsStr;
  end;
end;

initialization
  TestFramework.RegisterTest( TTestObjectName.Suite );

end.
