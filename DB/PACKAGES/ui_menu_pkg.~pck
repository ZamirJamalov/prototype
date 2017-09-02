create or replace package ui_menu_pkg is

  -- Author  : USER
  -- Created : 8/10/2017 9:52:16 9:52:16 
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;  
FUNCTION form_list RETURN CLOB;
end ui_menu_pkg;
/
create or replace package body ui_menu_pkg is

v_res  api_component.ttvalues := api_component.ttvalues();
  
FUNCTION grid_data RETURN CLOB IS
BEGIN
  json_kernel.append_as_text('{"columns":["id","root_id","caption","form_name","form_caption","schema_name"],');
  json_kernel.append_as_text('"rows":[');
  json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@root_id","@caption","@form_name","@form_caption","@schema_name"]}',
                            p_sql       => 'select rownum,id,root_id,caption,form_name,form_caption,schema_name from ui_menu'); 
                            
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

FUNCTION form_list RETURN CLOB IS 
BEGIN
  NULL;
END form_list;  
begin
 NULL;
end ui_menu_pkg;
/
