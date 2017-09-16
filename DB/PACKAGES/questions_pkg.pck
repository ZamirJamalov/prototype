create or replace package questions_pkg is

  -- Author  : USER
  -- Created : 9/12/2017 2:00:51 PM
  -- Purpose : 

FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION questions_list RETURN tt_component_obj;
FUNCTION questions_list_clob RETURN CLOB;
FUNCTION onchange RETURN CLOB;
end questions_pkg;
/
create or replace package body questions_pkg IS

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Grup adı","Kategoriya","Bölmə","Adı","Xüsusi çəki"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@group_name","@cat_name","@sec_name","@name","@spec_w"]}',
                            p_sql       => 'select rownum,a.id as id,a.group_name as group_name,a.cat_name as cat_name,a.sec_name as sec_name,a.name as name,a.spec_w as spec_w 
                             from (select a.id,d.name as group_name,c.name as cat_name,b.name as sec_name,a.name,a.spec_w 
                                   from scoring.questions a 
                                       left join scoring.scr_groups d 
                                    on a.scr_groups_id=d.id 
                                       inner join scoring.sections b
                                    on a.sections_id=b.id
                                       inner join scoring.categories c
                                    on b.categories_id=c.id    
                                order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                p_method_name => 'scoring.questions_pkg.grid_data',
                p_log_text    => NULL,
                p_log_clob    => SQLERRM);
     RETURN '';           
END grid_data;    

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN questions_seq.nextval;
END setid;  

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO questions(id,
                        sections_id,
                        name,
                        spec_w,
                        scr_groups_id)
                VALUES(api_component.getvalue('id'),
                       api_component.getvalue('sections_id'),
                       api_component.getvalue('name'),
                       api_component.getvalue('spec_w'),
                       api_component.getvalue('scr_groups_id'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                        
END add;  

FUNCTION upd RETURN CLOB IS 
BEGIN
  UPDATE questions a SET a.sections_id=api_component.getvalue('sections_id'),
                         a.name=api_component.getvalue('name'),
                         a.spec_w=api_component.getvalue('spec_w'),
                         a.scr_groups_id=api_component.getvalue('scr_groups_id')
                 WHERE   a.id=api_component.getvalue('id');        
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS  THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);
END upd;   

FUNCTION del RETURN CLOB IS 
BEGIN
  DELETE FROM questions WHERE id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
    ROLLBACK;
    RETURN uiresp('message','ERROR',SQLERRM);
END del;  

FUNCTION questions_list RETURN tt_component_obj IS
BEGIN
  SELECT t_component_obj(id,NAME,'') BULK COLLECT INTO v_res FROM questions a WHERE EXISTS (SELECT 1 FROM questions_params b WHERE a.id=b.questions_id);
  RETURN v_res;
END questions_list;  

FUNCTION questions_list_clob RETURN CLOB IS
BEGIN
  RETURN api_component.exec(p_ds_proc=>'scoring.questions_pkg.questions_list',p_value=>'');
END questions_list_clob;  

FUNCTION onchange RETURN CLOB IS 
  v_questions_id questions_params.questions_id%TYPE DEFAULT api_component.getvalue('questions');
BEGIN
  log_pkg.add(p_log_type    => log_pkg.RESPONSE,
              p_method_name => 'question_pkg.onchange',
              p_log_text    => 'galir'||v_questions_id,
              p_log_clob    => NULL);
  SELECT t_component_obj(nvl(ID,0),NAME,'') BULK COLLECT INTO v_res FROM questions_params WHERE questions_id=v_questions_id; --questions_id=(SELECT id FROM questions WHERE name=api_component.getvalue('questions'));
  api_component.setvalue(p_component=>'frmscoring.questions_params',p_values=>api_component.component_values_to_json(v_res));
  RETURN api_component.exec; 
END onchange;  

begin
 NULL;
end questions_pkg;
/
