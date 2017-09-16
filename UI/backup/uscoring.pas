unit uscoring;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CheckLst, ExtCtrls, Buttons, Calendar,ujson;

type

  { TfrmScoring }

  TfrmScoring = class(TForm)
    client_id: TComboBox;
    score_val: TEdit;
    Image2: TImage;
    Image3: TImage;
    Label3: TLabel;
    questions: TCheckListBox;
    questions_params: TCheckListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    SpeedButton1: TSpeedButton;
    procedure client_idChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure questionsItemClick(Sender: TObject; Index: integer);
    procedure questionsSelectionChange(Sender: TObject; User: boolean);
    procedure questions_paramsItemClick(Sender: TObject; Index: integer);
    procedure questions_paramsSelectionChange(Sender: TObject; User: boolean);
  private

  public

  end;

var
  frmScoring: TfrmScoring;
  ujs_, ujs_1:ujs;
  question_click_event:boolean;
  qa_finished:boolean;
implementation
uses unit1;
{$R *.lfm}

{ TfrmScoring }

procedure TfrmScoring.FormActivate(Sender: TObject);
begin

end;

procedure TfrmScoring.client_idChange(Sender: TObject);
begin

  if (client_id.Items[client_id.ItemIndex] ='000008') or (client_id.Items[client_id.ItemIndex] ='000010')  or (client_id.Items[client_id.ItemIndex] ='000012') then begin
     Image3.Visible:=false;
     Image2.Visible:=true;
  end
  else begin
     Image2.Visible:=false;
     Image3.Visible:=true;
  end;
  case client_id.Items[client_id.ItemIndex] of
    '000008': begin
                LabeledEdit1.Text:='Camalov Zamir Zeynal';
                LabeledEdit2.Text:='10%';
                LabeledEdit3.Text:='Hasanov İmran Əli';
                LabeledEdit4.Text:='21%';
     end;
    '000009': begin
                LabeledEdit1.Text:='Həsənova Həmidə İkram';
                LabeledEdit2.Text:='50%';
                LabeledEdit3.Text:='Əliyeva Ceyran Həsən';
                LabeledEdit4.Text:='40%';
     end;
    '000010': begin
                LabeledEdit1.Text:='Telamov Teymur Toğrul';
                LabeledEdit2.Text:='0%';
                LabeledEdit3.Text:='Cənnətov İzzət Faiq';
                LabeledEdit4.Text:='21%';
     end;
    '000011': begin
                LabeledEdit1.Text:='İvanova Yelena İvan';
                LabeledEdit2.Text:='32%';
                LabeledEdit3.Text:='Mirəli Yusifov Zakir';
                LabeledEdit4.Text:='45%';
     end;
    '000012': begin
                LabeledEdit1.Text:='Sakin Əliyev Cavad';
                LabeledEdit2.Text:='80%';
                LabeledEdit3.Text:='Cavidan Axundov Soltan';
                LabeledEdit4.Text:='78%';
     end;
  end;
end;

procedure TfrmScoring.FormCreate(Sender: TObject);
begin

end;

procedure TfrmScoring.FormShow(Sender: TObject);
var
   s:widestring;
   frm :TForm1;
begin
  //s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"TFORM":"'+self.name+'"');
 s := ujs_.runHub('zamir.ui_pkg.get_ui_comps','"form":"frmscoring","crud":"add","id":"",'+'"schema_name":"scoring"');
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

  questions.Selected[0]:=true;
  questions.Checked[0]:=true;
  questions.OnItemClick(sender,0);
  questions.Enabled:=false;




end;

procedure TfrmScoring.questionsItemClick(Sender: TObject; Index: integer);
var
   s:widestring;
   frm :TForm1;

begin

 //s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"TFORM":"'+self.name+'"');
 s := ujs_1.runHub('scoring.questions_pkg.onchange','"form":"frmscoring","crud":["add"],"id":[""],'+'"schema_name":["scoring"],"questions":["'+ujs_.getIdByIndex('questions',index)+'"]');
 if ujs_1.jsonError<>'' then begin
    Showmessage(ujs_1.jsonError);
    exit;
 end;
 // frm := TForm1.Create(nil);
 // frm.setlog(s);
 // frm.ShowModal;
  ujs_1 :=  ujs.Create;
  ujs_1.parseResponse(s);

  ujs_1.existsform(self,s,frmScoring as TWinControl);

end;

procedure TfrmScoring.questionsSelectionChange(Sender: TObject; User: boolean);
begin
// if question_click_event=true then
// questions.OnItemClick(sender,questions.ItemIndex);
 questions_params.SetFocus;
end;

procedure TfrmScoring.questions_paramsItemClick(Sender: TObject; Index: integer);
var
   s:widestring;
   frm :TForm1;
   i:integer;

begin
  //s := ujs_.runHub('scoring.questions_pkg.questions_list_clob','"TFORM":"'+self.name+'"');
  if client_id.ItemIndex<0 then begin
    showmessage('Müştərini seçin');
    exit;
 end;
 s := ujs_1.runHub('scoring.questions_params_pkg.onchange','"form":"frmscoring","crud":["add"],"id":[""],'+'"schema_name":["scoring"],"questions_params":["'+ujs_1.getIdByIndex('questions_params',index)+'"],"client_id":["'+client_id.Items[client_id.ItemIndex]+'"]');
 if ujs_1.jsonError<>'' then begin
    Showmessage(ujs_1.jsonError);
    exit;
 end;
 // frm := TForm1.Create(nil);
 // frm.setlog(s);
 // frm.ShowModal;
  //ujs_ :=  ujs.Create;
  //ujs_.parseResponse(s);

  ujs_1.existsform(self,s,frmScoring as TWinControl);
   //question_click_event:=true;

  if questions.ItemIndex<questions.Items.Count-1 then begin
     // showmessage(inttostr(questions.ItemIndex)+' '+inttostr(questions.Items.count));
      questions.Selected[questions.ItemIndex+1]:=true;
      questions.Checked[questions.ItemIndex]:=true;
     questions.OnItemClick(sender,questions.ItemIndex);
  end
  else begin
    questions.Enabled:=false;
    questions_params.Enabled:=false;
  end;




end;

procedure TfrmScoring.questions_paramsSelectionChange(Sender: TObject;
  User: boolean);
begin

end;

end.

