create or replace package ui_menu_pkg is

  -- Author  : USER
  -- Created : 8/10/2017 9:52:16 9:52:16 
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;  
FUNCTION form_list RETURN CLOB;
FUNCTION setid     RETURN VARCHAR2;
FUNCTION root_list RETURN tt_component_obj;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION ui_menu_list RETURN tt_component_obj;
FUNCTION getRootId(p_id ui_menu.id%TYPE) RETURN ui_menu.root_id%TYPE;
end ui_menu_pkg;
/
create or replace package body ui_menu_pkg is

--v_res  api_component.ttvalues := api_component.ttvalues();
v_res tt_component_obj := tt_component_obj();


FUNCTION UiResp(p_message_type VARCHAR2,p_rp_message_type VARCHAR2,p_message VARCHAR2 DEFAULT NULL) RETURN CLOB IS
 v_res CLOB;
BEGIN
  IF p_rp_message_type='OK' THEN 
     api_component.setJsonHeadMessageOk(p_message);
  ELSE
     api_component.setJsonHeadMessageError(p_message);
  END IF;  
   
  CASE p_message_type 
    WHEN 'user_or_password_is_invalid' THEN 
     NULL;
    WHEN 'message'THEN 
      NULL; 
    WHEN 'message1' THEN 
      api_component.setvalue(p_component=>'users.email',p_required=>'Y');  
    ELSE
      NULL;  
  END CASE;   
 
 
 RETURN  api_component.exec; 

END;  
  
FUNCTION grid_data RETURN CLOB IS
  v_idx NUMBER DEFAULT nvl(to_number(api_component.getvalue('index')),0)+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' asc ');
BEGIN
  json_kernel.append_as_text('{"columns":["id","root_id","caption","form_name","form_caption","schema_name","crud","external_form","Sıralama"],');
  json_kernel.append_as_text('"rows":[');
  json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@root_id","@caption","@form_name","@form_caption","@schema_name","@crud","@external_form","@sort_"]}',
                            p_sql       => 'select rownum,a.id as id,a.root_id as root_id,a.caption as caption,a.form_name as form_name,a.form_caption as form_caption,a.schema_name as schema_name,a.crud as crud,a.external_form as external_form,a.sort_ as sort_ from
                                           (select id,root_id,caption,form_name,form_caption,schema_name,crud,external_form,sort_ from ui_menu where root_id is not null order by '||v_idx||' '||v_sort_order||') a');  
                            
  json_kernel.append_as_text(']}'); 
  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
    RETURN '';
    log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                p_method_name => 'ui_menu_pkg.grid_data',
                p_log_text    => NULL,
                p_log_clob    => SQLERRM);
END grid_data;  

FUNCTION add RETURN CLOB IS 
BEGIN
 INSERT INTO ui_menu(id,
                     root_id,
                     caption,
                     form_name,
                     form_caption,
                     schema_name,
                     crud,
                     external_form,
                     sort_)
              VALUES (api_component.getvalue('id'),
                      api_component.getvalue('root_id'),
                      api_component.getvalue('caption'),
                      api_component.getvalue('form_name'),        
                      api_component.getvalue('form_caption'),
                      api_component.getvalue('schema_name'),
                      api_component.getvalue('crud'),
                      api_component.getvalue('external_form'),
                      api_component.getvalue('sort_'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                 p_method_name => 'ui_menu_pkg.add',
                 p_log_text    => NULL,
                 p_log_clob    => SQLERRM);
     RETURN uiresp('message','ERROR',SQLERRM);            
                       
END add;  

FUNCTION upd RETURN CLOB IS 
BEGIN
       log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                 p_method_name => 'ui_menu_pkg.upd',
                 p_log_text    => api_component.getvalue('caption'),
                 p_log_clob    => SQLERRM);  
  UPDATE ui_menu a SET a.root_id=api_component.getvalue('root_id'),
                       a.caption=api_component.getvalue('caption'),
                       a.form_name=api_component.getvalue('form_name'),
                       a.form_caption=api_component.getvalue('form_caption'),
                       a.schema_name=api_component.getvalue('schema_name'),
                       a.crud=api_component.getvalue('crud'),
                       a.external_form=api_component.getvalue('external_form'),
                       a.sort_=api_component.getvalue('sort_')
                     WHERE a.id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('messsage','ERROR',SQLERRM);
               
END upd;  

FUNCTION del RETURN CLOB IS 
 v_res NUMBER DEFAULT 0;
BEGIN
  SELECT COUNT(*) INTO v_res FROM ui_menu WHERE root_id=api_component.getvalue('id');
  IF v_res>0 THEN 
    RETURN uiresp('message','ERROR','Child nodes found. Please remove child nodes firstly');
  END IF;
  DELETE FROM ui_menu WHERE id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION 
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);
END;  

FUNCTION form_list RETURN CLOB IS 
BEGIN
  NULL;
END form_list;  

FUNCTION setid RETURN VARCHAR2 IS 
 v_res NUMBER DEFAULT 0;
BEGIN
  SELECT COUNT(*) INTO v_res FROM ui_menu;
  v_res := nvl(v_res,0) +2;
  RETURN  v_res;
END;  

FUNCTION root_list RETURN tt_component_obj IS
BEGIN
  SELECT t_component_obj(id,caption,'') BULK COLLECT INTO v_res FROM ui_menu ORDER BY id ASC;
  RETURN v_res;
END root_list;  

FUNCTION ui_menu_list RETURN tt_component_obj IS
BEGIN
 SELECT t_component_obj(id,caption,'') BULK COLLECT INTO v_res FROM ui_menu WHERE ui_menu.form_name IS NOT NULL ORDER BY ui_menu.caption ASC;
  RETURN v_res;
END;  

FUNCTION getRootId(p_id ui_menu.id%TYPE) RETURN ui_menu.root_id%TYPE IS
 v_res ui_menu.root_id%TYPE;
BEGIN
  SELECT root_id INTO v_res FROM ui_menu WHERE id=p_id;
  RETURN v_res;
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN -1; 
END getRootId;  

begin
 NULL;
end ui_menu_pkg;
/
