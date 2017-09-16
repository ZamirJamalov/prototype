unit UJson;

{$mode objfpc}{$H+}
//{$mode Delphi}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, CheckLst, fpjson, jsonparser, fphttpclient, Grids, ExtCtrls;

type

  { ujs }

  ujs = class
  private
     procedure click(sender:tobject);
    type
    Tvalue = record
      index: string;
      id: string;
      name: string;
      checked:string;
    end;

    type
    TResponse = record
      type_: string;
      name_: string;
      value:string;
      label_caption: string;
      width: string;
      top: string;
      font_size:string;
      font_color:string;
      background_color:string;
      enabled:string;
      visible:string;
      hint: string;
      onclick:string;
      onkeypress:string;
      onchange:string;
      required:string;
      changed:integer;
      values: array of Tvalue;
    end;
  type TResponse_array= array of ujs.TResponse;



  private
    response_array :TResponse_array;
    Value_array: array of ujs.Tvalue;
    comps_value_array: array of string;
    function stringToBoolean(p_string :string) : boolean;
    function getJsonError: string;
    procedure appendjson(p_response_array:TResponse_array);

  public
    property  AppendResponseJsonToExistsJson: TResponse_array  write appendjson;
    property  jsonError: string read getJsonError;
    function errorexists:boolean;
    function runHub(p_method_name: WideString; p_request_json: WideString): WideString;
    function prepareRequest(p_form: TForm): WideString;
    procedure prepareRequest_(p_component:TComponent);
    procedure parseResponse(p_json: WideString);
    function retParseResponse: TResponse_array;
    procedure clear;
    procedure existsform(p_form:tform;p_json:widestring;p_component:TWinControl);
    procedure newform(p_form:tform;p_json:widestring;p_component:Twincontrol);
    function getIdByIndex(p_component_name:String;p_index:integer):string;
  end;


 var



  v_json: WideString;
  comma_:integer;
  error_exists :boolean;
  click_form:tform;
  click_wincontrol:TWinControl;
  click_button_name:string;
  v_jsonError:string;
implementation

uses usession,umain,unit1;

function addComma(p_val: integer; p_point: integer): string;
begin
  if p_val > p_point then
    Result := ','
  else
    Result := '';
end;

function ujs.prepareRequest(p_form: TForm): WideString;
var
  i, i1, j, j1: integer;
  s: WideString;
  cmp:TComponent;
begin
  v_json := '';
  comma_ := 0;
  for i := 1 to p_form.componentCount -1 do
  begin

    cmp := p_form.Components[i];
    if cmp is TPanel then
    begin
      for i1 := 1 to (cmp as Tpanel).ComponentCount -1 do
      begin
        prepareRequest_((cmp as Tpanel).Components[i1]);
      end;
    end
    else
     prepareRequest_(cmp);
  end;

  Result := v_json;

end;

procedure ujs.prepareRequest_(p_component: TComponent);
 var
   j,j1:integer;
   f:boolean;
   s:widestring;
   a:string;
