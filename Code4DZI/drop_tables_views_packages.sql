




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


 -- Packages
    for c in (
              select object_name 
              from all_objects
              where 1=1
                and owner= v_my_schema       --'INSIS_MIGRATION_EY'
                and object_type='PACKAGE'                             
    )
    loop
      vsql:='drop package ' || v_my_schema || '.'|| c.object_name;
      --DBMS_OUTPUT.PUT_LINE(vsql);
      execute immediate vsql;
    end loop;

	DBMS_OUTPUT.PUT_LINE('Packages Dropped');


 -- Views

     for c in (
              select VIEW_NAME 
              from ALL_VIEWS av
              where 1=1
                and owner= v_my_schema  --'INSIS_MIGRATION_EY'
    )
    loop
        vsql:='drop view ' || c.VIEW_NAME;
        --DBMS_OUTPUT.PUT_LINE(vsql);
        execute immediate vsql;
    end loop;

	DBMS_OUTPUT.PUT_LINE('Views Dropped');

  -- Tables

     for c in (
              select table_name 
              from all_all_tables
              where 1=1
                and owner= v_my_schema    --'INSIS_MIGRATION_EY'
                and (table_name like('ETL_%')                  
                     OR table_name like('HST_%')
                     OR table_name like('IA_%')
                     OR table_name like('SA_%')
                     OR (table_name like('LA_%') AND table_name not like '%_LOAD')
                     OR table_name like('MIG_%')
                      OR table_name like('RLG_%')
		              	OR table_name ='MIGR_SRV_EVENT_LIST'
                                              )
                
    )
    loop
      vsql:='drop table '||CHR(34) || c.table_name || CHR(34);
      --DBMS_OUTPUT.PUT_LINE(vsql);
        begin
           execute immediate vsql;
           exception 
				when others then
					DBMS_OUTPUT.PUT_LINE('Failed to drop table '||c.table_name||'. Error:'||SQLERRM);
        end;
    end loop;

	DBMS_OUTPUT.PUT_LINE('Tables Dropped');

  -- Synonyms

    for c in (
              select synonym_name 
              from ALL_SYNONYMS as1
              where 1=1
                and owner= v_my_schema  --'INSIS_MIGRATION_EY'
    )
    loop
      vsql:='drop SYNONYM ' || c.synonym_name;
      --DBMS_OUTPUT.PUT_LINE(vsql);
      execute immediate vsql;
    end loop;


	DBMS_OUTPUT.PUT_LINE('Synonyms Dropped');

  -- sequences

    for c in (
              select sequence_name 
              from ALL_SEQUENCES 
              where 1=1
                and sequence_owner= v_my_schema  --'INSIS_MIGRATION_EY'
    )
    loop
      vsql:='drop sequence ' || c.sequence_name;
      --DBMS_OUTPUT.PUT_LINE(vsql);
      execute immediate vsql;
    end loop;


	DBMS_OUTPUT.PUT_LINE('Sequences Dropped');

exception when others then
	dbms_output.put_line(SQLERRM || 'vsql: ' || vsql);


end;
/
spool off;
exit;


