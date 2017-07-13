unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls,grids, Buttons,fpjson,jsonparser,MTProcs;
type
  Rmenu=record
    id:string;
    root_id:string;
    caption:string;
    form_name:string;
    form_caption:string;
    schema_name:string;
  end;
 type
   Rform=record
     form_name:string;
     form_caption:widestring;
   end;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnNew: TBitBtn;
    btnDel: TBitBtn;
    btnExcel: TBitBtn;
    btnRefresh: TBitBtn;
    btnView: TBitBtn;
    btnUpd: TBitBtn;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    procedure btnUpdClick(Sender: TObject);
    procedure showform(p_crud:string;p_id:string);
    procedure btnNewClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure newTab(p_form:Rform);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);



  private
    { private declarations }
    Fnode :TTreeNode;
    function getFormCaptionByActiveTab:String;
  public
    { public declarations }
    procedure onGridClick(Sender:Tobject);
    procedure onSelectCell(sender:tobject;acol,arow:integer;var CanSelect :boolean);
    procedure viewgrid(form:rform);
    procedure fillgrid(grid:TStringGrid;empty_grid:string;from_:integer;to_:integer);
  end;



var
   frmMain: TfrmMain;

   Tab:TTabSheet;
   button_new, button_upd, button_del, button_view, button_excel:TButton;
   panel,panel2:TPanel;
   stringGrid:TStringGrid;
   ora_package_name:string;
   arr_menu:array of rmenu;
   form:Rform;
   frm:TForm;
   schema_name :string;
   v_row:integer;
   v_grid_id:integer;
implementation
uses uchild,ujson,uusers,uForm;
{$R *.lfm}



{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
  var
    jData : TJSONData;
    jObject: TJSONObject;
    jArray : TJSONArray;
    i,j:integer;
    ujs_:ujs;
 begin
    ujs_ :=  ujs.Create;
    jData := GetJSON(ujs_.runHub('zamir.ui_pkg.menu_data',''));
    ujs_.Free;
    TreeView1.Items.Clear;
    for i:=0 to  jdata.FindPath('rows').Count-1 do begin
      setlength(arr_menu,i+1);
      arr_menu[i].id              :=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'[0]').AsString;
      arr_menu[i].root_id         :=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'[1]').AsString;
      arr_menu[i].caption         :=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'[2]').AsString;
      arr_menu[i].form_name       :=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'[3]').AsString;
      arr_menu[i].form_caption    :=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'[4]').AsString;
      arr_menu[i].schema_name     :=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'[5]').AsString;
    end;//for i
    for i:=0 to length(arr_menu)-1 do  begin
       if i=0 then begin
           TreeView1.Items.Add(nil,arr_menu[i].caption);
           continue;
        end;//if
       TreeView1.Items.AddChild(TreeView1.Items[strtoint(arr_menu[i].root_id)-1],arr_menu[i].caption);
    end;//for i
    TreeView1.FullExpand;
    jData.Free;
end;

procedure TfrmMain.TreeView1Click(Sender: TObject);
var
  i:integer;
begin
  IF TreeView1.Items.SelectionCount=0 THEN BEGIN
      exit;
  END;
  for i:=0 to length(arr_menu)-1 do begin
     if (TreeView1.Selected=Fnode) and (arr_menu[i].caption=TreeView1.Selected.Text) and (arr_menu[i].form_name<>'') then  begin
         form.form_name:=arr_menu[i].form_name;
         form.form_caption:=arr_menu[i].form_caption;
         schema_name := arr_menu[i].schema_name;
         newTab(form);
         exit;
       end; //IF
  end; //for
end;

procedure TfrmMain.newTab(p_form: Rform);
  var
   k:integer;
   jData : TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i:integer;
begin
   IF assigned(PageControl1.FindComponent('tab_'+p_form.form_name) as TTabSheet) then BEGIN
      PageControl1.ActivePage := self.PageControl1.FindComponent('tab_'+copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name))) as TTabSheet;
      showmessage('is active');
      exit;
   END;

   form := p_form;
   k := PageControl1.PageCount+1;
   Tab := TTabSheet.Create(PageControl1);
   tab.PageControl := PageControl1;
   tab.Parent := PageControl1;
   Tab.Name:='tab_'+p_form.form_name;
   Tab.Caption:=p_form.form_caption;
   viewgrid(p_form);
   IF panel2.Visible=false THEN Panel2.Visible:=true;
end;


procedure TfrmMain.TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  try
   Fnode := TreeView1.GetNodeAt(x,y);
  except
    on E:exception do
  end;
end;

function TfrmMain.getFormCaptionByActiveTab: String;
var
  i:integer;
begin
  FOR i := 0 TO length(arr_menu) - 1 DO BEGIN
     IF arr_menu[i].form_name = copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name)) THEN BEGIN
         result := arr_menu[i].form_caption;
         exit;
     END;
  END;
end;

procedure TfrmMain.onGridClick(Sender:Tobject);
 var
   i:integer;
   f:boolean;
