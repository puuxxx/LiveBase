unit ufmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ufmBase, Vcl.StdCtrls, Vcl.ExtCtrls,
  uDrawingArea;

type
  TfmMain = class(TfmBase)
    Panel1: TPanel;
    pb: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pbPaint(Sender: TObject);
  private
    FArea : TDrawingArea;
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

  Application.Terminate;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  inherited;
  FArea := TDrawingArea.Create( Env.EventModel );
end;

procedure TfmMain.FormResize(Sender: TObject);
begin
  FArea.OnNewSize( pb.Width, pb.Height );
end;

procedure TfmMain.pbPaint(Sender: TObject);
begin
  pb.Canvas.Lock;
  pb.Canvas.Draw(0, 0, FArea.AreaBitmap );
  pb.Canvas.Unlock;
end;

end.
