set echo off;
set pages 0;
set head off;
set feed off;
with cte as ( select count('x')   as cnt
                from       dba_tablespaces
                where      tablespace_name='TEMPMIG01'
                union     all
                select count('x')    as cnt
                from       dba_tablespaces
                where      tablespace_name='INSIS_MIGR_EY'
                union all
                select COUNT('x') AS cnt
                from all_users
                where username in( '&1', '&2'))
  select sum(cnt) || ' of the necessary entities exist' from cte; 
exit;
