unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, grids, Buttons, Menus, fpjson, jsonparser, MTProcs,
  LazUTF8Classes, RTTICtrls, IpHtml, comobj, LCLType, ActnList, BCImageButton,
  BGRAShape, BGRAImageManipulation, dtthemedclock, DTAnalogClock, BCButton,
  DTAnalogGauge, BCMaterialDesignButton, usession;
type
  Rmenu=record
    id:string;
    root_id:string;
    caption:string;
    form_name:string;
    form_caption:string;
    schema_name:string;
    crud:string;
    external_form:string;
  end;
 type
   Rform=record
     form_name:string;
     form_caption:widestring;
   end;


type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnCustomeDetails: TBCMaterialDesignButton;
    btnCustomerSearch: TBCMaterialDesignButton;
    Button1: TBitBtn;
    btnExcel: TBCMaterialDesignButton;
    btnRefresh: TBCMaterialDesignButton;
    btnView: TBCMaterialDesignButton;
    btnDel: TBCMaterialDesignButton;
    btnUpd: TBCMaterialDesignButton;
    btnNew: TBCMaterialDesignButton;
    edcustomer_code: TEdit;
    edcustomer_name: TEdit;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    Timer1: TTimer;
    TreeView1: TTreeView;
    procedure btnCustomeDetailsClick(Sender: TObject);
    procedure btnCustomerSearchClick(Sender: TObject);
    procedure btnexitClick(Sender: TObject);
    procedure btnnew_clickExecute(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnExcelClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnUpdClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edcustomer_codeKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MenuItem1Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Panel5Click(Sender: TObject);
    function showform(p_schema_name:String;p_form_name:String;p_crud:string;p_id:string;p_width,p_height:integer):string;
    procedure btnNewClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    function newTab(p_form:Rform):string;
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);



  private
    { private declarations }
    Fnode :TTreeNode;
    tabexists:boolean;
    v_login_name:string;
    function getFormCaptionByActiveTab:String;
    function getRmenuByActiveTab:Rmenu;
    function addcomma(p_val :integer):string;
    procedure setLoginName(p_loginname :string);
  public
    { public declarations }
    property LoginName: string write setLoginName;

    procedure loadMenu;
    procedure onGridClick(Sender:Tobject);
    procedure onSelectCell(sender:tobject;acol,arow:integer;var CanSelect :boolean);
    procedure onPrepareCanvas(sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
    procedure onCompareCells(Sender:Tobject;ACol,ARow,BCol,BRow:Integer;var Result:integer);
    procedure headerClick(Sender :TObject;IsColumn:boolean;index:integer);
    function viewgrid(form:rform;tab:ttabsheet):string;


  end;



var
   frmMain: TfrmMain;

   refresh_click:integer;
   button_new, button_upd, button_del, button_view, button_excel:TButton;
   panel,panel2:TPanel;

   ora_package_name:string;
   arr_menu:array of rmenu;
   form:Rform;
   frm:TForm;
   schema_name :string;
   v_row:integer;
   v_grid_id:integer;
   v_grid_sort:integer;
implementation
uses ujson,uForm,utools,uscoring,filemanager,uClientSearch,uncustomerdetails;

procedure refreshclick;
begin

end;

{$R *.lfm}



{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  loadMenu;
end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin

end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin

end;

procedure TfrmMain.TreeView1Click(Sender: TObject);
var
  i:integer;
  frm:Tfrm;
  frmscr:TfrmScoring;
  v_res:String;
begin
  IF TreeView1.Items.SelectionCount=0 THEN BEGIN
      exit;
  END;

  for i:=0 to length(arr_menu)-1 do begin
      if (TreeView1.Selected=Fnode) and (arr_menu[i].caption=TreeView1.Selected.Text) and (arr_menu[i].form_name<>'')  and (utools.stringToBoolean(arr_menu[i].external_form)=false) then  begin
         form.form_name:=arr_menu[i].form_name;
         form.form_caption:=arr_menu[i].form_caption;
         schema_name := arr_menu[i].schema_name;
         v_res := newTab(form);
         if v_res<>'' then begin
            showmessage(v_res);
            exit;
         end;
         if tabexists then begin
            tabexists:=false;
            exit;
         end;
       end; //IF
  end; //for
 for i:=0 to length(arr_menu)-1 do begin
      if (TreeView1.Selected=Fnode) and (arr_menu[i].caption=TreeView1.Selected.Text) and (arr_menu[i].form_name<>'')  and (utools.stringToBoolean(arr_menu[i].external_form)=true) then  begin

         if arr_menu[i].form_name='frmScoring' then begin
           if usession.customer_code='' then begin
              showmessage('Müştərini seçin');
              exit;
           end;
         end;

         form.form_name:=arr_menu[i].form_name;
         form.form_caption:=arr_menu[i].form_caption;
         schema_name := arr_menu[i].schema_name;
         //newTab(form);
         //exit;
         //showmessage('before newtab');
          v_res := newTab(form);
         if v_res<>'' then begin
            showmessage(v_res);
            exit;
         end;
         if tabexists then begin
            tabexists:=false;
            exit;
         end;
         if arr_menu[i].form_name='frmScoring' then begin
            frmscr := TfrmScoring.Create(nil);
            frmscr.Name := 'frmScoring';
            frmscr.Align:=alClient;
            frmscr.BorderStyle:=bsNone;
            frmscr.Parent:= PageControl1.ActivePage;
            frmscr.Show;
            exit;

         end;
         //showmessage('after newtab');
         frm :=  Tfrm.Create(nil);
         //showmessage('after frm create');
         frm.Name:=arr_menu[i].form_name;
         frm.Align:=alClient;
         frm.setCrud('');
         frm.Parent:=PageControl1.ActivePage;
         frm.BorderStyle:=bsNone;
         frm.schemaName:=arr_menu[i].schema_name;;
         frm.load_components(arr_menu[i].form_name,'');
         //showmessage('before show');
         frm.Visible:=true;
         //showmessage('after show');
         exit;
       end; //IF
  end; //for
end;

function TfrmMain.newTab(p_form: Rform):string;
  var
   jData : TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i:integer;
   Tab:TTabSheet;
   v_res:string;
begin
  IF assigned(PageControl1.FindComponent('tab_'+p_form.form_name) as TTabSheet) then BEGIN
      PageControl1.ActivePage := self.PageControl1.FindComponent('tab_'+p_form.form_name) as TTabSheet;//copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name))) as TTabSheet;
      Panel2.Visible:=utools.stringToBoolean(getRmenuByActiveTab.crud);
      tabexists:=true;
      exit;
   END;

   form := p_form;
   tab := TTabSheet.Create(PageControl1);
   //Tab := PageControl1.AddTabSheet;// TTabSheet.Create(PageControl1);
   //tab.PageControl := PageControl1;
   tab.Parent := PageControl1;
   Tab.Name:='tab_'+p_form.form_name;
   Tab.Caption:=p_form.form_caption;
   tab.Font.Size:=13;
   tab.Font.Name:='Verdana Light';
   tab.BorderWidth:=0;
   PageControl1.ActivePage:=tab;
   Cursor:=crSQLWait;
   if utools.stringToBoolean(getRmenuByActiveTab.external_form)=false then begin
      //showmessage('external_form is false');
      v_res:=viewgrid(p_form,tab);
      if v_res<>'' then begin
         tab.Free;
         result := v_res;
         exit;
      end;
   end;
   Cursor:=crDefault;
   Panel2.Visible:=utools.stringToBoolean(getRmenuByActiveTab.crud);
end;

procedure TfrmMain.TreeView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_F5 then begin
    loadMenu;
 end;
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

function TfrmMain.getRmenuByActiveTab: Rmenu;
var
  i:integer;
  xRmenu:Rmenu;
begin
 // showmessage(copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name))+'test');
  FOR i := 0 TO length(arr_menu) - 1 DO BEGIN

     IF LowerCase(arr_menu[i].form_name) = LowerCase((copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name)))) THEN BEGIN
         //showmessage(arr_menu[i].form_name+' '+copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name)));
         xRmenu.form_caption := arr_menu[i].form_caption;
         xRmenu.form_name:= arr_menu[i].form_name;
         xRmenu.schema_name:=arr_menu[i].schema_name;
         xRmenu.crud:=arr_menu[i].crud;
         xRmenu.external_form:=arr_menu[i].external_form;
         result := xRmenu;
     END;
  END;
  //showmessage(xrmenu.form_name);

