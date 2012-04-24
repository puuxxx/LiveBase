unit uEventModel;

interface

  uses uBase, Classes, SysUtils, Generics.Collections, uExceptions, uExceptionCodes;

  type
    TEventID = string;
    ISubscriber = interface
      procedure ProcessEvent( const aEventID : TEventID; const aEventData : variant );
    end;

    TBaseSubscriber = class( TBaseObject, ISubscriber )
      procedure ProcessEvent( const aEventID : TEventID; const aEventData : variant ); virtual;
    end;


    TInnerEventData = class( TBaseObject )
    public
      EventID : TEventID;
      Subscriber : ISubscriber;
    end;

    TEventModel = class( TBaseObject )
    strict private
      FList : TObjectList<TInnerEventData>;
    public
      constructor Create;
      destructor Destroy; override;

      procedure RegisterSubscriber( const aEventID : TEventID; const aSubscriber : ISubscriber );
      procedure UnRegister( const aEventID : TEventID; const aSubscriber : ISubscriber ); overload;
      procedure UnRegister( const aSubscriber : ISubscriber ); overload;
      procedure Event( const aEventID : TEventID; const aEventData : variant );
    end;


implementation

{ TBaseSubscriber }

procedure TBaseSubscriber.ProcessEvent(const aEventID: TEventID; const aEventData: variant );
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

procedure TEventModel.Event(const aEventID: TEventID; const aEventData: variant );
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
  const aSubscriber: ISubscriber);
var
  InnerData : TInnerEventData;
begin
  InnerData := TInnerEventData.Create;
  InnerData.EventID := aEventID;
  InnerData.Subscriber := aSubscriber;

  FList.Add( InnerData );
end;

procedure TEventModel.UnRegister(const aSubscriber: ISubscriber);
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
  const aSubscriber: ISubscriber);
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
