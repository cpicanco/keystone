{
  Keystone
  Copyright (C) 2018 Imagine - Tecnologia Comportamental.

  Written by cpicanco@imaginetc.com.br

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit Forms.Report;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  StdCtrls;

type

  { TFormReport }

  TFormReport = class(TForm)
    ButtonReturn: TButton;
    ButtonSave: TButton;
    SaveDialog: TSaveDialog;
    StringGridReport: TStringGrid;
    procedure ButtonReturnClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormKeyPress(Sender: TObject; var Key: char);
  private
    procedure WriteFooter;
  public
    procedure SetHeader(AHeader : string);
    procedure WriteRow(AVideoTime: Int64);
    procedure DeleteLastRow;
  end;

var
  FormReport: TFormReport;
  VideoLength: Int64;
  VideoDuration: TDateTime;

implementation

{$R *.lfm}

uses Forms.Main, Forms.Player, Timestamps;

var ReportHeader : string;
{ TFormReport }

procedure TFormReport.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;
end;

procedure TFormReport.FormKeyPress(Sender: TObject; var Key: char);
begin
 case Key of
   #8  : DeleteLastRow;
 end;
end;

procedure TFormReport.ButtonSaveClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    WriteFooter;
    StringGridReport.SaveToCSVFile(SaveDialog.FileName);
  end;
end;

procedure TFormReport.FormActivate(Sender: TObject);
begin
  FormMain.Hide;
  FormPlayer.Pause;
end;

procedure TFormReport.ButtonReturnClick(Sender: TObject);
begin
  FormPlayer.Pause;
  FormMain.Show;
end;

procedure TFormReport.WriteFooter;
var hh, mm, ss, ms : word;
begin
  DecodeTime(VideoDuration, hh, mm, ss, ms);
  with StringGridReport do
  begin
    RowCount := RowCount+1;
    Cells[0, RowCount-1] :=
    ReportHeader +LineEnding +
    'Duração: ' + Format('%dh%dm%d.%d',[hh,mm,ss,ms])+LineEnding+
    'Duração (ms): ' + IntToStr(VideoLength);
  end;
end;

procedure TFormReport.SetHeader(AHeader: string);
begin
  ReportHeader := AHeader;
end;

procedure TFormReport.WriteRow(AVideoTime: Int64);
begin

  with StringGridReport do
  begin
    RowCount := RowCount+1;
    Cells[0, RowCount-1] := Milliseconds;
    Cells[1, RowCount-1] := IntToStr(AVideoTime);
  end;
end;

procedure TFormReport.DeleteLastRow;
begin
  with StringGridReport do
    if RowCount > 1 then
      RowCount := RowCount-1;
end;

end.