end;

function TfrmMain.addcomma(p_val: integer): string;
begin
  if p_val>0 then result := ',' else result := '';
end;

procedure TfrmMain.setLoginName(p_loginname: string);
begin
   v_login_name:=p_loginname;
end;

procedure TfrmMain.loadMenu;
  var
     jData : TJSONData;
     jObject: TJSONObject;
     jArray : TJSONArray;
     i,j,v_root_id:integer;
     ujs_:ujs;
     node:TTreeNode;
   function getMainRootId(p_rootId:integer):integer;
    var
       i:integer;
    begin
      for i:=0 to length(arr_menu)-1 do begin
         if strtoint(arr_menu[i].id)=p_rootid then begin
           result := i;
         end;
       end;
   end;
   function RootIdExists(p_id:integer) :boolean;
     var
        i:integer;
        v_id:string;
    begin
        if p_id =0 then begin
           v_id := '';
        end else begin
           v_id := inttostr(p_id);
        end;

        for i:= 0 to length(arr_menu)-1 do begin
           if arr_menu[i].root_id=v_id then
              result := true;
        end;
        result := false;
    end;

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
       arr_menu[i].crud            :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[6]').AsString;
       arr_menu[i].external_form   :=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'[7]').AsString;
     end;//for i

     for i:= 0 to length(arr_menu)-1 do begin
       if i=0 then begin
       TreeView1.Items.Add(nil,arr_menu[i].caption);
      // v_root_id := strtoint(arr_menu[i].id);
       continue;
       end;
     //  showmessage(inttostr(getMainRootId(strtoint(arr_menu[i].root_id))));
     if rootIdExists(strtoint(arr_menu[i].root_id)-1)=false then begin
        TreeView1.Items.AddChild(treeview1.items[getMainRootId(strtoint(arr_menu[i].root_id))],arr_menu[i].caption);
        continue;
     end;
     try
       TreeView1.Items.AddChild(treeview1.items[strtoint(arr_menu[i].root_id)-1],arr_menu[i].caption);
      except
        showmessage(arr_menu[i].id+' '+inttostr(getMainRootId(strtoint(arr_menu[i].root_id))));
        TreeView1.Items.AddChild(treeview1.items[getMainRootId(strtoint(arr_menu[i].root_id))],arr_menu[i].caption);
      end;
      end;//for i
     //TreeView1.Font.Color:=clWindowText;
     jData.Free;

