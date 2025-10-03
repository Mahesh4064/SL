set line 200 pages 200;
col name for a20;
col VALUE for a20;

select NAME,VALUE,ISSES_MODIFIABLE,ISSYS_MODIFIABLE from v$parameter where NAME='&name';
