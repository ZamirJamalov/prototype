create or replace package utils_pkg is

  -- Author  : USER
  -- Created : 6/16/2017 14:06:42 14:06:42 
  -- Purpose : 
  
FUNCTION asVarchar2(p_value CLOB) RETURN  VARCHAR2; 
FUNCTION bool_text_to_yn(p_value VARCHAR2) RETURN CHAR;
FUNCTION yn_to_bool(p_value VARCHAR2) RETURN BOOLEAN;
FUNCTION is_num_interval(p_value VARCHAR2) RETURN  BOOLEAN;
PROCEDURE log_point(p_text VARCHAR2);
end utils_pkg;
/
create or replace package body utils_pkg is


FUNCTION asVarchar2(p_value CLOB) RETURN  VARCHAR2 IS
BEGIN
  RETURN CAST(p_value AS VARCHAR2);
END asVarchar2;  

FUNCTION bool_text_to_yn(p_value VARCHAR2) RETURN CHAR IS
BEGIN
  IF p_value='FALSE' THEN RETURN 'N'; END IF;
  IF p_value='TRUE' THEN RETURN 'Y'; END IF;
  RETURN p_value;
END;  
FUNCTION yn_to_bool(p_value VARCHAR2) RETURN BOOLEAN IS
BEGIN
  IF upper(p_value)='Y' THEN RETURN TRUE; ELSE RETURN FALSE; END IF;
END;  

FUNCTION is_num_interval(p_value VARCHAR2) RETURN  BOOLEAN IS
 v_a VARCHAR2(50);
 v_b VARCHAR2(50);
BEGIN
  IF instr(p_value,'-')<=0 THEN 
    RETURN FALSE;
  END IF;
  v_a := substr(p_value,1,instr(p_value,'-')-1);
  v_b := substr(p_value,instr(p_value,'-')+1,length(p_value));
  v_a := v_a+v_b;
  RETURN TRUE;
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN FALSE; 
END is_num_interval;  

PROCEDURE log_point(p_text VARCHAR2) IS
BEGIN
  log_pkg.add(p_log_type    => log_pkg.RESPONSE,
              p_method_name => 'log_point',
              p_log_text    => p_text,
              p_log_clob    => NULL);
END log_point;  

begin
  NULL;
end utils_pkg;
/
