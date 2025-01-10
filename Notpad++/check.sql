orain1> cat in1.sql

define last_db_size=311.94



!echo "*******************************************Database_info*******************************************"
select name,open_mode,log_mode,database_role,controlfile_type from v$database;

!echo "*******************************************Physical Size*******************************************"

select round(sum(bytes/1024/1024/1024),2) "Total_Size_IN_GB" from dba_data_files;

!echo "*******************************************Logical _size*******************************************"

select round(sum(bytes/1024/1024/1024),2) "Actual_Used_IN_GB" from dba_segments;

!echo "*******************************************Invalid Count*******************************************"

select count(*) "Invalid Count" from dba_objects where status='INVALID';

!echo "*******************************************Last Database Restart***********************************"

set lines 9000
set pages 9000
set long 99999
col host_name for a5
col instance_name for a10
col Uptime for a15
select
'Hostname : ' || host_name
,'Instance Name : ' || instance_name
,'Started At : ' || to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') stime
,'Uptime : ' || floor(sysdate - startup_time) || ' days(s) ' ||
trunc( 24*((sysdate-startup_time) -
trunc(sysdate-startup_time))) || ' hour(s) ' ||
mod(trunc(1440*((sysdate-startup_time) -
trunc(sysdate-startup_time))), 60) ||' minute(s) ' ||
mod(trunc(86400*((sysdate-startup_time) -
trunc(sysdate-startup_time))), 60) ||' seconds' uptime
from sys.v_$instance;

!echo "*******************************************SGA Details*********************************************"

select sum(VALUE)/1024/1024 "SGA (MB)" FROM v$sga;

Select sum(bytes/1024/1024) Free_Memory_In_MB From V$sgastat Where Name Like '%free memory%';

!echo "*******************************************Listener_status******************************************"

!lsnrctl status

!echo "*****************************************Archive Generation*****************************************"

select trunc(COMPLETION_TIME,'DD') Day, thread#,
round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB,
count(*) Archives_Generated from v$archived_log where COMPLETION_TIME > sysdate-3
group by trunc(COMPLETION_TIME,'DD'),thread# order by 1;

!echo "*******************************************Tnsping_check*********************************************"

!tnsping IN1.WORLD

!echo "*********************************************CPU_idle*************************************************"

!top -bn3 | grep '%Cpu(s)' | awk -F',' '{printf "CPU id %: %.2f%\n", $4}'

!echo "*******************************************Memory_utilization******************************************"

!free | awk '/Mem/{printf("RAM Usage: %.2f\n"), $3/$2*100}'| awk '{print $3"%"}'

!echo "******************************************Active Session**********************************************"

select count(*) "Active Session" from v$session where status IN ('ACTIVE');

!echo "*******************************************Process Count*******************************************"

select resource_name, current_utilization, max_utilization from v$resource_limit where resource_name in ('processes','sessions');

!echo "*****************************************Inactive Session*****************************************"

select count(*) "Inactive Holding Resource" from v$session where username is not null and status ='INACTIVE' and module is not null;

!echo "************************************Archive_Trace Mount point****************************************"

!df -h /oracle/IN1/oraarch /oracle/IN1/saptrace

!df -h  /oracle/IN4/oraarch /oracle/IN4/saptrace

!df -h  /oracle/IN2/oraarch /oracle/IN2/saptrace


select status, count(*) from dba_scheduler_job_run_details group by status;

!echo "********************************************Temp Usage*******************************************"

!echo "*********************************************Db_growth*******************************************"

select "Actual_Used_IN_GB" - &last_db_size "DB_GROWTH" from
(
select round(sum(bytes/1024/1024/1024),2) "Actual_Used_IN_GB" from dba_segments
);

!echo "*************************************Invalid Count************************************************"

select count(*) "Invalid Count" from dba_objects where status='INVALID';

!echo "****************************************RMAN BACKUP***********************************************"

set lines 150
set pages 900
col start for a20
col end for a20
col status format a11
col input_bytes_display format a10
col output_bytes_display format a10
col status_weight format 99999
SELECT to_char(start_time,'YYYY.MM.DD HH24:MI') "Start",to_char(end_time,'YYYY.MM.DD HH24:MI') "End",status,status_weight,input_type,input_bytes_display,   output_bytes_display,OUTPUT_DEVICE_TYPE
FROM V$RMAN_BACKUP_JOB_DETAILS order by start_time desc;

!echo "*****************************************Tablespace Info******************************************"

set pages 50000 lines 32767
col tablespace_name format a30
col TABLESPACE_NAME heading "Tablespace|Name"
col Allocated_size heading "Allocated|Size(MB)" form 99999999.99
col Current_size heading "Current|Size(MB)" form 99999999.99
col Used_size heading "Used|Size(MB)" form 99999999.99
col Available_size heading "Available|Size(MB)" form 99999999.99
col Pct_used heading "%Used (vs)|(Allocated)" form 99999999.99
select a.tablespace_name
,a.alloc_size/1024/1024 Allocated_size
,a.cur_size/1024/1024 Current_Size
,(u.used+a.file_count*65536)/1024/1024 Used_size
,(a.alloc_size-(u.used+a.file_count*65536))/1024/1024 Available_size
,((u.used+a.file_count*65536)*100)/a.alloc_size Pct_used
from dba_tablespaces t
,(select t1.tablespace_name
,nvl(sum(s.bytes),0) used
from dba_segments s
,dba_tablespaces t1
where t1.tablespace_name=s.tablespace_name(+)
group by t1.tablespace_name) u
,(select d.tablespace_name
,sum(greatest(d.bytes,nvl(d.maxbytes,0))) alloc_size
,sum(d.bytes) cur_size
,count(*) file_count
from dba_data_files d
group by d.tablespace_name) a
where t.tablespace_name=u.tablespace_name
and t.tablespace_name=a.tablespace_name;







define last_db_size=159.93
