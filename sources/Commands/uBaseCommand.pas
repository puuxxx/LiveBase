unit uBaseCommand;

interface

uses SysUtils, uBase, uExceptions, uExceptionCodes;

type

  TBaseCommand = class( TObject )
  public
    procedure Execute; overload; virtual;
    procedure Execute( const aData : Variant ); overload; virtual;
    procedure UnExecute; virtual;
  end;

implementation

{ TBaseCommand }

procedure TBaseCommand.Execute;
begin
  //
end;

procedure TBaseCommand.Execute(const aData: Variant );
begin
  //
end;

procedure TBaseCommand.UnExecute;
begin
  //
end;

end.
