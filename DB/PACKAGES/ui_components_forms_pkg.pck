create or replace package ui_components_forms_pkg is

  -- Author  : USER
  -- Created : 8/10/2017 10:48:46 10:48:46 
  -- Purpose : 


  
FUNCTION grid_data RETURN CLOB;
FUNCTION ui_setid RETURN VARCHAR2;  
FUNCTION add RETURN CLOB;  
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION list_forms RETURN tt_component_obj;
FUNCTION list_forms_coll RETURN tt_component_obj;

end ui_components_forms_pkg;
/
create or replace package body ui_components_forms_pkg is

--v_res api_component.ttvalues := api_component.ttvalues();
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

END UiResp;  



FUNCTION grid_data RETURN CLOB IS 
BEGIN
  json_kernel.append_as_text('{"columns":["id","name"],');
  json_kernel.append_as_text('"rows":[');
  json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@name"]}',
                            p_sql       => 'select rownum,id,name from ui_components_forms'); 
                            
  json_kernel.append_as_text(']}'); 
  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);
    /*RETURN '';
    log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                p_method_name => 'ui_components_forms_pkg.grid_data',
                p_log_text    => NULL,
                p_log_clob    => SQLERRM);*/
END grid_data;    

FUNCTION ui_setid RETURN  VARCHAR2 IS
BEGIN
  RETURN ui_components_forms_seq.nextval;
END ui_setid;  

FUNCTION add RETURN CLOB IS
BEGIN
   INSERT INTO ui_components_forms(id, name) VALUES (api_component.getvalue('id'),api_component.getvalue('name'));
   COMMIT;
   
   RETURN uiresp('message','OK'); 
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END add;

FUNCTION upd RETURN CLOB IS 
BEGIN
   UPDATE ui_components_forms a SET  a.name=api_component.getvalue('name') WHERE id=api_component.getvalue('id');
   COMMIT;
   RETURN uiresp('message','OK');
  EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);  
END upd;  

FUNCTION del RETURN CLOB IS
BEGIN
   DELETE FROM ui_components_forms a WHERE a.id=api_component.getvalue('id');
   COMMIT;
   RETURN uiresp('message','OK');
 EXCEPTION 
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;  
 
FUNCTION list_forms RETURN tt_component_obj IS 
BEGIN 
  SELECT t_component_obj(NAME,NAME,'') BULK COLLECT INTO v_res FROM ui_components_forms;
  RETURN v_res;
END list_forms;  

FUNCTION list_forms_coll RETURN tt_component_obj IS
BEGIN
   SELECT t_component_obj(NAME,NAME,'') BULK COLLECT INTO v_res FROM ui_components_forms;
   RETURN v_res;
END list_forms_coll;   
begin
 NULL;
end ui_components_forms_pkg;
/
