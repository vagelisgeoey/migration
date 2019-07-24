#!/bin/bash
# -- +++ anb 2017-04-24 : Always use SYS for sqlplus (even for DEVMIG)!
# -- +++ anb 2017-08-14 : Use Oracle HOME directory / ASM for tablespaces
# -- +++ anb 2017-08-17 : Use ConnectString for connecting to Oracle depending on environment.
# -- +++ anb 2017-09-08 : Specify OracleHOME, ASM, or specific directory for tablespaces. Verify Connection String 
# -- +++ anb 2017-09-11 : Get Start/end timestamp and print at the end of successful script 
# --  
# -- +++ anb 2018-08-09 : Grammar corrections

dbl_echo ()
   {
   	echo $1
	echo $1 >> ${dir}/spool.txt
   }

# function check_files checks the existance of all files in the install directory
 check_files () 
   {

	export exists=true
	if [ ! -e Create_INSIS_MIGRATION_EY.sql ]; then
		export exists=false
		dbl_echo "Create_INSIS_MIGRATION_EY.sql is missing" 
	fi
   	if [ ! -e environment_check.sql ]; then
		export exists=false
		dbl_echo "environment_check.sql is missing" 
	fi
   	if [ ! -e check_for_existing_data.sql ]; then
		export exists=false
		dbl_echo "check_for_existing_data.sql is missing" 
	fi
	if [ ! -e  DEVMIG_SPECS.sql ]; then
		export exists=false
		dbl_echo "DEVMIG_SPECS.sql is missing" 
	fi
   	if [ ! -e  DEVMIG-ETLHST_DATA.dmp ]; then
		export exists=false
		dbl_echo "DEVMIG-ETLHST_DATA.dmp is missing" 
	fi
  	if [ ! -e  GRANTS.sql ]; then
		export exists=false
		dbl_echo "GRANTS.sql is missing" 
	fi
	if [ ! -e  INSIS_MIGRATION_EY__SourceCode_Backup.sql ]; then
		export exists=false
		dbl_echo "INSIS_MIGRATION_EY__SourceCode_Backup.sql is missing" 
	fi
  	if [ ! -e  Create_Install_dir.sql ]; then
		export exists=false
		dbl_echo "Create_Install_dir.sql is missing" 
	fi
   	if [ ! -e  drop_tables_views_packages.sql ]; then
		export exists=false
		dbl_echo "drop_tables_views_packages.sql is missing"  
	fi
	if [ ! -e  setup_and_compile_invalid_packages.sql ]; then
		export exists=false
		ecdbl_echoho "setup_and_compile_invalid_packages.sql is missing"  
	fi
	if [ ! -e  restore_ETL_HST_data_default.par ]; then
		export exists=false
		dbl_echo "restore_ETL_HST_data_default.par is missing"  
	fi
	if [ ! -e  Read_Me-MIGRATION_system_deployment.docx ]; then
		export exists=false
		dbl_echo "Read_Me-MIGRATION_system_deployment.docx is missing"  
	fi
	if [ ! -e  sanity_check_migration.sql ]; then
		export exists=false
		dbl_echo "sanity_check_migration.sql is missing"  
	fi
	if [ ! -e  archive_Schema_code.sql ]; then
		export exists=false
		dbl_echo "archive_Schema_code.sql is missing"  
	fi
	if [ ! -e  setup_compile_archive_schema.sql ]; then
		export exists=false
		dbl_echo "setup_compile_archive_schema.sql is missing"  
	fi
	if [ ! -e  drop_archive_objects.sql ]; then
		export exists=false
		dbl_echo "drop_archive_objects.sql is missing" 
	fi
	if [ ! -e  MIGG.xlsx ]; then
		export exists=false
		dbl_echo "MIGG.xlsx is missing"  
	fi
	if [ ! -e  truncate_ETL_HST_tables.sql ]; then
		export exists=false
		dbl_echo "truncate_ETL_HST_tables.sql is missing"  
	fi
	if [ ! -e  Update_ETL_SETUP_INFO_with_MIGG2_folder.sql ]; then
		export exists=false
		dbl_echo "Update_ETL_SETUP_INFO_with_MIGG2_folder.sql is missing"  
	fi
#  +++ anb 2017-09-08 Check Connection String utility
	if [ ! -e  Check_ConnectionString.sql ]; then
		export exists=false
		dbl_echo "Check_ConnectionString.sql is missing"  
	fi
	if  ! $exists ; then 
		dbl_echo "Either abovementioned files do not exist in folder, or their file names are not the above.  Take care of that and Rerun batch file" 
  		exit 0
	  fi
	}
