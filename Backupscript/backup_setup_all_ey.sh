# backup install script 09/08/2018
# 
function imput_parameters	
	{
	#:START	
    #  Migration Sytem deployment configuration info
	read -e -p "Please enter the backup installation folder: "  inst_folder	
	read -e -p "Please enter Backup system schema: " -i "INSIS_MIGRATION_EY" schema
	read -e -p "Please enter Backup system schema password: " -i "INSIS_MIGRATION_EY" schema_pwd
	#dev
	if [[ $make_dev_backup =~ ^[Yy]$ ]]
	then
		read -e -p "Please enter the dev backup inst folder: "  dev_inst_folder
		read -e -p "Please enter dev backup schema: "  dev_schema
		read -e -p "Please enter dev backup schema password: "  dev_schema_pwd
	fi
	read -e -p "Please enter instance(SID)/service name: "  instance 
	read -e -p "Please enter IP: "  ip
	read -e -p "Please enter port: "  port
	 #  SYS password is masked
	read -rs -p "Please enter SYS password: " pword && echo "${pword//?/*}" && sys_pwd=$pword
	
	export	ConnStringSYS="SYS/${sys_pwd}@${ip}:${port}/${instance} as SYSDBA"
	export	ConnStringSchema="${schema}/${schema_pwd}@${ip}:${port}/${instance}"
	
	if [[ $make_dev_backup =~ ^[Yy]$ ]]; then
		export	ConnStringSchemaDev="${dev_schema}/${dev_schema_pwd}@${ip}:${port}/${instance}"
	fi
	}
#  end imput parameters function

function create_path
	{
	if [ ! -e $inst_folder ]; then
		mkdir $inst_folder
		#sudo chmod 777 $inst_folder
	fi
	#dailybackup
	if [ ! -e $inst_folder/dailybackup ]; then
		mkdir $inst_folder/dailybackup
		#sudo chmod 777 $inst_folder/dailybackup
	fi
	cd $inst_folder	
	if [ ! -e $dev_inst_folder ] && [[ $make_dev_backup =~ ^[Yy]$ ]]; then
		mkdir $dev_inst_folder
		#sudo chmod 777 $dev_inst_folder
	fi 
	if [ ! -e $inst_folder/$schema ]; then
		mkdir $inst_folder/$schema
		#sudo chmod 777 $inst_folder/$schema
	fi
	if [ ! -e $inst_folder/$schema/WaveDev ] && [[ $make_dev_backup =~ ^[Yy]$ ]]; then
		mkdir $inst_folder/$schema/WaveDev
		#sudo chmod 777 $inst_folder/$schema/WaveDev
	fi
	}
	
function create_install_dir
	{
	if [ -e create_install_dir.sql ]; then
		rm create_install_dir.sql
		echo "Delete previous run_backup.sh"
	fi	
	echo "alter session set nls_Language='ENGLISH'; " >> create_install_dir.sql
	echo "set serveroutput on FORMAT TRUNCATED; " >> create_install_dir.sql
	echo "spool spool.txt append; " >> create_install_dir.sql
	echo "create OR REPLACE directory DMP_DIR as '&1'; " >> create_install_dir.sql
	echo "GRANT all on directory DMP_DIR to &2; " >> create_install_dir.sql
	echo "create OR REPLACE directory DMP_LOG_DIR as '&1'; " >> create_install_dir.sql
	echo "GRANT all on directory DMP_LOG_DIR to &2; " >> create_install_dir.sql
	echo "spool off; " >> create_install_dir.sql
	echo "exit; " >> create_install_dir.sql
	sqlplus $ConnStringSYS  @ $inst_folder/create_install_dir.sql $inst_folder/$schema $schema
	if [[ $make_dev_backup =~ ^[Yy]$ ]]; then
		echo "alter session set nls_Language='ENGLISH'; " >> create_install_dir_dev.sql
		echo "set serveroutput on FORMAT TRUNCATED; " >> create_install_dir_dev.sql
		echo "spool spool.txt append; " >> create_install_dir_dev.sql
		echo "create OR REPLACE directory DMP_DEV_DIR as '&1'; " >> create_install_dir_dev.sql
		echo "GRANT all on directory DMP_DEV_DIR to &2; " >> create_install_dir_dev.sql
		echo "spool off; " >> create_install_dir_dev.sql
		echo "exit; " >> create_install_dir_dev.sql
		sqlplus $ConnStringSYS  @ $inst_folder/create_install_dir_dev.sql $inst_folder/$schema/WaveDev $dev_schema
	fi
	}
	
 check_files ()    
 {
	export exists=true
	if [ ! -e run_backup.sh ]; then
		export exists=false
		dbl_echo "run_backup.sh is missing" 
	fi
	if [ ! -e exp.sql ]; then
		export exists=false
		dbl_echo "exp.sql is missing" 
	fi
	if [ ! -e create_DEVMIG-specs_script.par ]; then
		export exists=false
		dbl_echo "create_DEVMIG-specs_script.par is missing" 
	fi
	if [ ! -e backup_ETL_HST_data.par ]; then
		export exists=false
		dbl_echo "backup_ETL_HST_data.par is missing" 
	fi
	if [ ! -e BACKUP_DEVMIG-SPECS.sh ]; then
		export exists=false
		dbl_echo "BACKUP_DEVMIG-SPECS.sh is missing" 
	fi
	if [ ! -e backup_DEVMIG-specs.par ]; then
		export exists=false
		dbl_echo "backup_DEVMIG-specs.par is missing" 
	fi
	if [ ! -e BACKUP_DEVMIG-ETLHST-DATA.sh ]; then
		export exists=false
		dbl_echo "BACKUP_DEVMIG-ETLHST-DATA.sh is missing" 
	fi
	
	if [[ $make_dev_backup =~ ^[Yy]$ ]]
	then
		cd dev
		if [ ! -e run_backupWaveDev.sh ]; then
			export exists=false
			dbl_echo "run_backupWaveDev.sh is missing" 
		fi
		if [ ! -e backup_DEVMIG-specsWaveDev.par ]; then
			export exists=false
			dbl_echo "backup_DEVMIG-specsWaveDev.par is missing" 
		fi
		if [ ! -e BACKUP_DEVMIG-SPECSWaveDev.sh ]; then
			export exists=false
			dbl_echo "BACKUP_DEVMIG-SPECSWaveDev.sh is missing" 
		fi
		if [ ! -e backup_ETL_HST_dataWaveDev.par ]; then
			export exists=false
			dbl_echo "backup_ETL_HST_dataWaveDev.par is missing" 
		fi
		if [ ! -e create_DEVMIG-specs_scriptWaveDev.par ]; then
			export exists=false
			dbl_echo "create_DEVMIG-specs_scriptWaveDev.par is missing" 
		fi
		if [ ! -e expWaveDev.sql ]; then
			export exists=false
			dbl_echo "expWaveDev.sql is missing" 
		fi
		if [ ! -e BACKUP_DEVMIG-ETLHST-DATA_WaveDev.sh ]; then
			export exists=false
			dbl_echo "BACKUP_DEVMIG-ETLHST-DATA_WaveDev.sh is missing" 
		fi
	fi
	if  ! $exists ; then 
		dbl_echo "Either abovementioned files do not exist in folder, or their file names are not the above.  Take care of that and Rerun batch file" 
  		exit 0
	  fi
	}
