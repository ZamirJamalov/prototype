UNIT umain;

{$mode objfpc}{$H+}

INTERFACE

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Buttons,fpjson,jsonparser,grids;

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

TYPE

  { TfrmMain }

  TfrmMain = CLASS(TForm)
    btnNew: TBitBtn;
    btnRefresh: TBitBtn;
    btnExport: TBitBtn;
    btnView: TBitBtn;
    btnDelete: TBitBtn;
    btnUpdate: TBitBtn;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    PROCEDURE btnNewClick(Sender: TObject);
    PROCEDURE FormCloseQuery(Sender: TObject; var CanClose: boolean);
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE TreeView1Click(Sender: TObject);
    PROCEDURE newtab(p_form:RForm);
    PROCEDURE TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure viewgrid(form:rform;tab:ttabsheet);
  private
    Fnode :TTreeNode;
  public

  END;

var
  frmMain: TfrmMain;
  form:Rform;
  frm:TForm;
  schema_name :string;
  arr_menu:array of rmenu;
implementation
uses ujson,uusers;
{$R *.frm}

{ TfrmMain }

PROCEDURE TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
BEGIN
  Application.Terminate;
end;

PROCEDURE TfrmMain.btnNewClick(Sender: TObject);
  VAR
     active_pagename : STRING;
     tempForm        : TFORM;
     fc              : TFORMCLASS;
BEGIN
   active_pagename :=  copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name));
   IF (assigned(application.FindComponent(active_pagename) as TFORM))  THEN   begin
      exit;
   end;
   IF (assigned(application.FindComponent(active_pagename) as TFORM))  THEN   begin
      (application.findcomponent(active_pagename) as TFORM).Destroy;
      (application.findcomponent(active_pagename) as TFORM).Free;
   end;
   IF NOT (assigned(application.FindComponent(active_pagename) as TFORM)) THEN BEGIN
      fc := TFormClass(FindClass('tfrm'+active_pagename));
      tempForm := fc.Create(Application);
      tempForm.Show;
   END;
end;

PROCEDURE TfrmMain.FormCreate(Sender: TObject);
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
    for i:=0 to  jdata.FindPath('Response.Components[0].rows').Count-1 do begin
      setlength(arr_menu,i+1);
      arr_menu[i].id              :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[0]').AsString;
      arr_menu[i].root_id         :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[1]').AsString;
      arr_menu[i].caption         :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[2]').AsString;
      arr_menu[i].form_name       :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[3]').AsString;
      arr_menu[i].form_caption    :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[4]').AsString;
      arr_menu[i].schema_name     :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[5]').AsString;
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

PROCEDURE TfrmMain.TreeView1Click(Sender: TObject);
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

PROCEDURE TfrmMain.newtab(p_form: RForm);
  var
   jData : TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i:integer;
   Tab:TTabSheet;

begin
   IF assigned(PageControl1.FindComponent('tab_'+p_form.form_name) as TTabSheet) then BEGIN
      PageControl1.ActivePage := self.PageControl1.FindComponent('tab_'+copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name))) as TTabSheet;
      showmessage('is active');
      exit;
   END;

   form := p_form;
   tab := TTabSheet.Create(PageControl1);
   //Tab := PageControl1.AddTabSheet;// TTabSheet.Create(PageControl1);
   //tab.PageControl := PageControl1;
   tab.Parent := PageControl1;
   Tab.Name:='tab_'+p_form.form_name;
   Tab.Caption:=p_form.form_caption;
   PageControl1.ActivePage:=tab;
   Cursor:=crSQLWait;
   viewgrid(p_form,tab);

   Cursor:=crDefault;
   IF panel2.Visible=false THEN begin Panel2.Visible:=true; end;
END;

PROCEDURE TfrmMain.TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
BEGIN
  try
   Fnode := TreeView1.GetNodeAt(x,y);
  except
    on E:exception do
  end;
end;

PROCEDURE TfrmMain.viewgrid(form: rform; tab: ttabsheet);
  var
    jData :  TJSONData;
    jObject: TJSONObject;
    jArray : TJSONArray;
    i,j:integer;
    ujs_:ujs;
    s:widestring;
    stringGrid:TStringGrid;
 begin
    ujs_ :=  ujs.Create;
    s := ujs_.runHub(schema_name+'.'+form.form_name+'_pkg.grid_data','');
    if ujs_.jsonError<>'' then begin
       Showmessage(ujs_.jsonError);
       exit;
    end;
    jData := GetJSON(s);
    ujs_.Free;
    stringGrid := TStringGrid.Create(tab);
    stringGrid.Name:='grid_'+form.form_name;
    stringGrid.Visible:=false;
    stringGrid.Parent := tab;
    stringGrid.Align:=alClient;
    stringGrid.Anchors:=[akLeft,akTop,akBottom,akRight];
    stringGrid.FixedCols:=0;
    stringGrid.RowCount:=1;
    stringGrid.ColumnClickSorts:=true;
    //stringGrid.OnSelectCell:=@onSelectCell;
    //stringGrid.OnClick:=@onGridClick;
    //stringGrid.OnPrepareCanvas:=@OnPrepareCanvas;
    //stringGrid.OnCompareCells:=@onCompareCells;
    //stringGrid.OnHeaderClick:=@HeaderClick;
    stringGrid.Options:=[goColSizing,goColMoving,goVertLine,goSmoothScroll,goRangeSelect,goHorzLine,goFixedVertLine,goFixedHorzLine];
    stringGrid.DoubleBuffered:=true;
    for i:=0 to  jdata.FindPath('Response.Components[0].columns').Count-1  do   begin
           stringGrid.Columns.Add;
           stringGrid.Columns[i].Title.Alignment:=taCenter;
           stringGrid.Columns[i].Title.Font.Style:=[fsBold];
           stringGrid.Columns[i].Title.Caption := jdata.FindPath('Response.Components[0].columns['+inttostr(i)+']').AsString;
           stringGrid.Columns[i].Width:=round(tab.Width/jdata.FindPath('Response.Components[0].columns').Count);
           stringGrid.Columns[i].Title.Font.Color:=clwhite;
           stringGrid.Columns[i].Title.Color:=$00621E0B;
           //stringGrid.Columns[i].Color:=$00FFD3CA;
     end;
     for i:=0 to  jdata.FindPath('Response.Components[0].rows').Count-1  do begin
         stringGrid.RowCount:=stringGrid.RowCount+1;
         for j:=0 to jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)).Count-1 do begin
            stringGrid.Cells[j,i+1]:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
         end;//for j
     end;//for i

     stringGrid.Visible:=true;
     jData.Free;

END;

END.