# End Check file directory	
	
	
# function imput parameters	
	imput_parameters ()
	{
	#:START	
    #  Migration Sytem deployment configuration info
	read -e -p "Please enter instance(SID)/service name: "  instance 
	read -e -p "Please enter IP: "   ip
	read -e -p "Please enter port: "   port
	read -e -p "Please enter Migration system schema: " -i "INSIS_MIGRATION_EY"   schema
	read -e -p "Please enter Migration system schema password: " -i "INSIS_MIGRATION_EY" schema_pwd
	read -e -p "Please enter archive schema: " -i "INSIS_MIGRATION_EY_ARC" arch_schema
	read -e -p "Please enter archive schema password: " -i "INSIS_MIGRATION_EY_ARC" arch_schema_pwd
	echo "instance/service name is " $instance >> spool.txt
	echo "IP is " $ip >> spool.txt	
	echo "port is " $port >> spool.txt
	echo "schema is " $schema >> spool.txt
	echo "schema_pwd is " $schema_pwd >> spool.txt
	echo "arch_schema is " $arch_schema >> spool.txt
	echo "arch_schema_pwd is " $arch_schema_pwd >> spool.txt
    #  SYS password is masked
	read -rs -p "Please enter SYS password: " pword && echo "${pword//?/*}" && sys_pwd=$pword
	#VG 20180918 add export pwd 
	
	if [ ! -e INSIS_configuration_data.sql ]; then
		dbl_echo "INSIS_configuration_data.sql is missing. Take care of that and Rerun batch file." 
		exit 0
	fi
	if [ -e GRANTS_exec.sql ]; then
		rm GRANTS_exec.sql 
	fi
	echo "2">GRANTS_exec.sql
	echo >> GRANTS_exec.sql
	echo "alter session set nls_Language='ENGLISH';" >> GRANTS_exec.sql
	echo "set serveroutput on FORMAT TRUNCATED;" >> GRANTS_exec.sql
	echo "spool spool.txt append;" >> GRANTS_exec.sql
	echo >> GRANTS_exec.sql
	cat GRANTS.sql >> GRANTS_exec.sql
	echo "spool off;" >> GRANTS_exec.sql
	echo "exit;" >> GRANTS_exec.sql
	
#  -- +++ anb 2017-08-17 : Use ConnectString for connecting to Oracle depending on environment.dbl_echo
#  INSISDB = PROD / INSISDB2 = UAT
	export	ConnStringSYS="SYS/${sys_pwd}@${ip}:${port}/${instance} as SYSDBA"
	export	ConnStringSchema="${schema}/${schema_pwd}@${ip}:${port}/${instance}"
	export	ConnStringSchemaArc="${arch_schema}/${arch_schema_pwd}@${ip}:${port}/${instance}"
	}
#  end imput parameters function

