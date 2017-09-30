create or replace package ui_components_pkg is

  -- Author  : USER
  -- Created : 8/10/2017 0:08:22 0:08:22 
  -- Purpose : 

FUNCTION READ(p_form_name VARCHAR2) RETURN ui_components%ROWTYPE;
FUNCTION grid_data RETURN CLOB;
FUNCTION list_component_types RETURN  tt_component_obj;--api_component.ttvalues ; 
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION ui_setid RETURN VARCHAR2;
FUNCTION del RETURN CLOB;
end ui_components_pkg;
/
create or replace package body ui_components_pkg is


--v_res api_component.ttvalues := api_component.ttvalues();
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

FUNCTION READ(p_form_name VARCHAR2) RETURN ui_components%ROWTYPE IS
 v_res ui_components%ROWTYPE;
BEGIN
  SELECT * INTO v_res FROM ui_components WHERE upper(type_)='TFORM' AND upper(name_)=upper(p_form_name);
  RETURN v_res;
END READ;  

FUNCTION grid_data RETURN CLOB IS 
  v_idx NUMBER DEFAULT to_number(nvl(api_component.getvalue('index'),0))+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
BEGIN
  json_kernel.append_as_text('{"columns":["id","root_id","type_","name_","default_value","label_caption","width_","font_size","font_color","background_color","enabled_","visible_","hint","sort_","onclick","onchange","ds_proc","top_","upd_enabled_","upd_visible_"],');
  json_kernel.append_as_text('"rows":[');
  json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@root_id","@type_","@name_","@default_value","@label_caption","@width_","@font_size","@font_color","@background_color","@enabled_","@visible_","@hint","@sort_","@onclick","@onchange","@ds_proc","@top_","@upd_enabled_","@upd_visible_"]}',
                            p_sql       => 'select rownum, a.id as id,a.root_id as root_id,a.type_ as type_,a.name_ as name_,a.default_value as default_value,a.label_caption as label_caption,a.width_ as width_,a.font_size as font_size,a.font_color as font_color,a.background_color as background_color,a.enabled_ as enabled_,a.visible_ as visible_,
                                                a.hint as hint,a.sort_ as sort_,a.onclick as onclick,a.onkeypress as onkeypress,a.required as required,a.onchange as onchange,a.ds_proc as ds_proc, a.top_ as top_, a.upd_enabled_ as upd_enabled_,a.upd_visible_ as upd_visible_
                            from (select id,root_id,type_,name_,default_value,label_caption,width_,font_size,font_color,background_color,enabled_,visible_,hint,sort_,onclick,onkeypress,required,onchange,ds_proc,top_,upd_enabled_,upd_visible_ from ui_components  order by '||v_idx||' '||v_sort_order||') a');
  json_kernel.append_as_text(']}'); 
  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
    RETURN uiresp('message','ERROR',SQLERRM);
END grid_data;   

FUNCTION list_component_types RETURN tt_component_obj IS --api_component.ttvalues IS 
BEGIN
 SELECT t_component_obj(p.id,p.name,p.checked)  BULK COLLECT INTO v_res FROM (
  SELECT 'TEDIT' AS id,'TEDIT' AS NAME,'' AS checked FROM dual
  UNION ALL
  SELECT 'TCHECKBOX' AS id,'TCHECKBOX' AS NAME,''  AS checked FROM dual
  UNION ALL
  SELECT 'TCOMBOBOX' AS id,'TCOMBOBOX' AS NAME,'' AS checked FROM dual
  UNION  ALL
  SELECT 'TCHECKLISTBOX' AS id,'TCHECKLISTBOX' AS NAME,'' AS checked FROM dual
  UNION ALL 
  SELECT 'TLABEL' AS id,'TLABEL' AS NAME,'' AS checked FROM dual
  UNION ALL
  SELECT 'TMEMO' AS id,'TMEMO' AS NAME,'' AS checked FROM dual) p;
  RETURN  v_res;
END list_component_types;  

FUNCTION add RETURN CLOB IS
 v_cnt     NUMBER;
 v_root_id NUMBER;
