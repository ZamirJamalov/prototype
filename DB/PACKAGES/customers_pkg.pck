create or replace package customers_pkg is

  -- Author  : USER
  -- Created : 9/21/2017 4:15:48 PM
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
end customers_pkg;
/
create or replace package body customers_pkg is

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

FUNCTION grid_data RETURN CLOB IS
  v_idx NUMBER DEFAULT nvl(to_number(api_component.getvalue('index')),0)+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
BEGIN
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Müştəri kodu","SAA","Sənəd seriya","Mobil tel","Doğum tarixi"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@code","@name","@document_no","@phone_number","@birthdate"]}',
                            p_sql       => 'select rownum,a.id as id,a.code as code,a.name as name,a.document_no as document_no,a.phone_number as phone_number,a.birthdate as birthdate 
                             from (select id,code,name,document_no,phone_number,birthdate from scoring.customers order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);
END grid_data; 
 
FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN customers_seq.nextval;
END setid;  

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO customers(code,
                        name,
                        document_no,
                        phone_number,
                        birthdate,
                        id)
           VALUES      (api_component.getvalue('code'),
                        api_component.getvalue('name'),
                        api_component.getvalue('document_no'),
                        api_component.getvalue('phone_number'),
                        api_component.getvalue('birthdate'),
                        api_component.getvalue('id'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                                       
END add;  

FUNCTION upd RETURN CLOB IS
  v_id customers.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  UPDATE customers a SET a.code=api_component.getvalue('code'),
                     a.name=api_component.getvalue('name'),
                     a.document_no=api_component.getvalue('document_no'),
                     a.phone_number=api_component.getvalue('phone_number'),
                     a.birthdate=api_component.getvalue('birthdate')
     WHERE           a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);
END upd;  

FUNCTION del RETURN CLOB IS 
  v_id customers.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  DELETE FROM customers WHERE id=v_id;  
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;
begin
 NULL;
end customers_pkg;
/