# create filesystem 
create_filesystem () 
   {
		dbl_echo "MIGG2 filesystem creation."
		dbl_echo "If exists in given directory, action will be skipped" 
		export dir_flag=1
		while [ $dir_flag -eq 1 ]
		do
			read -e -p "Please enter MIGG2 directory: "   migg2_dir
			cd $migg2_dir 

			if [ $? -eq 0 ] ; then
				export dir_flag=0
				dbl_echo "MIGG2 directory is '$migg2_dir'" 
			else
				dbl_echo "Enter a valid directory below or exit the process." 
				export dir_flag=1
			fi
		done                            

		for X in M01 M02 M03 M04 M08 M09 M10 M11 M14 M15 M16 M21 M24 M27 M28 M29 M31 M32 M34 M35 M37 M42 M43 M50 MIGG_SOURCES MIGG_ARCHIVE MIGG_CLIENTS MIGG_CLIENTS_ARCHIVE
		do 
				if [ ! -e ${migg2_dir}/$X ]; then  
					mkdir ${migg2_dir}/$X
					chmod 777 ${migg2_dir}/$X
					echo "${migg2_dir}/$X was created" >> ${dir}/spool.txt
				else
				    chmod 777 ${migg2_dir}/$X
					echo "${migg2_dir}/$X already exists" >> ${dir}/spool.txt 
				fi		
		done
		for X in M01 M02 M03 M04 M08 M09 M10 M11 M14 M15 M16 M21 M24 M27 M28 M29 M31 M32 M34 M35 M37 M42 M43 M50
		do 
			if [ ! -e ${migg2_dir}/MIGG_ARCHIVE/$X ] ; then
				mkdir ${migg2_dir}/MIGG_ARCHIVE/$X
				chmod 777 ${migg2_dir}/MIGG_ARCHIVE/$X
				echo "${migg2_dir}/MIGG_ARCHIVE/$X was created" >> ${dir}/spool.txt
			else 
			    chmod 777 ${migg2_dir}/MIGG_ARCHIVE/$X
				echo "${migg2_dir}/MIGG_ARCHIVE/$X already exists" >> ${dir}/spool.txt 
			fi		
		done
		if [ ! -e ${migg2_dir}/MIGG_SOURCES\MIGG.xlsx ]; then
			cp ${dir}/MIGG.xlsx ${migg2_dir}/MIGG_SOURCES/MIGG.xlsx 
		else 
			echo "MIGG.xlsx already exists in MIGG_SOURCES directory" >> ${dir}/spool.txt 
		fi
		chmod 777 ${migg2_dir}/MIGG_SOURCES/MIGG.xlsx 
		dbl_echo "About to return to Installation directory path"  
		cd $dir
   }
	
	#  check for existence of all necessary environment database entities (tablespaces and users).
check_db_entities ()
  {
	dbl_echo "About to check for existence of all necessary environment database entities (tablespaces and users)"  
	export tblspace=1
	if [ -e file.txt ]; then 
		rm file.txt 
	fi
	# 		sqlplus -s SYS/%sys_pwd%@localhost:1521/%instance%  as SYSDBA @environment_check.sql > file.txt %schema% %arch_schema%
	sqlplus -s $ConnStringSYS @environment_check.sql > file.txt $schema $arch_schema

	if [ ! -e file.txt ]; then 
		echo "file.txt was not created. Error in tablespaces check" >> spool.txt 
		exit 0
	fi 

	#  necessary objects are 4. if 4 is identified in file.txt then objects exist!!
	grep 4 file.txt	
	if [ $? -eq 1  ]; then 
		export tblspace=0 
	fi

	rm file.txt
  }
  
   #DIR1
	#  -- +++ anb 2017-08-14 : Use OracleHOME directory /ASM for tablespaces
