


ALTER session SET NLS_LANGUAGE='ENGLISH';

set serveroutput on FORMAT TRUNCATED;

spool spool.txt append;

--archive schema procedures. to be created in archive schema

CREATE OR REPLACE PROCEDURE DROP_TBL (TBL_NAME IN VARCHAR2)
    IS
    vSQL    VARCHAR2(250 BYTE);


BEGIN
 
        vSQL := 'DROP TABLE ' || TBL_NAME || ' CASCADE CONSTRAINTS PURGE';
        EXECUTE IMMEDIATE vSQL;
 

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
	if (SQLCODE=-942) then 
		null;
	else 
    		DBMS_OUTPUT.PUT_LINE(SQLCODE || '-' || SUBSTR(SQLERRM, 1, 200));
	end if;
END;
/

CREATE OR REPLACE PROCEDURE GRANT_ALL_TBL (MY_SCHEMA IN VARCHAR2)
    IS
    vSQL    VARCHAR2(250 BYTE);

BEGIN

    FOR cREC IN (SELECT TABLE_NAME FROM USER_TABLES)
    LOOP
        vSQL := 'GRANT ALL ON ' || cREC.TABLE_NAME || ' TO ' || MY_SCHEMA;
        EXECUTE IMMEDIATE vSQL;
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLCODE || '-' || SUBSTR(SQLERRM, 1, 200));
END;
/

--grant privileges on above procedures to migration system schema 

grant all on DROP_TBL to &1;

grant all on GRANT_ALL_TBL  to &1;

spool off;

exit;