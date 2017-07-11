create or replace package api_component is

  -- Author  : USER
  -- Created : 7/3/2017 0:05:40 0:05:40 
  -- Purpose : 



TYPE tttvalues IS RECORD
(id NUMBER,
 NAME VARCHAR2(4000),
 checked CHAR(1));

TYPE ttvalues IS TABLE OF tttvalues ;




  

PROCEDURE parse_component_params(p_json json); 

FUNCTION component_values_to_json(p_coll ttvalues,p_comma_param_renew BOOLEAN DEFAULT TRUE) RETURN CLOB;

PROCEDURE setvalue(p_component         VARCHAR2,
                   p_values            CLOB DEFAULT NULL,
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

FUNCTION exec RETURN CLOB;
FUNCTION exec(p_ds_proc VARCHAR2) RETURN CLOB;
PROCEDURE setJsonHeadMessageOk(p_message VARCHAR2 DEFAULT 'SUCCESS');
PROCEDURE setJsonHeadMessageError(p_message VARCHAR2);
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
 n NUMBER DEFAULT 0;
 v_value VARCHAR2(4000);
 

 tvalues ttvalues := ttvalues(); 
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
  FOR i IN 4..v_json.count LOOP
    ttcmp_.extend();
    n := n + 1;
    v_json_list := v_json.get_keys;
    ttcmp_(n).name:=v_json_list.get(i).get_string;
    --dbms_output.put_line(v_json_list.get(i).get_string);
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

FUNCTION component_values_to_json(p_coll ttvalues,p_comma_param_renew BOOLEAN DEFAULT TRUE) RETURN CLOB IS 
 v_res CLOB;
 n NUMBER DEFAULT 1;
BEGIN
  IF (v_add_comma2 =0) OR (p_comma_param_renew=TRUE) THEN 
       dbms_lob.createtemporary(v_res,TRUE);
    END IF;   
    
  IF p_comma_param_renew=TRUE THEN 
      v_add_comma2 := 0;
  END IF;
  
  IF p_coll IS NOT NULL THEN  
     dbms_lob.append(v_res,add_comma(v_add_comma2)||'{"index":"0","id":"","name":"","checked":""}');
     FOR i IN p_coll.first..p_coll.last LOOP
        dbms_lob.append(v_res,add_comma(v_add_comma2)||'{"index":"'||n||'","id":"'||p_coll(i).id||'","name":"'||p_coll(i).name||'","checked":"'||p_coll(i).checked||'"}');  
        n := n + 1;        
     END LOOP;
    END IF;
    --dbms_output.put_line(v_res);
   RETURN v_res;  
END component_values_to_json;  

PROCEDURE setvalue(p_component         VARCHAR2,
                   p_values            CLOB DEFAULT NULL,
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
   dbms_lob.append(rows,add_comma(v_add_comma1)||'{"type":"'||v_type||'","name":"'||v_component||'","label_caption":"'||p_label_caption||'","width":"'||p_width||'","top":"'||p_top||'","font_size":"'||p_font_size||'","font_color":"'||p_font_color||'","background_color":"'||p_background_color||'","enabled":"'||p_enabled||'","visible":"'||p_visible||'","hint":"'||p_hint||'","onclick":"'||p_onclick||'","onkeypress":"'||p_onkeypress||'","onchange":"'||p_onchange||'","required":"'||p_required||'","values":[');
   IF length(p_values)>0 THEN dbms_lob.append(rows,p_values); ELSE dbms_lob.append(rows,'{"index":"","id":"","name":"","checked":""}'); END IF;
   dbms_lob.append(rows,']}');    
END setvalue;                   



FUNCTION getvalue(p_component VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  FOR i IN ttcmp_.first..ttcmp_.last LOOP
    IF lower(p_component)=lower(ttcmp_(i).name) THEN 
      RETURN ttcmp_(i).value;
      EXIT;
    END IF;
  END LOOP;
  RETURN NULL; 
END getvalue; 

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

FUNCTION exec(p_ds_proc VARCHAR2) RETURN  CLOB IS
 v_res CLOB;
BEGIN
  dbms_lob.createtemporary(v_res,TRUE);
  IF length(p_ds_proc)>0 THEN 
    EXECUTE IMMEDIATE  'begin :1:='||p_ds_proc||'; end;' USING OUT v_res;
  ELSE
    v_res := '{"index":"0","id":"","name":"","checked":""}';  
  END IF;  
  RETURN v_res;
END exec;  

PROCEDURE setJsonHeadMessageOk(p_message VARCHAR2 DEFAULT 'SUCCESS') IS
BEGIN
   JsonHeadMessageType := 'OK';
   JsonHeadMessage := p_message;
END setJsonHeadMessageOk;  
PROCEDURE setJsonHeadMessageError(p_message VARCHAR2) IS
BEGIN
  JsonHeadMessageType := 'ERROR';
  JsonHeadMessage := p_message;
END;  
 
begin
  api_component.parse_component_params(hub.getJson);
end api_component;
/
