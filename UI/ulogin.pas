unit uLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CheckLst, ExtCtrls, Buttons, BCButton, BCButtonFocus, BCImageButton,
  BCMaterialDesignButton, BCDefaultThemeManager, BGRACustomDrawn, BCLabel,
  BCNumericKeyboard, BGRASpeedButton, BGRAKnob, BCPanel, UJson, windows;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    BCMaterialDesignButton1: TBCMaterialDesignButton;
    BCMaterialDesignButton2: TBCMaterialDesignButton;
    label3: TBCLabel;
    btnLogin: TButton;
    edLogin: TEdit;
    edPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edLoginChange(Sender: TObject);
    procedure edPasswordKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
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

procedure TfrmLogin.edPasswordKeyPress(Sender: TObject; var Key: char);
begin
  if key=#13 then
     btnLogin.Click;

end;

procedure TfrmLogin.FormActivate(Sender: TObject);
begin
    edLogin.SetFocus;
end;

procedure TfrmLogin.FormClose(Sender: TObject; var CloseAction: TCloseAction);
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
     frmMain.LoginName:=frmLogin.edLogin.Text;
     frmMain.ShowInTaskBar:= stAlways;
     frmLogin.Hide;
     frmMain.Show;
     frmMain.WindowState:=wsMaximized;
     //frmMain.BorderStyle:=bsnone;


     //frmMain.Visible:= true;

   end;
 except
   on E:Exception do
     showmessage(E.message);
 end;
end;

procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  Application.Terminate;
end;



procedure TfrmLogin.Button1Click(Sender: TObject);
begin

end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
 Label3.Font.Color:=$00621E0B;
 //edLogin.TextHintFontStyle:=Self.Font.Style;
 //edPassword.TextHintFontStyle:=Self.Font.Style;
 ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_SHOW);
 ShowWindow(FindWindowEx(0, 0, MAKEINTATOM($C017), 'Start'),SW_SHOW);
end;

end.

