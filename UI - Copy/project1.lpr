program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, uLogin, UJson, umain,usession,
  uthread, uUsers, uForm;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
 // Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmLogin, frmLogin);
 // Application.CreateForm(TfrmMain, frmMain);
  //Application.CreateForm(TForm2, Form2);
 // Application.CreateForm(TUsers, Users);
  //Application.CreateForm(Tfrm, frm);
  Application.Run;
end.