begin

   CASE UPPERCASE(p_component.ClassName)  OF
       'TEDIT':  BEGIN
                    comma_ := comma_ + 1;
                    v_json := v_json + addcomma(comma_, 1) + '"' + (p_component AS TEDIT).Name + '":["' +(p_component AS TEDIT).Text + '"]';
                  END; //TEDIT
     'TCHECKBOX':  BEGIN
                    comma_ := comma_ + 1;
                    if (p_component AS TCHECKBOX).Checked then a := 'Y' ELSE BEGIN a := 'N'; END;
                    v_json := v_json + addComma(comma_, 1)+ '"' + (p_component AS TCHECKBOX).Name + '":["' + a + '"]';
                  END;//TCHECBOX
     'TCOMBOBOX': BEGIN
                    comma_ := comma_ + 1;
                    FOR j := 0 to LENGTH(Response_array) - 1 DO BEGIN
                       IF (p_component AS TCOMBOBOX).Name = Response_array[j].name_ THEN BEGIN
                          v_json := v_json + addComma(comma_, 1) + '"' + (p_component AS TCOMBOBOX).Name + '":["' + Response_array[j].values[(p_component AS TCOMBOBOX).ItemIndex].id + '"]';
                       END; //IF
                    END; //FOR
                  END;//TCOMBOBOX
   'TCHECKLISTBOX': BEGIN
                      comma_ := comma_ + 1;
                      FOR j := 0 to LENGTH(Response_array) - 1 DO BEGIN
                         IF (p_component AS TCHECKLISTBOX).Name=Response_array[j].name_ THEN BEGIN
                             v_json := v_json + addComma(comma_, 1) + '"' +(p_component AS TCHECKLISTBOX).Name + '":[';
                             FOR j1 := 0 TO LENGTH(Response_array[j].values) - 1 DO BEGIN
                                 IF (p_component AS TCHECKLISTBOX).Checked[j1]=TRUE THEN BEGIN
                                     s := s + addComma(j1, 0) + '"' + Response_array[j].values[j1].id+'"';
                                 END; //IF
                             END;//FOR
                             v_json := v_json + ']';
                         END;//IF
                      END;//FOR
                     END;//TCHECKLISTBOX
   END; //CASE
 end;
 procedure ujs.parseResponse(p_json: WideString);
var
  jData: TJSONData;
  jObject: TJSONObject;
  jArray: TJSONArray;

  i, j, k, n: integer;
  f : boolean;
begin
  //GetJSON('{"Response":{"Components":[{"type":"ComboBox","name":"cmbLogin","caption":"","hint":"Login users","enable":"Y","values":[{"index":"0","value_id":"1","value":"zamir"}]},{"type":"ComboBox","name":"cmbLogin1","caption":"","hint":"Login users1","enable":"Y","values":[{"index":"1","value_id":"1","value":"zamir1"}]}]}}');
  jData := GetJSON(p_json);

  jObject := TJsonObject(jData);
  if jdata.FindPath('Response.Components').Count = 0 then  begin
    exit;
  end;
  //set session
  f := false;

  for i := 0 to jdata.FindPath('Response.Components').Count - 1 do begin
    k := i;
    if (jdata.FindPath('Response.Components[' + IntToStr(k) + '].type').AsString='TCOMBOBOX') or (jdata.FindPath('Response.Components[' + IntToStr(k) + '].type').AsString='TCHECKLISTBOX') then  begin
      SetLength(Response_array, k + 1);

      Response_array[k].type_ :=jdata.FindPath('Response.Components[' + IntToStr(k) + '].type').AsString;
      Response_array[k].name_ :=jdata.FindPath('Response.Components[' + IntToStr(k) + '].name').AsString;
      Response_array[k].value :=jdata.FindPath('Response.Components[' + IntToStr(k) + '].value').AsString;
      Response_array[k].label_caption :=jdata.FindPath('Response.Components[' + IntToStr(k) + '].label_caption').AsString;
      Response_array[k].width :=jdata.FindPath('Response.Components['+ inttostr(k) + '].width').AsString;
      Response_array[k].top :=jdata.FindPath('Response.Components['+ inttostr(k) + '].top').AsString;
      Response_array[k].font_size :=jdata.FindPath('Response.Components['+ inttostr(k) + '].font_size').AsString;
      Response_array[k].font_color:=jdata.FindPath('Response.Components['+ inttostr(k) + '].font_color').AsString;
      Response_array[k].background_color:=jdata.FindPath('Response.Components['+ inttostr(k) + '].background_color').AsString;
      Response_array[k].enabled:=jdata.FindPath('Response.Components['+ inttostr(k) + '].enabled').AsString;
      Response_array[k].visible:=jdata.FindPath('Response.Components['+ inttostr(k) + '].visible').AsString;
      Response_array[k].hint := jdata.FindPath('Response.Components[' + IntToStr(k) + '].hint').AsString;
      Response_array[k].onclick := jdata.FindPath('Response.Components[' + IntToStr(k) + '].onclick').AsString;
      Response_array[k].onkeypress:=jdata.FindPath('Response.Components['+ inttostr(k) + '].onkeypress').AsString;
      Response_array[k].onchange:=jdata.FindPath('Response.Components['+ inttostr(k) + '].onchange').AsString;
      Response_array[k].required :=jdata.FindPath('Response.Components['+ inttostr(k) + '].required').AsString;



      SetLength(Value_array, jData.FindPath('Response.Components[' + IntToStr(k) + '].values').Count);


      for j := 0 to jData.FindPath('Response.Components[' + IntToStr(k) + '].values').Count - 1 do  begin
          //SetLength(Value_array, j + 1);
          Value_array[j].index :=jData.FindPath('Response.Components[' + IntToStr(k) + '].values['+IntToStr(j) + '].index').AsString;
          Value_array[j].name :=jData.FindPath('Response.Components[' + IntToStr(k) + '].values[' +IntToStr(j) + '].name').AsString;
          Value_array[j].id :=jData.FindPath('Response.Components[' + IntToStr(k) + '].values[' +IntToStr(j) + '].id').AsString;
          value_array[j].checked := jData.FindPath('Response.Components[' + IntToStr(k) + '].values[' +IntToStr(j) + '].checked').AsString;
      end; //for j
          response_array[k].values:=value_array;
    end; //for i

  end;
