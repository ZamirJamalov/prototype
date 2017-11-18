create or replace package api_component is

  -- Author  : USERll
  -- Created : 7/3/2017 0:05:40 0:05:40 
  -- Purpose : 







  

PROCEDURE parse_component_params(p_json json); 

FUNCTION component_values_to_json(p_coll tt_component_obj,p_comma_param_renew BOOLEAN DEFAULT TRUE,p_required BOOLEAN DEFAULT FALSE) RETURN CLOB;
FUNCTION component_values_to_json_(p_coll tt_component_obj,p_comma_param_renew BOOLEAN DEFAULT TRUE) RETURN CLOB;

PROCEDURE setvalue(p_component         VARCHAR2,
                   p_values            CLOB DEFAULT NULL,
                   p_value             VARCHAR2 DEFAULT chr(1760),
                   p_label_caption     ui_components.label_caption%TYPE DEFAULT NULL,
                   p_width             ui_components.width_%TYPE DEFAULT NULL,
                   p_top               ui_components.top_%TYPE DEFAULT NULL,
                   p_font_size         ui_components.font_size%TYPE DEFAULT NULL,
                   p_font_color        ui_components.font_color%TYPE DEFAULT NULL,
                   p_background_color  ui_components.background_color%TYPE DEFAULT NULL,
                   p_enabled           ui_components.enabled_%TYPE DEFAULT 'Y',
                   p_visible           ui_components.visible_%TYPE DEFAULT 'Y',
                   p_hint              ui_components.hint%TYPE DEFAULT NULL,
                   p_onclick           ui_components.onclick%TYPE DEFAULT NULL,
                   p_onkeypress        ui_components.onkeypress%TYPE DEFAULT NULL,
                   p_onchange          ui_components.onchange%TYPE DEFAULT NULL,
                   p_required          ui_components.required%TYPE DEFAULT NULL);
                   
                   
                   
FUNCTION getvalue(p_component VARCHAR2) RETURN VARCHAR2;
FUNCTION getColumnValue(p_column_name  VARCHAR2) RETURN VARCHAR2;
PROCEDURE collectcolumnvalues(p_schema_name VARCHAR2, p_table_name VARCHAR2, p_id VARCHAR2 DEFAULT 0);
FUNCTION exec_(p_func_name VARCHAR2) RETURN VARCHAR2;
FUNCTION exec RETURN CLOB;
FUNCTION exec(p_ds_proc VARCHAR2,p_value VARCHAR2,p_required BOOLEAN DEFAULT FALSE) RETURN CLOB;
FUNCTION exec(p_json_part CLOB,p_action CLOB DEFAULT NULL) RETURN CLOB;
PROCEDURE setJsonHeadMessageOk(p_message VARCHAR2 DEFAULT 'SUCCESS');
PROCEDURE setJsonHeadMessageError(p_message VARCHAR2);
PROCEDURE setModifyCmbChecked(p_coll IN OUT  tt_component_obj,p_id VARCHAR2,p_checked VARCHAR2 DEFAULT '1');
FUNCTION  action_loadform(p_form VARCHAR2,p_call_proc_name VARCHAR2) RETURN CLOB;
end api_component;
/
create or replace package body api_component is


 v_json json;
 v_json_value json_value;
 v_json_list  json_list;
 TYPE TCMP IS RECORD
 (NAME VARCHAR2(200),
  VALUE VARCHAR2(4000));
 TYPE ttcmp IS TABLE OF tcmp;
 ttcmp_ ttcmp:= ttcmp(); 
 
  TYPE tcol IS RECORD
 (column_name VARCHAR2(500),
  COLUMN_VALUE VARCHAR2(4000));
 TYPE ttcol IS TABLE OF tcol;
 col ttcol := ttcol();
 
 
 n NUMBER DEFAULT 0;
 v_value VARCHAR2(4000);
 

 --tvalues ttvalues := ttvalues(); 
 rows_all CLOB;
 rows CLOB; 
 
 v_add_comma1 INTEGER :=0;
 v_add_comma2 INTEGER :=0;
 
 JsonHeadMessage  VARCHAR2(32767) DEFAULT NULL;
 JsonHeadMessageType VARCHAR2(10) DEFAULT 'OK';
 
 setvalue_activated BOOLEAN DEFAULT FALSE;
 --v_form ui_components.name_%TYPE;
