set line 200 pages 200;

col INDEX_NAME for a20;
col TABLE_NAME for a20;
col COLUMN_NAME for a20;

select INDEX_NAME,TABLE_NAME,COLUMN_NAME from user_ind_columns  where TABLE_NAME='&table_name';