END;

 function ujs.retParseResponse: TResponse_array;
 begin
    result := response_array;
 end;



procedure ujs.clear;
begin
  comma_:= 0;
end;



procedure ujs.existsform(p_form: tform; p_json: widestring;p_component:TWinControl);
 var
   k,j:integer;

   jData: TJSONData;
   jObject: TJSONObject;
   jArray: TJSONArray;
   v_form,v_name,v_value,v_hint,v_enabled:string;
   v_received_text:widestring;
   checkbox:TCheckBox;
   chbidx:integer;
begin
  jData := GetJson(p_json);

  error_exists :=false;
  if jdata.FindPath('Response.Message.Status').AsString = 'ERROR' then begin
    ShowMessage(jdata.FindPath('Response.Message.Text').AsString);
    error_exists :=true;
    exit;
  end;
 if lowercase(p_form.Name) = lowercase('frmLogin') then begin
    usession.session_var := jdata.FindPath('Response.Message.Text').AsString;
  end;

 for k := 0 to jdata.FindPath('Response.Components').Count-1 do begin
   //showmessage(jdata.FindPath('Response.Components['+inttostr(k)+'].type').AsString);

   if (jdata.FindPath('Response.Components['+inttostr(k)+'].type').AsString='TEDIT') or (jdata.FindPath('Response.Components['+inttostr(k)+'].type').AsString='TCHECKBOX') or (jdata.FindPath('Response.Components['+inttostr(k)+'].type').AsString='TCOMBOBOX') or (jdata.FindPath('Response.Components['+inttostr(k)+'].type').AsString='TMEMO') then begin

     if p_form.FindComponent('lbl_'+jdata.FindPath('Response.Components['+inttostr(k)+'].name').AsString) is TLabel then begin
       WITH (p_component.FindComponent('lbl_'+jdata.FindPath('Response.Components['+inttostr(k)+'].name').AsString) AS TLabel) DO BEGIN
           if jdata.FindPath('Response.Components['+inttostr(k)+'].required').AsString='Y' then begin
              color := clRed;
           end else begin
             color := clWhite;
           end;
       end;
      end;

    end;



   CASE jdata.FindPath('Response.Components['+inttostr(k)+'].type').AsString of
        'TLABEL': BEGIN
                      WITH (p_form.FindComponent(jdata.FindPath('Response.Components['+inttostr(k)+'].name').AsString) AS TLabel) DO BEGIN
                          if jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString<>'' then BEGIN   //''_ chr(1760)
                              caption := jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString;
                           END;
                           hint := jdata.FindPath('Response.Components['+inttostr(k)+'].hint').AsString;
                           showhint := TRUE;
                           enabled := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(k)+'].enabled').AsString);
                           visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].visible').AsString);
                           if jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString='' then begin
                             font.color := clBlack;
                            end
                           else begin
                             font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString);
                           end;
                        END;//WITH
                   END;//TLABEL
        'TEDIT': BEGIN

           WITH (p_form.FindComponent(jdata.FindPath('Response.Components['+inttostr(k)+'].name').AsString) AS TEdit) DO BEGIN
                             if jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString<>'' then BEGIN   //''_ chr(1760)
                              text := jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString;
                           END;

                           hint := jdata.FindPath('Response.Components['+inttostr(k)+'].hint').AsString;
                           showhint := TRUE;
                           enabled := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(k)+'].enabled').AsString);
                           visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].visible').AsString);
                           if jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString='' then begin
                             font.color := clBlack;
                            end
                           else begin
                             font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString);
                           end;
                        END;//WITH
                   END;//TEDIT
        'TMEMO': BEGIN
                       WITH (p_form.FindComponent(jdata.FindPath('Response.Components['+inttostr(k)+'].name').AsString) AS TMEMO) DO BEGIN

                           if jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString<>'' then BEGIN
                              text := jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString;
                           END;

                           hint := jdata.FindPath('Response.Components['+inttostr(k)+'].hint').AsString;
                           enabled := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(k)+'].enabled').AsString);
                           visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].visible').AsString);
                           if jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString='' then begin
                             font.color := clBlack;
                            end
                           else begin
                             font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString);
                           end;
                           if stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].required').AsString)=true then begin
                             color := clRed;
                           end
                           else begin
                             color := clwhite;
                           end;
                        END;//WITH
                   END;//TMEMO
       'TCHECKBOX': BEGIN

          WITH (p_form.findComponent(jdata.FindPath('Response.Components['+inttostr(k)+'].name').AsString)  AS TCHECKBOX) DO BEGIN
                            if jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString<>'' then BEGIN
                               Checked := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(k)+'].value').AsString);
                            END;
                            hint := jdata.FindPath('Response.Components['+inttostr(k)+'].hint').AsString ;
                            enabled := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(k)+'].enabled').AsString);
                            visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].visible').AsString);
                            if jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString='' then begin
                             font.color := clBlack;
                            end
                            else begin
                             font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString);
                            end;
                            if stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].required').AsString)=true then begin
                             color := clRed;
                            end
                            else begin
                             color := clwhite;
                            end;

                        END;//WITH
                    END;//TCHECKBOX
       'TCOMBOBOX': BEGIN
                        WITH (p_form.FindComponent(jdata.FindPath('Response.Components['+inttostr(k)+'].name').AsString ) AS TComboBox) DO BEGIN
                            hint := jdata.FindPath('Response.Components['+inttostr(k)+'].hint').AsString;
                            caption := jdata.FindPath('Response.Components['+inttostr(k)+'].label_caption').AsString ;
                            enabled := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(k)+'].enabled').AsString);
                            visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].visible').AsString);

                            if jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString='' then begin
                             font.color := clBlack;
                            end
                            else begin
                             font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString);
                            end;

                            if stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].required').AsString)=true then begin
                             color := clRed;
                            end
                            else begin
                             color := clwhite;
                            end;

                            if (jdata.FindPath('Response.Components['+inttostr(k)+'].values').count >0) and (jdata.FindPath('Response.Components['+inttostr(k)+'].values[0].index').asString<>'') then begin
                               clear;
                               FOR j := 0 TO jdata.FindPath('Response.Components['+inttostr(k)+'].values').count - 1 DO BEGIN
                                   items.add(jdata.FindPath('Response.Components['+inttostr(k)+'].values['+inttostr(j)+'].name').asString);
                                    //items.Add(p_response_array[k].values[j].name);
                               END;//FOR j
                               itemindex := 0;
                             end;
                        END;//WITH
                     END;//TCOMBOBOX
    'TCHECKLISTBOX': BEGIN


       WITH (p_form.FindComponent(jdata.FindPath('Response.Components['+inttostr(k)+'].name').asstring) AS TCheckListBox) DO BEGIN

                           // hint := jdata.FindPath('Response.Components['+inttostr(k)+'].hint').AsString;
                            hint := jdata.FindPath('Response.Components['+inttostr(k)+'].hint').AsString;
                            enabled := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(k)+'].enabled').AsString);
                            visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].visible').AsString);


                             if jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString='' then begin
                              font.color := clBlack;
                             end
                             else begin
                              font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(k)+'].font_color').AsString);
                             end;
                             if stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].required').AsString)=true then begin
                              color := clRed;
                             end
                             else begin
                             color := clwhite;
                             end;

                             if (jdata.FindPath('Response.Components['+inttostr(k)+'].values').count >0) and (jdata.FindPath('Response.Components['+inttostr(k)+'].values[0].index').asString<>'') then begin

                              clear;
                             chbidx :=0;
                             FOR j := 0 TO jdata.FindPath('Response.Components['+inttostr(k)+'].values').count-1  DO BEGIN
                                if jdata.FindPath('Response.Components['+inttostr(k)+'].values['+inttostr(j)+'].name').asString='' then begin
                                    Continue;
                                end;

                                items.add(jdata.FindPath('Response.Components['+inttostr(k)+'].values['+inttostr(j)+'].name').asString);
                                Checked[chbidx] := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(k)+'].values['+inttostr(j)+'].checked').asString);
                                chbidx := chbidx +1;
                             END; //FOR j
                          end;

                         END;//WITH
                     END;//TCHECKLISTBOX
   END; //case

 end;
