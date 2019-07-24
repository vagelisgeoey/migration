
ALTER SESSION SET NLS_LANGUAGE='ENGLISH';

set serveroutput on FORMAT TRUNCATED;


spool spool.txt append;

DECLARE
      v_archive_schema VARCHAR2(50);

BEGIN

    --update with current archive schema
    update etl_setup_info set ARCHIVE_SCHEMA='&1';

    SELECT ARCHIVE_SCHEMA INTO v_archive_schema FROM ETL_SETUP_INFO;

    IF v_archive_schema IS NOT NULL THEN

        MIGR_ARCHIVE.RUN_SETUP_ARCHIVE(v_archive_schema);

    END IF;

EXCEPTION WHEN OTHERS THEN  
  dbms_output.put_line(SQLERRM);
END;
/

DECLARE
     
      v_my_schema VARCHAR2(50);
    
begin


  -- get schema
  select sys_context('userenv','current_schema') INTO v_my_schema from dual;

  DBMS_UTILITY.COMPILE_SCHEMA(UPPER(v_my_schema));



EXCEPTION WHEN OTHERS THEN 
    dbms_output.put_line(SQLERRM);
END;
/

spool off;
exit;