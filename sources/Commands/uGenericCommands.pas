unit uGenericCommands;

interface

uses SysUtils, uBase, uBaseCommand, uEnvironment, uExceptions, uExceptionCodes,
  uEventModel, Forms, uRootForm, uStrings;

type
  TLaunchCommand = class( TBaseCommand )
  public
    procedure Execute; override;
    procedure UnExecute; override;
  end;

implementation

{ TLaunchCommand }

procedure TLaunchCommand.Execute;
begin
  if Assigned( Env ) then begin
    RaiseFatalException( SYS_EXCEPT );
  end;

  Env := TEnvironment.Create;
  Env.EventModel := TEventModel.Create;
  Env.RootForm := TfmRoot.Create( Application );
  with Env.RootForm do begin
    Visible := false;
    Caption := APP_TITLE;
  end;
end;

procedure TLaunchCommand.UnExecute;
begin
  FreeAndNil( Env.RootForm );
  FreeAndNil( Env.EventModel );
  FreeANdNil( Env );

  inherited;
end;

end.
