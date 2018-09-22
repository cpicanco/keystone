{
  Keystone
  Copyright (C) 2018 Imagine - Tecnologia Comportamental.

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
    Timer: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PlayerOpening(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FPlayRate : integer;
    Player : TPasLibVlcPlayer;
    procedure PlayRate(AValue : integer);
  public
    {$IFDEF WINDOWS}
    OriginalBounds: TRect;
    OriginalWindowState: TWindowState;
    ScreenBounds: TRect;
    {$ENDIF}
    procedure Pause;
    procedure Play(AVideo : string);
    procedure SwitchFullScreen;
    procedure SetVideoVariables;
  end;

var
  FormPlayer: TFormPlayer;

implementation

uses Forms.Main, Forms.Report, Timestamps, PasLibVlcUnit;

{$R *.lfm}


var
  Line : widestring;

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
  Line := ExtractFilePath(Application.ExeName)+'line.png';
  FPlayRate := 1;
  Player := TPasLibVlcPlayer.Create(Self);
  Player.TabStop := False;
  Player.Parent := Self;
  Player.BevelOuter := bvNone;
  Player.Align := alClient;
  Player.SnapShotFmt:='png';
  Player.OnKeyPress:=@FormKeyPress;
end;

procedure TFormPlayer.FormKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
    { backspace }
    #8  : FormReport.DeleteLastRow;

    { enter }
    #13 :
        begin
          FormReport.WriteRow(Player.GetVideoPosInMs); // in milliseconds
          Player.LogoSetOpacity(255);
          Timer.Enabled := True;
        end;

    { space }
    #32 : if Player.IsPlay then Player.Pause else Player.Resume;

    '1' : PlayRate(1);
    '2' : PlayRate(2);
    '3' : PlayRate(3);
    '4' : PlayRate(4);
  end;
end;

procedure TFormPlayer.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //case Key of
  //  { arrow left }
  //  37 : if Player.Seekable and Player.Playing then
  //         if Player.VideoPosition > 5100 then
  //           Player.VideoPosition:= Player.VideoPosition-5000;
  //
  //  { arrow right }
  //  39 : if Player.Seekable and Player.Playing  then
  //         if Player.VideoPosition < Player.VideoLength-5100 then
  //           Player.VideoPosition:= Player.VideoPosition+5000;
  //end;
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
// http://wiki.freepascal.org/Application_full_screen_mode
procedure TFormPlayer.SwitchFullScreen;
begin
  if BorderStyle <> bsNone then begin
    // To full screen
    OriginalWindowState := WindowState;
    OriginalBounds := BoundsRect;

    BorderStyle := bsNone;
    BoundsRect := Screen.DesktopRect;
  end else begin
    // From full screen
    BorderStyle := bsSizeable;
    if OriginalWindowState = wsMaximized then
      WindowState := wsMaximized
    else
      BoundsRect := OriginalBounds;
  end;
end;
{$ENDIF}

procedure TFormPlayer.SetVideoVariables;
begin
  if Player.IsPlay then
  begin
    VideoLength := Player.GetVideoLenInMs;
    VideoDuration := TimeStampToDateTime(MSecsToTimeStamp(VideoLength));
    if FileExists(Line) then
      Player.LogoShowFile(Line, 0,0, 100);
  end;
end;

end.

