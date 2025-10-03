set line 200 pages 200;
col HOST_NAME for a15;

select d.name,i.instance_name,i.host_name,d.OPEN_MODE,d.DATABASE_ROLE,d.log_mode,d.CONTROLFILE_TYPE,d.SWITCHOVER_STATUS from v$database d,v$instance i;
