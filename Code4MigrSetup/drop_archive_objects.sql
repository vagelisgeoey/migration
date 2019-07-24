




----------------------------------------
-- Drop everything in archive schema
----------------------------------------

----------------------------------------

ALTER session SET NLS_LANGUAGE='ENGLISH';

set serveroutput on FORMAT TRUNCATED;

spool spool.txt append;


DECLARE 
  vsql VARCHAR2(100);


BEGIN




 -- Packages
    for c in (
              select object_name 
              from all_objects
              where 1=1
                and owner= '&1'       --'INSIS_MIGRATION_EY'
                and object_type='PACKAGE'                             
    )
    loop
      vsql:='drop package ' || c.object_name;
      --DBMS_OUTPUT.PUT_LINE(vsql);
      execute immediate vsql;
    end loop;

	DBMS_OUTPUT.PUT_LINE('Archive Schema Packages Dropped');

 -- Procedures
 --   for c in (
 --             select object_name 
 --             from all_objects
 --             where 1=1
 --               and owner= '&1'      
 --               and object_type='PROCEDURE'                             
 --   )
 --   loop
 --     vsql:='drop procedure ' || c.object_name;
 --     --DBMS_OUTPUT.PUT_LINE(vsql);
 --     execute immediate vsql;
 --   end loop;

--	DBMS_OUTPUT.PUT_LINE('Archive Schema Procedures Dropped');


 -- Views

     for c in (
              select VIEW_NAME 
              from ALL_VIEWS av
              where 1=1
                and owner= '&1'  
    )
    loop
        vsql:='drop view ' || c.VIEW_NAME;
        --DBMS_OUTPUT.PUT_LINE(vsql);
        execute immediate vsql;
    end loop;

	DBMS_OUTPUT.PUT_LINE('Archive Schema Views Dropped');

  -- Tables

     for c in (
              select table_name 
              from all_all_tables
              where 1=1
                and owner= '&1'
                              
    )
    loop
      vsql:='drop table ' || c.table_name;
      --DBMS_OUTPUT.PUT_LINE(vsql);
        execute immediate vsql;
    end loop;

	DBMS_OUTPUT.PUT_LINE('Archive Schema Tables Dropped');

  -- Synonyms

    for c in (
              select synonym_name 
              from ALL_SYNONYMS as1
              where 1=1
                and owner= '&1'
    )
    loop
      vsql:='drop SYNONYM ' || c.synonym_name;
      --DBMS_OUTPUT.PUT_LINE(vsql);
      execute immediate vsql;
    end loop;


	DBMS_OUTPUT.PUT_LINE('Archive Schema Synonyms Dropped');

  -- sequences

    for c in (
              select sequence_name 
              from ALL_SEQUENCES 
              where 1=1
                and sequence_owner= '&1'
    )
    loop
      vsql:='drop sequence ' || c.sequence_name;
      --DBMS_OUTPUT.PUT_LINE(vsql);
      execute immediate vsql;
    end loop;


	DBMS_OUTPUT.PUT_LINE('Archive Schema Sequences Dropped');

exception when others then
	dbms_output.put_line(SQLERRM || ' vsql: ' || vsql);


end;
/
spool off;
exit;


