create or replace package cs_payment_data_pkg is

  -- Author  : USER
  -- Created : 9/23/2017 12:27:15 AM
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;  
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
end cs_payment_data_pkg;
/
create or replace package body cs_payment_data_pkg is


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

END;  

FUNCTION grid_data RETURN CLOB IS
  v_idx NUMBER DEFAULT nvl(to_number(api_component.getvalue('index')),0)+1;
  v_sort_order VARCHAR2(10) DEFAULT nvl(api_component.getvalue('sort_order'),' desc');
BEGIN
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Müştəri kodu","Gəlirlər","Ödənişlər","DTİ əmsalı","Sərbəst vəsait","Müştəri kodu(Z)","Gəlirlər(Z)","Ödənişlər(Z)","DTİ əmaslı(Z)","Sərbəst vəsait(Z)"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@customer_code","@customer_incomes","@customer_payments","@customer_dti","@customer_free_resource","@borrow_code","@borrow_incomes","@borrow_payments","@borrow_dti","@borrow_free_resource"]}',
                            p_sql       => 'select rownum,
                                                a.id as id,
                                                a.customer_code as customer_code,
                                                a.customer_incomes as customer_incomes,
                                                a.customer_payments as customer_payments,
                                                a.customer_dti as customer_dti,
                                                a.customer_free_resource as customer_free_resource,
                                                a.borrow_code as borrow_code,
                                                a.borrow_incomes as borrow_incomes,
                                                a.borrow_payments as borrow_payments,
                                                a.borrow_dti as borrow_dti,
                                                a.borrow_free_resource as borrow_free_resource,
                             from (select id,customer_code,customer_incomes,customer_payments,customer_dti,customer_free_resource,
                                          borrow_code,borrow_incomes,borrow_payments,borrow_dti,borrow_free_resource
                                           from scoring.cs_payment_data order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);
END grid_data;  

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN cs_payment_data_seq.nextval;
END setid;   

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO cs_payment_data(id,
                              customer_code,
                              customer_incomes,
                              customer_payments,
                              customer_dti,
                              customer_free_resource,
                              borrow_code,
                              borrow_incomes,
                              borrow_payments,
                              borrow_dti,
                              borrow_free_resource)
                    VALUES    (api_component.getvalue('id'),
                               api_component.getvalue('customer_code'),
                               api_component.getvalue('customer_incomes'),
                               api_component.getvalue('customer_payments'),
                               api_component.getvalue('customer_dti'),
                               api_component.getvalue('customer_free_resource'),
                               api_component.getvalue('borrow_code'),
                               api_component.getvalue('borrow_incomes'),
                               api_component.getvalue('borrow_payments'),
                               api_component.getvalue('borrow_dti'),
                               api_component.getvalue('borrow_free_resource'));          
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION 
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                              
END add;  

FUNCTION upd RETURN CLOB IS
 v_id cs_payment_data.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  UPDATE cs_payment_data a SET a.customer_code=api_component.getvalue('customers_code'),
                               a.customer_incomes=api_component.getvalue('customer_incomes'),
                               a.customer_payments=api_component.getvalue('customer_payments'),
                               a.customer_dti=api_component.getvalue('customer_dti'),
                               a.customer_free_resource=api_component.getvalue('customer_free_resource'),
                               a.borrow_code=api_component.getvalue('borrow_code'),
                               a.borrow_incomes=api_component.getvalue('borrow_incomes'),
                               a.borrow_payments=api_component.getvalue('borrow_payments'),
                               a.borrow_dti=api_component.getvalue('borrow_dti'),
                               a.borrow_free_resource=api_component.getvalue('borrow_free_resource')
                 WHERE         a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION 
   WHEN OTHERS THEN
     ROLLBACK;
     RETURN UiResp('message','ERROR',SQLERRM);                                 
END upd;   

FUNCTION del RETURN CLOB IS
  v_id cs_payment_data.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  DELETE FROM cs_payment_data WHERE id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;  
begin
 NULL;
end cs_payment_data_pkg;
/
