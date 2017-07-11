create or replace package json_kernel is

  -- Author  : ZAMIR
  -- Created : 11/2/2016 8:09:56 8:09:56 
  -- Purpose : 

function  prepare_json_sql(p_json varchar2, p_sql varchar2) return varchar2; 
function  json_part(p_part_name varchar2,p_json varchar2) return varchar2;
function  response return CLOB;
FUNCTION  responseClob RETURN CLOB; 
function  response_tvarchar2 return varchar2;
function  as_string(p_string varchar2) return varchar2;
procedure initialize;
procedure append_as_text(p_string varchar2);
procedure append_as_sql(p_json_part varchar2,p_sql VARCHAR2,
                        bind1 IN  VARCHAR2 DEFAULT 987654321,
                        bind2 IN  VARCHAR2 DEFAULT 987654321,
                        bind3 IN  VARCHAR2 DEFAULT 987654321,
                        bind4 IN  VARCHAR2 DEFAULT 987654321,
                        bind5 IN  VARCHAR2 DEFAULT 987654321,
                        bind6 IN  VARCHAR2 DEFAULT 987654321,
                        bind7 IN  VARCHAR2 DEFAULT 987654321,
                        bind8 IN  VARCHAR2 DEFAULT 987654321,
                        bind9 IN  VARCHAR2 DEFAULT 987654321,
                       bind10 IN  VARCHAR2 DEFAULT 987654321 
                       );
end json_kernel;
/
create or replace package body json_kernel is

v_main_json_clob   clob;
type ttmainjson is table of varchar2(32767) index by pls_integer;
tmainjson ttmainjson;

initialized BOOLEAN DEFAULT FALSE;

FUNCTION exists_where(p_sql VARCHAR2) RETURN BOOLEAN IS
 from_bpos  NUMBER;
 where_bpos NUMBER;
BEGIN
   from_bpos  := instr(lower(p_sql),'from');
   where_bpos := instr(lower(p_sql),'where_bpos');
END exists_where;  

FUNCTION nvl1(p_var IN VARCHAR2, p_res VARCHAR2) RETURN VARCHAR2 IS
BEGIN
 IF p_var='987654321' THEN 
    RETURN p_res;
 ELSE
   RETURN NULL;
 END IF;     
END nvl1;  

function  prepare_json_sql(p_json varchar2,p_sql varchar2) return varchar2 is
 bpos            number:=1;
 epos            number;
 v1              varchar2(32000);
 n               number:=0;
 json_tag_name   varchar2(32000);
 json_tag_value  varchar2(32000);
 v_as            varchar2(100) := ' as ';
 v_sql           varchar2(32000);
 v_json varchar2(32000);
