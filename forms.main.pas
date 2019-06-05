{
  Keystone
  Copyright (C) 2019 Imagine - Tecnologia Comportamental.

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
  ExtCtrls, IniPropStorage;

type

  { TFormMain }

  TFormMain = class(TForm)
    ButtonExample: TButton;
    ButtonStart: TButton;
    ComboBoxPhase: TComboBox;
    ComboBoxObserver: TComboBox;
    ComboBoxTurn: TComboBox;
    ComboBoxPlace: TComboBox;
    EditSampleDay: TEdit;
    EditToday: TEdit;
    IniPropStorage1: TIniPropStorage;
    LabelDay: TLabel;
    LabelSampleDay: TLabel;
    LabelObserver: TLabel;
    LabelPhase: TLabel;
    LabelTurn: TLabel;
    LabelPlace: TLabel;
    OpenDialog: TOpenDialog;
    Timer: TTimer;
    procedure ButtonExampleClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private

  public

  end;

var
  FormMain: TFormMain;

implementation

uses Forms.Player, Forms.Report, strutils;

{$R *.lfm}

{ TFormMain }

procedure TFormMain.ButtonStartClick(Sender: TObject);
var
  s1 : string;
begin
  if (ComboBoxPlace.ItemIndex = -1) or
     (ComboBoxTurn.ItemIndex = -1) or
     (ComboBoxPhase.ItemIndex = -1) or
     (ComboBoxObserver.ItemIndex = -1) or
     (EditToday.Text = '') then
  begin
    ShowMessage('Preencha as informações da observação.');
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
    s1 := OpenDialog.Filename;
    s1 := ExtractFileName(s1);
    s1 := ExtractDelimited(3, s1,['(',#32]);
    while Pos('-', s1) <> 0 do Delete(s1, Pos('-', s1), 1);
    if Length(s1) = 8 then
      EditSampleDay.Text := s1
    else
      begin
        ShowMessage(
          'Não foi possível continuar,' + #32 +
          'pois o nome do arquivo do vídeo não está no formato:' + #32 +
          '31 (2019-01-22 06''00''00 - 2019-01-22 08''00''00).avi');
        Exit;
      end;
    ButtonExample.Enabled:=False;
    ButtonStart.Enabled:=False;
    ComboBoxObserver.Enabled:=False;
    ComboBoxPhase.Enabled:=False;
    ComboBoxPlace.Enabled:=False;
    ComboBoxTurn.Enabled:=False;

    FormReport.Show;
    FormReport.SetHeader([
      ComboBoxPlace.Text,
      ComboBoxTurn.Text,
      EditToday.Text,
      EditSampleDay.Text,
      ComboBoxObserver.Text,
      ComboBoxPhase.Text
    ]);
    FormPlayer.Show;
    FormPlayer.SwitchFullScreen;
    FormPlayer.BringToFront;
    FormPlayer.Play(OpenDialog.FileName);
    Timer.Enabled:=True;
  end;
end;

procedure TFormMain.ButtonExampleClick(Sender: TObject);
begin
  if (ComboBoxPlace.Items.Count > 0) or
     (ComboBoxTurn.Items.Count > 0) or
     (ComboBoxObserver.Items.Count > 0) or
     (ComboBoxPhase.Items.Count > 0) then
    if QuestionDlg('Subscrever?',
      'Subscrever suas informações com as informações padrão?',
      mtCustom,[mrYes,'Sim',mrNo,'Não'], 0) =  mrYes then
      // do nothing
    else
      Exit;

  ComboBoxPlace.Items[0] := 'Oliveira Paiva';
  ComboBoxPlace.Items[1] := 'Rogaciano Leite';
  ComboBoxPlace.Items[2] := 'Virgílio Tavora';

  ComboBoxTurn.Items[0] := 'Manhã';
  ComboBoxTurn.Items[1] := 'Tarde';

  ComboBoxObserver.Items[0] := 'Abdala';
  ComboBoxObserver.Items[1] := 'Gerôncio';
  ComboBoxObserver.Items[2] := 'Raquel';
  ComboBoxObserver.Items[3] := 'José';
  ComboBoxObserver.Items[4] := 'Rafael';

  ComboBoxPhase.Items[0] := 'Pré';
  ComboBoxPhase.Items[1] := 'Pós';
  ComboBoxPhase.Items[2] := 'Follow up 1';
  ComboBoxPhase.Items[3] := 'Follow up 2';

  ComboBoxPlace.ItemIndex := 0;
  ComboBoxTurn.ItemIndex := 0;
  ComboBoxObserver.ItemIndex := 0;
  ComboBoxPhase.ItemIndex := 0;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  EditToday.Text := DateTimeToStr(Date);
end;

procedure TFormMain.TimerTimer(Sender: TObject);
begin
  Timer.Enabled:=False;
  FormPlayer.SetVideoVariables;
end;


end.