# End Check file directory	




function create_run_backup
  {
  if [ -e run_backup.sh ]; then
		rm run_backup.sh
		echo "Delete previous run_backup.sh"
	fi
   echo '#!/bin/bash' >> run_backup.sh
   echo '# --------------------------------------------------------------------' >> run_backup.sh
   echo '# ----------------------- filename: run_backup.bat -------------------' >> run_backup.sh
   echo '# ----------------------- Last update: 2018-05-23 10:44 --------------' >> run_backup.sh
   echo '# This batch file executes the SQL script that exports the source code' >> run_backup.sh 
   echo '# of all PACKAGES (DEFINITIONS AND BODIES) located in the Oracle DEVMIG' >> run_backup.sh
   echo '# instance at 10.201.36.190. It willl be loaded in Linux cron Task Scheduler' >> run_backup.sh
   echo '# to automate the backup procedure daily at 10 pm.' >> run_backup.sh
   echo "# script crated $(date '+%F %T') " >> run_backup.sh
   echo '' >> run_backup.sh
   echo "export ORACLE_HOME=$ORACLE_HOME"  >> run_backup.sh
   echo "export PATH=$ORACLE_HOME/bin:$PATH" >> run_backup.sh
   echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:usr/local/lib" >> run_backup.sh
   echo 'clear' >> run_backup.sh
   echo 'export LANG=en_US.UTF-8' >> run_backup.sh
   echo "export ExpPath='$inst_folder/$schema' " >> run_backup.sh
   echo ' ' >> run_backup.sh
   echo "export SAVESTAMP=\$(date '+%F %T')" >> run_backup.sh

   echo 'cd $ExpPath' >> run_backup.sh
   echo '' >> run_backup.sh
   echo '# -- Required to display results in english' >> run_backup.sh
   echo '' >> run_backup.sh
   echo 'export NLS_LANG=.al32utf8' >> run_backup.sh
   echo 'export LANG=en_US.utf8' >> run_backup.sh
   echo ' ' >> run_backup.sh
   echo '# Required to export Swedish characters correctly' >> run_backup.sh
   echo '' >> run_backup.sh
   echo 'echo "start sqlplus"' >> run_backup.sh
   # echo "sqlplus $'SYS/LfIns1sAdm@localhost:1521/DEVMIG as SYSDBA' @ $inst_folder/exp.sql" >> run_backup.sh
   echo "sqlplus \$'$ConnStringSYS' @ $inst_folder/exp.sql" >> run_backup.sh
   echo ' ' >> run_backup.sh
   echo ' ' >> run_backup.sh
   echo '#mv INSIS_MIGRATION_EY__SourceCode_Backup.sql "INSIS_MIGRATION_EY__SourceCode_$SAVESTAMP.sql"' >> run_backup.sh
   if [[ $make_dev_backup =~ ^[Yy]$ ]]; then
	   echo "cd '$dev_inst_folder'" >> run_backup.sh
	   echo './run_backupWaveDev.sh	' >> run_backup.sh
   fi
  }
  
