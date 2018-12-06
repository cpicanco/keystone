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
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure WriteHeader;
  public
    procedure SetHeader(AHeader : array of string);
    procedure WriteRow(AVideoTime: Int64);
    procedure DeleteLastRow;
  end;

var
  FormReport: TFormReport;
  VideoLength: Int64;
  VideoDuration: TDateTime;

implementation

{$R *.lfm}

uses LCLType, Forms.Main, Forms.Player, Timestamps;

var ReportHeader : array of string;

{ TFormReport }

procedure TFormReport.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;
end;

procedure TFormReport.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_BACK  : DeleteLastRow;
  end;
end;

procedure TFormReport.ButtonSaveClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    WriteHeader;
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

procedure TFormReport.WriteHeader;
var
  hh, mm, ss, ms : word;
begin
  DecodeTime(VideoDuration, hh, mm, ss, ms);

  StringGridReport.InsertRowWithValues(0, ['Lugar:',      ReportHeader[0]]);
  StringGridReport.InsertRowWithValues(1, ['Turno:',      ReportHeader[1]]);
  StringGridReport.InsertRowWithValues(2, ['Dia:',        ReportHeader[2]]);
  StringGridReport.InsertRowWithValues(3, ['Observador:', ReportHeader[3]]);
  StringGridReport.InsertRowWithValues(4, ['Fase:',       ReportHeader[4]]);
  StringGridReport.InsertRowWithValues(5, ['Duração:', Format('%dh%dm%d.%d',[hh,mm,ss,ms])]);
  StringGridReport.InsertRowWithValues(6, ['Duração (ms):', IntToStr(VideoLength)]);
end;

procedure TFormReport.SetHeader(AHeader: array of string);
var i : integer;
begin
  SetLength(ReportHeader, Length(AHeader));
  for i := Low(AHeader) to High(Aheader) do ReportHeader[i] := AHeader[i];
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

