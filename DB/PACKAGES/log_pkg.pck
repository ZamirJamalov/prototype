create or replace package log_pkg is

  -- Author  : USER
  -- Created : 5/27/2017 17:30:18 17:30:18 
  -- Purpose : 
  
REQUEST CONSTANT logs.log_type%TYPE := 'REQUEST';
RESPONSE CONSTANT logs.log_type%TYPE := 'RESPONSE';
  
PROCEDURE setParentIdNull;
PROCEDURE add(p_log_type logs.log_type%type, p_method_name logs.method_name%TYPE, p_log_text logs.log_text%TYPE, p_log_clob logs.log_clob%TYPE);   


end log_pkg;
/
create or replace package body log_pkg is

v_parent_id logs.parent_id%TYPE DEFAULT NULL;

PROCEDURE setParentIdNull IS
BEGIN
  v_parent_id := NULL;
END setParentIdNull;  

PROCEDURE add(p_log_type logs.log_type%type, p_method_name logs.method_name%TYPE, p_log_text logs.log_text%TYPE, p_log_clob logs.log_clob%TYPE) IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 INSERT INTO logs(id,
                  parent_id,
                  log_type,
                  datetime,
                  method_name,
                  log_text,
                  log_clob,
                  session_)
          VALUES  (logs_seq.nextval,
                   v_parent_id,
                   p_log_type,
                   SYSDATE,
                   p_method_name,
                   p_log_text,
                   p_log_clob,
                   hub.getSession)
                   RETURNING id INTO v_parent_id ;
 COMMIT;                   
                             
END add;  
 

begin
 v_parent_id := NULL;
end log_pkg;
/
