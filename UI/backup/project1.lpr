program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, datetimectrls, runtimetypeinfocontrols, printer4lazarus,
  uLogin, UJson, umain, usession, uthread, uUsers, uForm, utools, uscoring,
  Unit1, filemanager, uClientSearch, uncustomerdetails, ucomponents;

{$R *.res}

begin
  Application.Title:='Scoring';
  RequireDerivedFormResource:=True;
  Application.Initialize;
 // Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmLogin, frmLogin);
  //Application.CreateForm(TfrmScoring, frmScoring);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Tfrmcustomerdetails, frmcustomerdetails);
  //Application.CreateForm(Tfrmclientsearch, frmclientsearch);
 // Application.CreateForm(TfrmMain, frmMain);
  //Application.CreateForm(TForm2, Form2);
 // Application.CreateForm(TUsers, Users);
  //Application.CreateForm(Tfrm, frm);
  Application.Run;
end.

