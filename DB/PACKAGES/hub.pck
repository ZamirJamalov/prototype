create or replace package hub is

  -- Author  : USER
  -- Created : 5/27/2017 17:25:52 17:25:52 
  -- Purpose : 
FUNCTION getSession RETURN VARCHAR2;
FUNCTION getMethodname RETURN VARCHAR2;
FUNCTION getJson RETURN json;  
FUNCTION run(p_json_in CLOB) RETURN CLOB;  


end hub;
/
create or replace package body hub is

g_json json;
v_session_key VARCHAR2(250) DEFAULT NULL; 
v_method_name VARCHAR2(250) DEFAULT NULL;

FUNCTION getSession RETURN VARCHAR2 IS
BEGIN
  RETURN v_session_key; 
END getSession;  

FUNCTION getMethodName RETURN VARCHAR2 IS
BEGIN
  RETURN v_method_name;
END getMethodName;  

FUNCTION getJson RETURN json IS
BEGIN
  RETURN g_json; 
END getJson;  
 
FUNCTION run(p_json_in CLOB) RETURN CLOB IS
  v_json json;
  v_res CLOB;
 
  
BEGIN
  log_pkg.setParentIdNull;
  log_pkg.add(p_log_type    => log_pkg.REQUEST,
              p_method_name => 'hub.run',
              p_log_text    => '',
              p_log_clob    => p_json_in);
  
  --set global json
  g_json := json(p_json_in);
  
  v_json := json(p_json_in);
  v_session_key := json_ext.get_string(v_json,'session_key');
  v_method_name := json_ext.get_string(v_json,'method_name');
  
  --check session is null
  IF v_session_key IS NULL AND v_method_name<>'zamir.users_pkg.login' THEN 
     RETURN object_pkg.GetResponseTop(p_message_type=>object_pkg.response_message_type_error,p_message_text =>  'session_key is null')||object_pkg.getResponseBottom; 
  END IF;
  --check session is expired  
  IF v_session_key IS NOT NULL THEN 
    IF session_pkg.isExpired(v_session_key) THEN 
      RETURN object_pkg.GetResponseTop(p_message_type=>object_pkg.response_message_type_error,p_message_text =>  'session_key expired')||object_pkg.getResponseBottom; 
    END IF;  
  END IF;
  
  --EXECUTE IMMEDIATE 'begin :1 :='||v_method_name||'(:2); end;' USING OUT v_res,p_json_in;
  EXECUTE IMMEDIATE 'begin :1 :='||v_method_name||'(); end;' USING OUT v_res;
  
  log_pkg.add(p_log_type    => log_pkg.RESPONSE,
              p_method_name => v_method_name,
              p_log_text    => '',
              p_log_clob    => v_res);

  
  --RETURN object_pkg.GetResponseTop(p_message_type=>object_pkg.response_message_type_ok,p_message_text =>  'SUCCESS')||v_res||object_pkg.getResponseBottom; 
  RETURN v_res;
 EXCEPTION
   WHEN OTHERS THEN 
     log_pkg.add(p_log_type    => log_pkg.RESPONSE,
              p_method_name => CASE WHEN v_method_name IS NULL THEN 'hub.run' ELSE v_method_name END,
              p_log_text    => SQLERRM,
              p_log_clob    => object_pkg.GetResponseTop(p_message_type => object_pkg.response_message_type_error,
                      p_message_text =>  Sqlerrm)||object_pkg.getResponseBottom);   
      RETURN  object_pkg.GetResponseTop(p_message_type => object_pkg.response_message_type_error,
                      p_message_text =>  Sqlerrm)||object_pkg.getResponseBottom;      
END run;    




begin
 NULL;
end hub;
/
