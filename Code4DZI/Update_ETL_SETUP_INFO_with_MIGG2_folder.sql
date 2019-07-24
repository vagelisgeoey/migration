

alter session set nls_Language='ENGLISH';


set serveroutput on FORMAT TRUNCATED;

spool spool.txt append;


Update ETL_SETUP_INFO set MIGG_SOURCES_DIR='&1&2' || 'MIGG_SOURCES'
			,MIGG_DIR='&1'
			,MIGG_DIR_ARCHIVE='&1&2' || 'MIGG_ARCHIVE'
			,CLIENT_MIGG_DIR='&1&2' || 'MIGG_CLIENTS'
			,CLIENT_MIGG_DIR_ARC='&1&2' || 'MIGG_CLIENTS_ARCHIVE'
			,OS_SLASH='&2';
spool off;

exit;