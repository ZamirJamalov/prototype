unit uClientSearch;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Grids, Buttons,fpjson,jsonparser,ujson,strutils;

type

  { Tfrmclientsearch }

  Tfrmclientsearch = class(TForm)


    btnaccept: TButton;
    btncancel: TButton;
    code: TEdit;
    docno: TEdit;
    clientname: TEdit;
    Label1: TLabel;
    phonenumber: TEdit;
    btnclearall: TSpeedButton;
    StringGrid1: TStringGrid;
    procedure btnacceptClick(Sender: TObject);
    procedure btncancelClick(Sender: TObject);
    procedure btnclearallClick(Sender: TObject);
    procedure codeKeyPress(Sender: TObject; var Key: char);
    procedure codeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    type
      t_customer_data=record
        customer_name:string;
        customer_code:string;
    end;
      type
        tcustomers=record
           code:string;
           name:string;
           document_no:string;
           phone_number:string;
           birthdate:string;
        end;
       type
         t_customers_array=array of tcustomers;
   var
      v_customer_data:t_customer_data;
      v_form_active_:integer;
   procedure search(p_edit:TEdit);
   var
     cs_array        :t_customers_array;
     cs_rec          :tcustomers;
     v_row           :integer;
     v_selected_cls  :string;
  public
    property v_form_active:integer  read v_form_active_;
    type customer_data=tcustomers;
    function cs_data:t_customer_data;
  end;

var
  frmclientsearch: Tfrmclientsearch;


implementation
uses usession;
{$R *.lfm}

{ Tfrmclientsearch }

procedure Tfrmclientsearch.btncancelClick(Sender: TObject);
begin
 Close;
end;

procedure Tfrmclientsearch.btnacceptClick(Sender: TObject);
begin
 if StringGrid1.Cells[0,v_row]='' then begin
     showmessage('Müştərini siyahıdan seçiniz.');
     exit;
  end;
 v_customer_data.customer_code:=StringGrid1.Cells[0,v_row];
 v_customer_data.customer_name:=StringGrid1.Cells[1,v_row];
 usession.customer_code:=v_customer_data.customer_code;
 Close;
 v_form_active_:=2;
end;

procedure Tfrmclientsearch.btnclearallClick(Sender: TObject);
begin
   stringGrid1.RowCount:=1;
   code.Clear;
   docno.Clear;
   clientname.Clear;
   phonenumber.Clear;
end;

procedure Tfrmclientsearch.codeKeyPress(Sender: TObject; var Key: char);
begin
end;

procedure Tfrmclientsearch.codeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  search(sender as TEdit);
  v_row := 0;
end;

procedure Tfrmclientsearch.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
 if v_form_active_<>2 then begin
     v_form_active_:=1;
   end;
end;

procedure Tfrmclientsearch.FormCreate(Sender: TObject);
 var
   ujs_            :ujs;
   v_json          :widestring;
   jData           :TJSONData;
   i,j             :integer;
   s               :widestring;
begin
   v_form_active_ := 0;
   ujs_ :=  ujs.Create;
   s := ujs_.runHub('scoring.customers_pkg.grid_data','"TFORM":"","index":[],"sort_order":[]');
   if ujs_.jsonError<>'' then begin
      Showmessage(ujs_.jsonError);
      ujs_.Free;
      exit;
   end;
   jData := GetJSON(s);
   ujs_.Free;
   setlength(cs_array,jdata.FindPath('Response.Components[0].rows').Count);
    for i:=0 to  jdata.FindPath('Response.Components[0].rows').Count-1  do begin
         for j:=0 to jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)).Count-1 do begin
          case j of
           1: cs_rec.code:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
           2: cs_rec.name:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
           3: cs_rec.document_no:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
           4: cs_rec.phone_number:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
           5: cs_rec.birthdate:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
          end;
        end;//for j
        cs_array[i]:=cs_rec;
    end;//for i
    //stringGrid1.Options:=[goColSizing,goColMoving,goVertLine,goSmoothScroll,goHorzLine,goFixedVertLine,goFixedHorzLine,goHeaderPushedLook,goRowHighlight];
    StringGrid1.RowCount:=1;
    jData.Free;

end;

procedure Tfrmclientsearch.StringGrid1Click(Sender: TObject);
 var
   i      :integer;
   v_code :string;
begin
  // showmessage(inttostr(v_row));
   v_code := StringGrid1.Cells[0,v_row];
   for i:=0 to length(cs_array)-1 do begin
      if v_code=cs_array[i].code then begin
         code.Text:=cs_array[i].code;
         docno.Text:=cs_array[i].document_no;
         clientname.Text:=cs_array[i].name;
         phonenumber.Text:=cs_array[i].phone_number;
         exit;
      end;
  end;
end;

procedure Tfrmclientsearch.StringGrid1SelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
   v_row:=arow;
end;

procedure Tfrmclientsearch.search(p_edit: TEdit);
 var
    i      :integer;
    j      :integer;
    f      :boolean;
 begin
  f:=false;
  if length(p_edit.Text)=0 then begin
     StringGrid1.RowCount:=1;
     exit;
  end;
  stringGrid1.RowCount := 1;
  for i:=0 to length(cs_array)-1 do begin
     if npos(p_edit.Text,cs_array[i].code,1)>0 then begin
        f:=true;
        StringGrid1.RowCount:=stringGrid1.RowCount+1;
        StringGrid1.Cells[0,StringGrid1.RowCount-1]:=cs_array[i].code;
        StringGrid1.Cells[1,StringGrid1.RowCount-1]:=cs_array[i].name;
        StringGrid1.Cells[2,StringGrid1.RowCount-1]:=cs_array[i].birthdate;
     end;
  end;
  if not f then begin
     StringGrid1.RowCount:=1;
  end;

end;

function Tfrmclientsearch.cs_data: t_customer_data;
begin
  result := v_customer_data;
end;

end.