function create_run_backup_dev
  {
  if [ -e run_backupWaveDev.sh ]; then
		rm run_backupWaveDev.sh
		echo "Delete previous run_backupWaveDev.sh"
	fi
   echo '#!/bin/bash' >> run_backupWaveDev.sh
   echo '# --------------------------------------------------------------------' >> run_backupWaveDev.sh
   echo '# ----------------------- filename: run_backupWaveDev.bat -------------------' >> run_backupWaveDev.sh
   echo '# ----------------------- Last update: 2018-05-23 10:44 --------------' >> run_backupWaveDev.sh
   echo '# This batch file executes the SQL script that exports the source code' >> run_backupWaveDev.sh 
   echo '# of all PACKAGES (DEFINITIONS AND BODIES) located in the Oracle DEVMIG' >> run_backupWaveDev.sh
   echo '# instance at 10.201.36.190. It willl be loaded in Linux cron Task Scheduler' >> run_backupWaveDev.sh
   echo '# to automate the backup procedure daily at 10 pm.' >> run_backupWaveDev.sh
   echo "# script crated $(date '+%F %T') " >> run_backupWaveDev.sh
   echo '' >> run_backupWaveDev.sh
   echo "export ORACLE_HOME=$ORACLE_HOME"  >> run_backupWaveDev.sh
   echo "export PATH=$ORACLE_HOME/bin:$PATH" >> run_backupWaveDev.sh
   echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:usr/local/lib" >> run_backupWaveDev.sh
   echo 'clear' >> run_backupWaveDev.sh
   echo 'export LANG=en_US.UTF-8' >> run_backupWaveDev.sh
   echo "export ExpPath='$inst_folder/$schema/WaveDev' " >> run_backupWaveDev.sh
   echo ' ' >> run_backupWaveDev.sh
   echo "export SAVESTAMP=\$(date '+%F %T')" >> run_backupWaveDev.sh

   echo 'cd $ExpPath' >> run_backupWaveDev.sh
   echo '' >> run_backupWaveDev.sh
   echo '# -- Required to display results in english' >> run_backupWaveDev.sh
   echo '' >> run_backupWaveDev.sh
   echo 'export NLS_LANG=.al32utf8' >> run_backupWaveDev.sh
   echo 'export LANG=en_US.utf8' >> run_backupWaveDev.sh
   echo ' ' >> run_backupWaveDev.sh
   echo '# Required to export Swedish characters correctly' >> run_backupWaveDev.sh
   echo '' >> run_backupWaveDev.sh
   echo 'echo "start sqlplus"' >> run_backupWaveDev.sh
   # echo "sqlplus $'SYS/LfIns1sAdm@localhost:1521/DEVMIG as SYSDBA' @ $dev_inst_folder/exp.sql" >> run_backupWaveDev.sh
   echo "sqlplus \$'$ConnStringSYS' @ $dev_inst_folder/expWaveDev.sql" >> run_backupWaveDev.sh
   echo ' ' >> run_backupWaveDev.sh
   echo ' ' >> run_backupWaveDev.sh
   echo 'mv INSIS_MIGRATION_EY__SourceCode_Backup.sql "INSIS_MIGRATION_EY__SourceCode_$SAVESTAMP.sql"' >> run_backupWaveDev.sh
  }  
  
 function create_exp_sql
{
	if [ -e exp.sql ]; then
		rm exp.sql
		echo "Delete previous exp.sql"
	fi
	 echo "-- Run this script in SQL*Plus." >> exp.sql
     echo "" >> exp.sql
     echo "-- don't print headers or other junk" >> exp.sql
     echo "set heading off;" >> exp.sql
     echo "set echo off;" >> exp.sql
     echo "set pagesize 0;   " >> exp.sql
     echo "set feedback off;   " >> exp.sql
     echo "" >> exp.sql
     echo "-- don't truncate the line output" >> exp.sql
     echo "-- trim the extra space from linesize when spooling" >> exp.sql
     echo "set long 99999;      " >> exp.sql
     echo "set linesize 32767;  " >> exp.sql
     echo "set trimspool on;    " >> exp.sql
     echo "" >> exp.sql
     echo "  " >> exp.sql
     echo "" >> exp.sql
     echo "alter session set nls_Language='ENGLISH';" >> exp.sql
     echo "" >> exp.sql
     echo "" >> exp.sql
     echo "-- don't truncate this specific column's output" >> exp.sql
     echo "--col object_ddl format A32000;" >> exp.sql
     echo "" >> exp.sql
     echo "--SELECT * FROM all_directories" >> exp.sql
     echo "set serveroutput on FORMAT TRUNCATED;" >> exp.sql
     echo "--set termout off;" >> exp.sql
     echo "spool INSIS_MIGRATION_EY__SourceCode_Backup.sql" >> exp.sql
     echo "" >> exp.sql
     echo "declare " >> exp.sql
     echo "-- global variables" >> exp.sql
     echo "v_schema varchar2(30):='${schema}';  " >> exp.sql
     echo "v_dir varchar2(30):='DMP_DIR';                --outfile directory based in Oracle dba_directories" >> exp.sql
     echo "v_time varchar2(50):=to_char(systimestamp, 'yyyy-mm-dd@hh24-mi-ss');" >> exp.sql
     echo "" >> exp.sql
     echo "" >> exp.sql
     echo "TYPE tbl IS TABLE OF varchar2(5000) INDEX by PLS_INTEGER; " >> exp.sql
     echo "tbl1 tbl; " >> exp.sql
     echo "i pls_integer; " >> exp.sql
     echo "fileHandler UTL_FILE.FILE_TYPE;" >> exp.sql
     echo "" >> exp.sql
     echo "begin" >> exp.sql
     echo "     dbms_output.put_line(' ');" >> exp.sql
     echo "     dbms_output.put_line(' ');" >> exp.sql
     echo "     dbms_output.put_line('alter session set nls_Language=''ENGLISH'';');" >> exp.sql
     echo "     dbms_output.put_line('set serveroutput on FORMAT TRUNCATED;');" >> exp.sql
     echo "     dbms_output.put_line('spool spool.txt append;');	" >> exp.sql
     echo "     dbms_output.put_line(' ');" >> exp.sql
     echo "--     for c in (SELECT dbms_lob.fileexists(BFILENAME(v_dir,'.'))         -- if dir exists" >> exp.sql
     echo "--               from dual" >> exp.sql
     echo "--     )" >> exp.sql
     echo "--     loop" >> exp.sql
     echo "--  fileHandler := UTL_FILE.FOPEN(v_dir, 'INSIS_MIGRATION_EY__SourceCode_Backup_' || v_time || '.sql' , 'A',5000);" >> exp.sql
     echo "         for c1 in (select u.object_name as pkg,OBJECT_TYPE as part" >> exp.sql
     echo "                    from dba_objects u" >> exp.sql
     echo "                    where 1=1" >> exp.sql
     echo "                      and owner = v_schema" >> exp.sql
     echo "                      and OBJECT_TYPE IN ('PACKAGE','PACKAGE BODY')" >> exp.sql
     echo "            		      and not(object_name like 'TST%' or object_name like 'TEST%' or object_name like '%_TEST')" >> exp.sql
     echo "                    ORDER BY 2" >> exp.sql
     echo "          )" >> exp.sql
     echo "           loop" >> exp.sql
     echo "                  select REGEXP_REPLACE(REGEXP_replace(REGEXP_REPLACE(REGEXP_REPLACE(text,'INSIS_MIGRATION_EY(.){0,1}',''),'@@',' '),'['||chr(13)||']',' '),'['||chr(10)||']',' ') --remove  CR, LF ASCII chars" >> exp.sql
     echo "                    bulk collect into tbl1 " >> exp.sql
     echo "                  from dba_source                      " >> exp.sql                   
     echo "                  where 1=1 " >> exp.sql
     echo "                    and owner= v_schema " >> exp.sql
     echo "                    and name= c1.pkg " >> exp.sql
     echo "                    and type= c1.part" >> exp.sql
     echo "		              order by line;" >> exp.sql
     echo "    " >> exp.sql
     echo "         --         UTL_FILE.PUTF(fileHandler, 'CREATE OR REPLACE '); " >> exp.sql
     echo "		              dbms_output.put('CREATE OR REPLACE ');" >> exp.sql
     echo "                      " >> exp.sql
     echo "                  FOR i in  1 .. tbl1.count " >> exp.sql
     echo "                  loop                                  " >> exp.sql                                
     echo "            --         UTL_FILE.PUT_LINE(fileHandler, tbl1(i)); " >> exp.sql
     echo "			            dbms_output.put_line(tbl1(i));" >> exp.sql
     echo "                  end loop; " >> exp.sql
     echo "    " >> exp.sql
     echo "             --     UTL_FILE.PUT_LINE(fileHandler, '/');" >> exp.sql
     echo "            --     UTL_FILE.PUT_LINE(fileHandler, ' ');" >> exp.sql
     echo "      		        dbms_output.put_line('/');" >> exp.sql
     echo "        	        dbms_output.put_line(' ' );" >> exp.sql
     echo "           end loop;" >> exp.sql
     echo "       " >> exp.sql
     echo "    " >> exp.sql
     echo "    -- end loop;  --vdir exists loop" >> exp.sql
     echo "" >> exp.sql
     echo "     dbms_output.put_line('spool off;');" >> exp.sql
     echo "           dbms_output.put_line('exit;' );" >> exp.sql
     echo "    --    UTL_FILE.FCLOSE(fileHandler);" >> exp.sql
     echo "" >> exp.sql
     echo "exception when others then " >> exp.sql
     echo "  dbms_output.put_line(SQLERRM);" >> exp.sql
     echo "--  if UTL_FILE.IS_open(fileHandler) then " >> exp.sql
     echo "--    UTL_FILE.FCLOSE(fileHandler);" >> exp.sql
     echo "--  end if;" >> exp.sql
     echo "end;" >> exp.sql
     echo "/" >> exp.sql
     echo "spool off;" >> exp.sql
     echo "exit;" >> exp.sql
} 
  
