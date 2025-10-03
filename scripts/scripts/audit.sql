col USERNAME for a15;
col TIMESTAMP for a20;
col OBJ_NAME for a20;
col SQL_TEXT for a70;
set line 200 pages 200;

select username, to_char(timestamp,'MM/DD/YY HH24:MI') Timestamp,obj_name, action_name, sql_text from dba_audit_trail where username = '&username';
