{
  Keystone
  Copyright (C) 2018 Imagine - Tecnologia Comportamental.

  Written by cpicanco@imaginetc.com.br

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit Forms.Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TFormMain }

  TFormMain = class(TForm)
    ButtonStart: TButton;
    EditPlace: TEdit;
    EditTurn: TEdit;
    EditDay: TEdit;
    EditObserver: TEdit;
    EditPhase: TEdit;
    LabelDay: TLabel;
    LabelObserver: TLabel;
    LabelPhase: TLabel;
    LabelTurn: TLabel;
    LabelPlace: TLabel;
    OpenDialog: TOpenDialog;
    Timer: TTimer;
    procedure ButtonStartClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private

  public

  end;

var
  FormMain: TFormMain;

implementation

uses Forms.Player, Forms.Report;

{$R *.lfm}

{ TFormMain }

procedure TFormMain.ButtonStartClick(Sender: TObject);
begin
  if (EditPhase.Text = '') or
     (EditObserver.Text = '') or
     (EditDay.Text = '') or
     (EditTurn.Text = '') or
     (EditPlace.Text = '') then
  begin
    ShowMessage('Preencha as informações.');
    Exit;
  end;

  OpenDialog.InitialDir := ExtractFilePath(Application.ExeName);

  OpenDialog.Title := 'Escolha o arquivo .png de referência para a observação';
  OpenDialog.Filter := 'PNG|*.png;*.PNG';
  if OpenDialog.Execute then
  begin
    ReferencePNGFile := WideString(OpenDialog.FileName);
  end;

  OpenDialog.Title := 'Escolha o vídeo para a observação';
  OpenDialog.Filter := 'Vídeo|*.mp4;*.avi;*.mov;*.mkv';
  if OpenDialog.Execute then
  begin
    ButtonStart.Enabled:=False;
    FormReport.Show;
    FormReport.SetHeader(
      EditPlace.Text+LineEnding+
      EditTurn.Text+LineEnding+
      EditDay.Text+LineEnding+
      EditObserver.Text+LineEnding+
      EditPhase.Text
    );
    FormPlayer.Show;
    FormPlayer.SwitchFullScreen;
    FormPlayer.BringToFront;
    FormPlayer.Play(OpenDialog.FileName);
    Timer.Enabled:=True;
  end;

end;

procedure TFormMain.TimerTimer(Sender: TObject);
begin
  Timer.Enabled:=False;
  FormPlayer.SetVideoVariables;
end;


end.

