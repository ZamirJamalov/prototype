create or replace package object_pkg is

  -- Author  : USER
  -- Created : 5/23/2017 20:33:35 20:33:35 
  -- Purpose : 
  

 Edit       CONSTANT VARCHAR2(10) := 'Edit';
 ComboBox   CONSTANT VARCHAR2(10) := 'ComboBox';
 ListBox    CONSTANT VARCHAR2(10) := 'ListBox';
 StringGrid CONSTANT VARCHAR2(10) := 'StringGrid';
 Memo       CONSTANT VARCHAR2(10) := 'Memo';
 Label      CONSTANT VARCHAR2(10) := 'Label';
 Button     CONSTANT VARCHAR2(10) := 'Button';
 CheckBox   CONSTANT VARCHAR2(10) := 'CheckBox';
  
 enable_yes CONSTANT CHAR(1)      := 'Y';
 enable_no  CONSTANT CHAR(1)      := 'N';

TYPE TTValueType IS RECORD(
asNumber     NUMBER,
asVarchar2   VARCHAR2(32767),
asBoolean    BOOLEAN,
asClob       CLOB);
 
TYPE TTComponent IS record(
 TYPE        VARCHAR2(100),
 NAME        VARCHAR2(100),
 caption     VARCHAR2(100),
 hint        VARCHAR2(4000),
 ENABLE      CHAR(1),
 value_id    VARCHAR2(100),
 val         CLOB,
 required     CHAR(1),
 VALUE       ttvaluetype);
 
 

  
 
TYPE TTComponents IS TABLE OF TTComponent;  
TYPE tttcomponents IS TABLE OF ui_components%ROWTYPE;



TYPE TTForm IS record(
 NAME       VARCHAR2(100),
 caption    VARCHAR2(100),
 components TTComponents);


response_message_type_error CONSTANT VARCHAR2(10) := 'ERROR';
response_message_type_ok    CONSTANT VARCHAR2(10) := 'OK';

FUNCTION uiResp(p_coll tttcomponents,p_message_type VARCHAR2, p_message_text VARCHAR2) RETURN CLOB ;
PROCEDURE initSetComponentParamValues; 
PROCEDURE freeClobComponentParamValues;
PROCEDURE initSetComponentParams; 
PROCEDURE freeClobComponentParams;
FUNCTION  getClobComponentParams RETURN CLOB;
FUNCTION  getComponentParamValues RETURN CLOB;
PROCEDURE setComponentParams(component ttcomponent);
PROCEDURE setComponentParams(component tttcomponents);
FUNCTION  colltComponents(p_tform VARCHAR2) RETURN tttcomponents;
PROCEDURE  modifyColltComponents(p_coll IN OUT tttcomponents,
                                p_name ui_components.name_%TYPE,
                                p_default_value ui_components.default_value%TYPE DEFAULT NULL,
                                p_font_color ui_components.font_color%TYPE DEFAULT NULL,
                                p_background_color ui_components.background_color%TYPE DEFAULT NULL,
                                p_enabled ui_components.enabled_%TYPE DEFAULT NULL,
                                p_visible ui_components.visible_%TYPE DEFAULT NULL,
                                p_hint ui_components.hint%TYPE DEFAULT NULL) ;
FUNCTION  GetResponseTop(p_message_type VARCHAR2,p_message_text VARCHAR2) RETURN VARCHAR2;
FUNCTION  getResponseBottom RETURN VARCHAR2;
end object_pkg;
/
create or replace package body object_pkg is

clobComponentParamValues CLOB;
clobComponentParams CLOB;
n INTEGER :=1;

FUNCTION add_comma RETURN VARCHAR2 IS
BEGIN
  RETURN CASE WHEN n>1 THEN ',' ELSE NULL END ;
END add_comma;  

FUNCTION uiResp(p_coll tttcomponents, p_message_type VARCHAR2, p_message_text VARCHAR2) RETURN CLOB IS
BEGIN
 object_pkg.setComponentParams(p_coll);
 RETURN object_pkg.GetResponseTop(p_message_type,p_message_text)||object_pkg.getClobComponentParams||object_pkg.getResponseBottom;
END uiResp;  

PROCEDURE initSetComponentParamValues IS
BEGIN
  dbms_lob.createtemporary(clobComponentParamValues,TRUE); 
END initSetComponentParamValues;  

PROCEDURE freeClobComponentParamValues IS
BEGIN
  dbms_lob.freetemporary(clobComponentParamValues);