regentblspace ()
  {
	#if [ $recreate == "Y" ] ; then
		dbl_echo "Select location for datafiles to be created in" 
	#	dbl_echo "1.Use folder specified by OracleHOME" 
		dbl_echo "2.Use specific folder" 
		dbl_echo "3.Use ASM"  
                    
		export choice_flag=1
		while [ $choice_flag -eq 1 ]
		do
                    
			echo "Enter your choice(2,3):" >> spool.txt
                                #		CHOICE /C 23 /M "Enter your choice(2,3):"
			read -p "Enter your choice(2,3):" choise_var
                    
			case $choise_var in
			                    
			2)
				#		:UseFolder
				export choice_flag=0
				export dir1_flag=1
                    
				while [ $dir1_flag -eq 1 ]
				do
					export tbl_path
					read -p "Please enter path where datafiles will reside:" tbl_path 
					dbl_echo "datafiles path is defined to be '$tbl_path'" 
                    
					if [ -e chk_oraFld.txt ] ; then
						rm chk_oraFld.txt
					fi
					dbl_echo "Verify validity of path" 
					ls $tbl_path > chk_oraFld.txt
					grep 'File Not Found' chk_oraFld.txt
					if [ $? -eq 1 ] ; then 
						dbl_echo "Path is valid" 
						export dir1_flag=0
					else 
						dbl_echo "directory is not valid. Enter a valid one or exit the process." 
						export dir1_flag=1
					fi
				done
				#		if $dir1_flag==1 (GOTO UseFolder) 	
				#		goto CreateIt
				;;
                    
			3)		
				#		:UseASM
				export choice_flag=0
				export tbl_path="ASM"
                    
				dbl_echo "datafiles path is defined to be '$tbl_path'"  
				#			goto CreateIt
				;;
                    
			*)
			echo "Wrong value. Please enter 2 or 3"
			export choice_flag=1
			;;
		esac	
		done
		#:CreateIt
		sqlplus $ConnStringSYS @ Create_INSIS_MIGRATION_EY.sql  $schema $schema_pwd $tbl_path $arch_schema $arch_schema_pwd
                    
		# if an ORA is found during environment creation abort process!!
		grep "ORA-" spool.txt
		if [ $? -eq 1 ] ; then
			#echo "no error in environment creation" >> spool.txt
			dbl_echo "no error in environment creation" 
		else 
			#echo "ORA- found in environment creation" >> spool.txt
			dbl_echo "ORA- found in environment creation" 
			exit 0
		fi
                    
		#  -----------------------------------------------------------------
		# verify schema connection string	
		if [ -e chk_ConnStr.txt ] ; then
			rm chk_ConnStr.txt
		fi
		#echo "Checking $schema Connection String"
		#echo "Checking $schema Connection String"  >> spool.txt
		dbl_echo "Checking $schema Connection String"

		sqlplus $ConnStringSchema  @ Check_ConnectionString.sql > chk_ConnStr.txt
		grep "$schema" chk_ConnStr.txt
		if [ $? -eq 1 ] ; then
			dbl_echo "issues with $schema Connection String" 
			exit 0
		else 
			#echo "$schema Connection String ok" >> spool.txt
			dbl_echo "$schema Connection String ok!"				
		fi
		#echo "$schema Connection String ok!"				
                    
		#  -----------------------------------------------------------------				
		#  verify Archive schema connection string
		if [ -e chk_ConnStr.txt ] ; then
			rm chk_ConnStr.txt
		fi
		dbl_echo "Checking $arch_schema Connection String" 
		sqlplus $ConnStringSchemaArc  @ Check_ConnectionString.sql > chk_ConnStr.txt
		grep "$arch_schema" chk_ConnStr.txt
		if [ $? -eq 1 ] ; then
			dbl_echo "issues with %arch_schema% Connection String" 
			exit 0
		else
			#echo "$arch_schema Connection String ok" >> spool.txt
			dbl_echo "$arch_schema Connection String ok"				
		fi
		#echo "$arch_schema Connection String ok"				
                    
		#  -----------------------------------------------------------------
                    
		dbl_echo "Tablespaces and users were created!" 
	#fi
	
   }
   # end regenerate tablespaces
