unit ufmBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uEventModel;

type
  TfmBase = class(TForm, ISubscriber)
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  protected
    procedure ProcessEvent(const aEventID: TEventID; const aEventData: variant ); virtual;
  end;

implementation

{$R *.dfm}

procedure TfmBase.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfmBase.ProcessEvent( const aEventID: TEventID;
  const aEventData: variant );
begin
  //
end;

end.
