create or replace package ui_pkg is

  -- Author  : USER
  -- Created : 6/22/2017 0:11:13 0:11:13 
  -- Purpose : 
TFORM        CONSTANT VARCHAR2(50) := 'TFORM';
TEDIT        CONSTANT VARCHAR2(50) := 'TEDIT';
TLABEL       CONSTANT VARCHAR2(50) := 'TLABEL';
TCOMBOBOX    CONSTANT VARCHAR2(50) := 'TCOMBOBOX';
TCHECKBOX    CONSTANT VARCHAR2(50) := 'TCHECKBOX';
TLISTBOX     CONSTANT VARCHAR2(50) := 'TLISTBOX';
TMEMO        CONSTANT VARCHAR2(50) := 'TMEMO';

FUNCTION  menu_data RETURN CLOB;
FUNCTION  get_id(p_type ui_components.type_%TYPE,p_name ui_components.name_%TYPE) RETURN ui_components.root_id%TYPE;
FUNCTION  get_root_id(p_type ui_components.type_%TYPE,p_name ui_components.name_%TYPE) RETURN ui_components.root_id%TYPE;
PROCEDURE add_component(p_row ui_components%ROWTYPE);
PROCEDURE upd_component(p_row ui_components%ROWTYPE);  
PROCEDURE del_component(p_row ui_components%ROWTYPE);

FUNCTION  get_ui_comps RETURN CLOB;                                              
end ui_pkg;
/
create or replace package body ui_pkg is

FUNCTION menu_data RETURN CLOB IS
BEGIN
  json_kernel.append_as_text('{');
  json_kernel.append_as_text('"rows":[');
  json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@root_id","@caption","@form_name","@form_caption","@schema_name"]}',
                            p_sql       => 'select rownum,a.id as id,a.root_id as root_id,a.caption as caption,a.form_name as form_name,a.form_caption as form_caption,a.schema_name as schema_name
                             from (select id,root_id,caption,form_name,form_caption,schema_name from ui_menu order by id asc ) a');
  json_kernel.append_as_text(']}'); 
  RETURN json_kernel.response;   
 EXCEPTION
   WHEN OTHERS THEN 
    RETURN '';
    log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                p_method_name => 'ui_pkg.menu_data',
                p_log_text    => NULL,
                p_log_clob    => SQLERRM);
END menu_data;  

FUNCTION get_id(p_type ui_components.type_%TYPE,p_name ui_components.name_%TYPE) RETURN ui_components.root_id%TYPE IS
 v_res ui_components.id%TYPE;
BEGIN
  SELECT a.id INTO v_res FROM ui_components a WHERE upper(a.type_)=upper(p_type) AND upper(a.name_)=upper(p_name);
  RETURN v_res;
END;  

FUNCTION get_root_id(p_type ui_components.type_%TYPE,p_name ui_components.name_%TYPE) RETURN ui_components.root_id%TYPE IS
 v_res ui_components.root_id%TYPE;
BEGIN
  SELECT a.root_id INTO v_res FROM ui_components a WHERE upper(a.type_)=upper(p_type) AND upper(a.name_)=upper(p_name);
  RETURN v_res;
END;  

PROCEDURE add_component(p_row ui_components%ROWTYPE) IS
BEGIN
  INSERT INTO ui_components(id,
                            root_id,
                            type_,
                            name_,
                            default_value,
                            label_caption,
                            width_,
                            font_size,
                            font_color,
                            background_color,
                            enabled_,
                            visible_)
                     VALUES (ui_components_seq.nextval,
                             p_row.root_id,
                             p_row.type_,
                             p_row.name_,
                             p_row.default_value,
                             p_row.label_caption,
                             p_row.width_,
                             p_row.font_size,
                             p_row.font_color,
                             p_row.background_color,
                             p_row.enabled_,
                             p_row.visible_);
   COMMIT;
  EXCEPTION
    WHEN OTHERS THEN 
      ROLLBACK;
      log_pkg.add(p_log_type    => NULL,
                  p_method_name => 'ui_pkg.add_component',
                  p_log_text    => SQLERRM,
                  p_log_clob    => NULL);                                     

END add_component;                        

PROCEDURE upd_component(p_row ui_components%ROWTYPE) IS
BEGIN
  UPDATE ui_components a SET
                a.root_id=p_row.root_id,
                a.type_=p_row.type_,
                a.name_=p_row.name_,
                a.default_value=p_row.default_value,
                a.label_caption=p_row.label_caption,
                a.width_=p_row.width_,
                a.font_size=p_row.font_size,
                a.font_color=p_row.font_color,
                a.background_color=p_row.background_color,
                a.enabled_=p_row.enabled_,
                a.visible_=p_row.visible_
             WHERE
                a.id=p_row.id;
  COMMIT;
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     log_pkg.add(p_log_type    => NULL,
                 p_method_name => 'ui_pkg.upd_component',
                 p_log_text    => SQLERRM,
                 p_log_clob    => NULL);                    
END upd_component;  

PROCEDURE del_component(p_row ui_components%ROWTYPE) IS
BEGIN
  DELETE FROM ui_components WHERE id=p_row.id;
  COMMIT;
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     log_pkg.add(p_log_type    => NULL,
                 p_method_name => 'ui_pkg.del_component',
                 p_log_text    => SQLERRM,
                 p_log_clob    => NULL); 
END del_component;  

FUNCTION  get_ui_comps RETURN CLOB IS
BEGIN
  FOR i IN (SELECT * FROM ui_components WHERE root_id=(SELECT ID FROM ui_components WHERE type_='TFORM' AND upper(NAME_)=upper(zamir.json_ext.get_string(hub.getJson(),'form'))) ORDER BY sort_ ASC) LOOP
     api_component.setvalue(p_component        => zamir.json_ext.get_string(hub.getJson(),'form')||'.'||i.name_,
                            p_values           => api_component.exec(i.ds_proc),
                            p_label_caption    => i.label_caption,
                            p_width            => i.width_,
                            p_font_size        => i.font_size,
                            p_font_color       => i.font_color,
                            p_background_color => i.background_color,
                            p_enabled          => i.enabled_,
                            p_visible          => i.visible_,
                            p_hint             => i.hint,
                            p_onclick          => i.onclick,
                            p_onkeypress       => i.onkeypress,
                            p_onchange         => i.onchange,
                            p_required         => i.required);
                                  
  END LOOP;
 RETURN api_component.exec;
 EXCEPTION
   WHEN OTHERS THEN 
    RETURN '';
    log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                p_method_name => 'ui_pkg.get_ui_comps',
                p_log_text    => SQLERRM,
                p_log_clob    => SQLERRM);
END get_ui_comps;  

begin
 NULL;
end ui_pkg;
/