FUNCTION add_comma(p_var IN OUT NUMBER) RETURN VARCHAR2 IS
BEGIN
  p_var := p_var + 1;
  RETURN CASE WHEN p_var>1 THEN ',' ELSE NULL END ;
END add_comma; 

PROCEDURE parse_component_params(p_json json) IS
BEGIN
  v_json := p_json;
  ttcmp_.delete();
  BEGIN
     NULL;
     --v_form := zamir.json_ext.get_string(hub.getJson(),'form');
   EXCEPTION
     WHEN OTHERS THEN 
       log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                 p_method_name => 'api_component.setvalue',
                 p_log_text    => sqlerrm,
                 p_log_clob    =>NULL);
  END;
  IF json_ext.get_string(v_json,'method_name')='zamir.ui_pkg.get_ui_comps' THEN 
     RETURN;
  END IF;   
  FOR i IN 4..v_json.count LOOP
    ttcmp_.extend();
    n := n + 1;
    v_json_list := v_json.get_keys;
    ttcmp_(n).name:=v_json_list.get(i).get_string;
    dbms_output.put_line(v_json_list.get(i).get_string);
    v_json_list := json_list(v_json.get(i));
    FOR j IN 1..v_json_list.count LOOP
       IF v_json_list.get(j).get_string IS NOT NULL THEN 
         v_value := v_value||''||v_json_list.get(j).get_string||''||',';
         --dbms_output.put_line(v_json_list.get(j).get_string);
       END IF; 
    END LOOP;
       ttcmp_(n).value := substr(v_value,1,LENGTH(v_value)-1);
       v_value := '';
  END LOOP;
END parse_component_params;   

FUNCTION component_values_to_json(p_coll tt_component_obj,p_comma_param_renew BOOLEAN DEFAULT TRUE,p_required BOOLEAN DEFAULT FALSE) RETURN CLOB IS 
 v_res CLOB;
 n NUMBER DEFAULT 1;
BEGIN
  IF (v_add_comma2 =0) OR (p_comma_param_renew=TRUE) THEN 
       dbms_lob.createtemporary(v_res,TRUE);
    END IF;   
    
  IF p_comma_param_renew=TRUE THEN 
      v_add_comma2 := 0;
  END IF;
  
  IF p_coll.count>0 THEN
   IF p_required=FALSE THEN   dbms_lob.append(v_res,add_comma(v_add_comma2)||'{"index":"0","id":"","name":"","checked":""}'); ELSE n:=0; END IF;
     FOR i IN p_coll.first..p_coll.last LOOP
        dbms_lob.append(v_res,add_comma(v_add_comma2)||'{"index":"'||n||'","id":"'||p_coll(i).id||'","name":"'||p_coll(i).name||'","checked":"'||p_coll(i).checked||'"}');  
        n := n + 1;        
     END LOOP;
    ELSE
      dbms_lob.append(v_res,'{"index":"0","id":"","name":"","checked":""}'); 
    END IF;
 
   RETURN v_res;  
END component_values_to_json;  


FUNCTION component_values_to_json_(p_coll tt_component_obj,p_comma_param_renew BOOLEAN DEFAULT TRUE) RETURN CLOB IS 
 v_res CLOB;
 n NUMBER DEFAULT 0;
BEGIN
  IF (v_add_comma2 =0) OR (p_comma_param_renew=TRUE) THEN 
       dbms_lob.createtemporary(v_res,TRUE);
    END IF;   
    
  IF p_comma_param_renew=TRUE THEN 
      v_add_comma2 := 0;
  END IF;
  
  IF p_coll IS NOT NULL THEN  
    -- dbms_lob.append(v_res,add_comma(v_add_comma2)||'{"index":"0","id":"","name":"","checked":""}');
     FOR i IN p_coll.first..p_coll.last LOOP
        dbms_lob.append(v_res,add_comma(v_add_comma2)||'{"index":"'||n||'","id":"'||p_coll(i).id||'","name":"'||p_coll(i).name||'","checked":"'||p_coll(i).checked||'"}');  
        n := n + 1;        
     END LOOP;
    END IF;
    --dbms_output.put_line(v_res);
   RETURN v_res;  
