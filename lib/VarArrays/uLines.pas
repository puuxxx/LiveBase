//
// �-�� ��� ������ � WideString'���
//
unit uLines;

interface

uses
  Classes, SysUtils, WideStrings;


type
  WString = String;
  PWString = PString;
  TWChars = String;  //< ������ WChar'��

const
  CRLF     = #13#10;
  chTab    = #9    ;
  chNBSP   = #$A0  ;  //< ����������� ������
  chBullet = #$2022;  //< "�"




function IfThen (aValue: boolean;  const aTrue : WString;
                                   const aFalse: WString = ''): WString;  overload;
function IfThen (aValue: boolean;  const aTrue : WString;  const aTrueArgs : array of const;
                                   const aFalse: WString;  const aFalseArgs: array of const): WString;  overload;
function IfThen (aValue: boolean;  const aTrue : WString;  const aTrueArgs : array of const;
                                   const aFalse: WString = ''): WString;  overload;

  // ���������� ���� �� ����� (�� �������)
function Max (const aStr1, aStr2: wstring): wstring;  overload;
function Min (const aStr1, aStr2: wstring): wstring;  overload;


type
  TWIdentMapEntry = record
    Value: integer;
    Name : WString;
  end;
  TWIdentMap = array of TWIdentMapEntry;

    // ������ IntToIdent / IdentToInt
function WIdentToInt (const aWIdent: WString;  var aInt: integer;  const aWMap: array of TWIdentMapEntry): boolean;
function IntToWIdent (aInt: integer;  var aWIdent: WString;  const aWMap: array of TWIdentMapEntry): boolean;
    // ������ � �������� TWIdentMapEntry'��
procedure AddToWIdent (var aWMap: TWIdentMap;
                       aValue: integer;  const aName: WString);  

    // �������� ������� ������ (0..)