end;

procedure TfrmMain.onGridClick(Sender:Tobject);
 var
   i:integer;
   f:boolean;
begin
  f:=false;
  for i:=0 to (sender as TStringGrid).ColCount do begin
     if (lowercase((sender as TStringGrid).Columns[i].Title.Caption)='id') or (lowercase((sender as TStringGrid).Columns[i].Title.Caption)='sıra nömrəsi') then begin
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
 (*
  if not (gdfixed in aState) then
    if aRow mod 2 = 0 then begin
      (sender as TStringGrid).Canvas.Brush.Color := clWhite;
    end else begin
      (sender as TStringGrid).Canvas.Brush.Color := $00F8F8F8;
    end;
  *)
end;

procedure TfrmMain.onCompareCells(Sender: Tobject; ACol, ARow, BCol,
  BRow: Integer; var Result: integer);
begin
    v_grid_sort := 1;
    //showmessage(inttostr(v_grid_sort));
    Result := StrToIntDef((Sender as TStringGrid).Cells[ACol,Arow],0)-StrToIntDef((Sender as TStringGrid).Cells[BCol,BRow],0);

    if (Sender as TStringGrid).SortOrder=soDescending then
      result := -result;
end;

procedure TfrmMain.headerClick(Sender: TObject; IsColumn: boolean;index: integer);
 var
   jData :  TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i,j:integer;
   ujs_:ujs;
   s:widestring;
   stringGrid:TStringGrid;
   so:string;
