-- 当班人员每天2次， 早上上班后一次， 下班回家后一次
-- # 开4个terminal，先进入控制台
-- bin/remote prod

-- # 执行 psql $DATABASE_URL , 连上数据库
psql $DATABASE_URL

-- # 推荐先吸重要的4张表，再吸全部
vacuum verbose analyze event_store_messages;
vacuum verbose analyze event_store_completions;
vacuum verbose analyze listings;
vacuum verbose analyze products;
vacuum verbose analyze listing_variations;
vacuum verbose analyze product_variations;

vacuum verbose analyze problems;
vacuum verbose analyze images;
vacuum verbose analyze accounts;
vacuum verbose analyze shipping_profiles;
vacuum verbose analyze shipping_ebay_profiles;
vacuum verbose analyze orders;
vacuum verbose analyze order_lines;
vacuum verbose analyze parcels;
vacuum verbose analyze known_category_aspects_translation;
vacuum verbose analyze product_import_items;
vacuum verbose analyze addresses;
vacuum verbose analyze showcases;
vacuum verbose analyze product_ratings;
# 吸全部
VACUUM verbose ANALYZE;

-- 查询死元组
SELECT relname,n_dead_tup,n_mod_since_analyze,last_vacuum,last_autovacuum
FROM pg_stat_all_tables
WHERE schemaname = 'public'
order by n_dead_tup desc;

-- 吸async_proxy
vacuum verbose analyze proxy_requests;
vacuum verbose analyze proxy_requests_old;
vacuum verbose analyze goose_db_version;

select count(1) from proxy_requests;

CREATE INDEX known_category_aspects_translation_category_id_idx
    ON known_category_aspects_translation (category_id);

select count(1) from
    listings l
        inner join accounts ac on l.user_id=ac.user_id
        and ac.country in ('CN','TW','HK','AU','NZ','PL', 'NL', 'IE', 'AT', 'BE', 'CH', 'ES','US','UK','CA','DE')
where l.managed=true and l.item_id is not null;

