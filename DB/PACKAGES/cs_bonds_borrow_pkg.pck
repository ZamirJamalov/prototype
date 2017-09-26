create or replace package cs_bonds_borrow_pkg is

  -- Author  : USER
  -- Created : 9/23/2017 1:31:04 PM
  -- Purpose : 
  
FUNCTION grid_data RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;    

end cs_bonds_borrow_pkg;
/
create or replace package body cs_bonds_borrow_pkg is

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Müştəri kodu","Kredit No","İlkin məbləğ","Qalıq borc","Annuitet","Bağlanma"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@customer_code","@credit_no","@initial_amount","@remaining_debt","@annuity","@closed"]}',
                            p_sql       => 'select rownum,a.id as id,a.customer_code as customer_code,a.credit_no as credit_no,a.initial_amount as initial_amount,a.remaining_debt as remaining_debt,a.annuity as annuity, a.closed as closed
                             from (select id,customer_code,credit_no,initial_amount,remaining_debt,annuity,case closed when ''Y'' then ''Bəli'' else ''Xeyr'' end as closed from scoring.cs_bonds_borrow order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);
END grid_data;    
 
FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN cs_bonds_borrow_seq.nextval;
END setid; 

FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO cs_bonds_borrow(id,
                                customer_code,
                                credit_no,
                                initial_amount,
                                remaining_debt,
                                annuity,
                                closed)
                      VALUES    (api_component.getvalue('id'),
                                 api_component.getvalue('customer_code'),
                                 api_component.getvalue('credit_no'),
                                 api_component.getvalue('initial_amount'),
                                 api_component.getvalue('remaining_debt'),
                                 api_component.getvalue('annuity'),
                                 api_component.getvalue('closed'));
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                                            
END add;  

FUNCTION upd RETURN CLOB IS 
  v_id cs_bonds_borrow.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  UPDATE cs_bonds_borrow a SET a.customer_code=api_component.getvalue('customer_code'),
                                 a.credit_no=api_component.getvalue('credit_no'),
                                 a.initial_amount=api_component.getvalue('initial_amount'),
                                 a.remaining_debt=api_component.getvalue('remaining_debt'),
                                 a.annuity=api_component.getvalue('annuity'),
                                 a.closed=api_component.getvalue('closed')
                     WHERE       a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);                                   
END upd;  

FUNCTION del RETURN CLOB IS
  v_id cs_bonds_borrow.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  DELETE FROM cs_bonds_borrow WHERE id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM); 
END del;  

begin
 NULL;
end cs_bonds_borrow_pkg;
/