begin
 -- v_group_by :=nvl(instr(p_sql,v_group_by_,1),0);
 --v_order_by :=nvl(instr(p_sql,v_order_by_,1),0);
  --dbms_output.put_line(v_group_by);
  v_sql  := replace(p_sql,chr(13),'');
  v_sql  := replace(p_sql,chr(10),'');
  v_sql  := substr(v_sql,1,instr(lower(v_sql),' from ')-bpos);
  --dbms_output.put_line(v_sql);
  v_json := p_json;
 -- v_json := ''''||v_json;
 

  bpos := instr(v_sql,' ',1)+1;
  while bpos>0  loop
   epos := instr(v_sql,',',bpos);
   if epos>0 then
     v1 := trim(substr(v_sql,bpos,epos-bpos));
     bpos := epos+1;
   else
     v1 := trim(substr(v_sql,bpos,length(v_sql)));
     bpos:=0;
   end if;
  -- v1 := trim(both chr(13) from v1);
  if instr(lower(v1),v_as)>0 then
    json_tag_name  :=substr(v1,instr(lower(v1),v_as)+length(v_as),length(v1));
    json_tag_value :=substr(v1,1,instr(lower(v1),v_as)-1);
   else
    json_tag_name  :=v1;
    json_tag_value :=v1;
   end if;
    --dbms_output.put_line(v1);
    --dbms_output.put_line('---------');
    --dbms_output.put_line(json_tag_name);
    --dbms_output.put_line('---------');
    --dbms_output.put_line(json_tag_value);
    v_json := replace(v_json,'@'||json_tag_name,'''||'||json_tag_value||'||''');
   
    --- eger sql bosh qaytarsa onda p_json strukturunu oldufhu kimi bosh qaytarmaq 


   if n< 100 then n:=n+1 ; else exit; end if;

 end loop;
 --  v_sql:=replace(v_sql,'#13',chr(13));

  v_json := 'select '||''''||v_json||''''||'  '||substr(p_sql,instr(lower(p_sql),' from'),length(p_sql))||'';
  dbms_output.put_line(v_json);
  return v_json;

end prepare_json_sql;
 
function  json_part(p_part_name varchar2,p_json varchar2) return varchar2 is
 v_pos number;
 v_pos1 number;
 v_pos2 number;
 is_array boolean;
 function count_array_m(p_json varchar2,p_pos number) return number is
    v_count number:=0;
    v_pos   number:=0;
   begin
    if instr(p_json,'[',p_pos+1)>0 then
      v_count := v_count +1;
      --count_array_m(p_json,v_pos);
     else
       return v_count;
    end if;
   end;
begin
  v_pos :=  instr(p_json,'"'||p_part_name||'":');
  if v_pos>0 then
    v_pos1  := instr(p_json,'{',v_pos);
    v_pos2  := instr(p_json,'[',v_pos);
    if v_pos2>v_pos1 then
      is_array := true;
    end if;
  end if;

end json_part;

function response return CLOB is
begin
  dbms_lob.close(v_main_json_clob);
  --bns_debug.saveClobLog(v_main_json_clob);
  initialized :=FALSE;
  return v_main_json_clob;
 EXCEPTION
   WHEN OTHERS THEN 
     initialized := FALSE; 
end;

FUNCTION  responseClob RETURN CLOB IS
BEGIN
  return v_main_json_clob;
END;  


function response_tvarchar2 return varchar2 is
 v_text varchar2(4000);
begin
  --select dbms_lob.substr(v_main_json_clob,4000,1) into v_text from dual;
  --return v_text;
  return dbms_lob.substr(v_main_json_clob,4000,1);
end;  

function as_string(p_string varchar2) return varchar2 is
begin
  return ''''||p_string||'''';
end;

procedure initialize is
begin
 IF NOT initialized THEN 
   initialized := TRUE;
  dbms_lob.createtemporary(v_main_json_clob,true,dbms_lob.session);
  dbms_lob.open(v_main_json_clob,dbms_lob.lob_readwrite);
 END IF; 
 EXCEPTION 
   WHEN OTHERS THEN 
     initialized := FALSE;
end initialize;  

procedure append_as_text(p_string varchar2) is
begin
 initialize;
 dbms_lob.writeappend(v_main_json_clob,length(p_string),p_string);
end append_as_text;

procedure append_as_sql(p_json_part varchar2,p_sql VARCHAR2,
                        bind1 IN  VARCHAR2 DEFAULT 987654321,
                        bind2 IN  VARCHAR2 DEFAULT 987654321,
                        bind3 IN  VARCHAR2 DEFAULT 987654321,
                        bind4 IN  VARCHAR2 DEFAULT 987654321,
                        bind5 IN  VARCHAR2 DEFAULT 987654321,
                        bind6 IN  VARCHAR2 DEFAULT 987654321,
                        bind7 IN  VARCHAR2 DEFAULT 987654321,
                        bind8 IN  VARCHAR2 DEFAULT 987654321,
                        bind9 IN  VARCHAR2 DEFAULT 987654321,
                        bind10 IN VARCHAR2 DEFAULT 987654321 ) IS
  v_sql  VARCHAR2(32767);              
  a_null CHAR(1);
  f BOOLEAN := FALSE;

BEGIN
 initialize;
 tmainjson.delete();
 --v_sql := p_sql||' '||nvl1(bind1,'/*:1*/')||nvl1(bind2,'/*:2*/')||nvl1(bind3,'/*:3*/')||nvl1(bind4,'/*:4*/')||nvl1(bind5,'/*:5*/')||nvl1(bind6,'/*:6*/')||nvl1(bind7,'/*:7*/')||nvl1(bind8,'/*:8*/')||nvl1(bind9,'/*:9*/')||nvl1(bind10,'/*:10*/');
 --v_sql := p_sql ||':1'||':2'||':3'||':4'||':5'||':6'||':7'||':8'||':9'||':10';
       dbms_output.put_line(v_sql);
       dbms_output.put_line(  'select p.* from ( '||prepare_json_sql(p_json_part, p_sql)||' ) p where 1=1 ' ||
            nvl1(bind1,' and :1=987654321 ')||
            nvl1(bind2,' and :2=987654321 ')||
            nvl1(bind3,' and :3=987654321 ')||
            nvl1(bind4,' and :4=987654321 ')||
            nvl1(bind5,' and :5=987654321 ')||
            nvl1(bind6,' and :6=987654321 ')||
            nvl1(bind7,' and :7=987654321 ')||
            nvl1(bind8,' and :8=987654321 ')||
            nvl1(bind9,' and :9=987654321 ')||
            nvl1(bind10,' and :10=987654321 '));
       BEGIN
         execute immediate 
            'select p.* from ( '||prepare_json_sql(p_json_part, p_sql)||' ) p where 1=1 ' ||
            nvl1(bind1,' and :1=987654321 ')||
            nvl1(bind2,' and :2=987654321 ')||
            nvl1(bind3,' and :3=987654321 ')||
            nvl1(bind4,' and :4=987654321 ')||
            nvl1(bind5,' and :5=987654321 ')||
            nvl1(bind6,' and :6=987654321 ')||
            nvl1(bind7,' and :7=987654321 ')||
            nvl1(bind8,' and :8=987654321 ')||
            nvl1(bind9,' and :9=987654321 ')||
            nvl1(bind10,' and :10=987654321 ')
         bulk collect into tmainjson 
         USING bind1, bind2, bind3, bind4, bind5, bind6, bind7, bind8, bind9, bind10;
       END;

    
 
   
 if tmainjson.count>0 then 
   for i in tmainjson.first..tmainjson.last loop
     if i<tmainjson.last then
       dbms_lob.writeappend(v_main_json_clob,length(tmainjson(i)||','),tmainjson(i)||',');
     else
       dbms_lob.writeappend(v_main_json_clob,length(tmainjson(i)),tmainjson(i));
     end if;
   end loop;
 end if;
  tmainjson.delete();
end;

begin
 null;
end json_kernel;
/
