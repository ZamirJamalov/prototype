unit uLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CheckLst, ExtCtrls, Buttons, UJson,windows;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    btnLogin: TButton;
    edLogin: TEdit;
    edPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    TrayIcon1: TTrayIcon;
    procedure btnLoginClick(Sender: TObject);
    procedure edLoginChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  session_var :string;
  frmLogin: TfrmLogin;
  ujs_ : ujs;

implementation
 uses usession,umain;
{$R *.lfm}

{ TfrmLogin }

procedure TfrmLogin.edLoginChange(Sender: TObject);
begin

end;

procedure TfrmLogin.btnLoginClick(Sender: TObject);
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

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
    ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_SHOW);
  ShowWindow(
      FindWindowEx(0, 0, MAKEINTATOM($C017), 'Start'),
      SW_SHOW);
end;

end.

