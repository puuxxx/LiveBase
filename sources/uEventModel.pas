unit uEventModel;

interface

  uses uBase, Classes, SysUtils, Generics.Collections, uExceptions, uExceptionCodes;

  type
    TEventID = string;
    TEventData = TBaseObject;
    ISubscriber<T> = interface
      procedure ProcessEvent( const aEventID : TEventID; const aEventData : T );
    end;
    TBaseSubscriber = class( TBaseObject, ISubscriber<TObject> )
      procedure ProcessEvent( const aEventID : TEventID; const aEventData : TObject ); virtual;
      function Me : TBaseSubscriber;
    end;

    TInnerEventData = class( TBaseObject )
    public
      EventID : TEventID;
      Subscriber : TBaseSubscriber;
    end;

    TEventModel = class( TBaseObject )
    strict private
      FList : TObjectList<TInnerEventData>;
    public
      constructor Create;
      destructor Destroy; override;

      procedure RegisterSubscriber( const aEventID : TEventID; const aSubscriber : TBaseSubscriber );
      procedure UnRegister( const aEventID : TEventID; const aSubscriber : TBaseSubscriber ); overload;
      procedure UnRegister( const aSubscriber : TBaseSubscriber ); overload;
      procedure Event( const aEventID : TEventID; const aEventData : TEventData );
    end;


implementation

{ TBaseSubscriber }

function TBaseSubscriber.Me: TBaseSubscriber;
begin
  Result := Self;
end;

procedure TBaseSubscriber.ProcessEvent(const aEventID: TEventID;
  const aEventData: TObject);
begin
  RaiseFatalException( SYS_EXCEPT );
end;

{ TEventModel }

constructor TEventModel.Create;
begin
  inherited Create;
  FList := TObjectList<TInnerEventData>.Create;
end;

destructor TEventModel.Destroy;
begin
  FList.Clear;
  inherited;
end;

procedure TEventModel.Event(const aEventID: TEventID;
  const aEventData: TEventData);
var
  InnerData : TInnerEventData;
begin
  for InnerData in FList do begin
    if CompareStr( InnerData.EventID, aEventID ) = 0 then begin
      InnerData.Subscriber.ProcessEvent( aEventID, aEventData );
    end;
  end;
end;

procedure TEventModel.RegisterSubscriber(const aEventID: TEventID;
  const aSubscriber: TBaseSubscriber);
var
  InnerData : TInnerEventData;
begin
  InnerData := TInnerEventData.Create;
  InnerData.EventID := aEventID;
  InnerData.Subscriber := aSubscriber;

  FList.Add( InnerData );
end;

procedure TEventModel.UnRegister(const aSubscriber: TBaseSubscriber);
var
  i : integer;
  InnerData : TInnerEventData;
begin
  i := 0;
  while i < FList.Count do begin
    InnerData := FList.Items[i];
    if InnerData.Subscriber = aSubscriber then begin
      FList.Delete(i);
      continue;
    end;
    Inc(i);
  end;
end;

procedure TEventModel.UnRegister(const aEventID: TEventID;
  const aSubscriber: TBaseSubscriber);
var
  InnerData : TInnerEventData;
  i : integer;
begin
  for i := 0 to FList.Count - 1 do begin
    InnerData := FList.Items[ i ];
    if ( aSubscriber = InnerData.Subscriber ) and
       ( CompareStr( aEventID, InnerData.EventID ) = 0 ) then begin
       FList.Delete( i );
       break;
    end;
  end;
end;

end.
