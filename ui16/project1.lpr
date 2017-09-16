program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, ulogin, ujson, umain, usession, Unit1, uform, utools, uscoring
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TfrmLogin, frmLogin);
  //Application.CreateForm(TfrmMain, frmMain);
 // Application.CreateForm(TForm1, Form1);
 // Application.CreateForm(Tfrm, frm);
 // Application.CreateForm(Tfrmscoring, frmscoring);
  Application.Run;
end.

