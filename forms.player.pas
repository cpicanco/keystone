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
  StdCtrls, lclvlc, vlc;

type

  { TFormPlayer }

  TFormPlayer = class(TForm)
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure PlayerOpening(Sender: TObject);
  private
    Player : TLCLVLCPlayer;
    MediaItem : TVLCMediaItem;
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

uses Forms.Main, Forms.Report, Timestamps;

{$R *.lfm}

{ TFormPlayer }

procedure TFormPlayer.FormActivate(Sender: TObject);
begin
  FormMain.Hide;
  if Player.Playable and (not Player.Playing) then Player.Resume;
end;

procedure TFormPlayer.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := False;
end;

procedure TFormPlayer.FormCreate(Sender: TObject);
begin
  Player := TLCLVLCPlayer.Create(Self);
end;

procedure TFormPlayer.FormKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
    #13 : FormReport.WriteRow(Player.VideoPosition); // in milliseconds
    #32 : if Player.Playing then Player.Pause else Player.Resume;
  end;
end;

procedure TFormPlayer.PlayerOpening(Sender: TObject);
begin
  FirstTick := GetTickCount64;
end;

procedure TFormPlayer.Pause;
begin
  if Player.Playing then Player.Pause;
end;

procedure TFormPlayer.Play(AVideo: string);
begin
  Player.FitWindow := False;
  Player.ParentWindow := Self;
  Player.UseEvents := True;
  with Player do
    begin
      //OnBackward:=@LCLVLCPlayerBackward;
      //OnBuffering:=@LCLVLCPlayerBuffering;
      //OnEOF:=@PlayerEOF;
      //OnError:=@LCLVLCPlayerError;
      //OnForward:=@LCLVLCPlayerForward;
      //OnLengthChanged:=@LCLVLCPlayerLengthChanged;
      //OnMediaChanged:=@LCLVLCPlayerMediaChanged;
      //OnNothingSpecial:=@LCLVLCPlayerNothingSpecial;
      OnOpening:=@PlayerOpening;
      //OnPausableChanged:=@LCLVLCPlayerPausableChanged;
      //OnPause:=@LCLVLCPlayerPause;
      //OnPlaying:=@LCLVLCPlayerPlaying;
      //OnPositionChanged:=@LCLVLCPlayerPositionChanged;
      //OnSeekableChanged:=@LCLVLCPlayerSeekableChanged;
      //OnSnapshot:=@LCLVLCPlayerSnapshot;
      //OnStop := @LCLVLCPlayerStop;
      //OnTimeChanged:=@LCLVLCPlayerTimeChanged;
      //OnTitleChanged:=@LCLVLCPlayerTitleChanged;
    end;
  MediaItem := TVLCMediaItem.Create(nil);
  MediaItem.Path := AVideo;
  Player.Play(MediaItem);

  //Player.FullScreenMode:=True;
  //Player.PlayRate(1000);
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
    BoundsRect := Screen.MonitorFromWindow(Handle).BoundsRect;
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
  if Player.Playing then
  begin
    VideoLength := Player.VideoLength;
    VideoDuration := Player.VideoDuration;
  end;
end;

end.

