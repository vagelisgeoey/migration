---
-- +++ anb 2017-09-08 : Verify new Schema

-- run as sys
ALTER SESSION SET NLS_LANGUAGE = 'ENGLISH';
set serveroutput on FORMAT TRUNCATED;

set errorlogging on;


spool spool.txt append;

DECLARE
  vsql VARCHAR2(4000);
  vlen	pls_integer;
  i		pls_integer;
begin 

	
	vSQL := 'SELECT SYS_context (''userenv'',''current_schema'') FROM DUAL';
	dbms_output.put_line(vsql);
	SELECT SYS_context ('userenv','current_schema')  into vSQL
	FROM DUAL;
	dbms_output.put_line(vsql);
exception when others then
	dbms_output.put_line(SQLERRM || 'vsql: ' || vsql);
	
end;
/
spool off;
exit ;

     