function create_exp_sql_dev
{
	if [ -e expWaveDev.sql ]; then
		rm expWaveDev.sql
		echo "Delete previous expWaveDev.sql"
	fi
	 echo "-- Run this script in SQL*Plus." >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "-- don't print headers or other junk" >> expWaveDev.sql
     echo "set heading off;" >> expWaveDev.sql
     echo "set echo off;" >> expWaveDev.sql
     echo "set pagesize 0;   " >> expWaveDev.sql
     echo "set feedback off;   " >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "-- don't truncate the line output" >> expWaveDev.sql
     echo "-- trim the extra space from linesize when spooling" >> expWaveDev.sql
     echo "set long 99999;      " >> expWaveDev.sql
     echo "set linesize 32767;  " >> expWaveDev.sql
     echo "set trimspool on;    " >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "  " >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "alter session set nls_Language='ENGLISH';" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "-- don't truncate this specific column's output" >> expWaveDev.sql
     echo "--col object_ddl format A32000;" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "--SELECT * FROM all_directories" >> expWaveDev.sql
     echo "set serveroutput on FORMAT TRUNCATED;" >> expWaveDev.sql
     echo "--set termout off;" >> expWaveDev.sql
     echo "spool INSIS_MIGRATION_EY__SourceCode_Backup.sql" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "declare " >> expWaveDev.sql
     echo "-- global variables" >> expWaveDev.sql
     echo "v_schema varchar2(30):='${schema}';  " >> expWaveDev.sql
     echo "v_dir varchar2(30):='DMP_DIR';                --outfile directory based in Oracle dba_directories" >> expWaveDev.sql
     echo "v_time varchar2(50):=to_char(systimestamp, 'yyyy-mm-dd@hh24-mi-ss');" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "TYPE tbl IS TABLE OF varchar2(5000) INDEX by PLS_INTEGER; " >> expWaveDev.sql
     echo "tbl1 tbl; " >> expWaveDev.sql
     echo "i pls_integer; " >> expWaveDev.sql
     echo "fileHandler UTL_FILE.FILE_TYPE;" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "begin" >> expWaveDev.sql
     echo "     dbms_output.put_line(' ');" >> expWaveDev.sql
     echo "     dbms_output.put_line(' ');" >> expWaveDev.sql
     echo "     dbms_output.put_line('alter session set nls_Language=''ENGLISH'';');" >> expWaveDev.sql
     echo "     dbms_output.put_line('set serveroutput on FORMAT TRUNCATED;');" >> expWaveDev.sql
     echo "     dbms_output.put_line('spool spool.txt append;');	" >> expWaveDev.sql
     echo "     dbms_output.put_line(' ');" >> expWaveDev.sql
     echo "--     for c in (SELECT dbms_lob.fileexists(BFILENAME(v_dir,'.'))         -- if dir exists" >> expWaveDev.sql
     echo "--               from dual" >> expWaveDev.sql
     echo "--     )" >> expWaveDev.sql
     echo "--     loop" >> expWaveDev.sql
     echo "--  fileHandler := UTL_FILE.FOPEN(v_dir, 'INSIS_MIGRATION_EY__SourceCode_Backup_' || v_time || '.sql' , 'A',5000);" >> expWaveDev.sql
     echo "         for c1 in (select u.object_name as pkg,OBJECT_TYPE as part" >> expWaveDev.sql
     echo "                    from dba_objects u" >> expWaveDev.sql
     echo "                    where 1=1" >> expWaveDev.sql
     echo "                      and owner = v_schema" >> expWaveDev.sql
     echo "                      and OBJECT_TYPE IN ('PACKAGE','PACKAGE BODY')" >> expWaveDev.sql
     echo "            		      and not(object_name like 'TST%' or object_name like 'TEST%' or object_name like '%_TEST')" >> expWaveDev.sql
     echo "                    ORDER BY 2" >> expWaveDev.sql
     echo "          )" >> expWaveDev.sql
     echo "           loop" >> expWaveDev.sql
     echo "                  select REGEXP_REPLACE(REGEXP_replace(REGEXP_REPLACE(REGEXP_REPLACE(text,'INSIS_MIGRATION_EY(.){0,1}',''),'@@',' '),'['||chr(13)||']',' '),'['||chr(10)||']',' ') --remove  CR, LF ASCII chars" >> expWaveDev.sql
     echo "                    bulk collect into tbl1 " >> expWaveDev.sql
     echo "                  from dba_source                      " >> expWaveDev.sql                   
     echo "                  where 1=1 " >> expWaveDev.sql
     echo "                    and owner= v_schema " >> expWaveDev.sql
     echo "                    and name= c1.pkg " >> expWaveDev.sql
     echo "                    and type= c1.part" >> expWaveDev.sql
     echo "		              order by line;" >> expWaveDev.sql
     echo "    " >> expWaveDev.sql
     echo "         --         UTL_FILE.PUTF(fileHandler, 'CREATE OR REPLACE '); " >> expWaveDev.sql
     echo "		              dbms_output.put('CREATE OR REPLACE ');" >> expWaveDev.sql
     echo "                      " >> expWaveDev.sql
     echo "                  FOR i in  1 .. tbl1.count " >> expWaveDev.sql
     echo "                  loop                                  " >> expWaveDev.sql                                
     echo "            --         UTL_FILE.PUT_LINE(fileHandler, tbl1(i)); " >> expWaveDev.sql
     echo "			            dbms_output.put_line(tbl1(i));" >> expWaveDev.sql
     echo "                  end loop; " >> expWaveDev.sql
     echo "    " >> expWaveDev.sql
     echo "             --     UTL_FILE.PUT_LINE(fileHandler, '/');" >> expWaveDev.sql
     echo "            --     UTL_FILE.PUT_LINE(fileHandler, ' ');" >> expWaveDev.sql
     echo "      		        dbms_output.put_line('/');" >> expWaveDev.sql
     echo "        	        dbms_output.put_line(' ' );" >> expWaveDev.sql
     echo "           end loop;" >> expWaveDev.sql
     echo "       " >> expWaveDev.sql
     echo "    " >> expWaveDev.sql
     echo "    -- end loop;  --vdir exists loop" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "     dbms_output.put_line('spool off;');" >> expWaveDev.sql
     echo "           dbms_output.put_line('exit;' );" >> expWaveDev.sql
     echo "    --    UTL_FILE.FCLOSE(fileHandler);" >> expWaveDev.sql
     echo "" >> expWaveDev.sql
     echo "exception when others then " >> expWaveDev.sql
     echo "  dbms_output.put_line(SQLERRM);" >> expWaveDev.sql
     echo "--  if UTL_FILE.IS_open(fileHandler) then " >> expWaveDev.sql
     echo "--    UTL_FILE.FCLOSE(fileHandler);" >> expWaveDev.sql
     echo "--  end if;" >> expWaveDev.sql
     echo "end;" >> expWaveDev.sql
     echo "/" >> expWaveDev.sql
     echo "spool off;" >> expWaveDev.sql
     echo "exit;" >> expWaveDev.sql
}   
  