begin
  v_grid_sort := 2;
  //showmessage(getRMenuByActiveTab.schema_name);
 // if isColumn then
   //  (Sender as TStringGrid).SortColRow(true,index);
 if not IsColumn=true then begin
   exit;
   //showmessage((Sender as TStringGrid).Columns[index].Title.Caption);
 end;
 if (Sender as TStringGrid).SortOrder=soDescending then begin
    so := 'asc';
  end;
 if (Sender as TStringGrid).SortOrder=soAscending then begin
    so := 'desc';
  end;
   ujs_ :=  ujs.Create;
   s := ujs_.runHub(getRMenuByActiveTab.schema_name+'.'+getRMenuByActiveTab.form_name+'_pkg.grid_data','"TFORM":"","index":["'+inttostr(index)+'"],"sort_order":["'+so+'"]');
   if ujs_.jsonError<>'' then begin
      Showmessage(ujs_.jsonError);
      exit;
   end;
   jData := GetJSON(s);
   ujs_.Free;
   //(Sender as TStringGrid).FixedCols:=0;
   (Sender as TStringGrid).RowCount:=1;
   for i:=0 to  jdata.FindPath('Response.Components[0].columns').Count-1  do   begin
          //(Sender as TStringGrid).Columns.Add;
          //(Sender as TStringGrid).Columns[i].Title.Alignment:=taCenter;
          //(Sender as TStringGrid).Columns[i].Title.Font.Style:=[fsBold];
          //(Sender as TStringGrid).Columns[i].Title.Caption := jdata.FindPath('Response.Components[0].columns['+inttostr(i)+']').AsString;
          //(Sender as TStringGrid).Columns[i].Width:=round(Screen.Width/jdata.FindPath('Response.Components[0].columns').Count);
          //(Sender as TStringGrid).Columns[i].Title.Font.Color:=clwhite;
          //(Sender as TStringGrid).Columns[i].Title.Color:=$00621E0B;
          //stringGrid.Columns[i].Color:=$00FFD3CA;
    end;

   for i:=0 to  jdata.FindPath('Response.Components[0].rows').Count-1  do begin
        (Sender as TStringGrid).RowCount:=stringGrid.RowCount+1;
        for j:=0 to jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)).Count-1 do begin
           (Sender as TStringGrid).Cells[j,i+1]:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
        end;//for j
    end;//for i

    jData.Free;
end;



