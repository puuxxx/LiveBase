unit uBaseCommand;

interface

uses SysUtils, uBase, uExceptions, uExceptionCodes;

type
  TBaseCommand = class( TBaseObject )
  public
    procedure Execute; overload; virtual;
    procedure Execute( const aData : TBaseObject ); overload; virtual;
    procedure UnExecute; virtual;
  end;

implementation

{ TBaseCommand }

procedure TBaseCommand.Execute;
begin
  //
end;

procedure TBaseCommand.Execute(const aData: TBaseObject);
begin
  //
end;

procedure TBaseCommand.UnExecute;
begin
  //
end;

end.
