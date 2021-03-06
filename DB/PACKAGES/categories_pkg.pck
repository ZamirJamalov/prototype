﻿create or replace package categories_pkg is

  -- Author  : USER
  -- Created : 9/10/2017 12:29:11 PM
  -- Purpose : 
FUNCTION grid_data RETURN CLOB;  
FUNCTION add RETURN CLOB; 
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
FUNCTION categories_list RETURN tt_component_obj;
end categories_pkg;
/
create or replace package body categories_pkg is

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
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
BEGIN
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Adı","Xüsusi çəki"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@name","@spec_w"]}',
                            p_sql       => 'select rownum,a.id as id,a.name as name,a.spec_w as spec_w 
                             from (select id,name,spec_w from scoring.categories order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);
END grid_data;  

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO categories(id,
                         name,
                         spec_w)
              VALUES     (api_component.getvalue('id'),
                          api_component.getvalue('name'),
                          api_component.getvalue('spec_w'));
  COMMIT;
  RETURN UiResp('message','OK');
 EXCEPTION 
   WHEN OTHERS THEN 
     ROLLBACK; 
     RETURN uiresp('message','ERROR',SQLERRM);          
                                       
END add;  

FUNCTION upd RETURN CLOB IS
BEGIN
  UPDATE categories a SET a.name=api_component.getvalue('name'),
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
  DELETE FROM categories WHERE id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END;  

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
 RETURN categories_seq.nextval; 
END setid;  

FUNCTION categories_list RETURN tt_component_obj IS 
BEGIN
 SELECT t_component_obj(ct.id,ct.name,'')  BULK COLLECT INTO v_res FROM categories ct;
 RETURN v_res;
END categories_list; 
begin
 NULL;
end categories_pkg;
/
