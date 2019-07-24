 
                                
    

alter session set nls_Language='ENGLISH';
set serveroutput on FORMAT TRUNCATED;

spool spool.txt append;



DECLARE
    
      v_my_schema VARCHAR2(50);

     
begin
-- get schema
     select sys_context('userenv','current_schema') INTO v_my_schema
     from dual;

  FOR c in (
            select event_message
          		, EVENT_TYPE
          		, (select count(*) from MIGR_API_DETAIL_LOG) row_count
         		 ,(  SELECT count(*) FROM all_OBJECTS ao WHERE object_type IN ( 'PACKAGE', 'PACKAGE BODY' )  AND status != 'VALID'  AND owner =v_my_schema) invalid
            from MIGR_API_DETAIL_LOG 
            where LOG_ID=(SELECT MAX(log_id) from MIGR_API_DETAIL_LOG)
 
  
  
  )
  loop
      if c.event_message='End of RUN_ARCHIVE_SETUP' and c.event_type='Information' and c.row_count=11 and c.invalid=0 then 
        DBMS_OUTPUT.PUT_LINE('Migration System deployment was successful!');
      else 
        DBMS_OUTPUT.PUT_LINE('Migration System deployment was not successful.'); 
        DBMS_OUTPUT.PUT_LINE('Please, send the log to NyttSakSystem.');
      end if;  
  end loop;

end;
/
spool off;
exit;
