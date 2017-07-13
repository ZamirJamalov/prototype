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
    Panel1: TPanel;
    Panel3: TPanel;
    procedure btnSaveTopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
    procedure load_components(p_form:String);
    procedure setCrud(p_crud:string);
    procedure setCaption(p_caption:string);
    function  getClosedParam:boolean;
  end;

var
  frm: Tfrm;
  v_crud:string;
  closedParam : boolean;
  ujs_:ujs;
implementation

{$R *.lfm}

{ Tfrm }

procedure Tfrm.btnSaveTopClick(Sender: TObject);
 var
  ujs_1:ujs;
  s:widestring;
begin
  ujs_1 :=  ujs.Create;
  ujs_1.clear;

  s := ujs_.runHub(umain.schema_name+'.'+self.name+'_pkg.'+v_crud,'"TFORM":"'+self.name+'",'+ujs_.prepareRequest(self));
  ujs_1.parseResponse(s);
  ujs_.AppendResponseJsonToExistsJson := ujs_1.retParseResponse;
  ujs_.existsform(self,s,panel3);
  if ujs_.errorexists=false then
     showmessage('Data saved');
end;

procedure Tfrm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure Tfrm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  closedParam :=true;
end;

procedure Tfrm.FormCreate(Sender: TObject);
begin
  closedParam:=false;
end;



procedure Tfrm.load_components(p_form: String);
var
  v_json :widestring;
begin
     v_json := ujs_.runHub(umain.schema_name+'.ui_pkg.get_ui_comps','"form":"'+p_form+'"');
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

