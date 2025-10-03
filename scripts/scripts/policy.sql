set line 200 pages 200;
col audit_option format a15
col condition_eval_opt format a10
col audit_condition format a50
col OBJECT_SCHEMA for a20
col OBJECT_NAME for a20
col OBJECT_TYPE for a20

select audit_option, condition_eval_opt,OBJECT_SCHEMA,OBJECT_NAME,OBJECT_TYPE, audit_condition from   audit_unified_policies where  policy_name = '&policy';

