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
FUNCTION groups_list_for_questions RETURN tt_component_obj;
end scr_groups_pkg;
/
create or replace package body scr_groups_pkg is

v_res tt_component_obj := tt_component_obj();
 
FUNCTION isrootid(p_id scr_groups.id%TYPE) RETURN BOOLEAN IS
 v_res NUMBER DEFAULT 0;
BEGIN
  SELECT COUNT(*) INTO v_res FROM scr_groups WHERE root_id=p_id;
  IF v_res=0 THEN RETURN FALSE; ELSE RETURN TRUE; END IF;
END isrootid;  

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Grup Adı","Adı","Xüsusi çəki","Aktivdir","Qeyd"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@group_name","@name","@spec_w","@isactive","@description"]}',
                            p_sql       => 'select rownum,a.id as id,a.group_name as group_name,a.name as name,a.spec_w as spec_w,a.isactive as isactive,a.description as description
                             from (select a.id,b.name as group_name,a.name,a.spec_w,a.isactive,a.description from scoring.scr_groups a left join scoring.scr_groups b on a.root_id=b.id  order by '||v_idx||' '||v_sort_order||' ) a');  
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
                         spec_w,
                         root_id,
                         description,
                         isactive)
                  VALUES (api_component.getvalue('id'),
                          api_component.getvalue('name'),
                          api_component.getvalue('spec_w'),
                          api_component.getvalue('root_id'),
                          api_component.getvalue('description'),
                          api_component.getvalue('isactive'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN             
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                    
END add;  

FUNCTION upd RETURN CLOB IS
BEGIN
  IF api_component.getvalue('root_id')=api_component.getvalue('id') THEN 
     RETURN uiresp('message','ERROR','Root grup adı digər grup adından fərqli olmalıdır');
  END IF;
  IF isrootid(api_component.getvalue('id'))=TRUE AND api_component.getvalue('isactive')='Y' THEN 
     RETURN uiresp('message','ERROR','Bu qrupa alt qruplar bağlı olduğundan aktiv etməq mümkün deyildir.');
  END IF;
  UPDATE scr_groups a SET 
                          a.name=api_component.getvalue('name'),
                          a.spec_w=api_component.getvalue('spec_w'),
                          a.root_id=api_component.getvalue('root_id'),
                          a.description=api_component.getvalue('description'),
                          a.isactive=api_component.getvalue('isactive')
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
   RETURN uiresp('message','ERROR',SQLERRM); 
END del;  

FUNCTION groups_list RETURN tt_component_obj IS
BEGIN
  SELECT t_component_obj(id,NAME,'') BULK COLLECT INTO v_res  FROM scr_groups;
  RETURN v_res;
END groups_list;  

FUNCTION groups_list_for_questions RETURN tt_component_obj IS
BEGIN
  SELECT t_component_obj(id,NAME,'') BULK COLLECT INTO v_res  FROM scr_groups WHERE scr_groups.isactive='Y';
  RETURN v_res;
END groups_list_for_questions;  

begin
  NULL;
end scr_groups_pkg;
/
