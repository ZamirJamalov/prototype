create or replace package scr_loans_pkg is

  -- Author  : USER
  -- Created : 9/26/2017 10:04:18 AM
  -- Purpose : 
  
  
FUNCTION grid_data RETURN CLOB;
FUNCTION add RETURN CLOB;
FUNCTION upd RETURN CLOB;
FUNCTION del RETURN CLOB;
FUNCTION setid RETURN VARCHAR2;

end scr_loans_pkg;
/
create or replace package body scr_loans_pkg is

 

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
    json_kernel.append_as_text('{"columns":["Sıra nömrəsi","Məhsul adı","Kod","Limit","Məbləğ","Valyuta","Period","Illik faiz","Kamissiya","Möhlət(Ay)","Cerime Hes","Ilkin Ödəniş","Ayliq Ödəniş","Zamin tələbi","Girov tələbi","Min bal"],');
    json_kernel.append_as_text('"rows":[');
    json_kernel.append_as_sql(p_json_part => '{"row@rownum":["@id","@loan_prod_name","@prod_code","@limit","@amount","@currency","@period","@rate_year","@commission","@grace_period","@cerime_hes","@ilkin_odenish","@ayliq_odenish","@zamin_telebi","@girov_talabi","@min_bal"]}',
                            p_sql       => 'select rownum,a.id as id,a.loan_prod_name as loan_prod_name,a.prod_code as prod_code,a.limit_ as limit,amount as amount,a.currency as currency,a.period as period,a.rate_year as rate_year,a.commission as commission,a.grace_period as grace_period,a.cerime_hes as cerime_hes,a.ilkin_odenish as ilkin_odenish,a.ayliq_odenish as ayliq_odenish,a.zamin_telebi as zamin_telebi,a.girov_talabi as girov_talabi,a.min_bal as min_bal
                             from (select a.id,b.name as loan_prod_name,a.prod_code,a.limit_,a.amount,a.currency,a.period,a.rate_year,a.commission,a.grace_period,a.cerime_hes,a.ilkin_odenish,a.ayliq_odenish,a.zamin_telebi,a.girov_talabi,a.min_bal from scoring.scr_loans a,scoring.scr_loan_prod b where a.scr_loan_prod_id=b.id order by '||v_idx||' '||v_sort_order||' ) a');  
    json_kernel.append_as_text(']}');  

  RETURN api_component.exec(p_json_part=>json_kernel.response);   
 EXCEPTION
   WHEN OTHERS THEN 
     RETURN uiresp('message','ERROR',SQLERRM);
END grid_data;  
  
FUNCTION add RETURN CLOB IS
BEGIN
  INSERT INTO scr_loans(id,
                        scr_loan_prod_id,
                        prod_code,
                        limit_,
                        amount,
                        currency,
                        period,
                        rate_year,
                        commission,
                        grace_period,
                        cerime_hes,
                        ilkin_odenish,
                        ayliq_odenish,
                        zamin_telebi,
                        girov_talabi,
                        min_bal)
             VALUES(api_component.getvalue('id'),    
                    api_component.getvalue('scr_loan_prod_id'),
                    api_component.getvalue('prod_code'),
                    api_component.getvalue('limit_'),
                    api_component.getvalue('amount'),
                    api_component.getvalue('currency'),
                    api_component.getvalue('period'),
                    api_component.getvalue('rate_year'),
                    api_component.getvalue('commission'),
                    api_component.getvalue('grace_period'),
                    api_component.getvalue('cerime_hes'),
                    api_component.getvalue('ilkin_odenish'),
                    api_component.getvalue('ayliq_odenish'),
                    api_component.getvalue('zamin_telebi'),
                    api_component.getvalue('girov_talabi'),
                    api_component.getvalue('min_bal'));
   
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);    
END add;  

FUNCTION upd RETURN CLOB IS
  v_id scr_loans.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN  
  UPDATE scr_loans a SET a.scr_loan_prod_id=api_component.getvalue('scr_loan_prod_id'),
                         a.prod_code=api_component.getvalue('prod_code'),
                         a.limit_=api_component.getvalue('limit_'),
                         a.amount=api_component.getvalue('amount'),
                         a.currency=api_component.getvalue('currency'),
                         a.period=api_component.getvalue('period'),
                         a.rate_year=api_component.getvalue('rate_year'),
                         a.commission=api_component.getvalue('commission'),
                         a.grace_period=api_component.getvalue('grace_period'),
                         a.cerime_hes=api_component.getvalue('cerime_hes'),
                         a.ilkin_odenish=api_component.getvalue('ilkin_odenish'),
                         a.ayliq_odenish=api_component.getvalue('ayliq_odenish'),
                         a.zamin_telebi=api_component.getvalue('zamin_telebi'),
                         a.girov_talabi=api_component.getvalue('girov_talabi'),
                         a.min_bal=api_component.getvalue('min_bal')
                       WHERE a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR',SQLERRM);  
END upd;

FUNCTION del RETURN CLOB IS
  v_id scr_loans.id%TYPE DEFAULT api_component.getvalue('id');
BEGIN
  DELETE FROM scr_loans a WHERE a.id=v_id;
  COMMIT;
  RETURN uiresp('message','OK');
 EXCEPTION
   WHEN OTHERS THEN 
     ROLLBACK;
     RETURN uiresp('message','ERROR');
   
END del;  

FUNCTION setid RETURN VARCHAR2 IS
BEGIN
  RETURN scr_loans_seq.nextval;
END setid;  



begin
 NULL;
end scr_loans_pkg;
/
