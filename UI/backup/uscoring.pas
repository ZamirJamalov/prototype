unit uscoring;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CheckLst, ExtCtrls, Buttons, Calendar,ujson;

type

  { TfrmScoring }

  TfrmScoring = class(TForm)
    edquestions_params: TEdit;
    questions: TCheckListBox;
    questions_params: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel8: TPanel;
    procedure edquestions_paramsExit(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure questionsItemClick(Sender: TObject; Index: integer);
    procedure questionsSelectionChange(Sender: TObject; User: boolean);
    procedure questions_paramsExit(Sender: TObject);
    procedure questions_paramsItemClick(Sender: TObject; Index: integer);
  private

  public

  end;

var
  frmScoring: TfrmScoring;
  ujs_, ujs_1:ujs;
  question_click_event:boolean;
  qa_finished:boolean;
  v_question_index:integer;
implementation
uses unit1,uclientsearch,usession;
{$R *.lfm}

{ TfrmScoring }

procedure TfrmScoring.FormShow(Sender: TObject);
 begin
   //questions.Selected[0]:=true;
  //questions.Checked[0]:=true;
  //questions.OnItemClick(sender,0);
 // questions.Enabled:=false;



end;

procedure TfrmScoring.FormCreate(Sender: TObject);
var
   s:widestring;
   frm :TForm1;
begin
  //s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"TFORM":"'+self.name+'"');
// s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"form":"frmscoring","crud":"add","id":"",'+'"schema_name":"scoring"'+',"client_id":"'+usession.customer_code+'"');
  s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"form":"frmscoring",'+'"client_id":["'+usession.customer_code+'"]');
 if ujs_.jsonError<>'' then begin
    Showmessage(ujs_.jsonError);
    exit;
 end;
 // frm := TForm1.Create(nil);
 // frm.setlog(s);
 // frm.ShowModal;
  ujs_ :=  ujs.Create;
  ujs_.parseResponse(s);

  ujs_.existsform(self,s,frmScoring as TWinControl);



end;

procedure TfrmScoring.FormActivate(Sender: TObject);
begin

end;

procedure TfrmScoring.edquestions_paramsExit(Sender: TObject);
var
   s:widestring;
begin
  if usession.customer_code='' then begin
    showmessage('Müştərini seçin');
    exit;
 end;


 s := ujs_1.runHub('scoring.questions_params_pkg.onchange','"form":"frmscoring","crud":["add"],"id":[""],'+'"schema_name":["scoring"],"questions_params":[""],"client_id":["'+usession.customer_code+'"],'+'"questions":["'+ujs_.getIdByIndex('questions',v_question_index)+'"]'+',"append_value":["'+trim(edquestions_params.Text)+'"]');
 if ujs_1.jsonError<>'' then begin
    Showmessage(ujs_1.jsonError);
    exit;
 end;
  ujs_1.existsform(self,s,frmScoring as TWinControl);
  questions.Checked[questions.ItemIndex]:=true;
  questions.OnItemClick(sender,questions.ItemIndex);

end;

procedure TfrmScoring.questionsItemClick(Sender: TObject; Index: integer);
var
   s:widestring;
   frm :TForm1;
   ch:string;
   i:integer;
   f:boolean;
begin
 if (edquestions_params.Visible=TRUE) and (length(trim(edquestions_params.Text))=0) then begin
    questions.Checked[index]:=false;
    ShowMessage('Cavab daxil edilməyib');
    exit;
 end;
 if (edquestions_params.Visible=FALSE) then begin
    if questions.Checked[index]=true then begin
      f:= false;
      for i := 0 to questions_params.Items.Count-1 do begin
          if questions_params.Checked[i]=true then begin
             f:=true;
             exit;
          end;
      end;
      if not f then begin
         questions.Checked[index]:=false;
         showmessage('Cavab seçilməyib.');
         exit;
      end;
    end;
 end;


 if questions.Checked[index]=true then begin
     ch := 'Y';
 end else begin
     ch := 'N';
 end;

 //s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"TFORM":"'+self.name+'"');
 s := ujs_1.runHub('scoring.questions_pkg.onchange','"form":"frmscoring","crud":["add"],"id":[""],'+'"schema_name":["scoring"],"questions":["'+ujs_.getIdByIndex('questions',index)+'"]'+',"client_id":["'+usession.customer_code+'"]'+',"checked":["'+ch+'"]');
 if (ujs_1.jsonError<>'') then begin
   if (ujs_1.jsonError<>'editable_activate')  then begin
       Showmessage(ujs_1.jsonError);
      EXIT;
    end;
 end;

  v_question_index:=index;
  ujs_1 :=  ujs.Create;
  ujs_1.parseResponse(s);

  ujs_1.existsform(self,s,frmScoring as TWinControl);

end;

procedure TfrmScoring.questionsSelectionChange(Sender: TObject; User: boolean);
var
   s:widestring;
   frm :TForm1;
   ch:string;

begin
  if questions.ItemIndex<0 then begin
     exit;
  end;
 if questions.Checked[questions.ItemIndex]=true then begin
     ch := 'Y';
  end else begin
     ch := 'N';
  end;

 //s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"TFORM":"'+self.name+'"');
 s := ujs_1.runHub('scoring.questions_pkg.onchange','"form":"frmscoring","crud":["add"],"id":[""],'+'"schema_name":["scoring"],"questions":["'+ujs_.getIdByIndex('questions',questions.ItemIndex)+'"]'+',"client_id":["'+usession.customer_code+'"]'+',"checked":["'+ch+'"]');
 if ujs_1.jsonError<>''  then begin
     Showmessage(ujs_1.jsonError);
     exit;
 end;


  v_question_index:=questions.ItemIndex;
  ujs_1 :=  ujs.Create;
  ujs_1.parseResponse(s);

  ujs_1.existsform(self,s,frmScoring as TWinControl);
end;

procedure TfrmScoring.questions_paramsExit(Sender: TObject);
begin
end;

procedure TfrmScoring.questions_paramsItemClick(Sender: TObject; Index: integer);
var
   s:widestring;
begin
  if usession.customer_code='' then begin
    showmessage('Müştərini seçin');
    questions_params.Checked[index]:=false;
    exit;
 end;
  if questions_params.Checked[index]=false then begin
     exit;
  end else begin
      questions_params.Enabled:=false;
  end;

 s := ujs_1.runHub('scoring.questions_params_pkg.onchange','"form":"frmscoring","crud":["add"],"id":[""],'+'"schema_name":["scoring"],"questions_params":["'+ujs_1.getIdByIndex('questions_params',index)+'"],"client_id":["'+usession.customer_code+'"],'+'"questions":["'+ujs_.getIdByIndex('questions',v_question_index)+'"]'+',"append_value":[""]');
 if ujs_1.jsonError<>'' then begin
    Showmessage(ujs_1.jsonError);
    exit;
 end;
  ujs_1.existsform(self,s,frmScoring as TWinControl);
  questions.Checked[questions.ItemIndex]:=true;
  questions.OnItemClick(sender,questions.ItemIndex);

end;

end.