-- 获取正在运行的连接
-- select pg_terminate_backend(pid) from(
select * from (
                  SELECT pid,now()-backend_start as time,usename,datname,client_addr,state,query,backend_start
                  FROM
                      pg_stat_activity
                  WHERE
                      state = 'active'
              )a
-- where time>'00:30:00'
order by time desc;

select pg_terminate_backend(pid) from(
                  SELECT pid,now()-backend_start as time,usename,datname,client_addr,state,query,backend_start
                  FROM
                      pg_stat_activity
                  WHERE
                      state = 'active'
              )a
where time>'00:30:00';


SELECT pg_terminate_backend(pid);


-- 锁
select w1.pid as 等待进程,
       w1.mode as 等待锁模式,
       w2.usename as 等待用户,
       w2.query as 等待会话,
       b1.pid as 锁的进程,
       b1.mode 锁的锁模式,
       b2.usename as 锁的用户,
       b2.query as 锁的会话,
       b2.application_name 锁的应用,
       b2.client_addr 锁的IP地址,
       b2.query_start 锁的语句执行时间
from pg_locks w1
         join pg_stat_activity w2 on w1.pid=w2.pid
         join pg_locks b1 on w1.transactionid=b1.transactionid and w1.pid!=b1.pid
join pg_stat_activity b2 on b1.pid=b2.pid
where not w1.granted;

--查死锁
WITH RECURSIVE
    c(requested, current) AS
        ( VALUES
              ('AccessShareLock'::text, 'AccessExclusiveLock'::text),
              ('RowShareLock'::text, 'ExclusiveLock'::text),
              ('RowShareLock'::text, 'AccessExclusiveLock'::text),
              ('RowExclusiveLock'::text, 'ShareLock'::text),
              ('RowExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
              ('RowExclusiveLock'::text, 'ExclusiveLock'::text),
              ('RowExclusiveLock'::text, 'AccessExclusiveLock'::text),
              ('ShareUpdateExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
              ('ShareUpdateExclusiveLock'::text, 'ShareLock'::text),
              ('ShareUpdateExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
              ('ShareUpdateExclusiveLock'::text, 'ExclusiveLock'::text),
              ('ShareUpdateExclusiveLock'::text, 'AccessExclusiveLock'::text),
              ('ShareLock'::text, 'RowExclusiveLock'::text),
              ('ShareLock'::text, 'ShareUpdateExclusiveLock'::text),
              ('ShareLock'::text, 'ShareRowExclusiveLock'::text),
              ('ShareLock'::text, 'ExclusiveLock'::text),
              ('ShareLock'::text, 'AccessExclusiveLock'::text),
              ('ShareRowExclusiveLock'::text, 'RowExclusiveLock'::text),
              ('ShareRowExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
              ('ShareRowExclusiveLock'::text, 'ShareLock'::text),
              ('ShareRowExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
              ('ShareRowExclusiveLock'::text, 'ExclusiveLock'::text),
              ('ShareRowExclusiveLock'::text, 'AccessExclusiveLock'::text),
              ('ExclusiveLock'::text, 'RowShareLock'::text),
              ('ExclusiveLock'::text, 'RowExclusiveLock'::text),
              ('ExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
              ('ExclusiveLock'::text, 'ShareLock'::text),
              ('ExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
              ('ExclusiveLock'::text, 'ExclusiveLock'::text),
              ('ExclusiveLock'::text, 'AccessExclusiveLock'::text),
              ('AccessExclusiveLock'::text, 'AccessShareLock'::text),
              ('AccessExclusiveLock'::text, 'RowShareLock'::text),
              ('AccessExclusiveLock'::text, 'RowExclusiveLock'::text),
              ('AccessExclusiveLock'::text, 'ShareUpdateExclusiveLock'::text),
              ('AccessExclusiveLock'::text, 'ShareLock'::text),
              ('AccessExclusiveLock'::text, 'ShareRowExclusiveLock'::text),
              ('AccessExclusiveLock'::text, 'ExclusiveLock'::text),
              ('AccessExclusiveLock'::text, 'AccessExclusiveLock'::text)
        ),
    l AS
        (
            SELECT
                (locktype,DATABASE,relation::regclass::text,page,tuple,virtualxid,transactionid,classid,objid,objsubid) AS target,
                virtualtransaction,
                pid,
                mode,
                granted
            FROM pg_catalog.pg_locks
        ),
    t AS
        (
            SELECT
                blocker.target  AS blocker_target,
                blocker.pid     AS blocker_pid,
                blocker.mode    AS blocker_mode,
                blocked.target  AS target,
                blocked.pid     AS pid,
                blocked.mode    AS mode
            FROM l blocker
                     JOIN l blocked
                          ON ( NOT blocked.granted
                              AND blocker.granted
                              AND blocked.pid != blocker.pid
              AND blocked.target IS NOT DISTINCT FROM blocker.target)
                     JOIN c ON (c.requested = blocked.mode AND c.current = blocker.mode)
        ),
    r AS
        (
            SELECT
                blocker_target,
                blocker_pid,
                blocker_mode,
                '1'::int        AS depth,
                    target,
                pid,
                mode,
                blocker_pid::text || ',' || pid::text AS seq
            FROM t
            UNION ALL
            SELECT
                blocker.blocker_target,
                blocker.blocker_pid,
                blocker.blocker_mode,
                blocker.depth + 1,
                blocked.target,
                blocked.pid,
                blocked.mode,
                blocker.seq || ',' || blocked.pid::text
            FROM r blocker
                     JOIN t blocked
                          ON (blocked.blocker_pid = blocker.pid)
            WHERE blocker.depth < 1000
        )
SELECT * FROM r
ORDER BY seq;
--kill 死锁
--SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid='2218217'