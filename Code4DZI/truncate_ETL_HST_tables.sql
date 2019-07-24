




----------------------------------------
-- Drop Packages, Tables and Views, Synonyms, Sequences
----------------------------------------

----------------------------------------

ALTER session SET NLS_LANGUAGE='ENGLISH';

set serveroutput on FORMAT TRUNCATED;

spool spool.txt append;

DECLARE 
  vsql VARCHAR2(100);
  v_my_schema VARCHAR2(50);
begin

    select sys_context('userenv','current_schema') INTO v_my_schema
    from dual;




  -- Tables

     for c in (
              select table_name 
              from all_all_tables
              where 1=1
                and owner= v_my_schema    --'INSIS_MIGRATION_EY'
                and (table_name like('ETL_%')                  
                     OR table_name like('HST_%')
                     OR table_name like('RLG_%')
		     OR table_name ='MIGR_SRV_EVENT_LIST'
		     OR table_name='MIG_PROCESS_STEPS'	
                                              )
                
    )
    loop
      vsql:='truncate table '||CHR(34) || c.table_name|| CHR(34);
      --DBMS_OUTPUT.PUT_LINE(vsql);
        execute immediate vsql;
    end loop;

	DBMS_OUTPUT.PUT_LINE('Tables Truncated');

 

exception when others then
	dbms_output.put_line(SQLERRM || 'vsql: ' || vsql);


end;
/
spool off;
exit;


