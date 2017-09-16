unit uForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls,fpjson,jsonparser,ujson,umain;


TYPE
  tcomp=RECORD

  type_ : STRING;
  name_ : STRING;
  default_value : wideSTRING;
  label_caption : wideSTRING;
  width_ : STRING;
  font_size : STRING;
  font_color : STRING;
  background_color: STRING;
  enabled_ : STRING;
  visible_ : STRING;
  hint :widestring;
  required:string;
END;


type
  rcomponents =record
    comp:TComponent;
  end;

type

  { Tfrm }

  Tfrm = class(TForm)
    btnSaveTop: TButton;
    Button1: TButton;
    Panel1: TPanel;
    Panel3: TPanel;
    procedure btnSaveTopClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
    procedure setSchemaName(p_schema_name:String);
  public
    { public declarations }
    property schemaName :String write setSchemaName;
    procedure load_components(p_form:String;p_id:string);
    procedure setCrud(p_crud:string);
    procedure setCaption(p_caption:string);
    function  getClosedParam:boolean;
  end;

var
  frm: Tfrm;
  v_crud:string;
  closedParam : boolean;
  ujs_:ujs;
  schema_name:string;
implementation
 uses usession;
{$R *.lfm}

{ Tfrm }

procedure Tfrm.btnSaveTopClick(Sender: TObject);
 var
  ujs_1:ujs;
  s:widestring;
begin
 if  usession.call_proc_name=''  then begin

  ujs_1 :=  ujs.Create;
  ujs_1.clear;

  s := ujs_.runHub(schema_name+'.'+self.name+'_pkg.'+v_crud,'"TFORM":"'+self.name+'",'+ujs_.prepareRequest(self));
  if ujs_.jsonError<>'' then begin
     umain.refresh_click:=2;
     Showmessage(ujs_.jsonError);
     exit;
  end;
  ujs_1.parseResponse(s);
  ujs_.AppendResponseJsonToExistsJson := ujs_1.retParseResponse;
  ujs_.existsform(self,s,panel3);
  if ujs_.errorexists=false then begin
    umain.refresh_click:=1;
    close;
  end
 end
   else begin
     usession.call_proc_result:= ujs_.prepareRequest(self);
     usession.form_closed_by_user:=true;
     closedParam:=true;
     umain.refresh_click:=2;
     Close;
   end;

end;

procedure Tfrm.Button1Click(Sender: TObject);
begin
   if umain.refresh_click=0 then begin
     umain.refresh_click:=2;
  end;
  usession.form_closed:=true;
  Close;
end;

procedure Tfrm.FormActivate(Sender: TObject);
begin
  if v_crud='view_' then btnSaveTop.Visible:=false else btnSaveTop.Visible:=true;
end;

procedure Tfrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if umain.refresh_click=0 then begin
     umain.refresh_click:=2;
  end;
  usession.form_closed:=true;
end;

procedure Tfrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
   if umain.refresh_click=0 then begin
     umain.refresh_click:=2;
  end;

  usession.form_closed:=true;
  CanClose:=true;
end;

procedure Tfrm.FormCreate(Sender: TObject);
begin
  closedParam:=false;

end;

procedure Tfrm.setSchemaName(p_schema_name: String);
begin
   schema_name:=p_schema_name;
end;

procedure Tfrm.load_components(p_form: String;p_id:string);
var
  v_json :widestring;
begin
     v_json := ujs_.runHub('zamir.ui_pkg.get_ui_comps','"form":"'+p_form+'","crud":"'+v_crud+'","id":"'+p_id+'",'+'"schema_name":"'+schema_name+'"');
     if ujs_.jsonError<>'' then begin
        showmessage(ujs_.jsonError);
        exit;
     end;
     ujs_ :=  ujs.Create;
     ujs_.parseResponse(v_json);
     ujs_.newform(self,v_json,Panel3);
end;

procedure Tfrm.setCrud(p_crud: string);
begin
  v_crud := p_crud;
end;

procedure Tfrm.setCaption(p_caption: string);
begin
  self.Caption := p_caption;
end;

function Tfrm.getClosedParam: boolean;
begin
  result := closedParam;
end;


end.