#create new schema and grants
creat_schema ()
    {
	#(LEAVE)
	#  create MIGR_INST_DIR and grant dir privileges to new schema
	dbl_echo "About to create MIGR_INST_DIR and grant dir privileges to new schema" >> spool.txt

	sqlplus $ConnStringSYS  @ Create_Install_dir.sql $dir $schema

	dbl_echo "About to drop previous deployment objects, if exist" 

	sqlplus $ConnStringSchema  @ drop_tables_views_packages.sql   

	dbl_echo "About to drop previous deployment objects in Archive schema, if exist"   

	sqlplus $ConnStringSchemaArc  @ drop_archive_objects.sql  $arch_schema

	if [ -e DEVMIG_SPECS_exec.sql ] ; then
		rm DEVMIG_SPECS_exec.sql 
	fi
	echo 2>DEVMIG_SPECS_exec.sql
	echo >> DEVMIG_SPECS_exec.sql
	echo "alter session set nls_Language='ENGLISH';" >> DEVMIG_SPECS_exec.sql
	echo "set serveroutput on FORMAT TRUNCATED;" >> DEVMIG_SPECS_exec.sql
	echo "spool spool.txt append;" >> DEVMIG_SPECS_exec.sql
	echo >> DEVMIG_SPECS_exec.sql
	cat DEVMIG_SPECS.sql >> DEVMIG_SPECS_exec.sql
	echo "spool off;" >> DEVMIG_SPECS_exec.sql
	echo "exit;" >> DEVMIG_SPECS_exec.sql

	#echo "About to install DDL" >> spool.txt
	dbl_echo "About to install DDL" 

	sqlplus $ConnStringSchema  @ DEVMIG_SPECS_exec.sql   

	#echo "About to grant privileges to migration schema" >> spool.txt
	dbl_echo "About to grant privileges to migration schema"

	sqlplus $ConnStringSYS  @ GRANTS_exec.sql $schema
	
	dbl_echo "End grands!!!"
	}  
	#end create new schema
	
	
   # DAta insert -------------------------------
