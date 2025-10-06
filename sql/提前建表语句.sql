-- 建表语句

-- DO $$
-- DECLARE
--   i integer;
-- BEGIN
--   FOR i IN 151..200 LOOP
--      EXECUTE format('CREATE TABLE IF NOT EXISTS public.listings_%s PARTITION OF public.listings FOR VALUES FROM (%s000) TO (%s000)', i, i, i+1);
--   END LOOP;
-- END $$;
# 如果order_lines没法直接加上外键，则在创建分表的时候还需要把它的外键也加上
# 如果product_sync_tasks没法直接加上外键，则在创建分表的时候还需要把它的外键也加上
# stmt := format('ALTER TABLE order_lines ADD CONSTRAINT fk_order_lines_listing_id_%s FOREIGN KEY(user_id, listing_id) REFERENCES listings_%s(user_id, id) ON UPDATE CASCADE ON DELETE CASCADE;', i, i);
# RETURN NEXT stmt;
# stmt := format('ALTER TABLE product_sync_tasks ADD CONSTRAINT fk_product_sync_tasks_listing_id_%s FOREIGN KEY(user_id, listing_id) REFERENCES listings_%s(user_id, id) ON UPDATE CASCADE ON DELETE CASCADE;', i, i);
# RETURN NEXT stmt;
CREATE OR REPLACE FUNCTION generate_listings_paritions_statements()
RETURNS SETOF text AS $$
DECLARE
i integer;
   stmt text;
BEGIN
FOR i IN 201..250 LOOP
      stmt := format('CREATE TABLE IF NOT EXISTS public.listings_%s PARTITION OF public.listings FOR VALUES FROM (%s000) TO (%s000)', i, i, i+1));
      RETURN NEXT stmt;
      stmt := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS listing_%s_new_id_only_idx ON listings_%s USING btree(id);', i, i);
      RETURN NEXT stmt;
      stmt := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS listing_%s_account_id_new_id_idx ON listings_%s USING btree(account_id) INCLUDE(id);', i, i);
      RETURN NEXT stmt;
      stmt := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS listing_%s_category_id_new_id_idx ON listings_%s USING btree(category_id) INCLUDE(id) WHERE category_id IS NOT NULL;', i, i);
      RETURN NEXT stmt;
      stmt := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS listings_%s_source_id_new_id_idx ON listings_%s USING btree(source_id) INCLUDE(id) WHERE managed = true;', i, i);
      RETURN NEXT stmt;
      stmt := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS listings_%s_user_id_new_id_idx ON listings_%s USING btree(user_id) INCLUDE(id);', i, i);
      RETURN NEXT stmt;
      stmt := format('CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS listing_%s_new_id_idx ON listings_%s USING btree(user_id, id);', i, i);
      RETURN NEXT stmt;
      stmt := format('CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS listings_%s_source_id_site_id_user_id_new_id_idx ON listings_%s USING btree(source_id, site_id, user_id) INCLUDE(id);', i, i);
      RETURN NEXT stmt;
END LOOP;
END;
$$ LANGUAGE plpgsql;
-- 进入remote控制台，执行
psql -d $DATABASE_URL -c "SELECT generate_listings_paritions_statements()" -tA | psql -d $DATABASE_URL


-- DO $$
-- DECLARE
--   i integer;
-- BEGIN
--   FOR i IN 151..200 LOOP
--      EXECUTE format('CREATE TABLE IF NOT EXISTS public.listing_variations_%s PARTITION OF public.listing_variations FOR VALUES FROM (%s000) TO (%s000)', i, i, i+1);
--   END LOOP;
-- END $$;

-- listing_variations分表
CREATE OR REPLACE FUNCTION generate_listing_variations_partitions_statements()
RETURNS SETOF text AS $$
DECLARE
i integer;
   stmt text;
