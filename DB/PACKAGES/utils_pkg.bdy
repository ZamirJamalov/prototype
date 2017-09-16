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

begin
  NULL;
end utils_pkg;
/
