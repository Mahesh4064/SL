set line 200 pages 2000;
 col MEMBER for a50; 

select  a.GROUP#,a.sequence#,a.BYTES/1024/1024,a.MEMBERS,a.STATUS,b.TYPE,b.MEMBER from v$log a,v$logfile b where a.GROUP#=b.GROUP#;
