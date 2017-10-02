unit ucomponents;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ExtCtrls, grids, Buttons, Menus, fpjson, jsonparser, MTProcs,
  LazUTF8Classes, RTTICtrls, comobj, LCLType, ActnList, usession,ujson,filemanager;

type

  { Tcomponents }

  Tcomponents=class(TObject)
     private
         v_row :integer;
         v_packageName:string;
         function  addcomma(p_val: integer): string;
         procedure onGridClick(Sender:Tobject);
         procedure onSelectCell(sender:tobject;acol,arow:integer;var CanSelect :boolean);
         procedure headerClick(Sender :TObject;IsColumn:boolean;index:integer);


      public

         function gridLoad(width:integer;PackageName:String;JsonChunk:String):TStringGrid;
         procedure excelExport(StringGrid:TStringGrid);
  end;

implementation

{ Tcomponents }

procedure Tcomponents.onGridClick(Sender: Tobject);
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
  if not f then begin
     showmessage('There not found column with name id.This is critical');
  end;

end;

procedure Tcomponents.onSelectCell(sender: tobject; acol, arow: integer;
  var CanSelect: boolean);
begin
   v_row := arow;
end;

procedure Tcomponents.headerClick(Sender: TObject; IsColumn: boolean;
  index: integer);
var
   jData :  TJSONData;
   i,j:integer;
   ujs_:ujs;
   s:widestring;
   so:string;
begin
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
   s := ujs_.runHub(v_packageName+'.grid_data','"TFORM":"","index":["'+inttostr(index)+'"],"sort_order":["'+so+'"]');
   if ujs_.jsonError<>'' then begin
      Showmessage(ujs_.jsonError);
      exit;
   end;
   jData := GetJSON(s);
   ujs_.Free;

   (Sender as TStringGrid).RowCount:=1;
   for i:=0 to  jdata.FindPath('Response.Components[0].rows').Count-1  do begin
    (Sender as TStringGrid).RowCount:=(Sender as TStringGrid).RowCount+1;
     for j:=0 to jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)).Count-1 do begin
         (Sender as TStringGrid).Cells[j,i+1]:=jdata.FindPath('Response.Components[0].rows['+inttostr(i)+'].row'+inttostr(i+1)+'['+inttostr(j)+']').AsString;
     end;//for j
   end;//for i
  jData.Free;
end;

function TComponents.addcomma(p_val: integer): string;
begin
  if p_val>0 then result := ',' else result := '';
end;

procedure Tcomponents.excelExport(StringGrid:TStringGrid);
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
    frm:TForm;
begin
  frm := TForm.Create(nil);
  savedialog := TSaveDialog.Create(nil);
  savedialog.Filter:='*.csv|*.csv';
  if savedialog.Execute then begin

  fm := TTextFileManager.Create(frm);
  with StringGrid do begin
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


 fm.Save(savedialog.FileName,s,ffUTF8);
 end;
  end;

end;

function Tcomponents.gridLoad(width:integer;PackageName: String; JsonChunk: String):tstringgrid;
 var
   jData :  TJSONData;
   jObject: TJSONObject;
   jArray : TJSONArray;
   i,j:integer;
   ujs_:ujs;
   s:widestring;
   so:string;
   StringGrid:TStringGrid;
begin
  v_packageName:= PackageName;
  ujs_ :=  ujs.Create;
  s := ujs_.runHub(PackageName+'.grid_data','"TFORM":"","index":[],"sort_order":[]'+JsonChunk);
  if ujs_.jsonError<>'' then begin
     Showmessage(ujs_.jsonError);
     ujs_.Free;
     exit;
  end;
  jData := GetJSON(s);
  ujs_.Free;
  StringGrid :=TStringGrid.Create(nil);
  StringGrid.Align:=alClient;
  stringGrid.Anchors:=[akLeft,akTop,akBottom,akRight];
  stringGrid.FixedCols:=0;
  stringGrid.RowCount:=1;
  stringGrid.ColumnClickSorts:=true;
  stringGrid.OnSelectCell:=@onSelectCell;
  stringGrid.OnClick:=@onGridClick;
  //stringGrid.OnPrepareCanvas:=@OnPrepareCanvas;
  //stringGrid.OnCompareCells:=@onCompareCells;
  stringGrid.OnHeaderClick:=@HeaderClick;
  stringGrid.Options:=[goColSizing,goColMoving,goVertLine,goSmoothScroll,goHorzLine,goFixedVertLine,goFixedHorzLine,goHeaderPushedLook,goRowHighlight];
  stringGrid.DoubleBuffered:=true;
  stringGrid.SelectedColor:=$00F0FCED;//clGray;//$00CA8D51;
  stringGrid.Font.Name:='Calibri Light';
  stringGrid.Font.Size:=12;
  stringGrid.BorderStyle:=bsNone;
  for i:=0 to  jdata.FindPath('Response.Components[0].columns').Count-1  do   begin
         stringGrid.Columns.Add;
         stringGrid.Columns[i].Title.Alignment:=taCenter;
         //stringGrid.Columns[i].Title.Font.Style:=[fsBold];
         stringGrid.Columns[i].Title.Caption := jdata.FindPath('Response.Components[0].columns['+inttostr(i)+']').AsString;
         stringGrid.Columns[i].Width:=width;
           // stringGrid.Columns[i].Width:=round((tab.Width/jdata.FindPath('Response.Components[0].columns').Count)); //130;//
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
   jData.Free;
   StringGrid.Visible:=true;
   Result := StringGrid;
end;

end.

