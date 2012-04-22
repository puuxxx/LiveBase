unit uExceptions;

interface

uses SysUtils, uExceptionCodes;

type

  TException = class(Exception)
  end;

  TFatalException = class(TException)
  end;

procedure RaiseExeption(const aCode: integer);
procedure RaiseFatalException(const aCode: integer);
procedure ContractFailure;

procedure Warn(const aMessage: string);

implementation

procedure ContractFailure;
begin
  RaiseExeption(CONTRACT_EXCEPT);
end;

procedure RaiseExeption(const aCode: integer);
begin
  raise TException.Create('Error Message');
end;

procedure RaiseFatalException(const aCode: integer);
begin
  raise TFatalException.Create('Error message');
end;

procedure Warn(const aMessage: string);
begin
  //
end;

end.
