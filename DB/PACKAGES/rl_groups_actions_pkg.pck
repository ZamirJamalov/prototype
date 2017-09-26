create or replace package rl_groups_actions_pkg is

  -- Author  : USER
  -- Created : 9/18/2017 3:07:05 PM
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
  

end rl_groups_actions_pkg;
/
create or replace package body rl_groups_actions_pkg is

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Grup adı","Action adı"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@group_name","@action_name"]}',
                            p_sql       => 'select rownum,a.id as id,a.action_name  as action_name,a.group_name as group_name 
                             from (select a.id,b.name as action_name,c.name as group_name from rl_groups_actions a,rl_actions b,rl_groups c
                               where a.rl_actions_id=b.id and a.rl_groups_id=c.id order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);         
END grid_data;    

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO rl_groups_actions(rl_groups_id,
                                 rl_actions_id,
                                 id)
                         VALUES(api_component.getvalue('rl_groups_id'),
                                api_component.getvalue('rl_actions_id'),
                                api_component.getvalue('id'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                               
END add;    

FUNCTION upd RETURN CLOB IS 
 v_rl_groups_id rl_groups_actions.rl_groups_id%TYPE DEFAULT api_component.getvalue('rl_groups_id');
 v_rl_actions_id rl_groups_actions.rl_actions_id%TYPE DEFAULT api_component.getvalue('rl_actions_id');
 v_id rl_groups_actions.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  UPDATE rl_groups_actions a SET a.rl_groups_id=api_component.getvalue('rl_groups_id'),
                                 a.rl_actions_id=api_component.getvalue('rl_actions_id') 
                          WHERE  a.rl_groups_id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                            
END upd;

FUNCTION del RETURN CLOB IS
 v_id rl_groups_actions.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  DELETE FROM rl_groups_actions WHERE id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;  
 
FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN rl_groups_actions_seq.nextval;
END setid;  
begin
  NULL;
end rl_groups_actions_pkg;
/