function TfrmMain.viewgrid(form: rform; tab: ttabsheet):string;
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
   s := ujs_.runHub(schema_name+'.'+form.form_name+'_pkg.grid_data','"TFORM":"","index":[],"sort_order":[]');
   if ujs_.jsonError<>'' then begin
      //Showmessage(ujs_.jsonError);
      result := ujs_.jsonError;
      ujs_.Free;
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
   //stringGrid.OnCompareCells:=@onCompareCells;
   stringGrid.OnHeaderClick:=@HeaderClick;
   stringGrid.Options:=[goColSizing,goColMoving,goVertLine,goSmoothScroll,goHorzLine,goFixedVertLine,goFixedHorzLine,goHeaderPushedLook,goRowHighlight];
   stringGrid.DoubleBuffered:=true;
   stringGrid.SelectedColor:=$00F0FCED;//clGray;//$00CA8D51;
   stringGrid.Font.Name:='Calibri Light';
   stringGrid.Font.Size:=13;
   stringGrid.BorderStyle:=bsNone;
   for i:=0 to  jdata.FindPath('Response.Components[0].columns').Count-1  do   begin
          stringGrid.Columns.Add;
          stringGrid.Columns[i].Title.Alignment:=taCenter;
          //stringGrid.Columns[i].Title.Font.Style:=[fsBold];
          stringGrid.Columns[i].Title.Caption := jdata.FindPath('Response.Components[0].columns['+inttostr(i)+']').AsString;
          if i=0 then begin
             stringGrid.Columns[i].Width:=130;
            // stringGrid.Columns[i].Width:=round((tab.Width/jdata.FindPath('Response.Components[0].columns').Count)); //130;//
          end else begin
             stringGrid.Columns[i].Width:=250;
          end;
          stringGrid.Columns[i].Title.Font.Color:=$003C3C3C;
          stringGrid.Columns[i].Title.Font.Style:=[fsBold];
          stringGrid.Columns[i].Title.Font.Name:='Calibri Light';
          stringGrid.Columns[i].Title.Font.Size:=13;
          stringGrid.Columns[i].Title.Color:=$00F4F4F4;//$009B652F;
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

function TfrmMain.showform(p_schema_name:String;p_form_name:String;p_crud: string;p_id:string;p_width,p_height:integer):string;
var
    frm:Tfrm;
    v_width,v_height:integer;
    v_res:string;
begin

  //showmessage(p_form_name);
  // IF (assigned(application.FindComponent(p_form_name) as Tfrm )) then begin///  and ((application.findcomponent(p_form_name) as Tfrm).getClosedParam=false) THEN   begin
  //    exit;
  // end;
  // IF (assigned(application.FindComponent(p_form_name) as Tform)) then begin
  //     showmessage('ok1');
  // end;
 //  IF (assigned(application.FindComponent(p_form_name) as Tfrm)) then begin
 //      showmessage('ok2');
 //  end;
   v_width := p_width;
   v_height:=p_height;
   if v_width=0 then begin
      v_width:=700;
    end;
   if v_height=0 then begin
      v_height:=500;
    end;
   IF (assigned(application.FindComponent(p_form_name) as Tfrm)) then begin  //and ((application.findcomponent(p_form_name) as Tfrm).getClosedParam=true)) THEN   begin
      (application.findcomponent(p_form_name) as Tfrm).Destroy;
      (application.findcomponent(p_form_name) as Tfrm).Free;
   end;

   frm :=  Tfrm.Create(nil);
   frm.Name:=p_form_name;
   frm.Width:=v_width;
   frm.Height:=v_height;
   frm.schemaName:=p_schema_name;
   frm.setCrud(p_crud);
   case p_crud  of
         'add'   : frm.setCaption(getFormCaptionByActiveTab+'  -Yeni məlumat');
         'upd'   : frm.setCaption(getFormCaptionByActiveTab+'  -Cari məlumatın dəyişdirilməsi');
         'view_' : frm.setCaption(getFormCaptionByActiveTab+'  -Cari məlumata baxış');
         'del'   : frm.setCaption(getFormCaptionByActiveTab+'  -Cari məlumatın silinməsi');
   end;
   v_res := frm.load_components(p_form_name,p_id);
   if v_res='' then
    begin

        frm.ShowModal;
        result :='';
    end  else begin
        frm.FreeOnRelease;
        result := v_res;
    end;
end;

procedure TfrmMain.btnUpdClick(Sender: TObject);
 var
   v_res:string;
begin
  if v_grid_id=0 then begin
      showmessage('Dəyişiklik ediləcək sətri seçiniz');
  end
  else begin
      v_res := showform(getRmenuByActiveTab.schema_name,copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name)),'upd',inttostr(v_grid_id),0,0);
      if v_res<>'' then begin
        showmessage(v_res);
        exit;
     end;
      v_grid_id := 0;
      while refresh_click=0 do begin
        application.ProcessMessages;
      end;
      if refresh_click=1 then begin
         Button1.Click;
      end;
      refresh_click:=0;
  end;
