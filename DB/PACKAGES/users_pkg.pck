create or replace package users_pkg is

  -- Author  : USER
  -- Created : 5/31/2017 8:44:23 8:44:23 
  -- Purpose : 


FUNCTION login RETURN CLOB;  
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION grid_data RETURN CLOB;  
FUNCTION test RETURN tt_component_obj;
FUNCTION test1 RETURN tt_component_obj;
FUNCTION ui_setid RETURN VARCHAR2;
FUNCTION onclick_calculate RETURN CLOB;
FUNCTION setuimenuid RETURN CLOB;
end users_pkg;
/
create or replace package body users_pkg is

--
users_row    users%ROWTYPE;

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

FUNCTION login RETURN CLOB IS
 v_wrong_attempt_count NUMBER; 
 v_blocked_time        users.email%TYPE;
 v_session             users.Session_%TYPE;
BEGIN
  IF api_component.getvalue('edlogin') IS NULL AND api_component.getvalue('edpassword') IS NULL THEN 
    RETURN uiresp('message','ERROR','Empty fields');
  END IF;
  
  SELECT * INTO users_row FROM users WHERE login=api_component.getvalue('edlogin') AND password=api_component.getvalue('edpassword');
  
  IF users_row.wrong_attempt_count>=3 THEN 
    RETURN uiresp('message','ERROR','User Locked');
  END IF;
  v_session := session_pkg.getNewSession;
  --backup  current session
  IF users_row.session_ IS NOT NULL THEN 
    INSERT INTO sessions(session_,
                         user_id,
                         session_out_time)
               VALUES    (users_row.session_,
                          users_row.id,
                          SYSDATE);          
  END IF;
  --set new session
  UPDATE users SET session_= v_session, logon_time=SYSDATE,wrong_attempt_count=0 WHERE id=users_row.id;
  COMMIT;
  RETURN  uiresp('message','OK',session_pkg.getNewSession());
 
 EXCEPTION
   WHEN no_data_found THEN 
    UPDATE users SET wrong_attempt_count=nvl(wrong_attempt_count,0)+1 
       WHERE login=users_row.login 
        AND blocked_time IS NULL RETURNING wrong_attempt_count, blocked_time 
      INTO v_wrong_attempt_count,v_blocked_time;
    IF SQL%ROWCOUNT>0 AND v_wrong_attempt_count>=3 AND v_blocked_time IS NULL THEN 
      UPDATE users SET blocked_time=SYSDATE WHERE login=users.login; 
      
    END IF;
    COMMIT;
    RETURN  uiResp('user_or_password_is_invalid','ERROR','user_or_password_is_invalid');
  WHEN OTHERS THEN 
    RETURN  uiResp('message','ERROR',SQLERRM);
    
END login;  

FUNCTION add RETURN CLOB IS
BEGIN
  IF nvl(api_component.getvalue('test1'),0)!=1 THEN 
    RETURN uiresp('message','ERROR','test 1 olmalidir');
  END IF;
  INSERT INTO users(id,
                    session_,
                    login,
                    password,
                    wrong_attempt_count,
                    blocked_time,
                    email,
                    mob_phone)
             VALUES (users_seq.nextval,
                     NULL,
                     api_component.getvalue('login'),
                     api_component.getvalue('password'),
                     0,
                     NULL,
                     api_component.getvalue('email'),
                     api_component.getvalue('mob_phone'));
  COMMIT;                          
  RETURN uiresp('message1','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END add;  

FUNCTION upd RETURN CLOB IS
BEGIN
 UPDATE users a SET a.wrong_attempt_count=CASE WHEN api_component.getvalue('users.blocked')='Y' THEN 3 ELSE 0 END, 
                    a.blocked_time=CASE WHEN api_component.getvalue('users.blocked')='Y' THEN SYSDATE ELSE NULL END,
                    a.email=api_component.getvalue('users.email'),
                    a.mob_phone=api_component.getvalue('users.mob_phone')
        WHERE    a.login=api_component.getvalue('users.login');
 COMMIT;
 RETURN uiresp('message','OK'); 
END upd;  

FUNCTION del RETURN CLOB IS
BEGIN
  DELETE FROM users WHERE login=api_component.getvalue('users.login');
  COMMIT;
  RETURN uiresp('message','OK');
END del;  


FUNCTION grid_data RETURN CLOB IS
BEGIN
  json_kernel.append_as_text('{"columns":["id","session","login","email","wrong_attempt_count","blocked_time","mob_phone","logon_time"],');
  json_kernel.append_as_text('"rows":[');
  json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@session","@login","@email","@wrong_attempt_count","@blocked_time","@mob_phone","@logon_time"]}',
                            p_sql       => 'select rownum,a.id as id,a.session_ as session,a.login as login, a.email as email,a.wrong_attempt_count as wrong_attempt_count,a.blocked_time as blocked_time,a.mob_phone as mob_phone,a.logon_time as logon_time 
                             from (select id,session_,login,email,wrong_attempt_count,blocked_time,mob_phone,to_char(logon_time,''DD-MM-YYYY HH24:MI:SS'') as logon_time from users where rownum<10 order by id asc ) a');
  json_kernel.append_as_text(']}'); 
  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
    RETURN '';
    log_pkg.add(p_log_type    => log_pkg.RESPONSE,
                p_method_name => 'users_pkg.grid_data',
                p_log_text    => NULL,
                p_log_clob    => SQLERRM);
END grid_data;  

FUNCTION test RETURN tt_component_obj IS
 --v_res api_component.ttvalues := api_component.ttvalues();
 v_res tt_component_obj := tt_component_obj();
BEGIN
  SELECT t_component_obj(id,name_,'') BULK COLLECT INTO v_res FROM ui_components;
  --set checked for id 1
  api_component.setModifyCmbChecked(v_res,1);
  RETURN  v_res;
END test;  

FUNCTION test1 RETURN tt_component_obj IS 
  --v_res  api_component.ttvalues := api_component.ttvalues();
  v_res  tt_component_obj := tt_component_obj();
BEGIN
 SELECT  t_component_obj(p.id,p.name,p.checked)  BULK COLLECT INTO v_res FROM (
  SELECT 1 AS id,'name1' AS NAME,'' AS checked FROM dual
  UNION ALL
  SELECT 2 AS id,'name2' AS NAME,'' AS checked FROM dual) p  ;
  RETURN v_res;
END test1;  

FUNCTION ui_setid RETURN VARCHAR2 IS
BEGIN
  RETURN users_seq.nextval;
END ui_setid;  

FUNCTION onclick_calculate RETURN CLOB IS
BEGIN
  --api_component.setvalue(p_component=>'users.email',p_required=>'Y');  
  --api_component.setvalue(p_component=>'users.memo_test',p_value=>'SalamAleykum');
  --api_component.setvalue(p_component=>'users.test1',p_required => 'Y');
  --api_component.setvalue(p_component=>'users.Blocked',p_required => 'Y');
  
  --RETURN api_component.exec;
  RETURN api_component.action_loadform(p_form => 'ui_menu',p_call_proc_name => 'zamir.users_pkg.setuimenuid');
END onclick_calculate;  

FUNCTION setuimenuid RETURN CLOB IS
BEGIN
  api_component.setvalue(p_component=>'users.memo_test',p_value=>api_component.getvalue('id'));
  RETURN api_component.exec;
END setuimenuid;  

BEGIN
NULL;  
end users_pkg;
/
