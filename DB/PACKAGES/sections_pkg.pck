create or replace package sections_pkg is

  -- Author  : USER
  -- Created : 9/11/2017 4:05:46 PM
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB; 
FUNCTION setid RETURN VARCHAR2;
FUNCTION sections_list RETURN tt_component_obj;
FUNCTION add RETURN CLOB;
FUNCTION del RETURN CLOB;
end sections_pkg;
/
create or replace package body sections_pkg is

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
  v_idx NUMBER DEFAULT nvl(to_number(api_component.getvalue('index')),0)+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
BEGIN
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Kategoriya","Adı","Xüsusi çəki"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@cat_name","@name","@spec_w"]}',
                            p_sql       => 'select rownum,a.id as id,a.cat_name as cat_name,a.name as name,a.spec_w as spec_w 
                             from (select a.id,b.name as cat_name,a.name,a.spec_w from scoring.sections a,scoring.categories b where a.categories_id=b.id  order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                p_method_name => 'scoring.categories_pkg.grid_data',
                p_log_text    => NULL,
                p_log_clob    => SQLERRM);
     RETURN '';           
END grid_data;  

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
 RETURN sections_seq.nextval; 
END setid;  

FUNCTION sections_list RETURN tt_component_obj IS
BEGIN
 SELECT t_component_obj(p.id,p.name,'') BULK COLLECT INTO v_res FROM sections p;  
 RETURN v_res;
END sections_list;  

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO sections(id,
                       categories_id,
                       name,
                       spec_w)
                VALUES (api_component.getvalue('id'),
                        api_component.getvalue('categories_id'),
                        api_component.getvalue('name'),
                        api_component.getvalue('spec_w'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
    ROLLBACK;
    RETURN uiresp('message','ERROR',SQLERRM);                           
END add;  
 
FUNCTION del RETURN CLOB IS 
BEGIN
  DELETE FROM sections WHERE id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
    ROLLBACK;
    RETURN uiresp('message','ERROR',SQLERRM);
END del;  
begin
 NULL;
end sections_pkg;
/