end;

procedure TfrmMain.btnDelClick(Sender: TObject);
 var
   v_res:string;
begin
  if v_grid_id=0 then begin
      showmessage('Silinəcək sətri seçiniz');
  end
   else begin
        v_res := showform(getRmenuByActiveTab.schema_name,copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name)),'del',inttostr(v_grid_id),0,0);
        if v_res<>'' then begin
         showmessage(v_res);
         exit;
        end;
        v_grid_id := 0;
        while refresh_click=0 do begin
          application.ProcessMessages;
        end;
        Button1.Click;
        refresh_click:=0;
   end;
end;

procedure TfrmMain.btnnew_clickExecute(Sender: TObject);
begin
   btnNewClick(Sender);
end;

procedure TfrmMain.btnCustomerSearchClick(Sender: TObject);
 var
 frmcls:Tfrmclientsearch;
begin
  frmcls := Tfrmclientsearch.Create(nil);
  frmcls.ShowModal;
  while frmcls.v_form_active=0 do begin
      Application.ProcessMessages;
  end;
  if frmcls.v_form_active=2 then begin
    edcustomer_code.Text:=frmcls.cs_data.customer_code;
    edcustomer_name.Text:=frmcls.cs_data.customer_name;
    if edcustomer_code.Text<>'' then begin
       edcustomer_code.Visible:=true;
       edcustomer_name.Visible:=true;
       btnCustomeDetails.Visible:=true;
    end else begin
       edcustomer_code.Visible:=false;
       edcustomer_name.Visible:=false;
       btnCustomeDetails.Visible:=false;
    end;
  end;

end;

procedure TfrmMain.btnexitClick(Sender: TObject);
begin

end;

procedure TfrmMain.btnCustomeDetailsClick(Sender: TObject);
 var
   frm : Tfrmcustomerdetails;
begin
  frm := Tfrmcustomerdetails.Create(nil);
  frm.ShowModal;
end;

procedure TfrmMain.btnExcelClick(Sender: TObject);
 var
    active_pagename : string;
    tab : TTabSheet;
    i,j:integer;
    memo:TMemo;
    s:widestring;
   // str:TString;
    //str:TStringList;
    savedialog:TSaveDialog;
    XLApp: OLEVariant;
    fm :TTextFileManager;
begin
  savedialog := TSaveDialog.Create(nil);
  savedialog.Filter:='*.csv|*.csv';
  if savedialog.Execute then begin
  active_pagename :=  copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name));
  tab := self.PageControl1.FindComponent('tab_'+active_pagename) as TTabSheet;
  //memo :=  tmemo.Create(self);
  //str := TStringListUTF8.create;
  //str.Delimiter:=',';
  //str.StrictDelimiter:=true;


  fm := TTextFileManager.Create(self);
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

   (*
   try
   XLApp := CreateOleObject('Excel.Application'); // requires comobj in uses
   XLApp.Visible := False;         // Hide Excel
   XLApp.DisplayAlerts := False;
   XLApp.Workbooks.Open(savedialog.FileName);
     for i := 0 to colcount-1 do begin
         for j := 0 to rowcount-1 do begin
             Cells[i,j] := XLApp.Cells[i,j].Value
         end;
     end;

    finally
   XLApp.Quit;
   XLAPP := Unassigned;
   end;
   XLApp.ActiveWorkBook.Save;
   *)
  //SaveToCSVFile(savedialog.FileName,',');
  //str.Add(s);
  //str.text := AnsiToUtf8(str.text);
  //str.save
 // str.SaveToFile(savedialog.FileName);
 // str.Free;

 fm.Save(savedialog.FileName,s,ffUTF8);
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
   s := ujs_.runHub(getRmenuByActiveTab.schema_name+'.'+active_pagename+'_pkg.grid_data','');
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
          //Columns[i].Title.Alignment:=taCenter;
         // Columns[i].Title.Font.Style:=[fsBold];
         // Columns[i].Title.Caption := jdata.FindPath('Response.Components[0].columns['+inttostr(i)+']').AsString;
         // Columns[i].Width:=round(tab.Width/jdata.FindPath('Response.Components[0].columns').Count);
         // Columns[i].Title.Font.Color:=clwhite;
         // Columns[i].Title.Color:=$00621E0B;
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
 var
  v_res:string;
