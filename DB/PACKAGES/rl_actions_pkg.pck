create or replace package rl_actions_pkg is

  -- Author  : USER
  -- Created : 9/18/2017 8:14:10 AM
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION rl_actions_list RETURN tt_component_obj;
end rl_actions_pkg;
/
create or replace package body rl_actions_pkg is

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
END uiresp;

FUNCTION grid_data RETURN CLOB IS
  v_idx NUMBER DEFAULT nvl(to_number(api_component.getvalue('index')),0)+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
BEGIN
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Adı","Label"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@name","@label"]}',
                            p_sql       => 'select rownum,a.id as id,a.name as name,a.label as label 
                             from (select a.id,a.name,a.label from rl_actions a order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);           
END grid_data;    

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN rl_actions_seq.nextval;
END setid;  

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO rl_actions(id, NAME,label)
              VALUES(api_component.getvalue('id'),
                     api_component.getvalue('name'),
                     api_component.getvalue('label'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN  uiresp('message','ERROR',SQLERRM);                   
END add;  

FUNCTION upd RETURN CLOB IS
 v_id rl_actions.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  UPDATE rl_actions a SET a.name=api_component.getvalue('name') WHERE a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END upd;  

FUNCTION del RETURN CLOB IS
 v_id rl_actions.id%TYPE DEFAULT api_component.getvalue('id');  
BEGIN
  DELETE FROM rl_actions a WHERE a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;  

FUNCTION rl_actions_list RETURN tt_component_obj IS
BEGIN
  SELECT t_component_obj(id,name,'') BULK COLLECT INTO v_res FROM rl_actions;
  RETURN v_res;
END rl_actions_list;  

begin
 NULL;
end rl_actions_pkg;
/
