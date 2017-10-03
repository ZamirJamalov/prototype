unit uncustomerdetails;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml, PrintersDlgs, Forms, Controls, Graphics,
  Dialogs, ComCtrls, StdCtrls, Grids, ExtCtrls, Buttons, JSONPropStorage,
  ExtDlgs, fpjson, jsonparser, ujson, umain, usession, ucomponents;

type

  { Tfrmcustomerdetails }

  Tfrmcustomerdetails = class(TForm)
    btnShowCreditProds: TButton;
    btnshowscore: TButton;
    btnshowscore_details: TButton;
    btnscoring_approve: TButton;
    btnToExcel: TButton;
    edscore: TEdit;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    StringGrid2: TStringGrid;
    gridScoreResult: TStringGrid;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure btnscoring_approveClick(Sender: TObject);
    procedure btnshowscoreClick(Sender: TObject);
    procedure btnToExcelClick(Sender: TObject);
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

procedure Tfrmcustomerdetails.btnToExcelClick(Sender: TObject);
begin
  Tcomponents.Create().excelExport(gridScoreResult);
end;

procedure Tfrmcustomerdetails.btnscoring_approveClick(Sender: TObject);
 var
    s:widestring;
begin
 s:=  ujs_.runHub('scoring.cs_scoring_pkg.scroring_result_approved_click','"form":"frmscoring",'+'"client_id":["'+usession.customer_code+'"]');
 if ujs_.jsonError<>'' then begin
    showmessage(ujs_.jsonerror);
    exit;
 end;

 gridScoreResult.ColumnClickSorts:=true;
 gridScoreResult.Assign(Tcomponents.Create.gridLoad(gridScoreResult.Width,'scoring.cs_scoring_pkg',',"client_id":["'+usession.customer_code+'"]'));
 gridScoreResult.Visible:=true;
end;

(*

  var
    fs:TStringStream;
    phtml:TIpHtml;
    txt:String;
begin
  //Tcomponents.Create().gridLoad(gridScoreResult,'zamir.users_pkg','');
 txt := '<h1>Salam</h1>';
 fs:=TStringStream.Create(txt);
 try
   phtml := TIpHtml.Create;
   phtml.LoadFromStream(fs);
 finally
   fs.free;
 end;
 IpHtmlPanel1.SetHtml(phtml);



*)

end.

