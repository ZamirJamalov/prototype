unit utools;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

 function stringToBoolean(p_string: string): boolean;
implementation
function stringToBoolean(p_string: string): boolean;
begin
  IF (p_string='Y') OR (p_string='TRUE') THEN result := TRUE;
  IF (p_string='N') OR (p_string='FALSE') OR (p_string='')  THEN result := FALSE;

end;
end.

