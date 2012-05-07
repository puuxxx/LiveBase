program AutoBase;

uses
  Windows,
  Vcl.Forms,
  uRootForm in 'uRootForm.pas' {fmRoot},
  uEventModel in 'uEventModel.pas',
  uBase in 'uBase.pas',
  uExceptions in 'uExceptions.pas',
  uExceptionCodes in 'uExceptionCodes.pas',
  uDrawingArea in 'uDrawingArea.pas',
  uBaseCommand in 'Commands\uBaseCommand.pas',
  uGenericCommands in 'Commands\uGenericCommands.pas',
  uEnvironment in 'uEnvironment.pas',
  uStrings in 'uStrings.pas',
  ufmBase in 'Forms\ufmBase.pas' {fmBase},
  ufmMain in 'Forms\ufmMain.pas' {fmMain},
  uBaseEquipment in 'Equipment\uBaseEquipment.pas',
  uDrawingTypes in 'DrawingArea\uDrawingTypes.pas',
  uDrawingSupport in 'DrawingArea\uDrawingSupport.pas',
  uDrawingCommand in 'DrawingArea\uDrawingCommand.pas',
  uDrawingEvent in 'DrawingArea\uDrawingEvent.pas',
  uLines in '..\..\lib\VarArrays\uLines.pas',
  uVarArrays in '..\..\lib\VarArrays\uVarArrays.pas',
  uDrawingPrimitive in 'DrawingArea\uDrawingPrimitive.pas',
  uDrawingPage in 'DrawingArea\uDrawingPage.pas',
  uVertexPoint in 'DrawingArea\uVertexPoint.pas';

{$R *.res}

var
  LaunchCmd: TLaunchCommand;

begin
  Application.Initialize;
  Application.Title := APP_TITLE;

  ShowWindow(Application.Handle, SW_HIDE);
  LaunchCmd := TLaunchCommand.Create;
  try
    LaunchCmd.Execute;
    while not Application.Terminated do
    begin
      WaitMessage;
      Application.ProcessMessages;
    end;
    LaunchCmd.UnExecute;
  finally
    LaunchCmd.Free;
  end;

end.
