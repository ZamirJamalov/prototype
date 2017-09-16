unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Memo1: TMemo;
  private

  public
     procedure setlog(p_log :widestring);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.setlog(p_log: widestring);
begin
  Memo1.Text:=p_log;
end;

end.

