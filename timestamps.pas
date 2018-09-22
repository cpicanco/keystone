{
  Keystone
  Copyright (C) 2018 Imagine - Tecnologia Comportamental.

  Written by cpicanco@imaginetc.com.br

  The present file is distributed under the terms of the GNU General Public License (GPL v3.0).

  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.
}
unit Timestamps;

{$mode objfpc}{$H+}

interface

function Milliseconds: string; inline;

var FirstTick : Cardinal;

implementation

uses SysUtils;

function Milliseconds : string;
begin
  Result := IntToStr(GetTickCount64 - FirstTick);
end;

end.