insert_data () 
   {
    dbl_echo "Start inser data"
	export mode_flag=0
	#echo "About to create MIGR_INST_DIR and grant dir privileges to Migration schema" >> spool.txt
	echo "About to create MIGR_INST_DIR and grant dir privileges to Migration schema"
	sqlplus $ConnStringSYS @ Create_Install_dir.sql $dir $schema

	#echo "About to truncate configuration tables" >> spool.txt
	echo "About to truncate configuration tables" 
	sqlplus $ConnStringSchema  @ truncate_ETL_HST_tables.sql

	#echo "About to grant privileges to migration schema" >> spool.txt
	dbl_echo "About to grant privileges to migration schema"
	sqlplus $ConnStringSYS  @ GRANTS_exec.sql $schema				
	
	echo "For mode <> Package mode"

	#  check for existing data in ETL_SETUP_INFO -- creates rec_count.txt 
	dbl_echo "About to check if configuration tables are empty" >> spool.txt

	if [ -e rec_count.txt ] ; then
		rm rec_count.txt 
	fi
	
	sqlplus $ConnStringSchema  @ check_for_existing_data.sql $schema

	if [ ! -e rec_count.txt ] ; then
		dbl_echo "error in check for existing configuration data"  
		exit 0		
	fi

	#  remove parameter-relative lines from rec_count.txt -- creates rec_count1.txt
	grep -v -e 'old' -e 'new' rec_count.txt > rec_count1.txt  

	#  find number other than zero
	echo "existing data checking."
	grep [1-9] rec_count1.txt 	
	#  if no number in [1-9] exists, then execute impdp, else just print warning saying that there is existing data in target schema
	if [ $? -eq 1 ] ; then
#		 (GOTO NOTFOUND) 
		#:NOTFOUND
			dbl_echo "Target schema is empty. Data import will follow"  

#  dynamic update of target schema in par file 
#			export qq='"'
	export q="'"
#			export var1=$qq$q$schema$q$qq
	export var1=$q$schema$q

	if [ -e restore_ETL_HST_data.par ] ; then
		rm restore_ETL_HST_data.par 
	fi
# ADD dynamic import schema 2018-06-07 vg
   strings DEVMIG-ETLHST_DATA.dmp  | grep -m 1 -o -P '(?<=<OWNER_NAME>).*(?=</OWNER_NAME)' > owner.txt
   export impschema=$(cat owner.txt)
   if [ -e restore_ETL_HST_data1.par ] ; then
		rm restore_ETL_HST_data1.par 
	fi
	
	
	echo 2>restore_ETL_HST_data.par

	cat restore_ETL_HST_data_default.par | sed "s/owner=/owner=$var1/g" > restore_ETL_HST_data.par

	if [ $? -ne 0 ] ; then
		dbl_echo "Error in impdp par file dynamic creation"  
		exit 0 
	fi

	cat restore_ETL_HST_data.par | sed "s/schemas=INSIS_MIGRATION_EY/schemas=$impschema/g" > restore_ETL_HST_data1.par
	
	if [ -e import.log ] ; then
		rm import.log
	fi


	impdp $ConnStringSchema  PARFILE=restore_ETL_HST_data1.par remap_schema=$impschema:$schema LOGFILE=import.log

	if [ -e import.log ] ; then
		echo>> spool.txt
		cat import.log >> spool.txt
	else 
		#echo "ERROR. No IMPDP logfile" >> spool.txt
		dbl_echo "ERROR. No IMPDP logfile" 
		exit 0 
	fi

	#echo "About to load ${instance}-specific configuration data" >> spool.txt
	dbl_echo "About to load ${instance}-specific configuration data"
	sqlplus $ConnStringSchema  @INSIS_configuration_data.sql

	rm rec_count1.txt
	rm rec_count.txt
	#echo "Data are loaded."
	dbl_echo "Data was loaded."

	if [ $mode -eq 2 ]; then
		exit 0
	else 	
	    #sqlplus $ConnStringSchema  @add_os_slash.sql
		sqlplus $ConnStringSchema  @Update_ETL_SETUP_INFO_with_MIGG2_folder.sql $migg2_dir $os_slash
	fi
	else  
#		 (GOTO FOUND) 
#		:FOUND
			#echo "Target Schema is not empty. Data will not be loaded and Deployment will stop!"
			#echo "Target Schema is not empty. Data will not be loaded and Deployment will stop!" >> spool.txt
			dbl_echo "Target Schema is not empty. Data will not be loaded and Deployment will stop!"
			rm rec_count1.txt
			rm rec_count.txt
			exit 0
		fi
	}
	
# Packages
insert_packages () 
	{
	#:PACKAGES	
	#echo "About to create MIGR_INST_DIR and grant dir privileges to Migration schema" >> spool.txt
	dbl_echo "About to create MIGR_INST_DIR and grant dir privileges to Migration schema" 
	sqlplus $ConnStringSYS  @ Create_Install_dir.sql $dir $schema

	#echo "About to grant privileges to migration schema" >> spool.txt
	dbl_echo "About to grant privileges to migration schema" 
	sqlplus $ConnStringSYS @ GRANTS_exec.sql $schema 

	dbl_echo "About to install packages"  
# 	sqlplus ${schema}/${schema_pwd}@localhost:1521/$instance  @ INSIS_MIGRATION_EY__SourceCode_Backup.sql $os_slash
	sqlplus $ConnStringSchema  @ INSIS_MIGRATION_EY__SourceCode_Backup.sql  $os_slash
	#echo "Packages installed."
	dbl_echo "Packages installed."
	echo
	if [ $mode -eq 1 ] ; then
		dbl_echo "About to run Migration Setup. This will take a while..." 
# 		sqlplus ${schema}/${schema_pwd}@localhost:1521/$instance  @ setup_and_compile_invalid_packages.sql  
		sqlplus $ConnStringSchema  @ setup_and_compile_invalid_packages.sql  
	fi

	dbl_echo "About to install archive schema code and grant relative privileges to migration user" 

	sqlplus $ConnStringSchemaArc @ archive_Schema_code.sql  $schema



	if [ $mode -eq 1 ] ; then
		dbl_echo "About to run archive schema setup"  

		sqlplus $ConnStringSchema  @ setup_compile_archive_schema.sql   $arch_schema
		dbl_echo "Sanity check follows"  

# 		sqlplus ${schema}/${schema_pwd}@localhost:1521/$instance  @ sanity_check_migration.sql
		sqlplus $ConnStringSchema  @ sanity_check_migration.sql
		dbl_echo "For deployment status, please refer to Spool.txt which resides in the deployment folder."
	fi
	}

	
