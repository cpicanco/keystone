{
  Keystone
  Copyright (C) 2019 Imagine - Tecnologia Comportamental.

  Written by cpicanco@imaginetc.com.br

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit Forms.Player;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, PasLibVlcPlayerUnit;

type

  { TFormPlayer }

  TFormPlayer = class(TForm)
    Player: TPasLibVlcPlayer;
    Timer: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PlayerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PlayerOpening(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FPlayRate : integer;
    procedure PlayRate(AValue : integer);
  public
    procedure Pause;
    procedure Play(AVideo : string);
    procedure SwitchFullScreen;
    procedure SetVideoVariables;
  end;

var
  FormPlayer: TFormPlayer;
  ReferencePNGFile : widestring = '';

implementation

uses LCLType, Forms.Main, Forms.Report, Timestamps, PasLibVlcUnit;

{$R *.lfm}

const
  MSecsPerMinute = 60000;

var
  VideoMinutes : integer = 1;

type
  TCurrentPos = record
    InMSecs : integer;
    Minute : integer;
  end;

function CurrentPos(APlayer : TPasLibVlcPlayer) : TCurrentPos;
begin
  Result.Minute := 1;
  Result.InMSecs := 0;
  if APlayer.IsPlay then
  begin
    Result.InMSecs := APlayer.GetVideoPosInMs;
    if Result.InMSecs < MSecsPerMinute then Exit;
    Result.Minute := Result.InMSecs div MSecsPerMinute;
  end;
end;

procedure NextMinute(APlayer : TPasLibVlcPlayer);
var
  LCurrentPos : TCurrentPos;
begin
  if APlayer.IsPlay and (not APlayer.IsProcessingPaintMsg) then
  begin
    LCurrentPos := CurrentPos(APlayer);
    if LCurrentPos.Minute = VideoMinutes then Exit;
    APlayer.SetVideoPosInMs(((LCurrentPos.InMSecs div MSecsPerMinute)+1)*MSecsPerMinute);
  end;
end;

procedure PreviousMinute(APlayer : TPasLibVlcPlayer);
var
  LCurrentPos : TCurrentPos;
begin
  if APlayer.IsPlay and (not APlayer.IsProcessingPaintMsg) then
  begin
    LCurrentPos := CurrentPos(APlayer);
    if LCurrentPos.Minute = 1 then Exit;
    APlayer.SetVideoPosInMs(((LCurrentPos.InMSecs div MSecsPerMinute)-1)*MSecsPerMinute);
  end;
end;

procedure GoToMinute(APlayer : TPasLibVlcPlayer; AMinute : integer);
begin
  if AMinute < 1 then Exit;
  if AMinute > VideoMinutes then Exit;
  if APlayer.IsPlay then
     APlayer.SetVideoPosInMs(AMinute*MSecsPerMinute);
end;

{ TFormPlayer }

procedure TFormPlayer.FormActivate(Sender: TObject);
begin
  FormMain.Hide;
  Player.SetFocus;
  if not Player.IsPlay then Player.Resume;
end;

procedure TFormPlayer.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;
end;

procedure TFormPlayer.FormCreate(Sender: TObject);
begin
  FPlayRate := 1;
  Player.OnKeyUp := @FormKeyUp;
end;

procedure TFormPlayer.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  VideoPos : integer;
begin
  case Key of
    { backspace }
    VK_BACK  : FormReport.DeleteLastRow;

    { enter }
    VK_A, VK_S, VK_D, VK_F, VK_G:
      begin
        FormReport.WriteRow(Player.GetVideoPosInMs, Key); // in milliseconds
        Player.LogoSetOpacity(255);
        Timer.Enabled := True;
      end;

    { space }
    VK_SPACE :
      if Player.IsPlay then Player.Pause else Player.Resume;

    { 1 }
    VK_1 : PlayRate(1);

    { 2 }
    VK_2 : PlayRate(2);

    { 3 }
    VK_3 : PlayRate(3);

    { 4 }
    VK_4 : PlayRate(4);

    { arrow left }
    VK_LEFT :
      if ssCtrl in Shift then
      begin
        if Player.IsPlay and (not Player.IsProcessingPaintMsg) then
        begin
          VideoPos := Player.GetVideoPosInMs;
          if VideoPos > 5100 then
            Player.SetVideoPosInMs(VideoPos-5000);
        end
      end else PreviousMinute(Player);

    { arrow right }
    VK_RIGHT :
      if ssCtrl in Shift then
      begin
        if Player.IsPlay and (not Player.IsProcessingPaintMsg) then
        begin
          VideoPos := Player.GetVideoPosInMs;
          if VideoPos < VideoLength-5100 then
            Player.SetVideoPosInMs(VideoPos+5000);
        end
      end else NextMinute(Player);

    VK_L :
      if ssCtrl in Shift then
        GoToMinute(Player, InputBox(
          '',
          'Prompt', VideoMinutes.ToString).ToInteger);
    VK_P :
      if ssCtrl in Shift then
         SetVideoVariables;
  end;
end;

procedure TFormPlayer.PlayerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Player.SetFocus;
end;

procedure TFormPlayer.PlayerOpening(Sender: TObject);
begin
  FirstTick := GetTickCount64;
end;

procedure TFormPlayer.TimerTimer(Sender: TObject);
begin
  Timer.Enabled:=False;
  Player.LogoSetOpacity(100);
end;

procedure TFormPlayer.PlayRate(AValue: integer);
begin
  if AValue = FPlayRate then Exit;
  FPlayRate := AValue;
  FPlayRate := 100 * AValue;
  if FPlayRate > 400 then Exit;
  Player.SetPlayRate(FPlayRate);
end;

procedure TFormPlayer.Pause;
begin
  if Player.IsPlay then Player.Pause;
end;

procedure TFormPlayer.Play(AVideo: string);
begin
  Player.UseEvents := True;
  with Player do
    begin
      OnMediaPlayerOpening:=@PlayerOpening;

    end;
  Player.Play(WideString(AVideo));
end;

{$IFDEF LINUX}
procedure TFormPlayer.SwitchFullScreen;
begin
  WindowState := wsFullScreen;
end;
{$ENDIF}

{$IFDEF WINDOWS}
procedure TFormPlayer.SwitchFullScreen;
begin
  BorderStyle := bsNone;
  BoundsRect := Screen.MonitorFromWindow(Handle).BoundsRect;
end;
{$ENDIF}

procedure TFormPlayer.SetVideoVariables;
begin
  if Player.IsPlay then
  begin
    VideoLength := Player.GetVideoLenInMs;
    VideoMinutes := VideoLength div MSecsPerMinute;
    VideoDuration := TimeStampToDateTime(MSecsToTimeStamp(VideoLength));
    if FileExists(ReferencePNGFile) then
      Player.LogoShowFile(ReferencePNGFile, 0,0, 100);
  end;
end;

end.