END freeClobComponentParamValues;

PROCEDURE initSetComponentParams IS
BEGIN
  dbms_lob.createtemporary(clobComponentParams,TRUE); 
END initSetComponentParams;  

PROCEDURE freeClobComponentParams IS
BEGIN
  dbms_lob.freetemporary(clobComponentParams);
END freeClobComponentParams;  

FUNCTION  getClobComponentParams RETURN CLOB IS
 v_clob CLOB;
BEGIN
  v_clob := clobComponentParams;
  dbms_lob.freetemporary(clobComponentParams);
  n := 1;
  RETURN v_clob;
END getClobComponentParams;



FUNCTION getComponentParamValues RETURN CLOB IS
BEGIN
 RETURN '{"index":"@list_index","value_id":"@value_id","value":"@value"}';
END getComponentParamValues;  

PROCEDURE setComponentParams(component ttcomponent) IS
BEGIN
  
  dbms_lob.append(clobComponentParams,add_comma||'{"type":"'||component.type||'","name":"'||component.NAME||'","caption":"'||component.caption||'","hint":"'||component.hint||'","enable":"'||component.ENABLE||'","values":['||component.val||']}');
  n := n + 1;
END setComponentParams;  

PROCEDURE setComponentParams(component tttcomponents) IS
BEGIN
 IF component.count>0 THEN 
  FOR i IN 1..component.count LOOP 
    dbms_output.put_line(component(i).hint); 
    dbms_lob.append(clobComponentParams,add_comma||'{"type":"'||component(i).type_||'","name":"'||component(i).NAME_||'","caption":"'||component(i).label_caption||'","hint":"'||component(i).hint||'","enable":"'||component(i).enabled_||'","values":['||component(i).default_value||'],"required":"'||component(i).required||'"}');
    n := n + 1;
  END LOOP;
 END IF;    
END setComponentParams;   



FUNCTION  colltComponents(p_tform VARCHAR2) RETURN tttcomponents IS
 v_row ui_components%ROWTYPE;
 tttcomponents_ tttcomponents := tttcomponents();
BEGIN
  SELECT *  BULK COLLECT INTO tttcomponents_ FROM ui_components WHERE root_id=(SELECT id FROM ui_components WHERE type_='TFORM' AND lower(NAME_)=lower(p_tform));
  RETURN tttcomponents_;
END colltComponents;  

PROCEDURE modifyColltComponents(p_coll IN OUT tttcomponents,
                               p_name ui_components.name_%TYPE,
                               p_default_value ui_components.default_value%TYPE DEFAULT NULL,
                               p_font_color ui_components.font_color%TYPE DEFAULT NULL,
                               p_background_color ui_components.background_color%TYPE DEFAULT NULL,
                               p_enabled ui_components.enabled_%TYPE DEFAULT NULL,
                               p_visible ui_components.visible_%TYPE DEFAULT NULL,
                               p_hint ui_components.hint%TYPE DEFAULT NULL) IS
bb tttcomponents;
BEGIN
  bb :=p_coll;
  FOR i IN 1..p_coll.count LOOP
    IF lower(p_coll(i).name_)=lower(p_name) THEN 
      IF p_default_value IS NOT NULL THEN bb(i).default_value :=p_default_value; END IF;
      IF p_font_color IS NOT NULL THEN bb(i).font_color := p_font_color; END IF;
      IF p_background_color IS NOT NULL THEN bb(i).background_color := p_background_color; END IF;
      IF p_enabled IS NOT NULL THEN bb(i).enabled_ := p_enabled; END IF;
      IF p_visible IS NOT NULL THEN bb(i).visible_ := p_visible; END IF;
      IF p_hint IS NOT NULL THEN bb(i).hint := p_hint; dbms_output.put_line(bb(i).hint); END IF;
      p_coll := bb;
      EXIT;
      
    END IF;   
  END LOOP;
END modifyColltComponents;  

FUNCTION  GetResponseTop(p_message_type VARCHAR2,p_message_text VARCHAR2) RETURN VARCHAR2 IS
BEGIN
 RETURN '{"Response":{"Message" :{"Status":"'||p_message_type||'","Text":"'||p_message_text||'"},"Components":['; 
END GetResponseTop;  

FUNCTION  getResponseBottom RETURN VARCHAR2 IS
BEGIN
  RETURN ']}}';
END getResponseBottom;  

begin
 NULL;
end object_pkg;
/
