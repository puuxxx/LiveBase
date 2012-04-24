unit uVarArrays;

interface

uses
  SysUtils, Types, uLines;


type
  TVariants = array of Variant;
  PVariants = ^TVariants;
  TSqrVariants = array of TVariants;
  PSqrVariants = ^TSqrVariants;
  TCubVariants = array of TSqrVariants;
  PCubVariants = ^TCubVariants;
  TIntegers = array of Integer;
  PIntegers = ^TIntegers;
  TLines = array of string;
  TWLines = TLines;


var
  VarsFS: TFormatSettings;  //< ��������� �������������� ��� CompareVar(s) � ��.
                            //< ��-���������, �������� �������� ���. ������


  // ���������� 2 variant'� (��� except'a)
  //   ���� v1 � v2 - ������, �� ��� ��������� ����������� aWithCase
function VarEquals (const aV1, aV2: variant;  aWithCase: boolean = True): boolean;
function VarSame (const aV1, aV2: variant): boolean;
function CompareVar (const aV1, aV2: variant;  aWithCase: boolean = True): TValueRelationship;
function VarIfThen (aCond: boolean;  const aTrue, aFalse: variant): variant;
      // ���� �������� aVal � aValues, ���������� �����. �������� �� aResults
      // ���� �� ������� - ���������� aElse
function VarMap (const aVal: variant;
                 const aValues, aResults: array of variant;
                 const aElse: variant;
                 aWithCase: boolean = True): variant;

  // aVar ����� ���� ������������� � ordinal
function VarCanOrd (const aVar: variant): boolean;
  // aVar ����� ���� ������������� �� float
function VarCanReal (const aVar: variant): boolean;

  // ����� aVar
function Var_Copy (const aVar: variant): variant;


  // ���������� ���������� Variant'� � ��������� ����
function vFLT (const aV: variant;  aDef: double    = 0): double;
function vMNY (const aV: variant;  aDef: currency  = 0): currency;
function vINT (const aV: variant;  aDef: integer   = 0): integer;
function vSTR (const aV: variant;  const aDef: string = ''): string;
function vDAT (const aV: variant;  aDef: TDateTime = 0): TDateTime;




  ////////////////////////
  //  ������� Variant'��
  ////////////////////////

  // ��������� �������� �� �������� ����� (aInxes)
  // � aInxes ���� ����������� � ������� ��������� ���������� ���������
  // ������� aInxes[n] ������������� aWithCases[n]. ���� �� �������, �� ������
  //   ��������� ��������. ���� ��� �� ������, �� ��������� - True  
function CompareVars (const aVars1, aVars2: array of variant;
                      aInxes: array of integer;
                      aWithCases: array of boolean): TValueRelationship;

  // �������-������
function VA_Of (const aSrc: array of variant): variant;
  // �������� �������� aVA[aInx]
  //   ���� aVA - ������� ��������, �� ��� ������������ ��� aInx=0, ����� ��������� - Unassigned
  //   ���� aVA - ������, � aInx ������� �� ������� �������, �� ��������� - Unassigned
function VA_Get (const aVA: variant;  aInx: integer = 0): variant;  overload;
function VA_Get (const aVA: variant;  aInx: integer;  const aDef: variant): variant;  overload;
  // ����� ������� aVA
  // ���� ������� ��������, ���������� 1(aValAsArr==1) ��� 0(aValAsArr==0)
function VA_Lng (const aVA: variant;  aValAsArr: boolean = True): integer;
  // �������� � ������ � �������� ������� (-1 - � �����)
  //   ���� aDstVA - �� ������, �� �� ��������� ������ ��������
procedure VA_AddOf (var aDstVA: variant;  const aSrcVars: array of variant;  aDstInx: integer = -1);
  // ������ � ���������� ������� ����� ����������� aSepS (aVA ����� ���� � ������� ���������)
  //   aMaxLng - ����������� ���������� �� ����� (0 - ��� �����������)
function VAToStr (const aVA: variant;
                  aMaxLng: integer = 0;  const aSepS: String = '; ';
                  aToPack: boolean = False): String;
    // ��������������� ���������
function AddStr_ (var aResStr: String;  const aStr: String;
                 aInx, aLoInx, aHiInx: integer;
                 aMaxLng: integer;  const aSepS: String): boolean;


// ������ ���������
  // ����� �� ���� ��������
function VarsIfThen (aCond: Boolean;  const aTrue, aFalse: array of variant): TVariants;
  // �������� variant (������ ��� ��������) � TVariants
procedure VAToVars (const aVA: variant;  var aVars: TVariants);  overload;
function VAToVars (const aVA: variant): TVariants;  overload;
  // ����������� aSrc � aDst (��� ������������� array � TVariants)
procedure VarsToVars (const aSrc: array of Variant;  var aDst: TVariants);
function VarsOf (const aSrc: array of Variant): TVariants;
  // �������� ������� �������
function GetVar    (const aVars: array of variant;  aInx: integer = 0): variant;
function GetVarDef (const aVars: array of variant;  aInx: integer;
                    const aDef: variant): variant;
  // �������� ������; ���� aLng>0, �� - �������������� ���������� ����� �����
procedure ClearVars (var aVars: TVariants;  aLng: integer = -1);
  // ��������� ������ ���������� �� �������� �����
procedure PadBeginVars (var aVars: TVariants;  const aPadVal: variant;  aCount: integer);
procedure PadEndVars   (var aVars: TVariants;  const aPadVal: variant;  aCount: integer);
  // �������� � ������ � �������� ������� (-1 - � �����)
procedure AddVars (const aSrc: array of Variant;  var aDst: TVariants;  aDstInx: integer = -1);
function VarsSumOf (const aSrc1, aSrc2: array of variant;  aSrc1Inx: integer = -1): TVariants;
  // ���������� aDst �������� aSrc aSrcCnt ���
procedure FillVars (const aSrc: array of Variant;  var aDst: TVariants;  aSrcCnt: integer = 1);  overload;
function FillVars (const aSrc: array of Variant;  aSrcCnt: integer = 1): TVariants;  overload;
  // ������� �� �������
  //   True - ���� ��������� �������� ��������
function DelVar (const aVar: variant;  var aDst: TVariants;  aWithCase: boolean = True): boolean;  overload;
procedure DelVar (const aInx, aCnt: integer;  var aDst: TVariants);  overload;
  // ������� aVar � ������� aVars (< 0 - �� �������)
function VarPos (const aVar: variant;  const aVars: array of variant;  aWithCase: boolean = True): integer;
function HasVar (const aVar: variant;  const aVars: array of variant;  aWithCase: boolean = True): boolean;
  // ������ ���� aFind'�� �� aReplace'�
function VarsReplace (const aVars: TVariants;  const aFind, aReplace: variant;
                      aWithCase: boolean = True): boolean;
  // ������ � ��������, ��� � ����������
  //   True - ���� ��������� ��������� �������
function IncludeVar (const aVar: variant;  var aVars: TVariants;  aWithCase: boolean = True): boolean;
function ExcludeVar (const aVar: variant;  var aVars: TVariants;  aWithCase: boolean = True): boolean;
  // ����������� ��������
  //   True - ���� �������� ���������
function CrossVars (var aVars1: TVariants;  const aVars2: array of variant;
                    aWithCase: boolean = True): boolean;
  // ��������� ������������� aVars
function VarsToStr (const aVars: array of variant;
                    aMaxLng: integer = 0;  const aSepS: String = '; '): String;
  // ��������� ��������
function VarsEqu (const aVars1, aVars2: array of variant;  aWithCase: boolean = True): boolean;  overload;
function VarsEqu (const aVars1, aVars2: array of variant;
                  const aCmpFlds: array of integer;  //< ���� aCmpFlds=[], �� ������������ ��� ����
                  aWithCase: boolean = True
                 ): boolean;  overload;

  // ������ �� ������� ����� (���� " str1; str2; "str 3"; ....")
  // ������ ������ �� �����������
  // �������� aOpenQuotes - ������� ����� �������
  // ���� �� ����� aCloseQuotes, ������ ����� aOpenQuotes