begin
  if v_grid_id=0 then begin
      showmessage('Baxmaq istədiyiniz sətri seçiniz');
  end
  else begin
     v_res:=showform(getRmenuByActiveTab.schema_name,copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name)),'view_',inttostr(v_grid_id),0,0);
     if v_res<>'' then begin
        showmessage(v_res);
        exit;
     end;
     v_grid_id := 0;
  end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);
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
    s := ujs_.runHub(getRmenuByActiveTab.schema_name+'.'+active_pagename+'_pkg.grid_data','');
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
           //Columns[i].Title.Alignment:=taCenter;
          // Columns[i].Title.Font.Style:=[fsBold];
          // Columns[i].Title.Caption := jdata.FindPath('Response.Components[0].columns['+inttostr(i)+']').AsString;
          // Columns[i].Width:=round(tab.Width/jdata.FindPath('Response.Components[0].columns').Count);
          // Columns[i].Title.Font.Color:=clwhite;
          // Columns[i].Title.Color:=$00621E0B;
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

procedure TfrmMain.edcustomer_codeKeyPress(Sender: TObject; var Key: char);
begin
end;

procedure TfrmMain.FormActivate(Sender: TObject);
 var
   i:integer;
begin
    Label1.Caption:=uppercase(v_login_name)+#13+'Xoş gəlmişsiniz';
    TreeView1.Font.Color:=$00FAF9F7;
    Label1.Font.Color:=$00ECDFD1;
    Splitter1.Color:=$006A3B03;
    for i:=0 to Self.ComponentCount-1 do begin
      if self.Components[i] is TPanel  then begin
        with (self.Components[i] as TPanel) do begin
          case name of
                'Panel3',
                'Panel4',
                'Panel5': begin
                           BevelColor:=$00CE7205   ;
                           Color:=$00CE7205   ;//$00DEC4B0;
                          end;
                 'Panel7': begin
                            BevelColor:=$00925104;
                            Color:=$00925104;
                           end;
                 'Panel2': begin
                            BevelColor:=clWhite;
                            Color:=clWhite;
                           end
                 else begin

                        BevelColor:=$006A3B03;
                        Color:=$006A3B03;//$00DEC4B0;
                      end;
         end;
       end;
    end;
end;
end;
procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift=[ssCtrl])  then begin
     case key of
           ord('n'),
           ord('N'): btnNewClick(sender);
     end;
  end;
end;

procedure TfrmMain.MenuItem1Click(Sender: TObject);
begin
  PageControl1.ActivePage.Free;
  if PageControl1.PageCount=0 then
     Panel2.Visible:=false;
end;

procedure TfrmMain.PageControl1Change(Sender: TObject);
begin
  Panel2.Visible:=utools.stringToBoolean(getRmenuByActiveTab.crud);
end;

procedure TfrmMain.Panel5Click(Sender: TObject);
begin

end;

procedure TfrmMain.btnNewClick(Sender: TObject);
 var
   v_res:string;
begin
  v_res := showform(getRmenuByActiveTab.schema_name,copy(PageControl1.ActivePage.Name,5,length(PageControl1.ActivePage.Name)),'add','',0,0);
  if v_res<>'' then begin
        showmessage(v_res);
        exit;
     end;
  while refresh_click=0 do begin
      application.ProcessMessages;
  end;
  Button1.Click;
  refresh_click:=0;

end;

end.

