PL/SQL Developer Test script 3.0
45
declare

   plsql_block VARCHAR2(1000);
   l_old_name varchar2(50);
   l_new_name varchar2(50);
   l_clob clob;
   l_cnt number;
begin

 plsql_block := 'declare
  old_name VARCHAR2(50);
  new_name VARCHAR2(50);           
  ddl clob;
  ddl_body clob;
  begin
     old_name:=:l_old_name;
    new_name:=:l_new_name;
    ddl := dbms_metadata.get_ddl
      (object_type => ''PACKAGE_SPEC''
      ,name => old_name
      );
     
    ddl := REPLACE(UPPER(ddl), UPPER(old_name), UPPER(new_name));

    ddl_body := dbms_metadata.get_ddl
      (object_type => ''PACKAGE_BODY''
      ,name => old_name);
    ddl_body := REPLACE(ddl_body, UPPER(old_name), UPPER(new_name));
    
    EXECUTE IMMEDIATE ddl;
    EXECUTE IMMEDIATE ddl_body;
  end;';

  l_old_name := 'PKG_HEALTHCHECK_HC'; --------- PROVIDE PACAKGE NAME
  l_new_name := l_old_name||'_'||to_char(sysdate,'YYMMDD');
   
  select count(1) into l_cnt from user_objects where object_name=l_old_name;  

  if(l_cnt>0) then
    EXECUTE IMMEDIATE plsql_block USING l_old_name, l_new_name;
  end if;

commit;
end;
/
0
0