BEGIN
FOR i IN 201..250 LOOP
      stmt := format('CREATE TABLE IF NOT EXISTS public.listing_variations_%s PARTITION OF public.listing_variations FOR VALUES FROM (%s000) TO (%s000)', i, i, i+1);
      RETURN NEXT stmt;
      stmt := format('CREATE INDEX CONCURRENTLY IF NOT EXISTS listing_variations_%s_new_listing_id_idx ON listing_variations_%s USING btree(listing_id) INCLUDE (id);', i, i);
      RETURN NEXT stmt;
      stmt := format('CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS listing_variations_%s_new_listing_id_source_id_user_id_idx ON listing_variations_%s USING btree(listing_id, source_id, user_id);', i, i);
      RETURN NEXT stmt;
      stmt := format('ALTER TABLE listing_variations_%s ADD CONSTRAINT fk_listing_variations_%s_listing_id_new FOREIGN KEY(listing_id, user_id) REFERENCES listings_%s(id, user_id) ON UPDATE CASCADE ON DELETE CASCADE;', i, i, i);
      RETURN NEXT stmt;
END LOOP;
END;
$$ LANGUAGE plpgsql;
-- 进入remote控制台，执行
psql -d $DATABASE_URL -c "SELECT generate_listing_variations_partitions_statements()" -tA | psql -d $DATABASE_URL


---
DO $$
DECLARE
i integer;
BEGIN
FOR i IN 201..250 LOOP
      EXECUTE format('CREATE TABLE IF NOT EXISTS public.product_variations_%s PARTITION OF public.product_variations FOR VALUES FROM (%s000) TO (%s000)', i, i, i+1);
END LOOP;
END $$;


--- 这个脚本用来挂在本地，如果建索引啥的被卡住可以用来做blocking进程清理

require "pg"

# 创建一个新的数据库连接
conn = PG.connect(host: "localhost", port:, dbname: "",
                  user: "", password: "",)

loop do
  # 执行查询以获取 blocking_pid
  res = conn.exec_params('
    SELECT
      blockingl.relation::regclass,
      blockingl.locktype,
      blockingl.mode,
      blocked_activity.pid     AS blocked_pid,
      blocking_activity.pid    AS blocking_pid,
      blocked_activity.query   AS blocked_query,
      blocking_activity.query  AS blocking_query
    FROM pg_catalog.pg_locks blockedl
    JOIN pg_stat_activity blocked_activity  ON blocked_activity.pid = blockedl.pid
    JOIN pg_catalog.pg_locks blockingl ON(
      blockingl.locktype = blockedl.locktype
      AND blockingl.DATABASE IS NOT DISTINCT FROM blockedl.DATABASE
      AND blockingl.relation IS NOT DISTINCT FROM blockedl.relation
      AND blockingl.page IS NOT DISTINCT FROM blockedl.page
      AND blockingl.tuple IS NOT DISTINCT FROM blockedl.tuple
      AND blockingl.virtualxid IS NOT DISTINCT FROM blockedl.virtualxid
      AND blockingl.transactionid IS NOT DISTINCT FROM blockedl.transactionid
      AND blockingl.classid IS NOT DISTINCT FROM blockedl.classid
      AND blockingl.objid IS NOT DISTINCT FROM blockedl.objid
      AND blockingl.objsubid IS NOT DISTINCT FROM blockedl.objsubid
      AND blockingl.pid != blockedl.pid
    )
    JOIN pg_stat_activity blocking_activity ON blocking_activity.pid = blockingl.pid
    WHERE NOT blockedl.GRANTED AND blocked_activity.pid = 3084920;
  ')
  next if res.count.zero?

  # 获取 blocking_pid
  blocking_pid = res[0]["blocking_pid"]
  blocked_pid = res[0]["blocked_pid"]
  if blocked_pid.nil?
    puts "job done"
    break
end

  # 如果 blocking_pid 存在，执行 pg_terminate_backend
  if blocking_pid
    conn.exec_params("SELECT pg_cancel_backend($1)", [blocking_pid])
    # conn.exec_params("SELECT pg_terminate_backend($1)", [blocking_pid])
    puts "cancel blocking_pid: #{blocking_pid} success!"
end

  # 等待1秒
  sleep 0.5
end
