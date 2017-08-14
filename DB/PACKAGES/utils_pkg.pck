create or replace package utils_pkg is

  -- Author  : USER
  -- Created : 6/16/2017 14:06:42 14:06:42 
  -- Purpose : 
  
FUNCTION asVarchar2(p_value CLOB) RETURN  VARCHAR2; 
FUNCTION bool_text_to_yn(p_value VARCHAR2) RETURN CHAR;
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
END;  

begin
  NULL;
end utils_pkg;
/
