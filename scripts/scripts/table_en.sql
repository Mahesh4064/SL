set line 200 pages 200
col owner for a15;
col table_name for a15;
col column_name for a15;
col encryption_alg for a20;

select owner,table_name,column_name,encryption_alg from dba_encrypted_columns where table_name='&table_name' and owner='&owner';

