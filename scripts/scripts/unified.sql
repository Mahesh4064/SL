
set line 200 pages 200;
col event_timestamp format a30
col dbusername format a10
col action_name format a20
col object_schema format a10
col object_name format a20

select event_timestamp, dbusername, action_name, object_schema,object_name,SQL_TEXT from   unified_audit_trail where  dbusername = '&username' order by event_timestamp;
