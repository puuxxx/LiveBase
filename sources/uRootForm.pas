unit uRootForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Rtti, Vcl.StdCtrls, GdiPlus,
  GdiPlusHelpers,
  Vcl.ExtCtrls, ufmMain;

type
  TfmRoot = class(TForm)
    tmLaunchMainForm: TTimer;
    procedure tmLaunchMainFormTimer(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  fmRoot: TfmRoot;

implementation

{$R *.dfm}

procedure TfmRoot.tmLaunchMainFormTimer(Sender: TObject);
begin
  tmLaunchMainForm.Enabled := false;
  with TfmMain.Create(Self) do
  begin
    Show;
  end;
end;

end.
