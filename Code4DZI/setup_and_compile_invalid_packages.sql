


ALTER SESSION SET NLS_LANGUAGE='ENGLISH';

set serveroutput on FORMAT TRUNCATED;


spool spool.txt append;

DECLARE
    
      v_my_schema VARCHAR2(50);

     
begin
-- get schema
     select sys_context('userenv','current_schema') INTO v_my_schema
     from dual;

--DROP existing jobs
    FOR c IN (SELECT b.job_name
              FROM ETL_JOB_CONFIGURATION a JOIN USER_SCHEDULER_JOBS b 
                ON a.JOB_NAME=b.JOB_NAME
    )
    loop
        DBMS_SCHEDULER.DROP_JOB(job_name=>c.JOB_NAME,force=>TRUE);
    END LOOP;
          


  --migration setup actions   
        MIGR_SCHEDULED_JOBS.CREATE_PROGRAM();

        MIGR_SETUP.RUN_SETUP(v_my_schema);

        DBMS_OUTPUT.put_line('Migration setup is performed.');


exception when others then
	dbms_output.put_line(SQLERRM);

END;
/

DECLARE
     
      v_my_schema VARCHAR2(50);
      l_object_type VARCHAR2(50);
      l_obj_typ2 VARCHAR2(50);
      vsql VARCHAR2(500);
begin
-- get schema
     select sys_context('userenv','current_schema') INTO v_my_schema
     from dual;
--compile INVALID objects
--    for c in ( SELECT ao.OBJECT_NAME, ao.OBJECT_TYPE
--               FROM all_OBJECTS ao
--               WHERE object_type IN ( 'PACKAGE', 'PACKAGE BODY' )
--                   AND status != 'VALID'
--                   AND owner =v_my_schema                   
--    )
--    loop
--        CASE c.object_type
--                WHEN 'PACKAGE BODY'  THEN 
--                    l_object_type := 'PACKAGE'; 
--                    l_obj_typ2 := 'BODY';
--                ELSE
--                    l_object_type := c.object_type;
--                    l_obj_typ2 := NULL;
--      END CASE;
--      vsql := 'ALTER ' || l_object_type || ' ' || v_my_schema || '.' || c.OBJECT_NAME || ' COMPILE' || ' ' || l_obj_typ2;
--      EXECUTE IMMEDIATE vsql;
--   --   DBMS_OUTPUT.PUT_LINE(vsql);
--   --   DBMS_OUTPUT.PUT_LINE(c.object_type);
--    end loop;

    DBMS_UTILITY.COMPILE_SCHEMA(UPPER(v_my_schema));

end;

/

spool off;
exit;



