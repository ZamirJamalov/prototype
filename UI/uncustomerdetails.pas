unit uncustomerdetails;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls,fpjson,jsonparser,ujson,umain,usession;

type

  { Tfrmcustomerdetails }

  Tfrmcustomerdetails = class(TForm)
    btnshowscore: TButton;
    edscore: TEdit;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    procedure btnshowscoreClick(Sender: TObject);
  private

  public

  end;

var
  frmcustomerdetails: Tfrmcustomerdetails;
  ujs_, ujs_1:ujs;
implementation

{$R *.lfm}

{ Tfrmcustomerdetails }

procedure Tfrmcustomerdetails.btnshowscoreClick(Sender: TObject);
 var
   s:WideString;
begin
  s := ujs_.runHub('scoring.questions_params_pkg.showScore','"form":"frmscoring",'+'"client_id":["'+usession.customer_code+'"]');
 if ujs_.jsonError<>'' then begin
    Showmessage(ujs_.jsonError);
    exit;
 end;
 // frm := TForm1.Create(nil);
 // frm.setlog(s);
 // frm.ShowModal;
  ujs_ :=  ujs.Create;
  ujs_.parseResponse(s);

  ujs_.existsform(self,s,frmcustomerdetails as TWinControl);
end;

end.

