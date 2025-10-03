set line 200 pages 200;
col LIMIT for a20;
col PROFILE for a15;

select PROFILE,RESOURCE_NAME,RESOURCE_TYPE,LIMIT from dba_profiles where  PROFILE='&profile';
