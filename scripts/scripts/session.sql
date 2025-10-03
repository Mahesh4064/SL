set line 200 pages 200;
col USERNAME for a10;

select s.sid,s.serial#,s.username,s.paddr "SESS_PROC_ADD",s.saddr "SESSION_ADD",p.addr "PROCESS_ADD",p.SPID,p.username "RPOC_NAME" from v$session s,v$process p where p.addr=s.paddr and s.username is not null;
