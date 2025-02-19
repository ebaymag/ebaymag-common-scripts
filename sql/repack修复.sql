-- insert pg_repack error case处理

-- 1. 先查repack_trigger是否存在
SELECT
    n.nspname as schema_name,
    c.relname as table_name,
    t.tgname as trigger_name
FROM
    pg_trigger t
        JOIN
    pg_class c ON t.tgrelid = c.oid
        JOIN
    pg_namespace n ON c.relnamespace = n.oid
where t.tgname = 'repack_trigger';

-- 2. 具体确认repack语句是否是报错的语句
select *, pg_get_triggerdef(oid) from pg_trigger t where tgname = 'repack_trigger';

-- 3. 先干掉repack_trigger停掉同步， 再干掉repack的schema下的所有临时表
DROP TRIGGER repack_trigger ON listings_16;
DROP TABLE repack.log_34688671;
DROP TABLE repack.table_34688671;
DROP TABLE repack.log_34688767;
DROP TABLE repack.table_34688767;