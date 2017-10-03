create or replace package questions_params_pkg is

  -- Author  : USER
  -- Created : 9/12/2017 2:34:07 PM
  -- Purpose : 
FUNCTION getQuestionsId(p_questions_params_id questions_params.id%TYPE) RETURN questions.id%TYPE;  
FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;  
FUNCTION onchange RETURN CLOB;
FUNCTION showScore RETURN CLOB;
end questions_params_pkg;
/
create or replace package body questions_params_pkg IS

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

FUNCTION getQuestionsId(p_questions_params_id questions_params.id%TYPE) RETURN questions.id%TYPE IS
 v_res questions.id%TYPE;
BEGIN
  SELECT id INTO v_res FROM questions a WHERE a.id=(SELECT b.questions_id FROM questions_params b WHERE b.id=p_questions_params_id); 
  RETURN v_res;
END getQuestionsId;  

FUNCTION grid_data RETURN CLOB IS
  v_idx NUMBER DEFAULT nvl(to_number(api_component.getvalue('index')),0)+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
BEGIN
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Kategoriya","Bölmə","Sual","Cavablar","Bal"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@cat_name","@sec_name","@questions","@name","@spec_w"]}',
                            p_sql       => 'select rownum,a.id as id,a.cat_name as cat_name,a.sec_name as sec_name,a.q_name as questions,a.name as name,a.spec_w as spec_w 
                             from (select a.id,d.name as cat_name,c.name as sec_name,b.name as q_name,a.name,a.spec_w from scoring.questions_params a, scoring.questions b,scoring.sections c,scoring.categories d where a.questions_id=b.id and b.sections_id=c.id and c.categories_id=d.id order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);  
END grid_data; 

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN questions_params_seq.nextval;
END setid;  

FUNCTION add RETURN CLOB IS
BEGIN
  IF questions_pkg.READ(api_component.getvalue('questions_id')).answer_as_list='N' AND zamir.utils_pkg.is_num_interval(api_component.getvalue('name'))=FALSE THEN 
     RETURN uiresp('message','ERROR','Ad interval olmalıdır');
  END IF;
  INSERT INTO questions_params(id,
                               questions_id,
                               name,
                               spec_w)
                               
                       VALUES  (api_component.getvalue('id'),
                                api_component.getvalue('questions_id'),
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
  IF questions_pkg.READ(api_component.getvalue('questions_id')).answer_as_list='N' AND zamir.utils_pkg.is_num_interval(api_component.getvalue('name'))=FALSE THEN 
     RETURN uiresp('message','ERROR','Ad interval olmalıdır');
  END IF;
  UPDATE questions_params a SET a.questions_id=api_component.getvalue('questions_id'),
                                a.name=api_component.getvalue('name'),
                                a.spec_w=api_component.getvalue('spec_w')
                       WHERE    a.id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                               
END upd;  

FUNCTION del RETURN CLOB IS
BEGIN
  DELETE FROM questions_params WHERE id=api_component.getvalue('id');
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;

FUNCTION onchange RETURN CLOB IS
  v_cat                 NUMBER DEFAULT 0;
  v_sec                 NUMBER DEFAULT 0;
  v_que                 NUMBER DEFAULT 0;
  v_qa                  NUMBER DEFAULT 0;
  v_sb                  NUMBER DEFAULT 0;
  v_curr                NUMBER DEFAULT 0;
  v_questions_id        questions.id%TYPE DEFAULT api_component.getvalue('questions');
  v_questions_params_id questions_params.id%TYPE DEFAULT api_component.getvalue('questions_params');
  v_client_id           zamir.users.id%TYPE DEFAULT api_component.getvalue('client_id');
  v_user_id             NUMBER DEFAULT zamir.users_pkg.getid(hub.getSession);
  v_append_value        NUMBER DEFAULT api_component.getvalue('append_value');
  v_interval_1          NUMBER;
  v_interval_2          NUMBER;
  v_interval_found  BOOLEAN DEFAULT FALSE;
BEGIN
  IF questions_pkg.READ(v_questions_id).answer_as_list='N' THEN 
     FOR i IN (SELECT id,NAME FROM questions_params a WHERE a.questions_id=v_questions_id) LOOP
       IF v_append_value >= substr(i.name,1,instr(i.name,'-')-1) AND v_append_value <= substr(i.name,instr(i.name,'-')+1,length(i.name)) THEN 
          v_questions_params_id := i.id;
          v_interval_found := TRUE;
          EXIT; 
       END IF;   
     END LOOP;
  END IF; 
  IF v_interval_found = FALSE AND questions_pkg.READ(v_questions_id).answer_as_list='N' THEN 
     RETURN uiresp('message','ERROR','Heçbir məlumat daxil edilməyib və ya daxil edilən məlumat interval aralığlarında deyildir.');
  END IF;
  --Eger el ile melumat daxil edilmeyibse onda bu haqda melumat qaytar
  IF v_questions_params_id IS NULL THEN 
    RETURN uiresp('message','ERROR','Cavabı daxil edin');
  END IF;
  SELECT a.spec_w,b.spec_w,c.spec_w,d.spec_w
     INTO v_cat,v_sec,v_que,v_qa
   FROM categories a, sections b, questions c, questions_params d 
     WHERE a.id=b.categories_id AND b.id=c.sections_id AND c.id=d.questions_id AND d.id=v_questions_params_id ;
  
  v_sb :=((v_cat/100)*(v_sec/100)*(v_que/100)*(v_qa/100))*100;
  

  UPDATE questions_answers a SET a.sb=v_sb, a.questions_params_id=v_questions_params_id,a.append_value=v_append_value WHERE  a.questions_id=v_questions_id AND a.client_id=v_client_id;
  IF SQL%NOTFOUND THEN   
   INSERT INTO questions_answers(user_id, questions_params_id,client_id,sb,questions_id,append_value)
           VALUES (v_user_id,v_questions_params_id,v_client_id,v_sb,v_questions_id,v_append_value);
  END IF;  

  
  COMMIT;
  
  -- SELECT SUM(sb) INTO v_curr FROM questions_answers WHERE user_id=v_user_id AND client_id=v_client_id; 
  --api_component.setvalue(p_component=>'frmscoring.score_val',p_value =>nvl(v_curr,0),p_font_color => CASE WHEN v_curr<5 THEN '$0000FF' ELSE '$008000' END);
  RETURN api_component.exec;
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);   
END onchange;    

FUNCTION showScore RETURN CLOB IS
 v_client_id NUMBER DEFAULT api_component.getvalue('client_id');
 v_res NUMBER(22,2) DEFAULT 0;
BEGIN
  SELECT SUM(sb) INTO v_res FROM questions_answers WHERE client_id=v_client_id;  
  api_component.setvalue(p_component=>'frmcustomerdetails.edscore',p_value => nvl(v_res,0));
  RETURN api_component.exec;
END showScore;  
begin
  NULL;
end questions_params_pkg;
/