end;



procedure ujs.newform(p_form: tform; p_json: widestring;p_component: Twincontrol);
 var
   component:TComponent;
   v_top, i, j, n : integer;

   jData: TJSONData;
   jObject: TJSONObject;
   jArray: TJSONArray;
   cmbItemIndex :integer;
 begin
  v_top := 10;
  jData := GetJSON(p_json);
  jObject := TJsonObject(jData);
  click_form :=p_form;
  click_wincontrol := p_component;

  error_exists := false;
  if jdata.FindPath('Response.Message.Status').AsString = 'ERROR' then begin
     ShowMessage(jdata.FindPath('Response.Message.Text').AsString);
     error_exists := true;
     exit;
  end;

  if jdata.FindPath('Response.Components').Count = 0 then  begin
    exit;
  end;
  //set session
  if lowercase(p_form.Name) = lowercase('frmLogin') then begin
    usession.session_var := jdata.FindPath('Response.Message.Text').AsString;
  end;
  for i:=0 to jdata.FindPath('Response.Components').Count-1 do begin
        // showmessage(jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString);
         //create components labels
         if (jdata.FindPath('Response.Components['+inttostr(i)+'].type').AsString='TEDIT') or (jdata.FindPath('Response.Components['+inttostr(i)+'].type').AsString='TCHECKBOX') or (jdata.FindPath('Response.Components['+inttostr(i)+'].type').AsString='TCOMBOBOX') or (jdata.FindPath('Response.Components['+inttostr(i)+'].type').AsString='TMEMO') then begin
            component := TLabel.Create(p_component);
            with (component as TLabel) do begin
                parent:=p_component;
                Name:='lbl_'+jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString;
                caption := jdata.FindPath('Response.Components['+inttostr(i)+'].label_caption').AsString;
                Font.Size:=15;
                left := 10;
                top := v_top;
                width := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].width').AsString);

                if jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString='' then font.Color:=clblack else font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString);
                if jdata.FindPath('Response.Components['+inttostr(i)+'].background_color').AsString='' then Color:= clWhite else color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].background_color').AsString);
                enabled:=  stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].enabled').AsString);
                visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].visible').AsString);
                if jdata.FindPath('Response.Components['+inttostr(i)+'].required').AsString='Y' then begin
                   color := clRed;
                end else begin
                   color := clForm;
                end;
            end; //with
           end; //if

      case jdata.FindPath('Response.Components['+inttostr(i)+'].type').AsString of
          'TBUTTON':BEGIN
                       component := TButton.Create(p_component);
                       (component as tbutton).OnClick:=@click;
                       WITH (component AS TBUTTON) DO BEGIN
                          Parent := p_component;
                          name := jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString;
                          ShowHint:=true;
                          Hint:=jdata.FindPath('Response.Components['+inttostr(i)+'].hint').AsString;
                          click_button_name :=  name;
                          left := 200;
                          top := v_top;
                          width := strtoint(jdata.FindPath('Response.Components['+inttostr(i)+'].width').AsString);
                          Caption := jdata.FindPath('Response.Components['+inttostr(i)+'].label_caption').AsString;

                          if jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString='' then font.Color:=clblack else font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString);
                          if jdata.FindPath('Response.Components['+inttostr(i)+'].background_color').AsString='' then Color:= clWhite else color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].background_color').AsString);

                          enabled:=  stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].enabled').AsString);
                          visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].visible').AsString);

                       END;
                    END; //TBUTTON


           'TEDIT': begin

                              component := TEdit.Create(p_component);
                              with (component as TEdit) do begin
                                    parent:=p_component;
                                    Name:=jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString;
                                    ShowHint:=true;
                                    Hint:=jdata.FindPath('Response.Components['+inttostr(i)+'].hint').AsString;
                                    Font.Size:=15;
                                    left := 200;
                                    top := v_top;
                                    width := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].width').AsString);
                                    text := jdata.FindPath('Response.Components['+inttostr(i)+'].value').AsString;
                                    if jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString='' then font.Color:=clblack  else font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString);
                                    enabled:=  stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].enabled').AsString);
                                    visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].visible').AsString);
                               end; //with
                           end;   //tedit end

           'TCHECKBOX':    begin

                              component:=TCheckBox.Create(p_component);
                              with (component as TCheckBox) do begin
                                    parent := p_component;
                                    name := jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString;
                                    ShowHint:=true;
                                    Hint:=jdata.FindPath('Response.Components['+inttostr(i)+'].hint').AsString;
                                    checked := stringToBoolean(jdata.FindPath('Response.Components['+inttostr(i)+'].value').AsString);
                                    Caption:=''; //label var ona gore lazim deyil
                                    left := 200;
                                    top := v_top;
                                    width := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].width').AsString);
                                    Alignment:=taLeftJustify;
                                    if jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString='' then font.Color:=clblack else font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString);
                                    enabled:=  stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].enabled').AsString);
                                    visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].visible').AsString);

                               end; //with
                           end;//tcheckbox
           'TCOMBOBOX':    begin
                              component:=TComboBox.Create(p_component);
                              with (component as TComboBox) do begin
                                    parent := p_component;
                                    name := jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString;
                                    ShowHint:=true;
                                    Hint:=jdata.FindPath('Response.Components['+inttostr(i)+'].hint').AsString;
                                    Font.Size:=15;
                                    style := csDropDownList;
                                    Text := '';
                                    left := 200;
                                    top := v_top;
                                    width := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].width').AsString);

                                    if jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString='' then font.Color:=clblack else font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString);
                                    if jdata.FindPath('Response.Components['+inttostr(i)+'].background_color').AsString='' then Color:= clWhite else color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].background_color').AsString);
                                    enabled:=  stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].enabled').AsString);
                                    visible := stringtoboolean(jdata.FindPath('Response.Components['+inttostr(i)+'].visible').AsString);
                                    cmbItemIndex := 0;
                                    FOR j := 0 TO jdata.FindPath('Response.Components['+inttostr(i)+'].values').count - 1 DO BEGIN
                                      items.add(jdata.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].name').asString);
                                       if  jdata.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].checked').asString<>'' then begin
                                        cmbItemIndex:= StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].values['+inttostr(j)+'].checked').asString);
                                       end;

                                    END;//FOR j
                                    itemindex := cmbItemIndex;
                              end; //with
                            end;//TCOMBOBOX
           'TMEMO':         begin
                                component := TMemo.Create(p_component);
                               with (component as TMemo) do begin
                                parent := p_component;
                                name := jdata.FindPath('Response.Components['+inttostr(i)+'].name').AsString;
                                ShowHint:=true;
                                Hint:=jdata.FindPath('Response.Components['+inttostr(i)+'].hint').AsString;
                                Text := jdata.FindPath('Response.Components['+inttostr(i)+'].value').AsString;;
                                left := 200;
                                Height:=200;
                                top := v_top;
                                width := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].width').AsString);
                                if jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString='' then font.Color:=clblack  else font.color := StrToInt(jdata.FindPath('Response.Components['+inttostr(i)+'].font_color').AsString);
                                Visible:= stringtoboolean((jdata.FindPath('Response.Components['+inttostr(i)+'].visible').AsString));
                                Enabled:= stringtoboolean((jdata.FindPath('Response.Components['+inttostr(i)+'].enabled').AsString));
                               end; //with
                            end;//TMEMO
           end;  //case end
           v_top := v_top+50;
       end; //for