END component_values_to_json_;  

PROCEDURE setvalue(p_component         VARCHAR2,
                   p_values            CLOB DEFAULT NULL,
                   p_value             VARCHAR2 DEFAULT chr(1760),
                   p_label_caption     ui_components.label_caption%TYPE DEFAULT NULL,
                   p_width             ui_components.width_%TYPE DEFAULT NULL,
                   p_top               ui_components.top_%TYPE DEFAULT NULL,
                   p_font_size         ui_components.font_size%TYPE DEFAULT NULL,
                   p_font_color        ui_components.font_color%TYPE DEFAULT NULL,
                   p_background_color  ui_components.background_color%TYPE DEFAULT NULL,
                   p_enabled           ui_components.enabled_%TYPE DEFAULT 'Y',
                   p_visible           ui_components.visible_%TYPE DEFAULT 'Y',
                   p_hint              ui_components.hint%TYPE DEFAULT NULL,
                   p_onclick           ui_components.onclick%TYPE DEFAULT NULL,
                   p_onkeypress        ui_components.onkeypress%TYPE DEFAULT NULL,
                   p_onchange          ui_components.onchange%TYPE DEFAULT NULL,
                   p_required          ui_components.required%TYPE DEFAULT NULL) IS

 v_form      VARCHAR2(300) := substr(p_component,1,instr(p_component,'.')-1);
 v_component VARCHAR2(300) := substr(p_component,instr(p_component,'.')+1,length(p_component));   
 v_type      ui_components.type_%TYPE;
 v_cnt       NUMBER DEFAULT 0;
 v_row       CLOB;
 v_row_value CLOB;
BEGIN
   setvalue_activated := TRUE;
   --check is component exists
   SELECT COUNT(*),a.type_ INTO v_cnt,v_type FROM ui_components a, ui_components b WHERE a.root_id=b.id AND lower(a.name_)=lower(v_component) AND lower(b.name_)=LOWER(v_form) GROUP BY a.type_;
   IF v_cnt=0 THEN 
     log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                 p_method_name => 'api_component.setvalue',
                 p_log_text    => 'not found component. name: '||v_component,
                 p_log_clob    => 'not found component. name: '||v_component);
     RETURN;
   END IF;
    --/GetJSON('{"Response":{"Components":[{"type":"ComboBox","name":"cmbLogin","caption":"","hint":"Login users","enable":"Y","values":[{"index":"0","value_id":"1","value":"zamir"}]},{"type":"ComboBox","name":"cmbLogin1","caption":"","hint":"Login users1","enable":"Y","values":[{"index":"1","value_id":"1","value":"zamir1"}]}]}}');                
   IF v_add_comma1=0 THEN 
      dbms_lob.createtemporary(rows,TRUE);
   END IF;
   --dbms_output.put_line(v_add_comma1);
   IF upper(v_type)='TCOMBOBOX' OR upper(v_type)='TCHECKLISTBOX' THEN 
       dbms_lob.append(rows,add_comma(v_add_comma1)||'{"type":"'||v_type||'","name":"'||v_component||'","value":"'||p_value||'","label_caption":"'||p_label_caption||'","width":"'||p_width||'","top":"'||p_top||'","font_size":"'||p_font_size||'","font_color":"'||p_font_color||'","background_color":"'||p_background_color||'","enabled":"'||p_enabled||'","visible":"'||p_visible||'","hint":"'||p_hint||'","onclick":"'||p_onclick||'","onkeypress":"'||p_onkeypress||'","onchange":"'||p_onchange||'","required":"'||p_required||'","values":[');
        IF length(p_values)>0 THEN dbms_lob.append(rows,p_values); END IF; --ELSE dbms_lob.append(rows,'{"index":"","id":"'||chr(1760)||'","name":"'||chr(1760)||'","checked":"'||chr(1760)||'"}'); END IF;
        dbms_lob.append(rows,']}');    
    ELSE
       dbms_lob.append(rows,add_comma(v_add_comma1)||'{"type":"'||v_type||'","name":"'||v_component||'","value":"'||p_value||'","label_caption":"'||p_label_caption||'","width":"'||p_width||'","top":"'||p_top||'","font_size":"'||p_font_size||'","font_color":"'||p_font_color||'","background_color":"'||p_background_color||'","enabled":"'||p_enabled||'","visible":"'||p_visible||'","hint":"'||p_hint||'","onclick":"'||p_onclick||'","onkeypress":"'||p_onkeypress||'","onchange":"'||p_onchange||'","required":"'||p_required||'","values":[]}');
    END IF;     