#Main Program ------------------------------------------------------------------------
   clear

##added for ora_inv 20190708
  source setDB.env
## end added  
  
	export StartDateTime=$(date '+%F %T')
	export os_slash="/"
# Required to export Swedish characters correctly and display results in english
	export NLS_LANG=.al32utf8
	export LANG=en_US.utf8
# delete (if exists) and create spool.txt
	if [ -e spool.txt ]; then
		rm spool.txt
		echo "Delete spool.txt"
	fi
	echo 'Starting new spool' >spool.txt
	export dir_flag=0
    #:DIR
    #  get current directory and set Installation directory path
	
	export dir=$PWD
	export dir_flag=0
	#echo "Deployment directory is $dir"
	#echo "Deployment directory is $dir"  >> spool.txt
	dbl_echo "Deployment directory is $dir" 
    #  necessary files existence validation
	#echo "Checking files"
	dbl_echo "Checking files"
	check_files
	imput_parameters
	
	export mode
	export mode_flag=1
	while [ $mode_flag -eq 1 ]
	do
		echo "Please enter deployment mode"
		echo "1 for Full deployment"
		echo "2 for Data ONLY"
		echo "3 for code ONLY"
		read -p "4 Exit : " mode
#		echo "DepPlease enter deployment modeloyment mode value is " $mode >> spool.txt
		echo "Deployment mode is " $mode >> spool.txt
        case $mode in
			1)
				create_filesystem
				check_db_entities
				
				if [ $tblspace -eq 0 ] ; then
					dbl_echo "Missing database entity. Environment will be dropped and recreated"  
					regentblspace
				else 
					dbl_echo "All necessary database entities exist. Question to drop and recreate environment, irrespective of the fact that all DB entities exist, follows"  		
					export quest_flag=1
                	while [ $quest_flag -eq 1 ]
                		do
                			read -p  "Drop existing environment and recreate it?(Y/N):" recreate
                			echo "answer to drop-environment question is $recreate " >>spool.txt
                			export quest_flag=0
                			if [ $recreate != "Y" ] && [ $recreate != "N" ] ; then
                   				echo "Wrong value. Please enter Y or N" >> spool.txt
                				echo "Wrong value. Please enter Y or N"
                				export quest_flag=1
                			else
                			  if [ $recreate == "Y" ] ; then
                			  	regentblspace
                			  fi	
                			  export quest_flag=0
                			fi                			
                   		done
				fi
				creat_schema
				insert_data
				insert_packages
				export dir1_flag=0
			;;

			2) 
			insert_data
			export mode_flag=0
			;;

			3) 
			insert_packages
			export mode_flag=0
			;;
			
			4)
			exit 0
			;;

			*)	
			echo "Wrong value. Please enter 1, 2 or 3"
			export mode_flag=1
			;;
		esac	
		echo "mode_flag= $mode_flag "
	done
	
	

	
	dbl_echo "Migration Deployment is finished!"  

	export EndDateTime=$(date '+%F %T')
	dbl_echo "Deployment finished at $EndDateTime"
	dbl_echo "Deployment started  at $StartDateTime"

	
	echo "Exiting programm"
	chmod 777 *
	exit 0	