function create_backup_specs
	{
	if [ -e BACKUP_DEVMIG-SPECS.sh ]; then
		rm BACKUP_DEVMIG-SPECS.sh
		echo "Delete previous BACKUP_DEVMIG-SPECS.sh"
	fi
	echo '#!/bin/bash' >> BACKUP_DEVMIG-SPECS.sh
	echo "# -------------------------------------------------------------------- " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# ----------------------- filename: Backup DEVMIG via expdp.bat ------------------- " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# ----------------------- Last update: 2018-05-23 10:44 -------------- " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# This batch file uses the EXPDP Oracle command to create a DUMP of the  " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# ETL and HST tables and their contents located in the Oracle DEVMIG " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# instance at 10.201.36.190. It is created as a task in Windows Task Scheduler " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# to automate the backup procedure daily at 11 pm.  " >> BACKUP_DEVMIG-SPECS.sh 
    echo "clear " >> BACKUP_DEVMIG-SPECS.sh 
    echo "export ORACLE_HOME=$ORACLE_HOME"   >> BACKUP_DEVMIG-SPECS.sh
    echo "export PATH=$ORACLE_HOME/bin:$PATH" >> BACKUP_DEVMIG-SPECS.sh
    echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:usr/local/lib" >> BACKUP_DEVMIG-SPECS.sh	
    echo " " >> BACKUP_DEVMIG-SPECS.sh 
    echo "export SAVESTAMP=\$(date '+%F %T') " >> BACKUP_DEVMIG-SPECS.sh 
    echo "export ExpPath=' $inst_folder/$schema' " >> BACKUP_DEVMIG-SPECS.sh 
    echo "export DblRunPath='$inst_folder/Backup_scripts_WaveDev' " >> BACKUP_DEVMIG-SPECS.sh 
    echo " " >> BACKUP_DEVMIG-SPECS.sh 
    echo "export NLS_LANG=.al32utf8 " >> BACKUP_DEVMIG-SPECS.sh 
    echo "export LANG=en_US.utf8 " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# chcp 65001 " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# Backing up Tables and sequences specs " >> BACKUP_DEVMIG-SPECS.sh 
    echo "expdp $ConnStringSchema  PARFILE=$inst_folder/backup_DEVMIG-specs.par " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# -- Create relative SQL File  " >> BACKUP_DEVMIG-SPECS.sh 
    echo "impdp $ConnStringSchema PARFILE=$inst_folder/create_DEVMIG-specs_script.par  " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# -- Ensure this is executed at the correct directory " >> BACKUP_DEVMIG-SPECS.sh 
    echo " " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# cd Daiy_Backup_DB_INSIS_MIGRATION_EY_LNX " >> BACKUP_DEVMIG-SPECS.sh 
    echo "cd \$ExpPath " >> BACKUP_DEVMIG-SPECS.sh 
    echo "grep -v \"ALTER SESSION\" DEVMIG_SPECS.sql  >> DEVMIG_SPECS1.sql " >> BACKUP_DEVMIG-SPECS.sh 
    echo "cp DEVMIG_SPECS1.sql DEVMIG_SPECS2.sql " >> BACKUP_DEVMIG-SPECS.sh 
    echo "sed -i '/\\\"$schema\\\"./ s///g' DEVMIG_SPECS2.sql " >> BACKUP_DEVMIG-SPECS.sh 
    echo "# convert to ascii " >> BACKUP_DEVMIG-SPECS.sh 
    echo "more DEVMIG_SPECS2.sql >> DEVMIG_SPECS3.sql " >> BACKUP_DEVMIG-SPECS.sh 
    echo 'mv DEVMIG_SPECS3.sql "DEVMIG_SPECS_$SAVESTAMP.sql" ' >> BACKUP_DEVMIG-SPECS.sh 
    echo "rm DEVMIG_SPECS1.sql " >> BACKUP_DEVMIG-SPECS.sh 
    echo "rm DEVMIG_SPECS2.sql " >> BACKUP_DEVMIG-SPECS.sh 
    echo "rm DEVMIG_SPECS.sql " >> BACKUP_DEVMIG-SPECS.sh 
    echo " " >> BACKUP_DEVMIG-SPECS.sh
	if [[ $make_dev_backup =~ ^[Yy]$ ]]; then	
		echo "cd '$dev_inst_folder'" >> BACKUP_DEVMIG-SPECS.sh 
		echo "./BACKUP_DEVMIG-SPECSWaveDev.sh " >> BACKUP_DEVMIG-SPECS.sh 
	fi
	}
	
