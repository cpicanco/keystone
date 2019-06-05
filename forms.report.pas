{
  Keystone
  Copyright (C) 2019 Imagine - Tecnologia Comportamental.

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
var
  LFilename : string = '';
  LSampleDay : string;
  LPlace : string;
  LPhase : string;
  LTurn : string;
  LObserver : string;
  function Normalize(S : string) : string;
  begin
    Result := S;
    Result := StringReplace(Result, ' ', '-', [rfReplaceAll, rfIgnoreCase]);

    Result := StringReplace(Result, 'ô', 'o', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'õ', 'o', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'ó', 'o', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'ô', 'o', [rfReplaceAll, rfIgnoreCase]);

    Result := StringReplace(Result, 'â', 'a', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'á', 'a', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'ã', 'a', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'à', 'a', [rfReplaceAll, rfIgnoreCase]);

    Result := StringReplace(Result, 'é', 'e', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'è', 'e', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'ê', 'e', [rfReplaceAll, rfIgnoreCase]);

    Result := StringReplace(Result, 'í', 'i', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'ì', 'i', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'î', 'i', [rfReplaceAll, rfIgnoreCase]);

    Result := StringReplace(Result, 'ú', 'u', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'ù', 'u', [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, 'û', 'u', [rfReplaceAll, rfIgnoreCase]);

    Result := StringReplace(Result, 'ç', 'c', [rfReplaceAll, rfIgnoreCase]);

    Result := UpperCase(Result);
  end;

begin
  LSampleDay := Normalize(ReportHeader[3]);
  LPhase := Normalize(ReportHeader[5]);
  LPlace := Normalize(ReportHeader[0]);
  LTurn := Normalize(ReportHeader[1]);
  LObserver := Normalize(ReportHeader[4]);
  LFilename := LFilename.Join('_', [LSampleDay+'-'+LPhase, LPlace, LTurn, LObserver]);
  SaveDialog.FileName := LFilename;
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
  StringGridReport.InsertRowWithValues(2, ['Dia/coleta:', ReportHeader[2]]);
  StringGridReport.InsertRowWithValues(3, ['Dia/video:',  ReportHeader[3]]);
  StringGridReport.InsertRowWithValues(4, ['Observador:', ReportHeader[4]]);
  StringGridReport.InsertRowWithValues(5, ['Fase:',       ReportHeader[5]]);
  StringGridReport.InsertRowWithValues(6, ['Duração:', Format('%dh%dm%d.%d',[hh,mm,ss,ms])]);
  StringGridReport.InsertRowWithValues(7, ['Duração (ms):', IntToStr(VideoLength)]);
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