begin
  f:=false;
  for i:=0 to (sender as TStringGrid).ColCount do begin
     if lowercase((sender as TStringGrid).Columns[i].Title.Caption)='id' then begin
         f:=true;
         break;
     end;
  end;
  v_grid_id := strtoint((sender as TStringGrid).Cells[i,v_row]);
  if not f then begin
     showmessage('There not found column with name id.This is critical');
  end;
end;




procedure TfrmMain.onSelectCell(sender: tobject; acol, arow: integer;
  var CanSelect: boolean);
begin
  //showmessage((sender as Tstringgrid).Cells[acol,arow]) ;
  v_row := arow;
end;



procedure TfrmMain.viewgrid(form:rform);
  var
   jData : TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i,j:integer;
   ujs_:ujs;
begin
   ujs_ :=  ujs.Create;
   jData := GetJSON(ujs_.runHub(schema_name+'.'+form.form_name+'_pkg.grid_data',''));
   ujs_.Free;

   stringGrid := TStringGrid.Create(tab);
   stringGrid.Name:='grid_'+form.form_name;
   stringGrid.Visible:=false;
   stringGrid.Parent := tab;
   stringGrid.Align:=alClient;
   stringGrid.Anchors:=[akLeft,akTop,akBottom,akRight];
   stringGrid.Options:=[goColSizing,goColMoving,goVertLine,goSmoothScroll,goRangeSelect,goHorzLine,goFixedVertLine,goFixedHorzLine,goRowSelect];
   stringGrid.FixedCols:=0;
   stringGrid.RowCount:=1;
   stringGrid.ColumnClickSorts:=true;
   stringGrid.OnSelectCell:=@onSelectCell;
   stringGrid.OnClick:=@onGridClick;
   for i:=0 to  jdata.FindPath('columns').Count-1  do   begin
          stringGrid.Columns.Add;
          stringGrid.Columns[i].Title.Alignment:=taCenter;
          stringGrid.Columns[i].Title.Caption := jdata.FindPath('columns['+inttostr(i)+']').AsString;
          stringGrid.Columns[i].Width:=100;
    end;
    for i:=0 to  jdata.FindPath('rows').Count-1  do begin
        stringGrid.RowCount:=stringGrid.RowCount+1;
        for j:=0 to jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)).Count-1 do begin
           stringGrid.Cells[j,i+1]:=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
        end;//for j
    end;//for i
    stringGrid.Visible:=true;
    jData.Free;
end;

procedure TfrmMain.fillgrid(grid: TStringGrid; empty_grid: string; from_: integer; to_: integer);
var
  jData : TJSONData;
  jObject: TJSONObject;
  jArray : TJSONArray;
  i,j:integer;
  ujs_:ujs;
begin
  ujs_ :=  ujs.Create;
  jData := GetJSON(ujs_.runHub('zamir.users_pkg.grid_data',''));
  ujs_.Free;
  for i:=0 to  jdata.FindPath('columns').Count-1  do begin
       stringGrid.Columns.Add;
       stringGrid.Columns[i].Title.Alignment:=taCenter;
       stringGrid.Columns[i].Title.Caption := jdata.FindPath('columns['+inttostr(i)+']').AsString;
       stringGrid.Columns[i].Width:=100;
   end;
   for i:=0 to  jdata.FindPath('rows').Count-1 do begin
       stringGrid.RowCount:=stringGrid.RowCount+1;
       for j:=0 to jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)).Count-1 do begin
           stringGrid.Cells[j,i+1]:=jdata.FindPath('rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
        end;
    end;
    stringGrid.Visible:=true;
    jData.Free;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  Panel2.Destroy;
  Application.terminate;
end;

procedure TfrmMain.showform(p_crud: string;p_id:string);
var
    frm:Tfrm;
    active_pagename :string;
begin
   active_pagename :=  copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name));
   IF (assigned(self.FindComponent(active_pagename) as Tfrm))  and ((self.findcomponent(active_pagename) as Tfrm).getClosedParam=false) THEN   begin
      exit;
   end;
   IF (assigned(self.FindComponent(active_pagename) as Tfrm))  and ((self.findcomponent(active_pagename) as Tfrm).getClosedParam=true) THEN   begin
      (self.findcomponent(active_pagename) as Tfrm).Destroy;
      (self.findcomponent(active_pagename) as Tfrm).Free;
   end;
   IF NOT (assigned(self.FindComponent(active_pagename) as Tfrm)) THEN BEGIN
       frm :=  Tfrm.Create(self);
       frm.Name:=active_pagename;
       frm.load_components(active_pagename,p_id);
       frm.setCrud(p_crud);
       frm.setCaption(getFormCaptionByActiveTab);
       frm.Show;
    END;
end;

procedure TfrmMain.btnUpdClick(Sender: TObject);
begin
  if v_grid_id=0 then begin
      showmessage('no row selected');
  end else showform('upd',inttostr(v_grid_id));
end;

procedure TfrmMain.btnNewClick(Sender: TObject);
 var
   grid:TStringGrid;
   grid_id :string;
   frm:Tfrm;
   active_pagename:string;
begin
  active_pagename :=  copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name));

  showform('add','');
end;

end.