END setvalue;                   



FUNCTION getvalue(p_component VARCHAR2) RETURN VARCHAR2 IS
 TYPE runcode IS RECORD 
 (code VARCHAR2(50),
  char_ VARCHAR2(50));
 TYPE ttunicode IS TABLE OF runcode;
 tunicode ttunicode:=ttunicode();
 v_curr_value VARCHAR2(4000);
 v_found NUMBER DEFAULT 0;
BEGIN
 IF ttcmp_.count>0 THEN 
  
  
  FOR i IN ttcmp_.first..ttcmp_.last LOOP
    IF lower(p_component)=lower(ttcmp_(i).name) THEN 
      v_curr_value := ttcmp_(i).value;
      EXIT;
    END IF;
  END LOOP;
  SELECT *  BULK COLLECT INTO tunicode FROM unicode_conv;
  FOR i IN tunicode.first..tunicode.last LOOP
     v_curr_value := REPLACE(v_curr_value,tunicode(i).code,tunicode(i).char_);
  END LOOP;
  RETURN v_curr_value;
  END IF;    
  RETURN NULL; 
END getvalue; 

FUNCTION getColumnValue(p_column_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
 IF col.count>0 THEN 
 FOR i IN 1..col.count LOOP
    IF upper(col(i).column_name) = upper(p_column_name) THEN 
      RETURN col(i).column_value;
      EXIT;
    END IF;     
 END LOOP;
 END IF;
 RETURN NULL;  
END getColumnValue;  

PROCEDURE collectcolumnvalues(p_schema_name VARCHAR2, p_table_name VARCHAR2, p_id VARCHAR2 DEFAULT 0) IS
  v_json_string VARCHAR2(32767);
 v_sql_string VARCHAR2(32767);
 n NUMBER DEFAULT 0;
 l NUMBER DEFAULT 0;
 v_table VARCHAR2(100)  DEFAULT 'users';
 v_id VARCHAR2(100) DEFAULT '1';
 v_json json;
 v_json_list json_list;
BEGIN
  FOR i IN (SELECT column_name FROM all_tab_columns WHERE upper(owner)=upper(p_schema_name) AND upper(table_name)=upper(p_table_name)) LOOP
    v_json_string := v_json_string||CASE WHEN n>0 THEN ',' ELSE NULL END||'"'||i.column_name||'":"@'||i.column_name||'"';
    v_sql_string := v_sql_string||CASE WHEN n>0 THEN ',' ELSE NULL END||i.column_name;
    n := n + 1;
  END LOOP;
 
  json_kernel.append_as_text('{');
  json_kernel.append_as_sql(p_json_part =>v_json_string, p_sql => 'select '||v_sql_string|| ' from '|| p_schema_name||'.'||p_table_name ||' where id=:id or 0=:id and rownum<2',bind1 => p_id,bind2=>p_id);
  json_kernel.append_as_text('}');
 
  v_json := json(json_kernel.response);
  col.delete();
  
  FOR i IN 1..v_json.count LOOP
    col.extend();
    l := l + 1;
    v_json_list := v_json.get_keys;
    col(l).column_name := v_json_list.get(i).get_string();
    col(l).column_value := json_ext.get_string(v_json,v_json_list.get(i).get_string());
  END LOOP;
END collectcolumnvalues;  


FUNCTION exec_(p_func_name VARCHAR2) RETURN VARCHAR2 IS 
  v_res VARCHAR2(32767);
BEGIN
   EXECUTE IMMEDIATE  'begin :1:='||p_func_name||'; end;' USING OUT v_res;
   RETURN v_res;
END exec_;  

FUNCTION exec RETURN CLOB IS
BEGIN
   --IF NOT setvalue_activated THEN RETURN NULL; END IF; login de bu ishlemir
   setvalue_activated := FALSE;
   dbms_lob.createtemporary(rows_all,TRUE);
   dbms_lob.append(rows_all,'{"Response":');
   dbms_lob.append(rows_all,'{"Message":{"Status":"'||JsonHeadMessageType||'","Text":"'||JsonHeadMessage||'"},');
   dbms_lob.append(rows_all,'"Components":[');
   IF length(rows)>0 THEN dbms_lob.append(rows_all,rows); END IF;
   dbms_lob.append(rows_all,']}}');
   
   RETURN rows_all;
END exec;

FUNCTION exec(p_ds_proc VARCHAR2,p_value VARCHAR2,p_required BOOLEAN DEFAULT FALSE) RETURN  CLOB IS
 v_res CLOB;
 --v_tt_values ttvalues := ttvalues();
 v_tt_component_obj tt_component_obj := tt_component_obj();
BEGIN
  dbms_lob.createtemporary(v_res,TRUE);
  IF length(p_ds_proc)>0 THEN 
    EXECUTE IMMEDIATE  'begin :1:='||p_ds_proc||'; end;' USING OUT v_tt_component_obj;
    setModifyCmbChecked(v_tt_component_obj,p_value);
    v_res := component_values_to_json(p_coll => v_tt_component_obj,p_required => p_required);
  ELSE
    --v_res := '{"index":"0","id":"'||chr(1760)||'","name":"'||chr(1760)||'","checked":"'||chr(1760)||'"}';  
    v_res := NULL;
  END IF;  
  RETURN v_res;
END exec;  

FUNCTION exec(p_json_part CLOB,p_action CLOB DEFAULT NULL) RETURN CLOB IS
BEGIN
   setvalue_activated := FALSE;
   dbms_lob.createtemporary(rows_all,TRUE);
   dbms_lob.append(rows_all,'{"Response":');
   dbms_lob.append(rows_all,'{"Message":{"Status":"'||JsonHeadMessageType||'","Text":"'||JsonHeadMessage||'"},');
   dbms_lob.append(rows_all,'"Components":[');
   IF length(p_json_part)>0 THEN dbms_lob.append(rows_all,p_json_part); END IF;
   dbms_lob.append(rows_all,']},');
   dbms_lob.append(rows_all,'"Action":{'||p_action||'}}');
   
   RETURN rows_all;
END exec;  

PROCEDURE setJsonHeadMessageOk(p_message VARCHAR2 DEFAULT 'SUCCESS') IS
BEGIN
   JsonHeadMessageType := 'OK';
   JsonHeadMessage := p_message;
END setJsonHeadMessageOk;  
PROCEDURE setJsonHeadMessageError(p_message VARCHAR2) IS
BEGIN
  JsonHeadMessageType := 'ERROR';
  JsonHeadMessage := REPLACE(p_message,'"','<_400'); --lazarus-da iki dirnaqi json parse eda bilmadiyi uchun replace olunur
  JsonHeadMessage := REPLACE(JsonHeadMessage,':','<_401'); --lazarus-da iki dirnaqi json parse eda bilmadiyi uchun replace olunur   
END;  

PROCEDURE setModifyCmbChecked(p_coll IN OUT tt_component_obj,p_id VARCHAR2,p_checked VARCHAR2 DEFAULT '1') IS
 idx INTEGER DEFAULT 0;
BEGIN
  
  IF p_id IS NOT NULL AND p_coll.count>0 THEN 
  FOR i IN p_coll.first..p_coll.last LOOP
    idx := idx + 1;
    IF upper(p_coll(i).id)=upper(p_id) THEN 
       p_coll(i).checked := idx;
       EXIT;
    END IF;   
  END LOOP;
  END IF;   
END setModifyCmbChecked;  

FUNCTION  action_loadForm(p_form VARCHAR2,p_call_proc_name VARCHAR2) RETURN CLOB IS
 v_row ui_components%ROWTYPE DEFAULT ui_components_pkg.READ(p_form);
BEGIN
  json_kernel.append_as_text('"form":"'||p_form||'","width":"'||v_row.width_||'","height":"'||v_row.height||'","schema":"'||v_row.orcl_schema||'","proc_name":"'||p_call_proc_name||'"');
  RETURN exec(p_json_part=>null,p_action=>json_kernel.response);
END action_loadForm;  

begin
  api_component.parse_component_params(hub.getJson);
end api_component;
/
