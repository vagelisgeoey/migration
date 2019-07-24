

SET TERMOUT off;

spool rec_count.txt;

SELECT 'ETL_SETUP_INFO has ' || count(*) || ' rows' as cnt FROM &1..ETL_SETUP_INFO;
		   

spool off;
exit;