const
  ListSeps   = [#10,#13,';'];
  ListSpaces = [' '];
procedure VarsExtract (var aVars: TVariants;  const aStr: string;
                       const aSeps: TSysCharSet = ListSeps;
                       const aSpaces: TSysCharSet = ListSpaces;
                       const aOpenQuotes: TSysCharSet = [];
                       const aCloseQuotes: TSysCharSet = [];
                       aKeepEmpties: boolean = False);
function VarsConcat (const aVars   : array of variant;
                     const aSepStr : string = CRLF;
                     aWithFinSep   : boolean = False;
                     const aReplStr: string = #0;    //< ���� ������ (<>#0), �� � ���. ������� �������� �� ��� aSepStr'�
                     aNoEmpty      : boolean = False; //< �� ��������� ������ ������
                     const aFormat : string = #0     //< ���� ������ (<>#0), �� ������������� �� ��� ������ ������
                    ): string;
function VarsConcatNE (const aVars   : array of variant;
                       const aSepStr : string = CRLF;
                       aWithFinSep   : boolean = False;
                       const aReplStr: string = #0
                      ): string;
function VarsConcatFmt (const aFormat : string;
                        const aVars   : array of variant;
                        const aSepStr : string = CRLF;
                        aWithFinSep   : boolean = False;
                        const aReplStr: string = #0
                       ): string;
      // �������� � ������ � �����������
      // ���������� ������, ���� ��������
function AddSortVar (const aVar: variant;  var aDst: TVariants;
                     aWithCase: boolean = True;
                     aAscending: boolean = True;
                     aToAdd: boolean = True  //< ������� �������� aVar � aDst
                    ): integer;
      // ������������� ������
procedure SortVars (var aVars: TVariants;
                    aWithCase: boolean = True;
                    aAscending: boolean = True);





// ������ � ������������� ��������
type
  TCopyType = (
    ct_Rewrite,
    ct_Insert
  );
const
  ct_Append = ct_Insert;

  // �������� variant (������ ��� ��������) � TVariants
procedure VAToSqrVars (const aVA: variant;  var aSqrVars: TSqrVariants);  overload;
function VAToSqrVars (const aVA: variant): TSqrVariants;  overload;
procedure SqrVarsToVars (const aSrc: array of TVariants;  var aDst: TSqrVariants;
                         aCT: TCopyType = ct_Rewrite;  aInsPos: integer = -1;  //< -1 - �������� � �����
                         aKeepEmpties: boolean = False;   // false - ������ ������ �� ����������
                         aByRef: boolean = False);        // false - ��������� ������ �����
procedure AppendSqrVars (const aSrc: array of TVariants;  var aDst: TSqrVariants);
procedure SqrRefsToVars (const aSrc: array of TVariants;  var aDst: TSqrVariants;
                         aCT: TCopyType = ct_Rewrite;  aInsPos: integer = -1);
procedure AppendSqrRefs (const aSrc: array of TVariants;  var aDst: TSqrVariants);
function SqrVarsOf (const aSrc: array of TVariants;
                    aKeepEmpties: boolean = False;
                    aByRef: boolean = False): TSqrVariants;
  // SqrVarsOf (, True, True)
function SqrRefsOf (const aSrc: array of TVariants): TSqrVariants;
  // ����.2D ������ �� ������ ������� ��������
  // Cols - ���-�� ������� � Result'�
function SqrPrmsOf (const aSrc: array of variant): TSqrVariants;
  // �������� ��������
function GetSqrVar    (const aSqrVars: array of TVariants;
                       aRow: integer = 0;  aCol: integer = 0): variant;
function GetSqrVarDef (const aSqrVars: array of TVariants;  aRow, aCol: integer;
                       const aDef: variant): variant;
  // �������� ������; ���� aLng1/2>0, �� - �������������� ���������� ����� �����
  // aLng1 - ����� ��������� ��������� (���-�� �����);  aLng2 - ����� ������ ������
procedure ClearSqrVars (var aSqrVars: TSqrVariants;  aLng1: integer = -1;
                                                     aLng2: integer = -1);
  // ������� �������� ���-�� ���������
  // aCnt<0 -- ������� �� aInx �� �����
function DelSqrVars (aInx, aCnt: integer;  var aDst: TSqrVariants): boolean;
  // ��������� ������������� aSqrVars
function SqrVarsToStr (const aSqrVars: array of TVariants;
                       aMaxLng: integer = 0;  const aSepS: String = '; '): String;
  // �������� ������� sqr-�������
function SqrVarsColumn (const aSqrVars: array of TVariants;  aCol: integer): TVariants;  overload;
function SqrVarsColumn (const aSqrVars: array of TVariants;
                        const aRowInxes: array of integer;  aCol: integer): TVariants;  overload;
  // ��������� ��������
function SqrVarsEqu (const aSqrVars1, aSqrVars2: array of TVariants;  aWithCase: boolean = True): boolean;  overload;
function SqrVarsEqu (const aSqrVars1, aSqrVars2: array of TVariants;
                     const aCmpFlds: array of integer;  aWithCase: boolean = True): boolean;  overload;
  // ������� aVar � ������� aSqrVars [i,aKeyCol] (< 0 - �� �������)
function SqrVarPos (const aVar: variant;  const aSqrVars: array of TVariants;
                    aKeyCol: integer = 0;  aWithCase: boolean = True): integer;
function SqrHasVar (const aVar: variant;  const aSqrVars: array of TVariants;
                    aKeyCol: integer = 0;  aWithCase: boolean = True): boolean;
  // ����� �� ���������� �����                  
function SqrVarsPos (const aSqrVars: array of TVariants;
                     const aVars: array of variant;
                     const aKeyCols: array of integer;  aWithCase: boolean = True): integer;
  // ������ �� ������� �����-�������� (���� "name1 = val1, val2; name10 = val10, "val 11"; ....")
const
  ListEqus = ['='];
procedure SqrVarsExtract (var aSqrVars: TSqrVariants;  const aStr: string;
                          const aEqus: TSysCharSet = ListEqus;
                          const aSeps: TSysCharSet = ListSeps;
                          const aSpaces: TSysCharSet = ListSpaces;
                          const aOpenQuotes: TSysCharSet = [];
                          const aCloseQuotes: TSysCharSet = []);
function SqrVarsConcat (const aSqrVars: TSqrVariants;
                        const aEquStr: string = '=';
                        const aSepStr: string = CRLF;
                        aWithFinSep: boolean = False): string;  overload;
        // ��������� aSqrVars[aRowInxes[n]][aCol]'� (���������� TVariants)
        // aRowInxes==[] -- ��� ������ �� aSqrVars
function SqrVarsConcat (const aSqrVars: TSqrVariants;
                        const aRowInxes: array of integer;  aCol: integer = 0;
                        const aSepStr: string = CRLF;
                        aWithFinSep: boolean = False;
                        aReplStr: string = #0;
                        aNoEmpty: boolean = False): string; overload;
function SqrVarsConcat (const aSqrVars: TSqrVariants;  aCol: integer = 0;
                        const aSepStr: string = CRLF;
                        aWithFinSep: boolean = False;
                        aReplStr: string = #0;
                        aNoEmpty: boolean = False): string; overload;


      // �������� ������ � sqr-������, � �����������
function AddSortSqrVar (const aVars: array of variant;  var aDstSqr: TSqrVariants;
                        aKeyCol: integer = 0;  //< ����, �� �������� ���������� ������
                        aWithCase: boolean = True;
                        aAscending: boolean = True): integer;
      // ������������� ������ � sqr-�������
procedure SortSqrVars (var aSqrVars: TSqrVariants;   aKeyCol: integer = 0;
                       aWithCase: boolean = True;
                       aAscending: boolean = True);




// ������ � ���������� ��������
procedure CubVarsToVars (const aSrc: array of TSqrVariants;  var aDst: TCubVariants;
                         aCT: TCopyType = ct_Rewrite;  aInsPos: integer = -1;  //< -1 - �������� � �����
                         aKeepEmpties: boolean = False;
                         aByRef: boolean = False);
procedure CubRefsToVars (const aSrc: array of TSqrVariants;  var aDst: TCubVariants;
                         aCT: TCopyType = ct_Rewrite;  aInsPos: integer = -1);
  // ������� �������� ���-�� ���������
  // aCnt<0 -- ������� �� aInx �� �����
function DelCubVars (aInx, aCnt: integer;  var aDst: TCubVariants): boolean;
  //
function CubVarsOf (const aSrc: array of TSqrVariants;
                    aKeepEmpties: boolean = False;
                    aByRef: boolean = False): TCubVariants;
function CubRefsOf (const aSrc: array of TSqrVariants): TCubVariants;  // CubVarsOf (, True, True)
function CubPrmsOf (const aSrc: array of variant): TCubVariants;  // ����.3D ������ �� ������ ������� ��������
  // ��������� ������������� aCubVars
function CubVarsToStr (const aCubVars: array of TSqrVariants;
                       aMaxLng: integer = 0;  const aSepS: String = '; '): String;
  // ��������� ��������
function CubVarsEqu (const aCubVars1, aCubVars2: array of TSqrVariants;
                     aWithCase: boolean = True): boolean;





  ////////////////////////
  //  ������ �������
  ////////////////////////

function StrsOf (const aStrs: array of string): TLines;
function WStrsOf (const aWStrs: array of String): TWLines;
function WStrInx (const aWStr: String;
                  const aWStrs: array of String;
                  aWithCase: boolean = True): integer;
function WTextInx (const aWStr: String;
                   const aWStrs: array of String): integer;
procedure VAToWStrs (const aVA: variant;  var aWStrs: TWLines);  overload;
function VAToWStrs (const aVA: variant): TWLines;  overload;
procedure AddWStr (var aStrs: TWLines;  const aStr: string);


procedure VAToInts (const aVA: variant;  var aInts: TIntegers;  aValToArr: boolean = True);  overload;
function VAToInts (const aVA: variant;  aValToArr: boolean = True): TIntegers;  overload;

function IntsOf (const aInts: array of integer): TIntegers;  overload;
function IntsOf (aIntLo, aIntHi: integer): TIntegers;  overload;
  // ���������� � ������
procedure AddInt (var aIntArr: TIntegers;  aInt: integer);
// ������ � TIntegers, ��� � ����������
  // ��������� aInt � aInts, ���� ��� ��� �� ����
procedure IncludeInt  (var aIntArr: TIntegers;  aInt: integer);
procedure IncludeInts (var aIntArr: TIntegers;  const aInts: array of integer);  overload;
procedure IncludeInts (var aIntArr: TIntegers;  aIntLo, aIntHi: integer);  overload;
function IntsSumOf (const aInts1, aInts2: array of integer): TIntegers;
  // ������� ��� aInt �� aInts
procedure ExcludeInt  (var aIntArr: TIntegers;  aInt: integer);
procedure ExcludeInts (var aIntArr: TIntegers;  const aInts: array of integer);  overload;
procedure ExcludeInts (var aIntArr: TIntegers;  aIntLo, aIntHi: integer);  overload;
  // �������� �������
function HasInt (const aIntArr: array of integer;  aInt: integer): boolean;
        // ���� ����� aReqInts[n] � aSrcInts
function HasAnyInt (const aSrcInts, aReqInts: array of integer): boolean;
function IntInx (const aIntArr: array of integer;  aInt: integer): integer;
// ��������� � �����
  // ���������, ��� ��������
function IntsEqu (const aInts1, aInts2: TIntegers): boolean;
  // ���� �������� aVal � aValues, ���������� �����. �������� �� aResults
  // ���� �� ������� - ���������� aElse
function IntMap (const aVal: integer;
                 const aValues, aResults: array of integer;
                 const aElse: integer = -1): integer;
function GetIntMap (var aResult: integer;
                    const aVal: integer;
                    const aValues, aResults: array of integer;
                    const aElse: integer = -1): boolean;
function HasIntMap (const aVal: integer;
                    const aValues, aResults: array of integer;
                    const aElse: integer = -1): boolean;









implementation

uses
  Windows, Variants, VarUtils, Math, WideStrUtils;








type
  TVarType = (v_Unkn ,  // � ������� ����������� ��� ���������
              v_Null ,
              v_Undef,
              v_Err  ,
              v_Num  ,  //
              v_Date ,  //
              v_Str  ,  //
              v_Arr  ,
              v_Obj  ,
              v_Cust );

function Var_Type (const aV: variant): TVarType;
var
  vt: integer;
begin
  if VarIsStr(aV) then begin
    Result := v_Str;
    Exit;
  end;

  vt := FindVarData(aV)^.VType;
  if ( (vt and varArray) <> 0 )        then Result := v_Arr  else
  if ( (vt and varTypeMask) > varAny ) then Result := v_Cust else
  case (vt and varTypeMask) of
    varNull    : Result := v_Null;
    varEmpty   : Result := v_Undef;
    varError   : Result := v_Err;
    varBoolean ,
    varShortInt,
    varByte    ,
    varSmallint,
    varWord    ,
    varInteger ,
    varInt64   ,
    $0015      ,  //< varWord64
    varLongWord,
    $000E      ,  //< varDecimal
    varCurrency,
    varSingle  ,
    varDouble  : Result := v_Num;
    varDate    : Result := v_Date;
    varOleStr  ,
    varString  : Result := v_Str;
    varDispatch,
    varUnknown : Result := v_Obj;
    else         Result := v_Unkn;
  end;
end;

function CompareVar (const aV1, aV2: variant;  aWithCase: boolean): TValueRelationship;
var
  vt1, vt2: TVarType;
  bStr, ok: boolean;
  vt: array [boolean] of TVarType;
  v: array [boolean] of variant;
  f: array [boolean] of double;
  s: array [boolean] of string;
begin
  vt1 := Var_Type(aV1);
  vt2 := Var_Type(aV2);
  Result := CompareValue (ord(vt1), ord(vt2));
  if ( vt1 in [v_Num..v_Str] ) and
     ( vt2 in [v_Num..v_Str] )
  then begin
    // ���������� ������� ����
    if ( vt1 = v_Str ) or ( vt2 = v_Str ) then
    begin
      if ( vt1 = v_Str ) and ( vt2 = v_Str ) then begin
        // 2 ������
        if aWithCase then Result := WideCompareStr  (aV1, aV2)
                     else Result := WideCompareText (aV1, aV2);
      end else begin
        // ������ � ������ ��� �����
        v [False] := aV1;  v [True] := aV2;
        vt[False] := vt1;  vt[True] := vt2;
        bStr := ( vt[True] = v_Str );  //< ��� ������
        f [not bStr] := v [not bStr];
        case vt[not bStr] of
          v_Num : ok := TryStrToFloat    (v[bStr], f[bStr], VarsFS);
          v_Date: ok := TryStrToDateTime (v[bStr], TDateTime(f[bStr]), VarsFS);
          else    ok := False;
        end;
        if ok then begin
          // ��� �����
          Result := CompareValue (f[False], f[True], 0)
        end else begin
          // ��� ������
          s [bStr] := v [bStr];
          s [not bStr] := SysUtils.FloatToStr (f [not bStr], VarsFS);
          Result := CompareText (s[False], s[True]);  //< Text - ��-�� "E"/"e" � ���.������
        end;
      end;
    end else begin
      // 2 �����
      Result := CompareValue (double(aV1), double(aV2), 0);
    end;
  end;
end;


function VarEquals (const aV1, aV2: variant;  aWithCase: boolean): boolean;
begin
  Result := ( CompareVar (aV1, aV2, aWithCase) = 0 );
end;


function VarSame (const aV1, aV2: variant): boolean;
begin
  Result := VarEquals (aV1, aV2, False);
end;



function VarIfThen (aCond: boolean;  const aTrue, aFalse: variant): variant;
begin
  if aCond then Result := aTrue
           else Result := aFalse;
end;


function VarMap (const aVal: variant;
                 const aValues, aResults: array of variant;
                 const aElse: variant;
                 aWithCase: boolean): variant;
var
  n: integer;
begin
  n := VarPos (aVal, aValues, aWithCase);
  if ( n < 0 ) then Result := aElse
               else Result := aResults[n];
end;






function VarCanOrd (const aVar: variant): boolean;
var
  n: int64;
  b: boolean;
begin
  Result := VarIsOrdinal (aVar) or
            ( VarIsStr (aVar) and
              ( TryStrToInt64 (aVar, n) or
                TryStrToBool  (aVar, b)
            ) );
end;


function VarCanReal (const aVar: variant): boolean;
var
  f: double;
begin
  Result := VarIsNumeric(aVar) or
            ( VarIsStr (aVar) and
              TryStrToFloat (aVar, f, VarsFS) );
end;


function Var_Copy (const aVar: variant): variant;
var
  v: variant;
begin
  VarCopyNoInd (v, aVar);
  VarCopy (Result, v);
end;









//
// ���������� variant'�� � ��������� ����
//

function Corred (const aV: variant): variant;
begin
  if VarIsType (aV, varBoolean) then Result := ord (boolean(aV))
                                else Result := aV;
end;

function vFLT (const aV: variant;  aDef: double): double;
begin
  try
    if VarIsNumeric(aV) then Result := Corred(aV)
                        else Result := StrToFloatDef (aV, aDef, VarsFS);
  except Result := aDef; end;
end;

function vMNY (const aV: variant;  aDef: currency): currency;
begin
  try
    if VarIsNumeric(aV) then Result := Corred(aV)
                        else Result := StrToCurrDef (aV, aDef, VarsFS);
  except Result := aDef; end;
end;

function vINT (const aV: variant;  aDef: integer): integer;
begin
  try
    if VarIsOrdinal(aV) then Result := Corred(aV)
                        else Result := StrToIntDef (aV, aDef);
  except Result := aDef; end;
end;

function vSTR (const aV: variant;  const aDef: string): string;
begin
  try
    Result := string (Corred(aV));
  except Result := aDef;  end;
end;

function vDAT (const aV: variant;  aDef: TDateTime): TDateTime;
begin
  try
    if VarIsNumeric (aV) or
       VarIsType (aV,varDate) then Result := TDateTime (Corred(aV))
                              else Result := StrToDateTimeDef (aV, aDef, VarsFS);
  except Result := aDef;  end;
end;










  ////////////////////////
  //  ������� Variant'��
  ////////////////////////

function CompareVars (const aVars1, aVars2: array of variant;
                      aInxes: array of integer;
                      aWithCases: array of boolean): TValueRelationship;
var
  n, i: integer;
  WithCase: boolean;
begin
  Result := 0;
  WithCase := True;
  for n:=0 to High(aInxes) do begin
    i := aInxes[n];
    if ( n <= High(aWithCases) ) then WithCase := aWithCases[n];
    Result := CompareVar (aVars1[i], aVars2[i], WithCase);
    if ( Result <> 0 ) then Exit;
  end;
end;


function VA_Of (const aSrc: array of variant): variant;
begin
  Result := VarArrayOf (aSrc);
end;

function VA_Get (const aVA: variant;  aInx: integer;  const aDef: variant): variant;
begin
  if VarIsArray (aVA) then begin
    if InRange (aInx, VarArrayLowBound (aVA,1),
                      VarArrayHighBound(aVA,1))
      then Result := aVA[aInx]
      else Result := aDef;
  end
  else if ( aInx = 0 ) then Result := aVA
                       else Result := aDef;
end;

function VA_Get (const aVA: variant;  aInx: integer): variant;
begin
  Result := VA_Get (aVA, aInx, Unassigned);
end;


function VA_Lng (const aVA: variant;  aValAsArr: boolean): integer;
begin
  if VarIsArray (aVA) then Result := VarArrayHighBound(aVA,1)-
                                     VarArrayLowBound (aVA,1)+1
                      else Result := ord(aValAsArr);
end;


procedure VA_AddOf (var aDstVA: variant;  const aSrcVars: array of variant;  aDstInx: integer);
var
  Vars: TVariants;
begin
  if ( Length(aSrcVars) = 0 ) then Exit;
  if VarIsArray (aDstVA) and
     ( VarArrayHighBound(aDstVA,1) >= 0 ) then Vars := aDstVA
                                          else Vars := nil;
  AddVars (aSrcVars, Vars, aDstInx);
  aDstVA := Vars;
end;




// �������� � aResStr'� ������ aStr
function AddStr_ (var aResStr: String;  const aStr: string;
                 aInx, aLoInx, aHiInx: integer;
                 aMaxLng: integer;  const aSepS: String): boolean;
begin
  if ( aInx > aLoInx ) then aResStr := aResStr + aSepS;
  aResStr := aResStr + aStr;
  Result := ( aMaxLng <= 0 ) or
            ( Length(aResStr) <= aMaxLng );
  if not Result then
    if ( aInx < aHiInx ) then aResStr := aResStr + aSepS + ' ... ';
end;

// �������� � aResStr'� ��������� ������������� aVal'�
function AddValStr (var aResStr: String;  const aVal: variant;
                    aInx, aLoInx, aHiInx: integer;
                    aMaxLng: integer;  const aSepS: String): boolean;
begin
  Result := AddStr_ (aResStr,
                    VAToStr (aVal, aMaxLng-Length(aResStr), aSepS),
                    aInx, aLoInx, aHiInx,
                    aMaxLng, aSepS);
end;

function VAToStr (const aVA: variant;
                  aMaxLng: integer;  const aSepS: String;  aToPack: boolean): String;
var
  d, n, k, n1, n2: integer;
  v, vk: variant;
begin
  Result := '';
  if VarIsArray (aVA) then begin
    d := VarArrayDimCount(aVA);
    case d of
      1: begin
           n1 := VarArrayLowBound (aVA,1);
           n2 := VarArrayHighBound(aVA,1);
           if aToPack then begin
             // ����������� ������ �������� (����: Value[Count])
             n := n1;
             while (n <= n2) do begin
               v := aVA[n];
               k := n+1;
               if VarIsOrdinal (v) then
                 while ( k <= n2 ) do begin
                   vk := aVA[k];
                   if VarIsOrdinal(vk) and ( v = vk ) then Inc(k)
                                                      else break;
                 end;
               if ( k-n = 1 ) then begin
                 if not AddValStr (Result, v, n,n1,n2, aMaxLng, aSepS) then break;
               end else begin
                 if not AddStr_ (Result,
                                WideFormat ('%s[%d]', [string(v), k-n]),
                                n,n1,n2, aMaxLng, aSepS) then break;
               end;
               n := k;
             end;
           end else begin
             // ������ ������ ��������
             for n:=n1 to n2 do
               if not AddValStr (Result, aVA[n], n,n1,n2, aMaxLng, aSepS) then break;
           end;
           Result := '('+Result+')';
         end;
      {$IFNDEF NoSA}
      //2: Result := SAToStr (aVA, aMaxLng, aSepS);
      {$ENDIF}
      else
        raise Exception.CreateFmt ('Unsupported VarArray dimension count: %d', [d]);
    end;
  end else begin
    if VarIsNull (aVA) then Result := 'NULL'  else
    if VarIsEmpty(aVA) then Result := 'EMPTY' else
    if VarIsType (aVA, varDispatch) then Result := 'OBJECT' else
    try
      if VarIsType (aVA, varDate) then  // ����/�����
        Result := WideQuotedStr (FormatDateTime (VarsFs.LongDateFormat+' '+
                                                 VarsFs.LongTimeFormat, aVA), '''')
      else begin
        Result := string(aVA);
        if VarIsStr (aVA) then begin
          // �������� ��� ���.������� �� �� hex-������� (C-��������)
          if ( Pos ('\', Result) > 0 ) then
            Result := WideReplaceStr (Result, '\', '\\');
          for n:=Length(Result) downto 1 do
            if ( Result[n] < ' ' ) then begin
              Insert (WideFormat ('\x%.2x',[ord(Result[n])]),
                      Result,
                      n+1);
              Delete (Result, n, 1);
            end;
          // ������������
          Result := WideQuotedStr (Result, '''');
          // ��������� �����
          if ( aMaxLng > 0 ) and
             ( Length(Result) > aMaxLng )
          then
            Result := Copy (Result, 1, aMaxLng) + '''... ';
        end;
      end;
    except
      on e:Exception do Result := WideFormat ('EXCEPT:�%s�', [e.Message])
    end;
  end;
end;









function VarsIfThen (aCond: boolean;  const aTrue, aFalse: array of variant): TVariants;
begin
  if aCond then Result := VarsOf (aTrue )
           else Result := VarsOf (aFalse);
end;


procedure VAToVars (const aVA: variant;  var aVars: TVariants);
begin
  if VarIsArray (aVA) then begin
    if ( VarArrayHighBound(aVA,1) < 0 ) then aVars := nil
                                        else aVars := aVA;
  end
  else aVars := VarsOf([aVA]);
end;

function VAToVars (const aVA: variant): TVariants;
begin
  VAToVars (aVA, Result);
end;



procedure VarsToVars (const aSrc: array of Variant;  var aDst: TVariants);
var
  n: integer;
  New: TVariants;
begin
  SetLength (New, Length(aSrc));
  for n:=0 to High(aSrc) do
    New[n] := aSrc[n];
  aDst := New;
end;

function VarsOf (const aSrc: array of Variant): TVariants;
begin
  VarsToVars (aSrc, Result);
end;

function VarsToPVars (const aSrc: array of Variant;  const aDst: array of PVariant): boolean;
var
  n: integer;
begin
  Result := (Length(aSrc) = Length(aDst));
  for n:=0 to Min (High(aSrc), High(aDst)) do
    if ( aDst[n] <> nil ) then
      aDst[n]^ := aSrc[n];
end;


function GetVarDef (const aVars: array of variant;  aInx: integer;
                    const aDef: variant): variant;
begin
  if InRange (aInx, 0, High(aVars)) then Result := aVars[aInx]
                                    else Result := aDef;
end;

function GetVar (const aVars: array of variant;  aInx: integer): variant;
begin
  Result := GetVarDef (aVars, aInx, Unassigned);
end;



procedure ClearVars (var aVars: TVariants;  aLng: integer = -1);
var
  n: integer;
begin
  if ( aLng > 0 ) then SetLength (aVars, aLng);
  for n:=0 to High(aVars) do
    aVars[n] := Unassigned;
end;


procedure PadEndVars (var aVars: TVariants;  const aPadVal: variant;  aCount: integer);
var
  n: integer;
begin
  for n:=1 to aCount-Length(aVars) do
    AddVars ([aPadVal], aVars);
end;

procedure PadBeginVars (var aVars: TVariants;  const aPadVal: variant;  aCount: integer);
var
  n: integer;
begin
  for n:=1 to aCount-Length(aVars) do
    AddVars ([aPadVal], aVars, 0);
end;



procedure AddVars (const aSrc: array of Variant;  var aDst: TVariants;  aDstInx: integer);
var
  n, d, s: integer;
begin
  d := Length(aDst);
  s := Length(aSrc);
  if not InRange (aDstInx, 0, High(aDst)) then aDstInx := d;
  SetLength (aDst, d+s);
  // ������������ ����� (����� ����� �� ������� �������)
  for n:=d-1 downto aDstInx do
    aDst [n+s] := aDst[n];
  // ������� aSrc
  for n:=0 to s-1 do
    aDst [aDstInx+n] := aSrc[n];
end;

function VarsSumOf (const aSrc1, aSrc2: array of variant;  aSrc1Inx: integer): TVariants;
begin
  Result := VarsOf (aSrc1);
  AddVars (aSrc2, Result, aSrc1Inx);
end;

procedure FillVars (const aSrc: array of Variant;  var aDst: TVariants;  aSrcCnt: integer);
var
  n: integer;
begin
  aDst := nil;
  for n:=1 to aSrcCnt do
    AddVars (aSrc, aDst);
end;

function FillVars (const aSrc: array of Variant;  aSrcCnt: integer): TVariants;
begin
  FillVars (aSrc, Result, aSrcCnt);
end;





function DelVar (const aVar: variant;  var aDst: TVariants;  aWithCase: boolean): boolean;
var
  n, k: integer;
  New: TVariants;
begin
  Result := False;
  SetLength (New, Length(aDst));
  k := 0;  //< ������� ������� NewVars
  for n:=0 to High(aDst) do
    if VarEquals (aVar, aDst[n], aWithCase) then Result := True
    else begin
      New[k] := aDst[n];
      Inc(k);
    end;
  SetLength (New, k);
  aDst := New;
end;

procedure DelVar (const aInx, aCnt: integer;  var aDst: TVariants);
var
  n, k: integer;
  New: TVariants;
begin
  SetLength (New, Length(aDst)-aCnt);
  k := 0;
  for n:=0 to High(aDst) do
    if not InRange (n, aInx, aInx+aCnt-1) then begin
      New[k] := aDst[n];
      Inc(k);
    end;
  aDst := New;
end;


function VarPos (const aVar: variant;  const aVars: array of variant;  aWithCase: boolean): integer;
var
  n: integer;
begin
  Result := -1;
  for n:=0 to High(aVars) do
    if VarEquals (aVar, aVars[n], aWithCase) then begin
      Result := n;
      Exit;
    end;
end;

function HasVar (const aVar: variant;  const aVars: array of variant;  aWithCase: boolean): boolean;
begin
  Result := ( VarPos (aVar, aVars, aWithCase) >= 0 );
end;



function VarsReplace (const aVars: TVariants;  const aFind, aReplace: variant;
                      aWithCase: boolean): boolean;
var
  n: integer;
begin
  Result := False;
  for n:=0 to High(aVars) do
    if VarEquals (aFind, aVars[n], aWithCase) then begin
      aVars[n] := aReplace;
      Result := True;
    end;
end;


function IncludeVar (const aVar: variant;  var aVars: TVariants;  aWithCase: boolean): boolean;
begin
  Result := not HasVar (aVar, aVars, aWithCase);
  if Result then AddVars ([aVar], aVars);
end;

function ExcludeVar (const aVar: variant;  var aVars: TVariants;  aWithCase: boolean): boolean;
begin
  Result := DelVar (aVar, aVars, aWithCase);
end;



function CrossVars (var aVars1: TVariants;  const aVars2: array of variant;
                    aWithCase: boolean): boolean;
var
  New: TVariants;
  n: integer;
begin
  New := nil;
  for n:=0 to High(aVars1) do
    if HasVar (aVars1[n], aVars2, aWithCase) then
      IncludeVar (aVars1[n], New, aWithCase);
  aVars1 := New;
  Result := ( aVars1 <> nil );
end;



function VarsToStr (const aVars: array of variant;  aMaxLng: integer;  const aSepS: String): String;
var
  n: integer;
begin
  Result := '';
  for n:=0 to High(aVars) do
    if not AddValStr (Result, aVars[n], n,0,High(aVars), aMaxLng, aSepS) then break;
  Result := '('+Result+')';
end;




function VarsEqu (const aVars1, aVars2: array of variant;  aWithCase: boolean): boolean;
var
  n: integer;
begin
  Result := False;
  if ( Length(aVars1) <> Length(aVars2) ) then Exit;
  for n:=0 to High(aVars1) do
    if not VarEquals (aVars1[n], aVars2[n], aWithCase) then Exit;
  Result := True;
end;

function VarsEqu (const aVars1, aVars2: array of variant;
                  const aCmpFlds: array of integer;  aWithCase: boolean): boolean;
var
  n,Inx: integer;
begin
  if ( Length(aCmpFlds) = 0 ) then begin
    Result := VarsEqu (aVars1, aVars2, aWithCase);
    Exit;
  end;
  //
  Result := False;
  for n:=0 to High(aCmpFlds) do begin
    Inx := aCmpFlds[n];
    if ( Inx > High(aVars1) ) or
       ( Inx > High(aVars2) ) or
       ( not VarEquals (aVars1[Inx], aVars2[Inx], aWithCase) ) then Exit;
  end;
  Result := True;
end;





procedure VarsExtract (var aVars: TVariants;  const aStr: string;
                       const aSeps, aSpaces, aOpenQuotes, aCloseQuotes: TSysCharSet;
                       aKeepEmpties: boolean);
var
  p1, p2, pE, L: integer;
  WithQts: boolean;
  Seps, Spaces, BegSeps, CloseQs: TSysCharSet;
begin
  aVars := nil;
  L := Length(aStr);
  WithQts := ( aOpenQuotes <> [] );
  if WithQts then begin
    CloseQs := aCloseQuotes;
    if ( CloseQs = [] ) then CloseQs := aOpenQuotes;
  end;
  Spaces := aSpaces - aOpenQuotes - aCloseQuotes;
  Seps := aSeps - aSpaces - aOpenQuotes - aCloseQuotes;
  BegSeps := Seps + Spaces;
  p1 := 1;
  repeat
    // ���� ������ ����� (� �������� ��������� ��������)
    repeat
      if ( p1 > L ) then Exit;
      if aKeepEmpties then begin
        if not ( CharInSet( aStr[p1], Spaces ) ) then break;
      end else begin
        if not CharInSet( aStr[p1], BegSeps ) then break;
      end;
      Inc(p1);
    until False;
    // ���� �������� �����������
    p2 := p1 + ord ((not WithQts) and
                    (not aKeepEmpties));
    repeat
      if WithQts then  // ��������� �� ����������� �������
        while ( p2 <= L ) and
              ( CharInSet( aStr[p2], aOpenQuotes ) ) do
          repeat  // ���� ���������� �������
            Inc(p2);
            if ( p2 > L ) then break;
            if ( CharInSet( aStr[p2], CloseQs ) ) then begin
              Inc(p2);  break;
            end;
          until False;
      // ���������� ������
      if ( p2 <= L ) and
         ( not CharInSet( aStr[p2], Seps ) ) then Inc(p2)
                                    else break;
    until False;
    pE := p2;
    // ���� ����� ����� (�������� �������� �������)
    while ( p2-1 >= p1 ) and
          ( CharInSet( aStr[p2-1], Spaces ) ) do Dec(p2);
    // �������� �����
    SetLength (aVars, Length(aVars)+1);
    aVars [High(aVars)] := Copy (aStr, p1, p2-p1);
    if aKeepEmpties then p1 := pE+1
                    else p1 := p2;
  until False;
end;


function VarsConcat (const aVars: array of variant;  const aSepStr: string;
                     aWithFinSep: boolean;
                     const aReplStr: string;
                     aNoEmpty: boolean;
                     const aFormat : string): string;
var
  n: integer;
  ToRepl, ToForm: boolean;
  SrcS: string;
begin
  ToRepl := ( aReplStr <> #0 ) and ( aSepStr <> '' );
  ToForm := ( aFormat <> #0 );
  Result := '';
  for n:=0 to High(aVars) do begin
    SrcS := aVars[n];
    if aNoEmpty and ( SrcS = '' ) then continue;
    if ToForm then SrcS := WideFormat (aFormat, [SrcS]);
    if ToRepl then SrcS := WideReplaceStr (SrcS, aSepStr, aReplStr);
    Result := Result +
              IfThen (( n > 0 ) and
                      ( (not aNoEmpty) or
                        (Result <> '') ),
                      aSepStr) +
              SrcS;
  end;
  if aWithFinSep then
    Result := Result + aSepStr;
end;


function VarsConcatNE (const aVars: array of variant;
                       const aSepStr: string;  aWithFinSep: boolean;
                       const aReplStr: string): string;
begin
  Result := VarsConcat (aVars, aSepStr, aWithFinSep, aReplStr, True);
end;


function VarsConcatFmt (const aFormat: string;  const aVars: array of variant;
                        const aSepStr: string;  aWithFinSep: boolean;
                        const aReplStr: string
                       ): string;
begin
  Result := VarsConcat (aVars, aSepStr, aWithFinSep, aReplStr, True, aFormat);
end;





function AddSortVar (const aVar: variant;  var aDst: TVariants;
                     aWithCase, aAscending, aToAdd: boolean): integer;
var
  d1, d2, d, r, rL, rH: integer;
begin
  d1 := 0;
  d2 := High(aDst);
  d := 0;
  if ( d2 < 0 ) then d := 0
  else begin
    rL := CompareVar (aVar, aDst[0 ], aWithCase);
    rH := CompareVar (aVar, aDst[d2], aWithCase);
    if ( rL = 0 ) or
       ( (rL < 0) = aAscending ) then d := 0 else
    if ( rH = 0 ) or
       ( (rH > 0) = aAscending ) then d := d2+1
    else begin
      Inc(d1);
      while ( d1 <= d2 ) do begin
        d := (d1 + d2) shr 1;
        if ( d1 = d2 ) then break;
        r := CompareVar (aDst[d], aVar, aWithCase);
        if ( r = 0 ) then break;
        if ( (r < 0) = aAscending ) then d1 := d+1
                                    else d2 := d;
      end;
    end;
  end;
  if aToAdd then AddVars ([aVar], aDst, d);
  Result := d;
end;


procedure SortVars (var aVars: TVariants;  aWithCase, aAscending: boolean);
var
  New: TVariants;
  n: integer;
begin
  New := nil;
  for n:=0 to High(aVars) do
    AddSortVar (aVars[n], New, aWithCase, aAscending);
  aVars := New;
end;






  //
  // ������ � ������������� ��������
  //



procedure VAToSqrVars (const aVA: variant;  var aSqrVars: TSqrVariants);
begin
  if VarIsArray (aVA) then begin
    if ( VarArrayHighBound(aVA,1) < 0 ) then aSqrVars := nil
                                        else aSqrVars := aVA;
  end
  else aSqrVars := SqrVarsOf ([VarsOf([aVA])]);
end;

function VAToSqrVars (const aVA: variant): TSqrVariants;
begin
  VAToSqrVars (aVA, Result);
end;




procedure SqrVarsToVars (const aSrc: array of TVariants;  var aDst: TSqrVariants;
                         aCT: TCopyType;  aInsPos: integer;
                         aKeepEmpties, aByRef: boolean);
var
  n, d, s: integer;
begin
  // ���������� ����� Src
  if aKeepEmpties then s := Length(aSrc)
  else begin
    s := 0;
    for n:=0 to High(aSrc) do
      if ( Length(aSrc[n]) > 0 ) then Inc (s);
  end;
  // ������� Dst
  if ( aCT = ct_Rewrite ) then aDst := nil;
  d := Length(aDst);
  if not InRange (aInsPos, 0, d-1) then aInsPos := d;
  SetLength (aDst, d+s);
  // ������������ ����� (����� ����� �� ������� �������)
  for n:=d-1 downto aInsPos do
    aDst [n+s] := aDst[n];
  // ������� aSrc
  d := aInsPos;
  for n:=0 to High(aSrc) do
    if aKeepEmpties or (Length(aSrc[n]) > 0) then begin
      if aByRef then aDst[d] := aSrc[n]
                else aDst[d] := VarsOf (aSrc[n]);
      Inc(d);
    end;
end;

procedure AppendSqrVars (const aSrc: array of TVariants;  var aDst: TSqrVariants);
begin
  SqrVarsToVars (aSrc, aDst, ct_Append);
end;

procedure SqrRefsToVars (const aSrc: array of TVariants;  var aDst: TSqrVariants;
                         aCT: TCopyType;  aInsPos: integer);
begin
  SqrVarsToVars (aSrc, aDst, aCT, aInsPos, True, True);
end;

procedure AppendSqrRefs (const aSrc: array of TVariants;  var aDst: TSqrVariants);
begin
  SqrRefsToVars (aSrc, aDst, ct_Append);
end;

function SqrVarsOf (const aSrc: array of TVariants;  aKeepEmpties, aByRef: boolean): TSqrVariants;
begin
  SqrVarsToVars (aSrc, Result, ct_Rewrite, -1, aKeepEmpties, aByRef);
end;

function SqrRefsOf (const aSrc: array of TVariants): TSqrVariants;
begin
  Result := SqrVarsOf (aSrc, True, True);
end;



function SqrPrmsOf (const aSrc: array of variant): TSqrVariants;
var
  n: integer;
begin
  SetLength (Result, Length(aSrc));
  for n:=0 to High(Result) do
    Result[n] := VarsOf ([aSrc[n]]);
end;



function GetSqrVarDef (const aSqrVars: array of TVariants;  aRow, aCol: integer;
                       const aDef: variant): variant;
begin
  if InRange (aRow, 0, High(aSqrVars)) and
     InRange (aCol, 0, High(aSqrVars[aRow])) then Result := aSqrVars [aRow] [aCol]
                                             else Result := aDef;
end;
function GetSqrVar (const aSqrVars: array of TVariants;  aRow, aCol: integer): variant;
begin
  Result := GetSqrVarDef (aSqrVars, aRow, aCol, Unassigned);
end;



procedure ClearSqrVars (var aSqrVars: TSqrVariants;  aLng1, aLng2: integer);
var
  n: integer;
begin
  if ( aLng1 > 0 ) then SetLength (aSqrVars, aLng1);
  for n:=0 to High(aSqrVars) do
    ClearVars (aSqrVars[n], aLng2);
end;



function DelSqrVars (aInx, aCnt: integer;  var aDst: TSqrVariants): boolean;
var
  n: integer;
begin
  Result := False;
  if ( not InRange (aInx, 0, High(aDst)) ) or ( aCnt = 0 ) then Exit;
  if ( aCnt < 0 ) or
     ( aInx+aCnt > Length(aDst) ) then aCnt := Length(aDst)-aInx;
  //
  for n:=aInx to High(aDst)-aCnt do
    aDst [n] := aDst [n+aCnt];
  SetLength (aDst, Length(aDst)-aCnt);
  Result := True;
end;


function SqrVarsToStr (const aSqrVars: array of TVariants;
                       aMaxLng: integer;  const aSepS: String): String;
var
  n: integer;
begin
  Result := '';
  for n:=0 to High(aSqrVars) do
    if not AddStr_ (Result,
                   VarsToStr (aSqrVars[n], aMaxLng-Length(Result), aSepS),
                   n,0,High(aSqrVars), aMaxLng, aSepS) then break;
  Result := '('+Result+')';
end;




function SqrVarsColumn (const aSqrVars: array of TVariants;
                        const aRowInxes: array of integer;  aCol: integer): TVariants;
var
  n, inx: integer;
begin
  SetLength (Result, Length(aRowInxes));
  for n:=0 to High(aRowInxes) do begin
    inx := aRowInxes[n];
    if InRange (inx , 0, High(aSqrVars)) and
       InRange (aCol, 0, High(aSqrVars[inx]))
    then
      Result[n] := aSqrVars[inx][aCol]
    else
      Result[n] := Unassigned;
  end;
end;



function SqrVarsColumn (const aSqrVars: array of TVariants;  aCol: integer): TVariants;
begin
  Result := SqrVarsColumn (aSqrVars, IntsOf(0,High(aSqrVars)), aCol);
end;






function SqrVarsEqu (const aSqrVars1, aSqrVars2: array of TVariants;
                     const aCmpFlds: array of integer;  aWithCase: boolean): boolean;
var
  n: integer;
begin
  Result := False;
  if ( Length(aSqrVars1) <> Length(aSqrVars2) ) then Exit;
  for n:=0 to High(aSqrVars1) do
    if not VarsEqu (aSqrVars1[n], aSqrVars2[n], aCmpFlds, aWithCase) then Exit;
  Result := True;
end;

function SqrVarsEqu (const aSqrVars1, aSqrVars2: array of TVariants;
                     aWithCase: boolean): boolean;
begin
  Result := SqrVarsEqu (aSqrVars1, aSqrVars2, [], aWithCase);
end;





function SqrVarPos (const aVar: variant;  const aSqrVars: array of TVariants;
                    aKeyCol: integer;  aWithCase: boolean): integer;
var
  n: integer;
begin
  Result := -1;
  for n:=0 to High(aSqrVars) do
    if InRange (aKeyCol, 0, High(aSqrVars[n])) and
       VarEquals (aVar, aSqrVars[n][aKeyCol], aWithCase)
    then begin
      Result := n;  Exit;
    end;
end;

function SqrHasVar (const aVar: variant;  const aSqrVars: array of TVariants;
                    aKeyCol: integer;  aWithCase: boolean): boolean;
begin
  Result := ( SqrVarPos (aVar, aSqrVars, aKeyCol, aWithCase) >= 0 );
end;





function SqrVarsPos (const aSqrVars: array of TVariants;
                     const aVars: array of variant;
                     const aKeyCols: array of integer;  aWithCase: boolean): integer;
var
  n: integer;
begin
  Result := -1;
  for n:=0 to High(aSqrVars) do
    if VarsEqu (aSqrVars[n], aVars, aKeyCols, aWithCase) then begin
      Result := n;  Exit;
    end;
end;



procedure SqrVarsExtract (var aSqrVars: TSqrVariants;  const aStr: string;
                          const aEqus, aSeps, aSpaces, aOpenQuotes, aCloseQuotes: TSysCharSet);
var
  vars: TVariants;
  n: integer;
begin
  VarsExtract (vars, aStr, aSeps, aSpaces, aOpenQuotes, aCloseQuotes);
  aSqrVars := nil;
  SetLength (aSqrVars, Length(vars));
  for n:=0 to High(vars) do
    VarsExtract (aSqrVars[n], vars[n], aEqus, aSpaces, aOpenQuotes, aCloseQuotes);
end;


function SqrVarsConcat (const aSqrVars: TSqrVariants;
                        const aEquStr, aSepStr: string;
                        aWithFinSep: boolean): string;
var
  vars: TVariants;
  n: integer;
begin
  vars := nil;
  SetLength (vars, Length(aSqrVars));
  for n:=0 to High(aSqrVars) do
    vars[n] := VarsConcat (aSqrVars[n], aEquStr, False);
  Result := VarsConcat (vars, aSepStr, aWithFinSep);
end;


function SqrVarsConcat (const aSqrVars: TSqrVariants;
                        const aRowInxes: array of integer;  aCol: integer;
                        const aSepStr: string;
                        aWithFinSep: boolean;
                        aReplStr: string;
                        aNoEmpty: boolean): string;
begin
  Result := VarsConcat (SqrVarsColumn (aSqrVars, aRowInxes, aCol),
                        aSepStr, aWithFinSep, aReplStr, aNoEmpty);
end;

function SqrVarsConcat (const aSqrVars: TSqrVariants;  aCol: integer;
                        const aSepStr: string;
                        aWithFinSep: boolean;
                        aReplStr: string;
                        aNoEmpty: boolean): string;
begin
  Result := SqrVarsConcat (aSqrVars, IntsOf(0,High(aSqrVars)), aCol,
                           aSepStr, aWithFinSep, aReplStr, aNoEmpty);
end;








function AddSortSqrVar (const aVars: array of variant;  var aDstSqr: TSqrVariants;
                        aKeyCol: integer;  aWithCase, aAscending: boolean): integer;
var
  vars: TVariants;
  inx: integer;
begin
  vars := SqrVarsColumn (aDstSqr, aKeyCol);
  inx := AddSortVar (GetVar (aVars, aKeyCol),
                     vars,
                     aWithCase, aAscending, False);
  SqrRefsToVars ([VarsOf(aVars)],
                 aDstSqr,
                 ct_Insert, inx);
  Result := 0;
end;


procedure SortSqrVars (var aSqrVars: TSqrVariants;  aKeyCol: integer;
                       aWithCase, aAscending: boolean);
var
  New: TSqrVariants;
  n: integer;
begin
  New := nil;
  for n:=0 to High(aSqrVars) do
    AddSortSqrVar (aSqrVars[n], New, aKeyCol, aWithCase, aAscending);
  aSqrVars := New;
end;





  //
  // ������ � ���������� ��������
  //



procedure CubVarsToVars (const aSrc: array of TSqrVariants;  var aDst: TCubVariants;
                         aCT: TCopyType;  aInsPos: integer;
                         aKeepEmpties, aByRef: boolean);
var
  n, d, s: integer;
begin
  // ���������� ����� Src
  if aKeepEmpties then s := Length(aSrc)
  else begin
    s := 0;
    for n:=0 to High(aSrc) do
      if ( Length(aSrc[n]) > 0 ) then Inc (s);
  end;
  // ������� Dst
  if ( aCT = ct_Rewrite ) then aDst := nil;
  d := Length(aDst);
  if not InRange (aInsPos, 0, d-1) then aInsPos := d;
  SetLength (aDst, d+s);
  // ������������ ����� (����� ����� �� ������� �������)
  for n:=d-1 downto aInsPos do
    aDst [n+s] := aDst[n];
  // ������� aSrc
  d := aInsPos;
  for n:=0 to High(aSrc) do
    if aKeepEmpties or (Length(aSrc[n]) > 0) then begin
      if aByRef then aDst[d] := aSrc[n]
                else aDst[d] := SqrVarsOf (aSrc[n]);
      Inc(d);
    end;
end;


procedure CubRefsToVars (const aSrc: array of TSqrVariants;  var aDst: TCubVariants;
                         aCT: TCopyType;  aInsPos: integer);
begin
  CubVarsToVars (aSrc, aDst, aCT, aInsPos, True, True);
end;


function CubVarsOf (const aSrc: array of TSqrVariants;  aKeepEmpties, aByRef: boolean): TCubVariants;
begin
  CubVarsToVars (aSrc, Result, ct_Rewrite, -1, aKeepEmpties, aByRef);
end;


function CubRefsOf (const aSrc: array of TSqrVariants): TCubVariants;
begin
  Result := CubVarsOf (aSrc, True, True);
end;


function DelCubVars (aInx, aCnt: integer;  var aDst: TCubVariants): boolean;
var
  n: integer;
begin
  Result := False;
  if ( not InRange (aInx, 0, High(aDst)) ) or ( aCnt = 0 ) then Exit;
  if ( aCnt < 0 ) or
     ( aInx+aCnt > Length(aDst) ) then aCnt := Length(aDst)-aInx;
  //
  for n:=aInx to High(aDst)-aCnt do
    aDst [n] := aDst [n+aCnt];
  SetLength (aDst, Length(aDst)-aCnt);
  Result := True;
end;


function CubPrmsOf (const aSrc: array of variant): TCubVariants;
var
  n: integer;
begin
  SetLength (Result, Length(aSrc));
  for n:=0 to High(Result) do
    Result[n] := SqrPrmsOf ([aSrc[n]]);
end;


function CubVarsToStr (const aCubVars: array of TSqrVariants;
                       aMaxLng: integer = 0;  const aSepS: String = '; '): String;
var
  n: integer;
begin
  Result := '';
  for n:=0 to High(aCubVars) do
    if not AddStr_ (Result,
                   SqrVarsToStr (aCubVars[n], aMaxLng-Length(Result), aSepS),
                   n,0,High(aCubVars), aMaxLng, aSepS) then break;
  Result := '('+Result+')';
end;



function CubVarsEqu (const aCubVars1, aCubVars2: array of TSqrVariants;
                     aWithCase: boolean): boolean;
var
  n: integer;
begin
  Result := False;
  if ( Length(aCubVars1) <> Length(aCubVars2) ) then Exit;
  for n:=0 to High(aCubVars1) do
    if not SqrVarsEqu (aCubVars1[n], aCubVars2[n], aWithCase) then Exit;
  Result := True;
end;








  ////////////////////////
  //  ������ �������
  ////////////////////////


function StrsOf (const aStrs: array of string): TLines;
var
  n: integer;
begin
  SetLength (Result, Length(aStrs));
  for n:=0 to High(aStrs) do
    Result[n] := aStrs[n];
end;

function WStrsOf (const aWStrs: array of String): TWLines;
var
  n: integer;
begin
  SetLength (Result, Length(aWStrs));
  for n:=0 to High(aWStrs) do
    Result[n] := aWStrs[n];
end;

function WStrInx (const aWStr: String;
                  const aWStrs: array of String;
                  aWithCase: boolean): integer;
var
  n: integer;
begin
  Result := -1;
  for n:=0 to High(aWStrs) do
    if ( aWithCase and
         WideSameStr (aWStr, aWStrs[n]) )
       or
       ( (not aWithCase) and
         WideSameText (aWStr, aWStrs[n]) )
    then begin
      Result := n;  exit;
    end;
end;

function WTextInx (const aWStr: String;
                   const aWStrs: array of String): integer;
begin
  Result := WStrInx (aWStr, aWStrs, False);
end;


procedure VAToWStrs (const aVA: variant;  var aWStrs: TWLines);
begin
  if VarIsArray (aVA) then begin
    if ( VarArrayHighBound(aVA,1) < 0 ) then aWStrs := nil
                                        else aWStrs := aVA;
  end
  else aWStrs := WStrsOf ([aVA]);
end;

function VAToWStrs (const aVA: variant): TWLines;
begin
  VAToWStrs (aVA, Result);
end;

procedure AddWStr (var aStrs: TWLines;  const aStr: string);
begin
  SetLength (aStrs, Length(aStrs)+1);
  aStrs [High(aStrs)] := aStr;
end;








procedure VAToInts (const aVA: variant;  var aInts: TIntegers;  aValToArr: boolean);
begin
  if VarIsArray (aVA) then begin
    if ( VarArrayHighBound(aVA,1) < 0 ) then aInts := nil
                                        else aInts := aVA;
  end
  else
    if aValToArr then aInts := IntsOf ([aVA])
                 else aInts := nil;
end;

function VAToInts (const aVA: variant;  aValToArr: boolean): TIntegers;
begin
  VAToInts (aVA, Result, aValToArr);
end;


function IntsOf (const aInts: array of integer): TIntegers;
var
  n: integer;
begin
  SetLength (Result, Length(aInts));
  for n:=0 to High(aInts) do
    Result[n] := aInts[n];
end;

function IntsOf (aIntLo, aIntHi: integer): TIntegers;
begin
  Result := nil;
  IncludeInts (Result, aIntLo, aIntHi);
end;


procedure AddInt (var aIntArr: TIntegers;  aInt: integer);
begin
  SetLength (aIntArr, Length(aIntArr)+1);
  aIntArr [High(aIntArr)] := aInt;
end;

procedure IncludeInt (var aIntArr: TIntegers;  aInt: integer);
var
  n: integer;
begin
  for n:=0 to High(aIntArr) do
    if ( aIntArr[n] = aInt ) then Exit;
  AddInt (aIntArr, aInt);
end;

procedure IncludeInts (var aIntArr: TIntegers;  const aInts: array of integer);
var
  n: integer;
begin
  for n:=0 to High(aInts) do
    IncludeInt (aIntArr, aInts[n]);
end;

procedure IncludeInts (var aIntArr: TIntegers;  aIntLo, aIntHi: integer);
var
  n: integer;
begin
  for n:=aIntLo to aIntHi do
    IncludeInt (aIntArr, n);
end;


function IntsSumOf (const aInts1, aInts2: array of integer): TIntegers;
begin
  Result := IntsOf (aInts1);
  IncludeInts (Result, aInts2);
end;


procedure ExcludeInt (var aIntArr: TIntegers;  aInt: integer);
var
  n, k: integer;
  NewInts: TIntegers;
begin
  SetLength (NewInts, Length(aIntArr));
  k := 0;  //< ������� ������� NewInts
  for n:=0 to High(aIntArr) do
    if ( aIntArr[n] <> aInt ) then begin
      NewInts[k] := aIntArr[n];
      Inc(k);
    end;
  SetLength (NewInts, k);
  aIntArr := nil;
  aIntArr := NewInts;
end;

procedure ExcludeInts (var aIntArr: TIntegers;  const aInts: array of integer);
var
  n: integer;
begin
  for n:=0 to High(aInts) do
    ExcludeInt (aIntArr, aInts[n]);
end;

procedure ExcludeInts (var aIntArr: TIntegers;  aIntLo, aIntHi: integer);
var
  n: integer;
begin
  for n:=aIntLo to aIntHi do
    ExcludeInt (aIntArr, n);
end;




function IntInx (const aIntArr: array of integer;  aInt: integer): integer;
var
  n: integer;
begin
  Result := -1;
  for n:=0 to High(aIntArr) do
    if ( aIntArr[n] = aInt ) then begin
      Result := n;
      Exit;
    end;
end;


function HasInt (const aIntArr: array of integer;  aInt: integer): boolean;
begin
  Result := ( IntInx (aIntArr, aInt) >= 0 );
end;

function HasAnyInt (const aSrcInts, aReqInts: array of integer): boolean;
var
  n: integer;
begin
  Result := True;
  for n:=0 to High(aReqInts) do
    if HasInt (aSrcInts, aReqInts[n]) then Exit;
  Result := False;
end;




function IntsEqu (const aInts1, aInts2: TIntegers): boolean;
var
  n: integer;
begin
  Result := False;
  if ( Length(aInts1) <> Length(aInts2) ) then Exit;
  for n:=0 to High(aInts1) do
    if ( aInts1[n] <> aInts2[n] ) then Exit;
  Result := True;
end;

function GetIntMap (var aResult: integer;
                    const aVal: integer;
                    const aValues, aResults: array of integer;
                    const aElse: integer): boolean;
var
  n: integer;
begin
  if ( Length(aValues) <> Length(aResults) ) then
    raise Exception.Create ('GetIntMap`s arrays have different sizes');
  n := IntInx (aValues, aVal);
  Result := ( n >= 0 );
  if Result then aResult := aResults[n]
            else aResult := aElse;

end;

function HasIntMap (const aVal: integer;
                    const aValues, aResults: array of integer;
                    const aElse: integer): boolean;
var
  res: integer;
begin
  Result := GetIntMap (res, aVal, aValues, aResults, aElse);
end;

function IntMap (const aVal: integer;
                 const aValues, aResults: array of integer;
                 const aElse: integer): integer;
begin
  GetIntMap (Result, aVal, aValues, aResults, aElse);
end;





initialization
  VarsFs := TFormatSettings.Create( GetThreadLocale );
end.

