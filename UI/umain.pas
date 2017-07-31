unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls,grids, Buttons,fpjson,jsonparser,MTProcs,LazUTF8Classes;
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
    Timer1: TTimer;
    TrayIcon1: TTrayIcon;
    TreeView1: TTreeView;
    procedure btnDelClick(Sender: TObject);
    procedure btnExcelClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnUpdClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure showform(p_crud:string;p_id:string);
    procedure btnNewClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure newTab(p_form:Rform);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);



  private
    { private declarations }
    Fnode :TTreeNode;
    function getFormCaptionByActiveTab:String;
    function addcomma(p_val :integer):string;
  public
    { public declarations }
    procedure onGridClick(Sender:Tobject);
    procedure onSelectCell(sender:tobject;acol,arow:integer;var CanSelect :boolean);
    procedure onPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
    procedure viewgrid(form:rform);
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
uses uchild,ujson,uusers,uForm,uforms,uselfdialogbox;
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

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
    TrayIcon1.BalloonFlags:=bfInfo;
     TrayIcon1.BalloonTitle:='New version is available';
     TrayIcon1.BalloonHint:='Bank program 1.10 is released. Please visit us. www.test.com';
     TrayIcon1.ShowBalloonHint;
end;



procedure TfrmMain.TreeView1Click(Sender: TObject);
var
  i:integer;
begin
  IF TreeView1.Items.SelectionCount=0 THEN BEGIN
      exit;
  END;
  for i:=0 to length(arr_menu)-1 do begin
     if (TreeView1.Selected=Fnode) and (arr_menu[i].caption=TreeView1.Selected.Text) and (arr_menu[i].form_name='XFORMS') then  begin
         frm := TxFORMS.Create(self);
         frm.Visible:=true;
         exit;
     end;
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
   Cursor:=crSQLWait;
   viewgrid(p_form);
   Cursor:=crDefault;
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

function TfrmMain.addcomma(p_val: integer): string;
begin
  if p_val>0 then result := ',' else result := '';
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

procedure TfrmMain.onPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
begin
  if not (gdfixed in aState) then
    if aRow mod 2 = 0 then begin
      (sender as TStringGrid).Canvas.Brush.Color := clWhite;
    end else begin
      (sender as TStringGrid).Canvas.Brush.Color := $00F8F8F8;
    end;
end;



procedure TfrmMain.viewgrid(form:rform);
  var
   jData :  TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i,j:integer;
   ujs_:ujs;
   s:widestring;
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
   stringGrid.OnSelectCell:=@onSelectCell;
   stringGrid.OnClick:=@onGridClick;
   stringGrid.OnPrepareCanvas:=@OnPrepareCanvas;
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
       frm.schemaName:=schema_name;
       frm.setCrud(p_crud);
       frm.load_components(active_pagename,p_id);
       case p_crud  of
        'add'   : frm.setCaption(getFormCaptionByActiveTab+'  -Yeni melumat');
        'upd'   : frm.setCaption(getFormCaptionByActiveTab+'  -Cari melumatin deyishdirilmsei');
        'view_' : frm.setCaption(getFormCaptionByActiveTab+'  -Cari melumata baxish');
        'del'   : frm.setCaption(getFormCaptionByActiveTab+'  -Cari melumatin silinmesi');
       end;
       frm.Show;
    END;
end;

procedure TfrmMain.btnUpdClick(Sender: TObject);
begin
  if v_grid_id=0 then begin
      showmessage('no row selected');
  end else showform('upd',inttostr(v_grid_id));
end;

procedure TfrmMain.btnDelClick(Sender: TObject);
begin
  if v_grid_id=0 then begin
      showmessage('no row selected');
  end else showform('del',inttostr(v_grid_id));
end;

procedure TfrmMain.btnExcelClick(Sender: TObject);
 var
    active_pagename : string;
    tab : TTabSheet;
    i,j:integer;
    memo:TMemo;
    s:widestring;
    // str:TStringListUTF8;
    str:TStringList;
    savedialog:TSaveDialog;
begin
  savedialog := TSaveDialog.Create(nil);
  savedialog.Filter:='*.csv|*.csv';
  if savedialog.Execute then begin
  active_pagename :=  copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name));
  tab := self.PageControl1.FindComponent('tab_'+active_pagename) as TTabSheet;
  memo :=  tmemo.Create(self);
  str := TStringListUTF8.create;


  with (self.PageControl1.FindComponent('tab_'+active_pagename) as TTabSheet).FindComponent('grid_'+active_pagename) as TStringGrid do begin
   for i:=0 to colcount-1 do begin
    s := s + addcomma(i)+columns[i].Title.Caption;
   end;
   s := s+#13#10;
   for i :=1 to rowcount-1 do begin
         for j := 0 to colcount-1 do begin
          s := s + addcomma(j)+Cells[j,i];
         end; //for j
         s:= s+#13#10;
   end; //for i
  SaveToCSVFile(savedialog.FileName,',');
  str.Text :=s;
  str.text := AnsiToUtf8(str.text);
  str.SaveToFile(savedialog.FileName);
  str.Free;
 end;
  end;

end;

procedure TfrmMain.btnRefreshClick(Sender: TObject);
var
   jData :  TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i,j:integer;
   ujs_:ujs;
   s:widestring;
   active_pagename:String;
   tab :TTabSheet;
begin
   active_pagename :=  copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name));

   ujs_ :=  ujs.Create;
   s := ujs_.runHub(schema_name+'.'+active_pagename+'_pkg.grid_data','');
   if ujs_.jsonError<>'' then begin
      Showmessage(ujs_.jsonError);
      exit;
   end;
   jData := GetJSON(s);
   ujs_.Free;

   tab := self.PageControl1.FindComponent('tab_'+active_pagename) as TTabSheet;
   with (self.PageControl1.FindComponent('tab_'+active_pagename) as TTabSheet).FindComponent('grid_'+active_pagename) as TStringGrid do begin
    Clear;
    FixedCols:=0;
    RowCount:=1;
    for i:=0 to  jdata.FindPath('Response.Components[0].columns').Count-1  do   begin
          //Columns.Add;
          Columns[i].Title.Alignment:=taCenter;
          Columns[i].Title.Font.Style:=[fsBold];
          Columns[i].Title.Caption := jdata.FindPath('Response.Components[0].columns['+inttostr(i)+']').AsString;
          Columns[i].Width:=round(tab.Width/jdata.FindPath('Response.Components[0].columns').Count);
          Columns[i].Title.Font.Color:=clwhite;
          Columns[i].Title.Color:=$00621E0B;
          //stringGrid.Columns[i].Color:=$00FFD3CA;
      end;
      for i:=0 to  jdata.FindPath('Response.Components[0].rows').Count-1  do begin
         RowCount:=RowCount+1;
        for j:=0 to jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)).Count-1 do begin
           Cells[j,i+1]:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
        end;//for j
      end;//for i
    jData.Free;
   end; //with

end;

procedure TfrmMain.btnViewClick(Sender: TObject);
begin
  if v_grid_id=0 then begin
      showmessage('no row selected');
  end else showform('view_',inttostr(v_grid_id));
end;

procedure TfrmMain.btnNewClick(Sender: TObject);
begin
  showform('add','');
end;

end.