end;

function ujs.getIdByIndex(p_component_name: String; p_index: integer): string;
 var
    i,j:integer;
begin
   for i:=0 to length(response_array)-1 do begin
     if response_array[i].name_=p_component_name then begin
        for j:=0 to length(response_array[i].values)-1 do begin
          if response_array[i].values[j].index=inttostr(p_index+1) then begin
              result := response_array[i].values[j].id;
          end;
        end;
     end;
   end;
end;

procedure ujs.click(sender: tobject);
var
   i, j:integer;
   s:widestring;
   v_response_array:TResponse_array;
   jData: TJSONData;
   jObject: TJSONObject;
   timer:TTimer;
   click_wincontrol_tmp : TWinControl;
   click_form_tmp : tform;
begin
  //showmessage(click_form.Name);
  usession.form_closed:=false;
  v_response_array := response_array;
  s := runHub(umain.schema_name+'.'+click_form.name+'_pkg.onclick_'+click_button_name,'"TFORM":"'+click_form.name+'",'+prepareRequest(click_form));
  jData := GetJSON(s);
  if jdata.FindPath('Action.form').AsString='' then begin
     parseResponse(s);

     existsform(click_form,s,click_wincontrol);
  end
  else begin
     click_wincontrol_tmp := click_wincontrol;
     click_form_tmp :=  click_form;
     usession.call_proc_name:=jdata.FindPath('Action.proc_name').AsString;
     frmMain.showform(jdata.FindPath('Action.schema').AsString,jdata.FindPath('Action.form').AsString,'','',strtoint(jdata.FindPath('Action.width').AsString),strtoint(jdata.FindPath('Action.height').AsString));

     while usession.form_closed=false do begin
       Application.ProcessMessages;
     end;
     //form terminated
     if usession.form_closed_by_user=false then begin
         click_form := click_form_tmp;
         click_wincontrol :=click_wincontrol_tmp;
         usession.form_closed_by_user:=false;
         usession.form_closed:=false;
        exit;
     end;
      v_response_array := response_array;
      s := runHub(usession.call_proc_name,'"TFORM":"'+jdata.FindPath('Action.form').AsString+'",'+usession.call_proc_result);
      jData := GetJSON(s);
      parseResponse(s);

      existsform(click_form_tmp,s,click_wincontrol_tmp);
      click_form := click_form_tmp;
      click_wincontrol :=click_wincontrol_tmp;
      usession.call_proc_name:='';
      usession.call_proc_result:='';
      usession.form_closed:=false;
   end;

