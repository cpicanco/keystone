{
  Keystone
  Copyright (C) 2018 Imagine - Tecnologia Comportamental.

  Written by cpicanco@imaginetc.com.br

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
program keystone;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Forms.Main,
  Forms.Player,
  Forms.Report
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormPlayer, FormPlayer);
  Application.CreateForm(TFormReport, FormReport);
  Application.Run;
end.

