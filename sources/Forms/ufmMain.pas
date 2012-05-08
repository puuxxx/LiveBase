unit ufmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufmBase, Vcl.StdCtrls, Vcl.ExtCtrls,
  uDrawingArea, uEventModel, uDrawingEvent, JvWndProcHook, JvComponentBase,
  JvMouseGesture, uDrawingPrimitive;


const
  WM_PLEASEREPAINT = WM_USER+ 1;
type
  TfmMain = class(TfmBase)
    pb: TPaintBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pbPaint(Sender: TObject);
    procedure pbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure pbDblClick(Sender: TObject);
  private
    FArea: TDrawingArea;
  protected
    procedure ProcessEvent( const aEventID: TEventID; const aEventData: variant ); override;
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses uEnvironment;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Env.EventModel.UnRegister(Self);
  Application.Terminate;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  FArea := TDrawingArea.Create(Env.EventModel);

  Env.EventModel.RegisterSubscriber( EVENT_PLEASE_REPAINT, Self );
end;

procedure TfmMain.FormResize(Sender: TObject);
begin
  FArea.OnNewSize(pb.Width, pb.Height);
end;

procedure TfmMain.pbDblClick(Sender: TObject);
var
  P : TPoint;
begin
  GetCursorPos( P  );
  P := pb.ScreenToClient( P );

  FArea.CreateFigure( ftBox, P.X, P.Y );
  pb.Repaint;
end;

procedure TfmMain.pbMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FArea.OnMouseDown( Button, X, Y );
end;

procedure TfmMain.pbMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  FArea.OnMouseMove( X, Y );
end;

procedure TfmMain.pbMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FArea.OnMouseUp( Button, X, Y );
end;

procedure TfmMain.pbPaint(Sender: TObject);
begin
  pb.Canvas.Draw(0, 0, FArea.AreaBitmap);
end;

procedure TfmMain.ProcessEvent( const aEventID: TEventID; const aEventData: variant );
begin
  if aEventID = EVENT_PLEASE_REPAINT then begin
    pb.Repaint;
  end;
end;


end.