BEGIN
  --first add form if not exist 
  SELECT COUNT(*) INTO v_cnt FROM ui_components WHERE type_='TFORM' AND upper(NAME_)=upper(api_component.getvalue('form_list'));
  IF v_cnt=0 THEN 
    INSERT INTO ui_components(id,type_,root_id,name_) 
             VALUES (ui_components_seq.nextval,'TFORM',1,upper(api_component.getvalue('form_list'))) RETURNING id INTO v_root_id;         
   ELSE
    SELECT id INTO v_root_id FROM ui_components WHERE TYPE_='TFORM' AND  upper(NAME_)=upper(api_component.getvalue('form_list'));           
  END IF;
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
                            visible_,
                            hint,
                            sort_,
                            onclick,
                            onkeypress,
                            required,
                            onchange,
                            ds_proc,
                            top_,
                            upd_enabled_,
                            upd_visible_)
               VALUES       (api_component.getvalue('id'),
                             v_root_id,
                             api_component.getvalue('type_'),
                             api_component.getvalue('name_'),
                             api_component.getvalue('default_value'),
                             api_component.getvalue('label_caption'),
                             api_component.getvalue('width_'),
                             api_component.getvalue('font_size'),
                             api_component.getvalue('font_color'),
                             api_component.getvalue('background_color'),
                             utils_pkg.bool_text_to_yn(api_component.getvalue('enabled_')),
                             utils_pkg.bool_text_to_yn(api_component.getvalue('visible_')),
                             api_component.getvalue('hint'),
                             api_component.getvalue('sort_'),
                             api_component.getvalue('onclick'),
                             api_component.getvalue('onkeypress'),
                             utils_pkg.bool_text_to_yn(api_component.getvalue('required')),
                             api_component.getvalue('onchange'),
                             api_component.getvalue('ds_proc'),
                             api_component.getvalue('top_'),
                             utils_pkg.bool_text_to_yn(api_component.getvalue('upd_enabled_')),
                             utils_pkg.bool_text_to_yn(api_component.getvalue('upd_visible_')));
                             
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                              
                                          
END add;  

FUNCTION upd RETURN CLOB IS 
BEGIN
  UPDATE ui_components a SET a.type_=api_component.getvalue('type_'),
                             a.name_=api_component.getvalue('name_'),
                             a.default_value=api_component.getvalue('default_value'),
                             a.label_caption=api_component.getvalue('label_caption'),
                             a.width_=api_component.getvalue('width_'),
                             a.font_size=api_component.getvalue('font_size'),
                             a.font_color=api_component.getvalue('font_color'),
                             a.background_color=api_component.getvalue('background_color'),
                             a.enabled_=api_component.getvalue('enabled_'),
                             a.visible_=api_component.getvalue('visible_'),
                             a.hint=api_component.getvalue('hint'),
                             a.sort_=api_component.getvalue('sort_'),
                             a.onclick=api_component.getvalue('onclick'),
                             a.onkeypress=api_component.getvalue('onkeypress'),
                             a.required=api_component.getvalue('required'),
                             a.onchange=api_component.getvalue('onchange'),
                             a.ds_proc=api_component.getvalue('ds_proc'),
                             a.top_=api_component.getvalue('top_'),
                             a.upd_enabled_=api_component.getvalue('upd_enabled_'),
                             a.upd_visible_=api_component.getvalue('upd_visible_')
                WHERE  a.id=api_component.getvalue('id');
   COMMIT;
   RETURN uiresp('message','OK');
  EXCEPTION
    WHEN OTHERS THEN 
      ROLLBACK;
      RETURN uiresp('message','ERROR',SQLERRM);                               
END;  

FUNCTION ui_setid RETURN VARCHAR2 IS
BEGIN
  --SELECT t_component_obj('',ui_components_seq.nextval,'') BULK COLLECT INTO v_res FROM dual;
  --RETURN api_component.component_values_to_json(v_res);
  --api_component.setvalue(p_component => 'ui_menu.id',p_value=>ui_components_seq.nextval);
  --RETURN api_component.exec;
  RETURN ui_components_seq.nextval;
END ui_setid;  

FUNCTION del RETURN CLOB IS
BEGIN
  DELETE FROM ui_components a WHERE a.id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;  

begin
 NULL;
end ui_components_pkg;
/
