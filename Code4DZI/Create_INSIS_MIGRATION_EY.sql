---
-- +++ anb 2017-08-14 : Use Oracle HOME directory for tablespaces
-- +++ anb 2017-09-08 : Specify OracleHOME, ASM, or specific directory for tablespaces



-- run as sys
ALTER SESSION SET NLS_LANGUAGE = 'ENGLISH';
set serveroutput on FORMAT TRUNCATED;

spool spool.txt append;

DECLARE
  vsql 			VARCHAR2(4000);
  vfolder 		VARCHAR2(4000);	-- +++ anb 2017-08-14 : Use Oracle HOME directory or ASM for tablespaces
  vfolderTemp 	VARCHAR2(4000);	-- +++ anb 2017-08-14 : Use Oracle HOME directory or ASM for tablespaces

begin 


for c in (select tablespace_name
          from dba_tablespaces
          where tablespace_name in ('TEMPMIG01', 'INSIS_MIGR_EY')
)
  loop
      vsql:= 'drop tablespace ' || c.tablespace_name || ' INCLUDING CONTENTS CASCADE CONSTRAINTS';
      execute immediate vsql;
      dbms_output.put_line('Tablespace ' || c.tablespace_name || ' dropped!');
  end loop;

dbms_output.put_line('Start dropping users' ||'&1' ||  ' &4' );

for c in (select username
          from all_users
          where username in( '&1', '&4')
)
  loop
      vsql:= 'drop user ' || c.username || ' cascade';
      execute immediate vsql;
      dbms_output.put_line('User ' || c.username || ' dropped!');
  end loop;

 dbms_output.put_line('Create tablespace a..'); 
  
-- +++ anb 2017-08-14 : Use OracleHOME directory, ASM, or specific folder for tablespaces 
vfolder := '&3';
if ( substr(vfolder,1,10) ='OracleHome' )
	then 
				-- create temprorary tablespace  tempmig01 tempfile ''TEMPMIG01.dbf'' size 32GB
		vfolderTemp := ' TEMPFILE ''TEMPMIG01.dbf'' ';
		vFolder		:= ' datafile ''INSIS_MIGR_EY01.dbf'' ';
else 
	if (substr(vfolder,1,3) ='ASM' )
		then 
				-- create temprorary tablespace  tempmig01 add tempfile <+DATA>  size 32GB
			vfolderTemp := ' TEMPFILE ''+DATA'' ';
			vFolder 	:= ' datafile ''+DATA'' ';
	else
		-- create temprorary tablespace  tempmig01 tempfile ''&3\TEMPMIG01.dbf'' size 32GB
		vfolderTemp := ' TEMPFILE ''&3/TEMPMIG01.dbf''';
		vFolder		:= ' datafile ''&3/INSIS_MIGR_EY01.dbf''';	
	End if;
end if;	
-- +++ end anb 2017-08-14 : Use Oracle HOME directory or ASM for tablespaces

 dbms_output.put_line('Create tablespace ' || vfolderTemp ); 
--CREATE UNDO TABLESPACE UNDOMIG01 
 --|| ' TEMPFILE ''&3\TEMPMIG01.dbf'' SIZE 34359721984'   -- +++ anb 2017-08-14 : Use Oracle HOME directory for tablespaces
vsql:='CREATE TEMPORARY TABLESPACE TEMPMIG01 '
 || vfolderTemp
 || ' SIZE 34359721984 REUSE EXTENT MANAGEMENT LOCAL '; 

dbms_output.put_line(vsql); 

  execute immediate vsql;
  dbms_output.put_line('TEMPORARY TABLESPACE TEMPMIG01 is created!');
  


-- New tablespace
--  || ' DATAFILE ''&3\INSIS_MIGR_EY01.dbf'' SIZE 34359721984   REUSE'  -- +++ anb 2017-08-14 : Use Oracle HOME directory for tablespaces
vsql:='CREATE TABLESPACE INSIS_MIGR_EY '
  || vFolder
  || ' SIZE 34359721984   REUSE'
  || ' AUTOEXTEND ON NEXT 1310720 MAXSIZE 34359721984'
  || ' LOGGING ONLINE PERMANENT BLOCKSIZE 8192'
  || ' EXTENT MANAGEMENT LOCAL AUTOALLOCATE DEFAULT '
  || ' NOCOMPRESS  SEGMENT SPACE MANAGEMENT AUTO'     ;

  execute immediate vsql;
  dbms_output.put_line('TABLESPACE INSIS_MIGR_EY is created!');


-- New Schema
vsql:='CREATE USER &1'
	|| ' IDENTIFIED BY &2'
	|| ' DEFAULT TABLESPACE INSIS_MIGR_EY'
	|| ' TEMPORARY TABLESPACE TEMPMIG01'
	|| ' PROFILE "DEFAULT"'
	|| ' QUOTA UNLIMITED ON INSIS_MIGR_EY' ;
  
	execute immediate vsql;
  dbms_output.put_line('user &1 is created!');

vsql:='GRANT CREATE ANY DIRECTORY, CREATE ANY JOB, CREATE ANY PROCEDURE, CREATE ANY SYNONYM'
  || ', CREATE ANY TABLE, CREATE CREDENTIAL, CREATE EXTERNAL JOB, CREATE JOB, CREATE PROCEDURE, CREATE PUBLIC SYNONYM'
  || ', CREATE SEQUENCE, CREATE SESSION, CREATE SYNONYM, CREATE TABLE, CREATE VIEW, DEBUG ANY PROCEDURE, DEBUG CONNECT SESSION'
  || ', DROP ANY DIRECTORY, MANAGE SCHEDULER, UNLIMITED TABLESPACE, datapump_imp_full_database  '
  || ' TO &1';
execute immediate vsql;
  dbms_output.put_line('grants to user &1 are granted!');


-- New Archive Schema
vsql:='CREATE USER &4'
	|| ' IDENTIFIED BY &5'
	|| ' DEFAULT TABLESPACE INSIS_MIGR_EY'
	|| ' TEMPORARY TABLESPACE TEMPMIG01'
	|| ' PROFILE "DEFAULT"'
	|| ' QUOTA UNLIMITED ON INSIS_MIGR_EY' ;
  execute immediate vsql;
  dbms_output.put_line('user &4 is created!');

vsql:='GRANT CREATE ANY DIRECTORY, CREATE ANY JOB, CREATE ANY PROCEDURE, CREATE ANY SYNONYM'
  || ', CREATE ANY TABLE, CREATE CREDENTIAL, CREATE EXTERNAL JOB, CREATE JOB, CREATE PROCEDURE, CREATE PUBLIC SYNONYM'
  || ', CREATE SEQUENCE, CREATE SESSION, CREATE SYNONYM, CREATE TABLE, CREATE VIEW, DEBUG ANY PROCEDURE, DEBUG CONNECT SESSION'
  || ', DROP ANY DIRECTORY, MANAGE SCHEDULER, UNLIMITED TABLESPACE, datapump_imp_full_database  '
  || ' TO &4';
execute immediate vsql;
  dbms_output.put_line('grants to user &4 are granted!');


exception when others then
	dbms_output.put_line(SQLERRM);

end;
/
spool off;
exit;

     
