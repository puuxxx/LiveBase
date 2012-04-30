unit ufmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufmBase, Vcl.StdCtrls, Vcl.ExtCtrls,
  uDrawingArea, uEventModel, uDrawingEvent;

type
  TfmMain = class(TfmBase)
    pb: TPaintBox;
    Panel1: TPanel;
    ColorBox1: TColorBox;
    pbBackground: TPaintBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pbPaint(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure pbBackgroundPaint(Sender: TObject);
    procedure pbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
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

procedure TfmMain.ColorBox1Change(Sender: TObject);
begin
  FArea.BackgroundColor := ColorBox1.Selected;
end;

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  Env.EventModel.UnRegister(Self);
  Application.Terminate;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  FArea := TDrawingArea.Create(Env.EventModel);
  Env.EventModel.RegisterSubscriber( EVENT_BACKGROUND_COLOR, Self);
  Env.EventModel.RegisterSubscriber( EVENT_PLEASE_REPAINT, Self );
  ColorBox1Change(nil);
end;

procedure TfmMain.FormResize(Sender: TObject);
begin
  FArea.OnNewSize(pb.Width, pb.Height);
end;

procedure TfmMain.pbBackgroundPaint(Sender: TObject);
begin
  pbBackground.Canvas.Brush.Color := pbBackground.Color;
  pbBackground.Canvas.FillRect(pbBackground.ClientRect);
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
  FArea.OnMouseUp( Button, Shift, X, Y );
end;

procedure TfmMain.pbPaint(Sender: TObject);
begin
  pb.Canvas.Draw(0, 0, FArea.AreaBitmap);
end;

procedure TfmMain.ProcessEvent( const aEventID: TEventID; const aEventData: variant );
begin
  if aEventID = EVENT_BACKGROUND_COLOR then begin
    pbBackground.Color := TDrawingCommandData.ExtractColor( aEventData );
    pb.Repaint;
  end else
  if aEventID = EVENT_PLEASE_REPAINT then begin
    pb.Repaint;
  end;
end;

end.
