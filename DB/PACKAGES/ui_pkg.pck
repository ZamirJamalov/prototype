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

FUNCTION menu_data RETURN CLOB IS
BEGIN
  json_kernel.append_as_text('{');
  json_kernel.append_as_text('"rows":[');
  json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@root_id","@caption","@form_name","@form_caption","@schema_name","@crud","@external_form"]}',
                            p_sql       => 'select rownum,a.id as id,a.root_id as root_id,a.caption as caption,a.form_name as form_name,a.form_caption as form_caption,a.schema_name as schema_name,a.crud as crud,a.external_form as external_form
                             from (select id,root_id,caption,form_name,form_caption,schema_name,crud,external_form
  from ui_menu 
  start with root_id is null
  connect by prior ID = root_id AND  ui_menu.id IN (SELECT ui_menu_id FROM rl_groups_menu a, users b where a.rl_groups_id=b.rl_groups_id and b.session_=:1)  ) a',bind1 => hub.getSession); --AND  ui_menu.id IN (SELECT ui_menu_id FROM rl_groups_menu)
  json_kernel.append_as_text(']}'); 
  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
   RETURN uiresp('message','ERROR',SQLERRM);
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
   v_form VARCHAR2(4000);
   v_grid_id VARCHAR2(100);
   v_crud VARCHAR2(100);
   v_schema_name VARCHAR2(100);

 FUNCTION getFormName(p_id INTEGER) RETURN VARCHAR2 IS
    v_res VARCHAR2(100);
   BEGIN
     SELECT ui_cf.name INTO v_res FROM ui_components_forms ui_cf, ui_components ui_c1, ui_components ui_c WHERE upper(ui_cf.name)=upper(ui_c1.name_) AND ui_c.id=p_id AND ui_c.root_id=ui_c1.id;
     RETURN v_res;
   END getFormName;  
 FUNCTION getSchemaName(p_form VARCHAR2) RETURN VARCHAR2 IS
   v_res VARCHAR2(100);
  BEGIN
    SELECT schema_name INTO v_res FROM ui_menu WHERE upper(form_name)=upper(p_form);
    RETURN v_res;
  END getSchemaName;   
BEGIN
 
  v_form := zamir.json_ext.get_string(hub.getJson(),'form');
  v_grid_id := zamir.json_ext.get_string(hub.getJson(),'id');
  v_crud := zamir.json_ext.get_string(hub.getJson(),'crud');    
  v_schema_name :=zamir.json_ext.get_string(hub.getJson(),'schema_name');   
  api_component.collectcolumnvalues(p_schema_name => v_schema_name, p_table_name  => upper(v_form), p_id => v_grid_id);
   
 IF upper(v_form)='UI_COMPONENTS' THEN 
   
  FOR i IN (SELECT * FROM ui_components WHERE root_id=(SELECT ID FROM ui_components WHERE type_='TFORM' AND upper(NAME_)=upper(v_form)) ORDER BY sort_ ASC) LOOP
     api_component.setvalue(p_component        => v_form||'.'||i.name_,
                            p_values           => CASE 
                                                      WHEN i.type_ IN ('TCOMBOBOX','TCHECKLISTBOX') THEN
                                                          CASE
                                                              WHEN i.name_='form_list' THEN
                                                                 CASE 
                                                                     WHEN v_crud!='add' THEN 
                                                                          api_component.exec(p_ds_proc=>i.ds_proc,p_value=>getFormName(v_grid_id))
                                                                     ELSE
                                                                          api_component.exec(p_ds_proc=>i.ds_proc,p_value=>'')
                                                                  END              
                                                              ELSE
                                                                  api_component.exec(p_ds_proc=>i.ds_proc,p_value=>api_component.getColumnValue(i.name_))
                                                           END 
                                                      ELSE NULL 
                                                   END,--api_component.exec(i.ds_proc,CASE WHEN i.name_='form_list' THEN v_form ELSE api_component.getColumnValue(i.name_) END)  ,
                            p_value            => CASE 
                                                      WHEN i.type_ NOT IN ('TCOMBOBOX','TCHECKLISTBOX') AND i.ds_proc IS NOT NULL THEN 
                                                           CASE 
                                                              WHEN v_crud<>'add' THEN nvl(api_component.getColumnValue(i.name_),i.default_value)
                                                              ELSE api_component.exec_(i.ds_proc)
                                                           END
                                                      ELSE nvl(api_component.getColumnValue(i.name_),i.default_value)      
                                                  END, 
                            p_label_caption    => i.label_caption,
                            p_width            => i.width_,
                            p_font_size        => i.font_size,
                            p_font_color       => i.font_color,
                            p_background_color => i.background_color,
                            p_enabled          => CASE v_crud  WHEN 'upd' THEN i.upd_enabled_  ELSE i.enabled_ END,
                            p_visible          => CASE v_crud WHEN  'upd' THEN i.upd_visible_  ELSE i.visible_ END,
                            p_hint             => i.hint,
                            p_onclick          => i.onclick,
                            p_onkeypress       => i.onkeypress,
                            p_onchange         => i.onchange,
                            p_required         => i.required);
  END LOOP;
 ELSE
    
  FOR i IN (SELECT * FROM ui_components WHERE root_id=(SELECT ID FROM ui_components WHERE type_='TFORM' AND upper(NAME_)=upper(v_form)) ORDER BY sort_ ASC) LOOP
     api_component.setvalue(p_component        => v_form||'.'||i.name_,
                            p_values           => CASE WHEN i.type_ IN ('TCOMBOBOX','TCHECKLISTBOX') THEN  api_component.exec(p_ds_proc=>i.ds_proc,p_value=>api_component.getColumnValue(i.name_),p_required=>utils_pkg.yn_to_bool(i.required))  ELSE NULL END,
                            p_value            => CASE 
                                                      WHEN i.type_ NOT IN ('TCOMBOBOX','TCHECKLISTBOX') AND i.ds_proc IS NOT NULL THEN 
                                                           CASE 
                                                              WHEN v_crud<>'add' THEN nvl(api_component.getColumnValue(i.name_),i.default_value)
                                                              ELSE api_component.exec_(i.ds_proc)
                                                            END
                                                      ELSE nvl(api_component.getColumnValue(i.name_),i.default_value)      
                                                  END,           
                            p_label_caption    => i.label_caption,
                            p_width            => i.width_,
                            p_font_size        => i.font_size,
                            p_font_color       => i.font_color,
                            p_background_color => i.background_color,
                            p_enabled          => CASE v_crud  WHEN 'upd' THEN i.upd_enabled_  ELSE i.enabled_ END,
                            p_visible          => CASE v_crud WHEN  'upd' THEN i.upd_visible_  ELSE i.visible_ END,
                            p_hint             => i.hint,
                            p_onclick          => i.onclick,
                            p_onkeypress       => i.onkeypress,
                            p_onchange         => i.onchange,
                            p_required         => i.required);
  END LOOP;
 END IF;
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
