unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, ZConnection, ZDataset, ZStoredProcedure,fpjson,jsonparser, Ora;

type
  Tvalue =record
    index         : string;
    value_id      : string;
    value         : string;
  end;

type
  TResponse=record
    type_         : string;
    name_         : string;
    caption       : string;
    hint          : string;
    enable        : string;
    values        : array of Tvalue;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ComboBox1: TComboBox;
    cmbLogin: TComboBox;
    ListBox1: TListBox;
    ListView1: TListView;
    Memo1: TMemo;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    ZStoredProc1: TZStoredProc;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure runHub(method_name:string);
  end;

var
  Form1: TForm1;
  Response_array : array of TResponse;
  Value_array : array of Tvalue;



implementation
 uses
    uLogin;
{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
 var
    jData : TJSONData;
    jObject: TJSONObject;
    jArray : TJSONArray;

    i, j : integer;
begin
    SetLength(Response_array,0);
    SetLength(Value_array,0);
    jData := GetJSON('{"Response":{"Components":[{"type":"ComboBox","name":"cmbLogin","caption":"","hint":"Login users","enable":"Y","values":[{"index":"0","value_id":"1","value":"zamir"}]},{"type":"ComboBox","name":"cmbLogin1","caption":"","hint":"Login users1","enable":"Y","values":[{"index":"1","value_id":"1","value":"zamir1"}]}]}}');
    jObject := TJsonObject(jData);

    for i:=0 to  jdata.FindPath('Response.Components').Count - 1 do
       begin
         SetLength(Response_array,i+1);
         Response_array[i].type_     :=  jdata.FindPath('Response.Components['+inttostr(i)+'].type').AsString;
         Response_array[i].name_     :=  jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString;
         Response_array[i].caption   :=  jdata.FindPath('Response.Components['+inttostr(i)+'].caption').AsString;
         Response_array[i].hint      :=  jdata.FindPath('Response.Components['+inttostr(i)+'].hint').AsString;
         Response_array[i].enable    :=  jdata.FindPath('Response.Components['+inttostr(i)+'].enable').AsString;
         SetLength(Value_array,0);
         for j := 0 to  jData.FindPath('Response.Components['+inttostr(i)+'].values').Count - 1 do
           begin

             SetLength(Value_array,j+1);

              Value_array[j].index     :=  jData.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].index').AsString;

              Value_array[j].value     :=  jData.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].value').AsString;

              Value_array[j].value_id  :=  jData.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].value_id').AsString;

              Response_array[i].values := Value_array;
            //  memo1.lines.add(jData.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].index').AsString);
            //  memo1.lines.add(jData.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].value').AsString);
            //  memo1.lines.add(jData.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].value_id').AsString);

           end;
       end;
    for i := 0 to length(Response_array)-1 do
      begin
        if (FindComponent(response_array[i].name_) = nil) then
          begin
            Memo1.lines.Add(response_array[i].name_+' tapilmadi');
            Continue;
          end;

        if (Response_array[i].type_='ComboBox') then
          begin
            with (FindComponent(response_array[i].name_) as TComboBox) do
             begin

               Style := csDropDownList;
               Hint := response_array[i].hint;
               if Hint <>'' then
                 begin
                   ShowHint:= true;
                 end;
               Caption := response_array[i].caption;
               if response_array[i].enable='Y' then
                 begin
                  Enabled := true;
                 end;
               if response_array[i].enable='N' then
                 begin
                  Enabled := false;
                 end;
             end;

            for j := 0 to length(Response_array[i].values)-1 do
              begin
                (FindComponent(response_array[i].name_) as TComboBox).Items.Add(response_array[i].values[j].value);
              end;
              (FindComponent(response_array[i].name_) as TComboBox).ItemIndex := 0;
          end;
      end;

//    showmessage(inttostr(jdata.FindPath('Response.Components').Count));
end;

procedure TForm1.Button2Click(Sender: TObject);
 var
 v_json : widestring;
begin
  v_json:='{"method_name":"test1"}';
  ZConnection1.Connect;
  ZQuery1.SQL.Text:= ' select hub.run(:json) as res from dual';
  ZQuery1.ParamByName('json').AsWideString:=v_json;
  ZQuery1.open;
  Memo1.Lines.Add(ZQuery1.FieldByName('res').AsWideString);
  ZConnection1.Disconnect;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  frmLogin.Visible := true;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

end;

procedure TForm1.runHub(method_name: string);
 var
  v_json : widestring;
 begin
   v_json:='{"method_name":"'+method_name+'"}';
   ZConnection1.Connect;
   ZQuery1.SQL.Text:= ' select hub.run(:json) as res from dual';
   ZQuery1.ParamByName('json').AsWideString:=v_json;
   ZQuery1.open;
   Memo1.Lines.Add(ZQuery1.FieldByName('res').AsWideString);
   ZConnection1.Disconnect;
end;

end.

