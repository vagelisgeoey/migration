
alter session set nls_Language='ENGLISH';



set serveroutput on FORMAT TRUNCATED;

spool spool.txt append;

create OR REPLACE directory MIGR_INST_DIR as '&1';
GRANT all on directory MIGR_INST_DIR to &2;

spool off;

exit;