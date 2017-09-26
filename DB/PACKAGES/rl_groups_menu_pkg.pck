create or replace package rl_groups_menu_pkg is

  -- Author  : USER
  -- Created : 9/19/2017 2:24:14 PM
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;  
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;


end rl_groups_menu_pkg;
/
create or replace package body rl_groups_menu_pkg is

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Grup adı","Menu adı"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@group_name","@menu_name"]}',
                            p_sql       => 'select rownum,a.id as id,a.group_name as group_name,a.menu_name as menu_name 
                             from (select a.id,b.name as group_name,c.caption as menu_name
                               from rl_groups_menu a, rl_groups b,ui_menu c where a.rl_groups_id=b.id and a.ui_menu_id=c.id order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
    RETURN uiresp('message','ERROR',SQLERRM);         
END grid_data;      

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN rl_groups_menu_seq.nextval;
END setid; 

FUNCTION add RETURN CLOB IS
  TYPE rr_col IS RECORD
  (id ui_menu.id%TYPE,
   root_id ui_menu.root_id%TYPE);
  TYPE t_rr_col IS TABLE OF rr_col;
  v_t_rr_col t_rr_col:=t_rr_col(); 
  TYPE ttt IS TABLE OF NUMBER;
  tt ttt:=ttt();
  v_root_id NUMBER DEFAULT 0;
  n NUMBER DEFAULT 0;
  v_ui_menu_id NUMBER DEFAULT api_component.getvalue('ui_menu_id');
  FUNCTION rec(p_id NUMBER) RETURN NUMBER IS
    v_res NUMBER;
   BEGIN
     SELECT root_id INTO v_res FROM ui_menu WHERE ID=p_id;
     RETURN v_res;
   END;
BEGIN
  /*
  
     
DECLARE
 v_root_id NUMBER DEFAULT 0;
 v_id NUMBER DEFAULT 20;
 FUNCTION rec(p_id NUMBER) RETURN NUMBER IS
    v_res NUMBER;
   BEGIN
     SELECT root_id INTO v_res FROM ui_menu WHERE ID=p_id;
     RETURN v_res;
   END;
BEGIN
  WHILE v_root_id IS NOT NULL LOOP
    v_root_id := rec(v_id);
    v_id := v_root_id;
    dbms_output.put_line(v_id);
  END LOOP;
END;
   */
  SELECT id,root_id BULK COLLECT INTO v_t_rr_col FROM ui_menu;
  SELECT ui_menu_id BULK COLLECT INTO tt FROM rl_groups_menu WHERE rl_groups_id=api_component.getvalue('rl_groups_id');
  IF  v_ui_menu_id MEMBER OF tt THEN 
    RETURN uiresp('message','ERROR','This data exists');
  END IF;
  INSERT INTO rl_groups_menu(id,
                             rl_groups_id,
                             ui_menu_id)
                  VALUES    (api_component.getvalue('id'),
                             api_component.getvalue('rl_groups_id'),
                             v_ui_menu_id);
                          
  WHILE v_root_id IS NOT NULL  LOOP
    v_root_id := rec(v_ui_menu_id);
    IF v_root_id IS NULL THEN 
        EXIT;
    END IF;
    v_ui_menu_id := v_root_id;
    IF NOT v_ui_menu_id MEMBER OF tt THEN 
      INSERT INTO rl_groups_menu(id,
                             rl_groups_id,
                             ui_menu_id)
                  VALUES    (rl_groups_menu_seq.nextval,
                             api_component.getvalue('rl_groups_id'),
                             v_ui_menu_id);
    END IF;
  END LOOP;
                         
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                                         
END add;  

FUNCTION upd RETURN CLOB IS 
  v_id rl_groups_menu.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  UPDATE rl_groups_menu a  SET a.rl_groups_id=api_component.getvalue('rl_groups_id'),
                               a.ui_menu_id=api_component.getvalue('ui_menu_id')
                  WHERE        a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                               
END upd; 

FUNCTION del RETURN CLOB IS
    v_id rl_groups_menu.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  DELETE FROM rl_groups_menu WHERE id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
   RETURN uiresp('message','ERROR',SQLERRM); 
END del;   

begin
  NULL;
end rl_groups_menu_pkg;
/