function create_backup_specs_dev
	{
	if [ -e BACKUP_DEVMIG-SPECSWaveDev.sh ]; then
		rm BACKUP_DEVMIG-SPECSWaveDev.sh
		echo "Delete previous BACKUP_DEVMIG-SPECSWaveDev.sh"
	fi
	echo '#!/bin/bash' >> BACKUP_DEVMIG-SPECSWaveDev.sh
	echo "# -------------------------------------------------------------------- " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# ----------------------- filename: Backup DEVMIG via expdp.bat ------------------- " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# ----------------------- Last update: 2018-05-23 10:44 -------------- " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# This batch file uses the EXPDP Oracle command to create a DUMP of the  " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# ETL and HST tables and their contents located in the Oracle DEVMIG " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# instance at 10.201.36.190. It is created as a task in Windows Task Scheduler " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# to automate the backup procedure daily at 11 pm.  " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "clear " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "export ORACLE_HOME=$ORACLE_HOME"   >> BACKUP_DEVMIG-SPECSWaveDev.sh
    echo "export PATH=$ORACLE_HOME/bin:$PATH" >> BACKUP_DEVMIG-SPECSWaveDev.sh
    echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:usr/local/lib" >> BACKUP_DEVMIG-SPECSWaveDev.sh	
    echo " " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "export SAVESTAMP=\$(date '+%F %T') " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "export ExpPath='$inst_folder/$schema/WaveDev' " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "export DblRunPath='$dev_inst_folder' " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo " " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "export NLS_LANG=.al32utf8 " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "export LANG=en_US.utf8 " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# chcp 65001 " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# Backing up Tables and sequences specs " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "expdp $ConnStringSchemaDev  PARFILE=$dev_inst_folder/backup_DEVMIG-specsWaveDev.par " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# -- Create relative SQL File  " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "impdp $ConnStringSchemaDev PARFILE=$dev_inst_folder/create_DEVMIG-specs_scriptWaveDev.par  " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# -- Ensure this is executed at the correct directory " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo " " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# cd Daiy_Backup_DB_INSIS_MIGRATION_EY_LNX " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "cd \$ExpPath " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "grep -v \"ALTER SESSION\" DEVMIG_SPECS.sql  >> DEVMIG_SPECS1.sql " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "cp DEVMIG_SPECS1.sql DEVMIG_SPECS2.sql " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "sed -i '/\\\"$dev_schema\\\"./ s///g' DEVMIG_SPECS2.sql " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "# convert to ascii " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "more DEVMIG_SPECS2.sql >> DEVMIG_SPECS3.sql " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo 'mv DEVMIG_SPECS3.sql "DEVMIG_SPECS_$SAVESTAMP.sql" ' >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "rm DEVMIG_SPECS1.sql " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "rm DEVMIG_SPECS2.sql " >> BACKUP_DEVMIG-SPECSWaveDev.sh 
    echo "rm DEVMIG_SPECS.sql " >> BACKUP_DEVMIG-SPECSWaveDev.sh 

	}	
	
function create_bk_specs_par
	{
	if [ -e backup_DEVMIG-specs.par ]; then
		rm backup_DEVMIG-specs.par
		echo "Delete previous backup_DEVMIG-specs.par"
	fi
	echo "directory=DMP_DIR" >> backup_DEVMIG-specs.par 
	echo "schemas=$schema" >> backup_DEVMIG-specs.par 
	echo "dumpfile=DEV_MIG_SPECS.dmp logfile=devmig-specs.log REUSE_DUMPFILES=Y" >> backup_DEVMIG-specs.par 
	echo "INCLUDE=TABLE:\" IN (select table_name from all_all_tables where owner='$schema' and ( table_name like 'ETL_%' or table_name like 'HST_%' or table_name like 'MIG%' or table_name like 'IA_%'  or table_name='RLG_LOCK_TBL' or table_name='MIGR_SRV_EVENT_LIST' or table_name='MIG_PROCESS_STEPS'))\" " >> backup_DEVMIG-specs.par 
	echo "content=metadata_only  " >> backup_DEVMIG-specs.par 
	echo "include=sequence include=index include=synonym" >> backup_DEVMIG-specs.par 
	}

