create or replace package questions_pkg is

  -- Author  : USER
  -- Created : 9/12/2017 2:00:51 PM
  -- Purpose : 
FUNCTION READ(p_id questions.id%TYPE) RETURN questions%ROWTYPE;
FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION questions_list_ui RETURN tt_component_obj;
FUNCTION questions_list RETURN tt_component_obj;
FUNCTION questions_list_clob RETURN CLOB;
FUNCTION onchange RETURN CLOB;
end questions_pkg;
/
create or replace package body questions_pkg IS

v_res tt_component_obj := tt_component_obj();

FUNCTION READ(p_id questions.id%TYPE) RETURN questions%ROWTYPE IS
 v_res questions%ROWTYPE;
BEGIN
  SELECT * INTO v_res FROM questions WHERE id=p_id;
  RETURN v_res;
END READ;  

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Grup adı","Kategoriya","Bölmə","Adı","Xüsusi çəki","Cavablar sıyahıda"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@group_name","@cat_name","@sec_name","@name","@spec_w","@answer_as_list"]}',
                            p_sql       => 'select rownum,a.id as id,a.group_name as group_name,a.cat_name as cat_name,a.sec_name as sec_name,a.name as name,a.spec_w as spec_w,a.answer_as_list as answer_as_list
                             from (select a.id,d.name as group_name,c.name as cat_name,b.name as sec_name,a.name,a.spec_w,a.answer_as_list
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
    RETURN uiresp('message','ERROR',SQLERRM);      
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
                        scr_groups_id,
                        answer_as_list)
                VALUES(api_component.getvalue('id'),
                       api_component.getvalue('sections_id'),
                       api_component.getvalue('name'),
                       api_component.getvalue('spec_w'),
                       api_component.getvalue('scr_groups_id'),
                       api_component.getvalue('answer_as_list'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                        
END add;  

FUNCTION upd RETURN CLOB IS 
  v_id NUMBER DEFAULT api_component.getvalue('id');
BEGIN
  IF api_component.getvalue('answer_as_list')='N' THEN 
   FOR i IN (SELECT a.questions_id,a.name FROM questions_params a WHERE a.questions_id=v_id) LOOP
    IF zamir.utils_pkg.is_num_interval(i.name)=FALSE THEN 
     RETURN uiresp('message','ERROR','Sualın cavabı və ya cavabları interval tipinə uyğun deyil.');
    END IF;
   END LOOP; 
  END IF; 
  UPDATE questions a SET a.sections_id=api_component.getvalue('sections_id'),
                         a.name=api_component.getvalue('name'),
                         a.spec_w=api_component.getvalue('spec_w'),
                         a.scr_groups_id=api_component.getvalue('scr_groups_id'),
                         a.answer_as_list=api_component.getvalue('answer_as_list')
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

FUNCTION questions_list_ui RETURN tt_component_obj IS 
BEGIN
  SELECT t_component_obj(id,NAME,'') BULK COLLECT INTO v_res FROM questions;
  RETURN v_res;
END questions_list_ui;  

FUNCTION questions_list RETURN tt_component_obj IS
BEGIN
  SELECT t_component_obj(a.id,a.NAME,CASE WHEN b.client_id IS NOT NULL THEN a.sort_ ELSE NULL END) BULK COLLECT INTO v_res FROM questions a LEFT JOIN questions_answers b ON a.id=b.questions_id  WHERE EXISTS (SELECT 1 FROM questions_params b WHERE a.id=b.questions_id);
  RETURN v_res;
END questions_list;  

FUNCTION questions_list_clob RETURN CLOB IS
 v_client_id NUMBER DEFAULT api_component.getvalue('client_id');
 v_clob CLOB;
 v_active_group_id NUMBER DEFAULT scr_groups_pkg.getActiveGroupId(zamir.users_pkg.READ(hub.getSession).scr_groups_id);
BEGIN
 -- RETURN api_component.exec(p_ds_proc=>'scoring.questions_pkg.questions_list',p_value=>'');
 SELECT t_component_obj(a.id,a.NAME,CASE WHEN b.client_id IS NOT NULL THEN rownum ELSE NULL END) BULK COLLECT INTO v_res 
   FROM questions a LEFT JOIN questions_answers b
     ON a.id=b.questions_id  
     AND b.client_id=v_client_id
      WHERE EXISTS (SELECT 1 FROM questions_params b WHERE a.id=b.questions_id)
      AND a.scr_groups_id=v_active_group_id;
      
  api_component.setvalue(p_component=>'frmscoring.questions', p_values=>api_component.component_values_to_json(v_res));  
  RETURN api_component.exec;  
END questions_list_clob;  

FUNCTION onchange RETURN CLOB IS 
  v_questions_id  questions_params.questions_id%TYPE DEFAULT api_component.getvalue('questions');
  v_client_id     NUMBER DEFAULT api_component.getvalue('client_id');
  v_checked       CHAR(1) DEFAULT api_component.getvalue('checked');
  v_questions_row questions%ROWTYPE DEFAULT READ(v_questions_id);
  v_append_value  questions_answers.append_value%TYPE;
  v_cnt           NUMBER DEFAULT 0;
BEGIN
  --zamir.utils_pkg.log_point(v_questions_row.scr_groups_id||' '||v_client_id||' '||scr_groups_pkg.getParentRoot(v_questions_id)||' '||v_questions_id);
  IF v_checked='N' THEN 
     SELECT COUNT(*) INTO v_cnt FROM cs_scoring a ,customers b
            WHERE a.customers_id=b.id 
             AND b.code=v_client_id AND a.scr_groups_id=scr_groups_pkg.getParentRoot(v_questions_row.scr_groups_id); 
    IF v_cnt>0 THEN 
       RETURN uiresp('message','ERROR','Nəticələr təstiqlənmişdir. Dəyişmək mümkün deyildir');
    END IF;
     DELETE FROM questions_answers a WHERE a.client_id=v_client_id AND a.questions_id=v_questions_id;
     COMMIT;
  END IF;
  IF READ(v_questions_id).answer_as_list='Y' THEN
     SELECT t_component_obj(nvl(a.ID,0),a.NAME,CASE WHEN b.questions_params_id IS NOT NULL THEN rownum ELSE NULL END) 
        BULK COLLECT INTO v_res FROM questions_params a LEFT JOIN questions_answers b 
          ON a.questions_id=b.questions_id AND a.id=b.questions_params_id AND b.client_id=v_client_id
              WHERE a.questions_id=v_questions_id; 
     api_component.setvalue(p_component=>'frmscoring.questions_params',p_values=>api_component.component_values_to_json(v_res),p_visible => 'Y',p_enabled => CASE WHEN v_checked='N' THEN 'Y' ELSE 'N' END);
     api_component.setvalue(p_component=>'frmscoring.edquestions_params',p_visible=>'N');
     api_component.setvalue(p_component=>'frmscoring.label2',p_value=>'Cavabı seçiniz');
  ELSE
    BEGIN 
      SELECT b.append_value INTO v_append_value FROM questions_answers b WHERE b.client_id=v_client_id AND  b.questions_id=v_questions_id; 
     EXCEPTION
       WHEN no_data_found THEN 
         v_append_value := NULL;
    END; 
     api_component.setvalue(p_component=>'frmscoring.edquestions_params',p_value=>v_append_value,p_visible => 'Y',p_enabled => CASE WHEN v_checked='N' THEN 'Y' ELSE 'N' END);
     api_component.setvalue(p_component=>'frmscoring.questions_params',p_visible => 'N');
     api_component.setvalue(p_component=>'frmscoring.label2',p_value=>'Cavabı daxil ediniz');
  END IF;   
  
  RETURN api_component.exec; 
END onchange;  

begin
 NULL;
end questions_pkg;
/
