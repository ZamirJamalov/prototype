create or replace package cs_scoring_pkg is

  -- Author  : USER
  -- Created : 9/30/2017 11:48:10 PM
  -- Purpose : 
  
FUNCTION  scroring_result_approved_click RETURN CLOB; 
FUNCTION grid_data RETURN CLOB;

end cs_scoring_pkg;
/
create or replace package body cs_scoring_pkg is


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


FUNCTION  scroring_result_approved_click RETURN CLOB IS
 v_customers_row         customers%ROWTYPE DEFAULT customers_pkg.READ(api_component.getvalue('client_id'));
 v_scr_groups_id         cs_scoring.scr_groups_id%TYPE DEFAULT zamir.users_pkg.READ(p_session => hub.getSession).scr_groups_id;
 v_cnt1                  NUMBER DEFAULT 0;
 v_cnt2                  NUMBER DEFAULT 0;
 v_questions_groups_id   NUMBER DEFAULT scr_groups_pkg.getActiveGroupId(v_scr_groups_id);
BEGIN
  SELECT COUNT(*) INTO v_cnt1 FROM questions_answers a ,questions b WHERE a.questions_id=b.id AND b.scr_groups_id=v_questions_groups_id AND a.client_id=v_customers_row.code;
  SELECT COUNT(*) INTO v_cnt2 FROM questions a WHERE a.scr_groups_id=v_questions_groups_id;
  --zamir.utils_pkg.log_point(v_cnt1||' '||v_cnt2||' '||v_questions_groups_id);
  IF v_cnt2>v_cnt1 THEN 
    RETURN uiresp('message','ERROR','Bütün suallara cavab verildikdən sonra bu mümkündür');
  ELSIF v_cnt2=0 THEN 
    RETURN uiresp('message','ERROR','Suallar tapılmadı.');
  END IF;
  
  DELETE FROM cs_scoring a WHERE a.customers_id=v_customers_row.id;
  IF SQL%NOTFOUND THEN 
    INSERT INTO cs_scoring(customers_id,
                           scoring_result_approved,
                           scr_groups_id)
               VALUES      (v_customers_row.id,
                            'Y',
                            v_scr_groups_id);
  END IF;
  
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
  WHEN OTHERS THEN 
    RETURN uiresp('message','ERROR',SQLERRM);
END;  

FUNCTION grid_data RETURN CLOB IS
  v_idx NUMBER DEFAULT nvl(to_number(api_component.getvalue('index')),0)+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
  v_client_id         customers.code%TYPE DEFAULT api_component.getvalue('client_id');
  v_scr_groups_id         cs_scoring.scr_groups_id%TYPE DEFAULT zamir.users_pkg.READ(p_session => hub.getSession).scr_groups_id;
BEGIN
    json_kernel.append_as_text('{"columns":["Sual","Cavab"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@question","@answer"]}',
                            p_sql       => 'select rownum,a.question as question,a.answer as answer
                             from (SELECT b.name AS question,CASE WHEN a.append_value IS NULL THEN c.name ELSE to_char(a.append_value) END AS answer 
  FROM scoring.questions_answers a, scoring.questions b,scoring.questions_params c 
  WHERE a.questions_id=b.id AND a.questions_params_id=c.id AND a.client_id=:1 AND b.scr_groups_id IN (SELECT ID FROM scoring.scr_groups WHERE root_id=:2) order by '||v_idx||' '||v_sort_order||' ) a',bind1 => v_client_id,bind2 => v_scr_groups_id);  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);
END grid_data; 

begin
  NULL;
end cs_scoring_pkg;
/