end;

function ujs.stringToBoolean(p_string: string): boolean;
begin
  IF (p_string='Y') OR (p_string='TRUE') THEN result := TRUE;
  IF (p_string='N') OR (p_string='FALSE') OR (p_string='')  THEN result := FALSE;

end;

function ujs.getJsonError: string;
begin
  result :=  v_jsonError;
end;

procedure ujs.appendjson(p_response_array: TResponse_array);
 var
    i,j:integer;
begin
  for i := 0 to length(response_array) - 1 do begin
     for j := 0 to length(p_response_array) - 1 do begin
        if response_array[i].name_=p_response_array[j].name_ then
           response_array[i].values := p_response_array[j].values;
      end; //for j
  end; //for i
end;



function ujs.errorexists: boolean;
begin
  result := error_exists;
end;

function ujs.runHub(p_method_name: WideString; p_request_json: WideString): WideString;
var
  v_json: WideString;
  S: WideString;
  i:integer;
  jdata:TJSONData;
  frm:TForm1;
begin
  i:=0;
  IF length(p_request_json) > 0 THEN
    v_json := '{"session_key":"' + usession.session_var + '","method_name":"' + p_method_name + '",' + p_request_json + '}'
  ELSE BEGIN
    v_json := '{"session_key":"' + usession.session_var + '","method_name":"' + p_method_name + '"}';
  END; //IF
 // showmessage(v_json);

  v_json:=StringReplace(v_json,'ə','<_301',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'Ə','<_302',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'İ','<_303',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'ş','<_304',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'Ş','<_305',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'ç','<_306',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'Ç','<_307',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'ı','<_308',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'ğ','<_309',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'Ğ','<_310',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'ö','<_311',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'Ö','<_312',[rfReplaceAll]);
  v_json:=StringReplace(v_json,' ','<_313',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'ü','<_314',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'Ü','<_315',[rfReplaceAll]);
  v_json:=StringReplace(v_json,'%','<_316',[rfReplaceAll]);
  //frm := TForm1.Create(nil);
  //frm.setlog(v_json);
  //frm.ShowModal;
  WITH TFPHttpClient.Create(nil) DO
    TRY
      s := Post('http://localhost:8089/WebApplication1/NewServlet?myparam=' + v_json);
      jdata := getjson(s);
      v_jsonError := '';
      if jdata.FindPath('Response.Message.Status').AsString = 'ERROR' then begin
        v_jsonError :=  jdata.FindPath('Response.Message.Text').AsString;
        v_jsonError := StringReplace(v_jsonError,'<_400','"',[rfReplaceAll]);
        v_jsonError := StringReplace(v_jsonError,'<_401',':',[rfReplaceAll]);
     end;
    FINALLY
      Free;
    END;
  (*
  s := StringReplace(s,'<_301','ə',[rfReplaceAll]);
  s := StringReplace(s,'<_302','Ə',[rfReplaceAll]);
  s := StringReplace(s,'<_303','İ',[rfReplaceAll]);
  s := StringReplace(s,'<_304','ş',[rfReplaceAll]);
  s := StringReplace(s,'<_305','Ş',[rfReplaceAll]);
  s := StringReplace(s,'<_306','ç',[rfReplaceAll]);
  s := StringReplace(s,'<_307','Ç',[rfReplaceAll]);
  s := StringReplace(s,'<_308','ı',[rfReplaceAll]);
  s := StringReplace(s,'<_309','ğ',[rfReplaceAll]);
  s := StringReplace(s,'<_310','Ğ',[rfReplaceAll]);
  s := StringReplace(s,'<_311','ö',[rfReplaceAll]);
  s := StringReplace(s,'<_312','Ö',[rfReplaceAll]);
  *)


  Result := s;
END; //runhub

end.
