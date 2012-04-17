unit uExceptions;

interface

uses SysUtils;

  type

    TException = class( Exception )
    end;

    TFatalException = class( TException )
    end;

    procedure RaiseExeption( const aCode : integer );
    procedure RaiseFatalException( const aCode : integer );

implementation

procedure RaiseExeption( const aCode : integer );
begin
  raise TException.Create('Error Message');
end;

procedure RaiseFatalException( const aCode : integer );
begin
  raise TFatalException.Create('Error message');
end;

end.
