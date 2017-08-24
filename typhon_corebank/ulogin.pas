UNIT uLogin;

{$mode objfpc}{$H+}

INTERFACE

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,ujson,umain,usession;

TYPE

  { TfrmLogin }

  TfrmLogin = CLASS(TForm)
    btnLogin: TButton;
    edLogin: TLabeledEdit;
    edPassword: TLabeledEdit;
    Label1: TLabel;
    PROCEDURE btnLoginClick(Sender: TObject);
  private

  public

  END;

var
  frmLogin: TfrmLogin;
  ujs_ : ujs;
implementation

{$R *.frm}

{ TfrmLogin }

PROCEDURE TfrmLogin.btnLoginClick(Sender: TObject);
var
   frmMain : umain.TfrmMain;
   s:widestring;
begin
 //showmessage('bas');
 // Form1.Memo1.Lines.Add(ujs_.prepareRequest(frmLogin));
// Form1.Memo1.Lines.Add(ujs_.runHub('corebank.users_pkg.login',ujs_.prepareRequest(frmLogin)));
 ujs_ :=  ujs.Create();
 try
 usession.session_var:='';
 s:=ujs_.runHub('zamir.users_pkg.login','"TFORM":"'+self.name+'",'+ujs_.prepareRequest(frmLogin));
 //exit;
 //if ujs_.parseResponse(frmLogin,s)=true then
   begin
     ujs_.existsform(self,s,self);
     if ujs_.errorexists then begin exit; end;
     frmMain := umain.TfrmMain.Create(nil);
     frmMain.ShowInTaskBar:= stAlways;
     frmMain.Show;
     frmLogin.Hide;
     //frmMain.Visible:= true;

   end;
 except
   on E:Exception do
     showmessage(E.message);
 end;

end;

END.

