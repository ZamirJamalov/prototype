create or replace package scr_groups_pkg is

  -- Author  : USER
  -- Created : 9/15/2017 9:39:06 AM
  -- Purpose : 
  

FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;  
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION groups_list RETURN tt_component_obj;

end scr_groups_pkg;
/
create or replace package body scr_groups_pkg is

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Adı","Xüsusi çəki"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@name","@spec_w"]}',
                            p_sql       => 'select rownum,a.id as id,a.name as name,a.spec_w as spec_w 
                             from (select a.id,a.name,a.spec_w from scoring.scr_groups a order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
    RETURN uiresp('message','ERROR',SQLERRM);         
END grid_data;  

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN scr_groups_seq.nextval;
END;  

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO scr_groups(id,
                         name,
                         spec_w)
                  VALUES (api_component.getvalue('id'),
                          api_component.getvalue('name'),
                          api_component.getvalue('spec_w'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN             
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                    
END add;  

FUNCTION upd RETURN CLOB IS
BEGIN
  UPDATE scr_groups a SET 
                          a.name=api_component.getvalue('name'),
                          a.spec_w=api_component.getvalue('spec_w')
               WHERE      a.id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);              
END upd;  

FUNCTION del RETURN CLOB IS
BEGIN
  DELETE FROM scr_groups WHERE id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
   ROLLBACK;
   RETURN uiresp('message','ERROR','ERROR'); 
END del;  

FUNCTION groups_list RETURN tt_component_obj IS
BEGIN
  SELECT t_component_obj(id,NAME,'') BULK COLLECT INTO v_res  FROM scr_groups;
  RETURN v_res;
END groups_list;  
begin
  NULL;
end scr_groups_pkg;
/