function create_bk_specs_par_dev
	{
	if [ -e backup_DEVMIG-specsWaveDev.par ]; then
		rm backup_DEVMIG-specsWaveDev.par
		echo "Delete previous backup_DEVMIG-specsWaveDev.par"
	fi
	echo "directory=DMP_DEV_DIR" >> backup_DEVMIG-specsWaveDev.par 
	echo "schemas=$dev_schema" >> backup_DEVMIG-specsWaveDev.par 
	echo "dumpfile=DEV_MIG_SPECS.dmp logfile=devmig-specs.log REUSE_DUMPFILES=Y" >> backup_DEVMIG-specsWaveDev.par 
	echo "INCLUDE=TABLE:\" IN (select table_name from all_all_tables where owner='$dev_schema' and ( table_name like 'ETL_%' or table_name like 'HST_%' or table_name like 'MIG%' or table_name like 'IA_%'  or table_name='RLG_LOCK_TBL' or table_name='MIGR_SRV_EVENT_LIST' or table_name='MIG_PROCESS_STEPS'))\" " >> backup_DEVMIG-specsWaveDev.par 
	echo "content=metadata_only  " >> backup_DEVMIG-specsWaveDev.par 
	echo "include=sequence include=index include=synonym" >> backup_DEVMIG-specsWaveDev.par 
	}
	
function create_bk_specs_script_par
	{
	if [ -e create_DEVMIG-specs_script.par ]; then
		rm create_DEVMIG-specs_script.par
		echo "Delete previous create_DEVMIG-specs_script.par"
	fi
	echo "directory=DMP_DIR schemas=$schema " >> create_DEVMIG-specs_script.par
	echo "dumpfile=DEV_MIG_SPECS.dmp  " >> create_DEVMIG-specs_script.par
	echo "sqlfile=DEVMIG_SPECS.sql  " >> create_DEVMIG-specs_script.par
	echo "transform=segment_attributes:n " >> create_DEVMIG-specs_script.par
	echo "exclude=statistics  " >> create_DEVMIG-specs_script.par
	}
	
function create_bk_specs_script_par_dev
	{
	if [ -e create_DEVMIG-specs_scriptWaveDev.par ]; then
		rm create_DEVMIG-specs_scriptWaveDev.par
		echo "Delete previous create_DEVMIG-specs_scriptWaveDev.par"
	fi
	echo "directory=DMP_DEV_DIR schemas=$dev_schema " >> create_DEVMIG-specs_scriptWaveDev.par
	echo "dumpfile=DEV_MIG_SPECS.dmp  " >> create_DEVMIG-specs_scriptWaveDev.par
	echo "sqlfile=DEVMIG_SPECS.sql  " >> create_DEVMIG-specs_scriptWaveDev.par
	echo "transform=segment_attributes:n " >> create_DEVMIG-specs_scriptWaveDev.par
	echo "exclude=statistics  " >> create_DEVMIG-specs_scriptWaveDev.par
	}	
	
function create_etl_par
	{
	if [ -e backup_ETL_HST_data.par ]; then
		rm backup_ETL_HST_data.par
		echo "Delete previous backup_ETL_HST_data.par"
	fi
	echo "directory=DMP_DIR " >> backup_ETL_HST_data.par
	echo "schemas=$schema " >> backup_ETL_HST_data.par
	echo "logfile=dmp_log_dir:devmig-etlhst_data.log " >> backup_ETL_HST_data.par
	echo "dumpfile=DEVMIG-ETLHST_DATA.dmp  REUSE_DUMPFILES=Y " >> backup_ETL_HST_data.par
	echo "INCLUDE=TABLE:\" IN (select table_name from all_all_tables where owner='$schema' and ( table_name like 'ETL_%' or table_name like 'HST_%' or table_name='MIGR_SRV_EVENT_LIST' or table_name='RLG_LOCK_TBL'  or table_name='MIG_PROCESS_STEPS'))\"  " >> backup_ETL_HST_data.par
	echo "content=data_only  " >> backup_ETL_HST_data.par
	}	
	
function create_etl_par_dev
	{
	if [ -e backup_ETL_HST_dataWaveDev.par ]; then
		rm backup_ETL_HST_dataWaveDev.par
		echo "Delete previous backup_ETL_HST_dataWaveDev.par"
	fi
	echo "directory=DMP_DEV_DIR " >> backup_ETL_HST_dataWaveDev.par
	echo "schemas=$dev_schema " >> backup_ETL_HST_dataWaveDev.par
	echo "logfile=DMP_DEV_DIR:devmig-etlhst_data.log " >> backup_ETL_HST_dataWaveDev.par
	echo "dumpfile=DEVMIG-ETLHST_DATA.dmp  REUSE_DUMPFILES=Y " >> backup_ETL_HST_dataWaveDev.par
	echo "INCLUDE=TABLE:\" IN (select table_name from all_all_tables where owner='$dev_schema' and ( table_name like 'ETL_%' or table_name like 'HST_%' or table_name='MIGR_SRV_EVENT_LIST' or table_name='RLG_LOCK_TBL'  or table_name='MIG_PROCESS_STEPS'))\"  " >> backup_ETL_HST_dataWaveDev.par
	echo "content=data_only  " >> backup_ETL_HST_dataWaveDev.par
	}		
	