function StrWord (const aStr: wstring;  aWordInx: integer;
                  const aSeps: TSysCharSet = [#10,#13,';'];
                  const aSpaces: TSysCharSet = [' '];
                  const aOpenQuotes: TSysCharSet = [];
                  const aCloseQuotes: TSysCharSet = []
                 ): wstring;

    // ���������� ������, ���� ��� ������� aLng
function LimitStr (const aStr: wstring;  aLng: integer): wstring;

    // ���������������� aStr � ������������� ���������
    // aToCut - �������� ������� ������
function CenterStr (const aStr: wstring;  aLng: integer;  const aCh: WideChar = ' ';  aToCut: boolean = True): wstring;
function LPadStr   (const aStr: wstring;  aLng: integer;  const aCh: WideChar = ' ';  aToCut: boolean = True): wstring;
function RPadStr   (const aStr: wstring;  aLng: integer;  const aCh: WideChar = ' ';  aToCut: boolean = True): wstring;

function TrimStr (const aStr: wstring;  aTrimChars: TSysCharSet = [#1..' ']): wstring;

function StrIsEmpty (const aStr: wstring;  aTrimChars: TSysCharSet = [#1..' ']): boolean;

    // ����������� ������ (� ������������ ���������)
function NoBreakStr (const aStr: wstring): wstring;


// ������ �� StringList'��

  type
    TIDValue = class
      Value : Variant;
      constructor Create ( const aValue : Variant );
    end;

  // ������� Strings �� ��������
  procedure ClearStrings ( aStrings : TWideStrings );
  // ��������� �������� � Strings
  procedure AddStringItem ( aStrings : TWideStrings; const aName : string; const aValue : Variant );
  // �������� �������� �� �������
  function GetValueFromStrings ( aStrings : TWideStrings; const aIndex : integer ) : Variant;
  // �������� ������ �� ��������
  function GetValueIndex ( aStrings : TWideStrings; const aValue : Variant ) : integer;
  // ������� ������� �� ������
  procedure DeleteStringsItem ( aStrings : TWideStrings; const aIndex : integer );
  // ������� [] �� <>
  function SquareToTriangleBrackets( const aLine : WideString ) : WideString;





  //
  // ���� �� ��������� ������
  //

type
  TFormatApply = (  // ��������� ������-������ �� ���.������
    fa_Repeat,  //< � ����������� (�� ��������� ���.������)
    fa_Once     //< ���������� (��������� -- ��� ����)
  );

    // �������� ������ �����
procedure GetMaskStr (
            const aSrcStr,                //< �������� ������ (�����/���������/�������)
                  aFormat : wstring;      //< ��������� ������ ('x' - ����� �����)
                  aFA     : TFormatApply; //< ��������� aFormat'� �� aSrcStr
            var   aMaskStr,               //< ����� (��������� ��������� aSrcStr'� �� aFormat)
                  aNormStr: wstring       //< ��������������� ������ (��, ��� ������ � aMaskStr �� aSrcStr)
          );







implementation

uses
  Math, Variants, Windows,
  uVarArrays;



function IfThen (aValue: boolean;  const aTrue, aFalse: WString): WString;
begin
  if aValue then Result := aTrue
            else Result := aFalse;
end;

function IfThen (aValue: boolean;  const aTrue : WString;  const aTrueArgs : array of const;
                                   const aFalse: WString;  const aFalseArgs: array of const): WString;
begin
  if aValue then Result := WideFormat (aTrue , aTrueArgs )
            else Result := WideFormat (aFalse, aFalseArgs);
end;

function IfThen (aValue: boolean;  const aTrue: WString;  const aTrueArgs: array of const;
                                   const aFalse: WString): WString;
begin
  if aValue then Result := WideFormat (aTrue, aTrueArgs)
            else Result := aFalse;
end;


function Max (const aStr1, aStr2: wstring): wstring;
begin
  if ( aStr1 > aStr2 ) then Result := aStr1
                       else Result := aStr2;
end;

function Min (const aStr1, aStr2: wstring): wstring;
begin
  if ( aStr1 < aStr2 ) then Result := aStr1
                       else Result := aStr2;
end;




// ������ IntToIdent / IdentToInt

function WIdentToInt (const aWIdent: WString;  var aInt: integer;  const aWMap: array of TWIdentMapEntry): boolean;
var
  n: integer;
begin
  Result := True;
  for n:=Low(aWMap) to High(aWMap) do
    with aWMap[n] do
      if WideSameText (Name, aWIdent) then begin
        aInt := Value;  Exit;
      end;
  Result := False;
end;

function IntToWIdent (aInt: integer;  var aWIdent: WString;  const aWMap: array of TWIdentMapEntry): boolean;
var
  n: integer;
begin
  Result := True;
  for n:=Low(aWMap) to High(aWMap) do
    with aWMap[n] do
      if ( Value = aInt ) then begin
        aWIdent := Name;  Exit;
      end;
  Result := False;
end;

procedure AddToWIdent (var aWMap: TWIdentMap;
                       aValue: integer;  const aName: WString);
var
  L: integer;
begin
  L := Length(aWMap);
  SetLength (aWMap, L+1);
  with aWMap[L] do begin
    Value := aValue;
    Name  := aName ;
  end;
end;




function StrWord (const aStr: wstring;  aWordInx: integer;
                  const aSeps: TSysCharSet = [#10,#13,';'];
                  const aSpaces: TSysCharSet = [' '];
                  const aOpenQuotes: TSysCharSet = [];
                  const aCloseQuotes: TSysCharSet = []
                 ): wstring;
var
  Words: TVariants;
begin
  VarsExtract (Words, aStr, aSeps, aSpaces, aOpenQuotes, aCloseQuotes);
  Result := GetVar (Words, aWordInx);
end;



function LimitStr (const aStr: wstring;  aLng: integer): wstring;
begin
  Result := aStr;
  if ( Length(Result) > aLng ) then SetLength (Result, aLng);
end;



type
  TAlign = -1..+1;  // ����/�����/�����

function AlignStr (const aStr: wstring;  aLng: integer;  const aCh: WideChar;
                   aAlign: TAlign;  aToCut: boolean): wstring;
var
  LengthNeed: Integer;
begin
  LengthNeed := aLng;
  Dec (aLng, Length(aStr));
  if ( aLng = 0 ) then begin
    Result := aStr;
  end else if ( aLng < 0 ) then begin
    Result := Trim(aStr);
    if ( Length(Result) < LengthNeed ) and aToCut then
      SetLength (Result, LengthNeed);
  end else begin
    Result := StringOfChar (aCh, aLng);
    case aAlign of
      0    : Insert (aStr, Result, aLng div 2);
      +1   : Result := Result + aStr;
      else   Result := aStr + Result;
    end;
  end;
end;


function CenterStr (const aStr: wstring;  aLng: integer;  const aCh: WideChar;  aToCut: boolean): wstring;
begin
  Result := AlignStr (aStr, aLng, aCh, 0, aToCut);
end;

function LPadStr (const aStr: wstring;  aLng: integer;  const aCh: WideChar;  aToCut: boolean): wstring;
begin
  Result := AlignStr (aStr, aLng, aCh, +1, aToCut);
end;

function RPadStr (const aStr: wstring;  aLng: integer;  const aCh: WideChar;  aToCut: boolean): wstring;
begin
  Result := AlignStr (aStr, aLng, aCh, -1, aToCut);
end;




function TrimStr (const aStr: wstring;  aTrimChars: TSysCharSet): wstring;
var
  p, L: integer;
begin
  L := Length(aStr);
  p := 1;
  while ( p <= L ) and
        ( CharInSet( aStr[p], aTrimChars ) ) do Inc(p);
  if ( p > L ) then Result := ''
  else begin
    while ( CharInSet( aStr[L], aTrimChars ) ) do Dec(L);
    Result := Copy (aStr, p, L-p+1);
  end;
end;


function StrIsEmpty (const aStr: wstring;  aTrimChars: TSysCharSet): boolean;
begin
  Result := ( TrimStr (aStr, aTrimChars) = '' );
end;





function NoBreakStr (const aStr: wstring): wstring;
var
  n: integer;
begin
  Result := aStr;
  for n:=1 to Length(Result) do
    if ( Result[n] = ' ' ) then Result[n] := chNBSP;
end;








// Strings

constructor TIDValue.Create ( const aValue : Variant );
begin
  inherited Create;
  Value := aValue;
end;

procedure ClearStrings ( aStrings : TWideStrings );
var
  Inx : integer;
  Obj : TObject;
begin
  for Inx := 0 to aStrings.Count - 1 do begin
    Obj := aStrings.Objects[Inx];
    if Assigned( Obj ) then FreeAndNil(Obj);
  end;
end;

procedure AddStringItem ( aStrings : TWideStrings; const aName : string; const aValue : Variant );
var
  IDValue : TIDValue;
begin
  IDValue := TIDValue.Create( aValue );
  aStrings.AddObject( aName, IDValue );
end;

function GetValueFromStrings ( aStrings : TWideStrings; const aIndex : integer ) : Variant;
var
  Obj : TObject;
begin
  Result := '';
  if ( aStrings.Count > 0 )      and
     ( aIndex >= 0 )             and
     ( aIndex < aStrings.Count ) then begin
    Obj := aStrings.Objects[aIndex];
    if Assigned( Obj ) and ( Obj is TIDValue ) then
      Result := TIDValue( Obj ).Value;
  end;
end;

function GetValueIndex ( aStrings : TWideStrings; const aValue : Variant ) : integer;
var
  Inx, Cnt : integer;
  Obj : TObject;
begin
  Result := -1;
  Cnt := aStrings.Count;
  for Inx := 0 to Cnt - 1 do begin
    Obj := aStrings.Objects[Inx];
    if Assigned(Obj) and ( Obj is TIDValue ) and
       VarSameValue( TIDValue(Obj).Value, aValue ) then begin
      Result := Inx;
      exit;
    end;
  end;
end;

procedure DeleteStringsItem ( aStrings : TWideStrings; const aIndex : integer );
var
  Obj : TObject;
begin
  if aStrings.Count > 0 then begin
    if ( aIndex >= 0 )             and
       ( aIndex < aStrings.Count ) then begin
      Obj := aStrings.Objects[aIndex];
      if Assigned( Obj ) then FreeAndNil(Obj);
      aStrings.Delete(aIndex);
    end;
  end;
end;

function SquareToTriangleBrackets( const aLine : WideString ) : WideString;
var
  s : WideString;
begin
  s := aLine;


  if Pos( WideString('vartostr'), WideLowerCase(s) ) = 2 then begin
    // ������� �� ������� VarToStr

    Delete( s, 1, 1); //< ������� ������ ������ '['
    SetLength( S, length(s)-1 ); //< ������� ��������� ������
  end else
  if s[1] = '[' then begin
    // �������� ���������� ������ �� �����������

    s[1] := '<';
    s[ length(aLine) ] := '>';
  end;

  Result := s;
end;














  //
  // ���� �� ��������� ������
  //


procedure GetMaskStr (const aSrcStr, aFormat: wstring;  aFA: TFormatApply;
                      var aMaskStr, aNormStr: wstring);
const
  DigCh = 'x';  //< ������-������ "����� �����"
  FormatChs = [DigCh];
  InpCh = '_';  //< ���������� ������-�������� � �����

  function MaskStr: widestring;

    function FmtToDisp (const aFmt: widestring;
                        var aDisp : widestring): boolean;
    var
      n: integer;
    begin
      Result := False;
      aDisp  := aFmt;
      for n:=1 to Length(aDisp) do
        if ( CharInSet( aDisp[n], FormatChs ) ) then begin
          aDisp[n] := InpCh;
          Result   := True;
        end;
    end;

  var
    FirstPut: boolean;
    r, n: integer;
    ch: widechar;

    procedure IncResPos;
    begin
      inc(r);
      if ( r > Length(Result) ) then begin
        r := 1;
        FirstPut := True;
      end;
    end;

    procedure PutResCh;
    begin
      if FirstPut then begin  // �������� ���������� �������
        FirstPut := False;
        FmtToDisp (aFormat, Result);
        aNormStr := '';
      end;
      Result[r] := ch;
      IncResPos;
      aNormStr := aNormStr+ch;
      inc(n);
    end;

  var
    Rest: wstring;
  begin
    Result := aSrcStr;
    if ( aFormat = '' ) then exit;  //< ��� ���������� �����
    aNormStr := '';
    if not FmtToDisp (aFormat, Result) then exit;  //< ������ ��������� �������
    FirstPut := False;
    r := 1;
    n := 1;
    while ( n <= Length(aSrcStr) ) do begin
      ch := aSrcStr[n];
      case aFormat[r] of
        DigCh: if ( CharInSet( ch, ['0'..'9'] ) ) then PutResCh
                                       else inc(n);
        else   IncResPos;
      end;
      // ����� ��� fa_Once
      if ( aFA = fa_Once ) and FirstPut then begin
        Rest := Copy (aSrcStr, n, Length(aSrcStr));
        Result   := Result   + Rest;
        aNormStr := aNormStr + Rest;
        exit;
      end;
    end;
  end;

begin
  aNormStr := aSrcStr;
  aMaskStr := MaskStr;
end;


end.

