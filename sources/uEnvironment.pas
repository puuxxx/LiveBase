unit uEnvironment;

interface
  uses uBase, uEventModel, uRootForm;

  type
    TEnvironment = class( TBaseObject )
    public
      EventModel : TEventModel;
      RootForm : TFmRoot;

      constructor Create;
    end;

  var
    Env : TEnvironment;
implementation

{ TEnvironment }

constructor TEnvironment.Create;
begin
  inherited Create;
  EventModel := nil;
  RootForm := nil;
end;

initialization
  Env := nil;

end.