function create_etl_sh
	{
	if [ -e BACKUP_DEVMIG-ETLHST-DATA.sh ]; then
		rm BACKUP_DEVMIG-ETLHST-DATA.sh
		echo "Delete previous BACKUP_DEVMIG-ETLHST-DATA.sh"
	fi
	echo '#!/bin/bash' >> BACKUP_DEVMIG-ETLHST-DATA.sh
	echo "# -------------------------------------------------------------------- " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# ----------------------- filename: Backup DEVMIG via expdp.bat ------------------- " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# ----------------------- Last update: 2015-11-30 11:53 -------------- " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# This batch file uses the EXPDP Oracle command to create a DUMP of the  " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# ETL and HST tables and their contents located in the Oracle DEVMIG " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# instance at 10.180.50.158. It is created as a task in Windows Task Scheduler " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# to automate the backup procedure daily at 11 pm.  " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "clear " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
   echo "export ORACLE_HOME=$ORACLE_HOME"  >> BACKUP_DEVMIG-ETLHST-DATA.sh
   echo "export PATH=$ORACLE_HOME/bin:$PATH" >> BACKUP_DEVMIG-ETLHST-DATA.sh
   echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:usr/local/lib" >> BACKUP_DEVMIG-ETLHST-DATA.sh	
	echo "export SAVESTAMP=\$(date '+%F %T') " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "export ExpPath=' $inst_folder/$schema' " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "export DblRunPath='$inst_folder/Backup_scripts_WaveDev' " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# F: " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "export NLS_LANG=.al32utf8 " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "export LANG=en_US.utf8 " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# Backing up Table data for ETL_ and HST_ tables " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "expdp $ConnStringSchema  PARFILE=$inst_folder/backup_ETL_HST_data.par " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo " " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	echo "# ------------------------------------------------------------------------------------ " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	if [[ $make_dev_backup =~ ^[Yy]$ ]]; then
		echo "#  +++ anb 2018.05.08 added backup for Wave dev. " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
		echo "cd '$dev_inst_folder'" >> BACKUP_DEVMIG-ETLHST-DATA.sh 
		echo "./BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh " >> BACKUP_DEVMIG-ETLHST-DATA.sh 
	fi
	}
	
function create_etl_sh_dev
	{
	if [ -e BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh ]; then
		rm BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh
		echo "Delete previous BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh"
	fi
	echo '#!/bin/bash' >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh
	echo "# -------------------------------------------------------------------- " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# ----------------------- filename: Backup DEVMIG via expdp.bat ------------------- " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# ----------------------- Last update: 2015-11-30 11:53 -------------- " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# This batch file uses the EXPDP Oracle command to create a DUMP of the  " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# ETL and HST tables and their contents located in the Oracle DEVMIG " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# instance at 10.180.50.158. It is created as a task in Windows Task Scheduler " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# to automate the backup procedure daily at 11 pm.  " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "clear " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
    echo "export ORACLE_HOME=$ORACLE_HOME"  >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh
    echo "export PATH=$ORACLE_HOME/bin:$PATH" >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh
    echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:usr/local/lib" >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh	
	echo "export SAVESTAMP=\$(date '+%F %T') " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "export ExpPath='$inst_folder/$schema/WaveDev' " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "export DblRunPath='$inst_folder/Backup_scripts_WaveDev' " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# F: " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "export NLS_LANG=.al32utf8 " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "export LANG=en_US.utf8 " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "# Backing up Table data for ETL_ and HST_ tables " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo "expdp $ConnStringSchemaDev  PARFILE=$dev_inst_folder/backup_ETL_HST_dataWaveDev.par " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	echo " " >> BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh 
	}	
	
function create_bk_command
		{
		if [ -e dailybackup.sh ]; then
			rm dailybackup.sh
			echo "Delete previous dailybackup.sh"
	    fi
		echo '#!/bin/bash' >> dailybackup.sh
		echo "export SAVESTAMP=\$(date '+%F %T')"  >> dailybackup.sh 
		echo "cd '$inst_folder/dailybackup' " >> dailybackup.sh
		echo " tar -czvf insis_bk.tar.gz $inst_folder/$schema" >> dailybackup.sh
		echo 'mv insis_bk.tar.gz "insis_bk$SAVESTAMP.tar.gz"' >> dailybackup.sh
		echo "export ExpPath='$inst_folder/$schema' " >> dailybackup.sh
        echo ' ' >> run_backup.sh
        echo 'cd $ExpPath' >> dailybackup.sh
		echo 'rm -f *' >> dailybackup.sh
		if [[ $make_dev_backup =~ ^[Yy]$ ]]; then
			echo 'cd WaveDev' >> dailybackup.sh
			echo 'rm -f *' >> dailybackup.sh
		fi
		}
	
#Main Program ------------------------------------------------------------------------
   clear

	export StartDateTime=$(date '+%F %T')
	export os_slash="/"
# Required to export Swedish characters correctly and display results in english
	export NLS_LANG=.al32utf8
	export LANG=en_US.utf8

	#Dev Backup - NOTE: Uncomment the following 2 lines if you want to restore the functionality of keeping a Development SCHEMA Backup. Coment also the next line
	#read -p "Do you want to setup a Development Backup? " -r make_dev_backup
	#echo
	
	#Dev Backup - NOTE: comment out the following line if you want to restore the Development SCHEMA Backup.
	make_dev_backup='n'
	
	
	imput_parameters

	create_path
	create_install_dir
	
	create_run_backup
	create_exp_sql
	create_backup_specs
	create_bk_specs_par
	create_bk_specs_script_par
	create_etl_par
	create_etl_sh
	
	chmod 777 run_backup.sh
	chmod 777 BACKUP_DEVMIG-SPECS.sh
	chmod 777 BACKUP_DEVMIG-ETLHST-DATA.sh
	chmod 777 dailybackup.sh
	
	if [[ $make_dev_backup =~ ^[Yy]$ ]]
	then
		cd $dev_inst_folder
		create_run_backup_dev
		create_exp_sql_dev
		create_backup_specs_dev
		create_bk_specs_par_dev
		create_bk_specs_script_par_dev
		create_etl_par_dev
		create_etl_sh_dev
		chmod 777 run_backupWaveDev.sh
		chmod 777 BACKUP_DEVMIG-SPECSWaveDev.sh
		chmod 777 BACKUP_DEVMIG-ETLHST-DATAWaveDev.sh
	fi
	
	create_bk_command
	
	exit
	