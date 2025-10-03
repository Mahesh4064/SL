set lines 200
col MEMBER for a60
select a.group#, a.SEQUENCE#, a.thread#, b.member, a.status, (bytes/1024/1024) fsize
from v$log a, v$logfile b where a.group# = b.group#
order by 3,1;
