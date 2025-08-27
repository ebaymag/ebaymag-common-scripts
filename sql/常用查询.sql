-- 获取从internal拉取的错误listing
select * from event_store_messages where kind='ebaymagapi::ErrorListing' order by original_time desc limit 100;
select * from event_store_messages where kind='ebaymagapi::SetItemFieldLock' order by original_time desc limit 10;
select * from event_store_messages where kind='ebaymagapi::SetSellerSetting' order by original_time desc limit 10;
select * from event_store_messages where kind='ebaymagapi::SetItemMapping' order by original_time desc limit 10;
-- 获取itemRevised事件
select * from event_store_messages where kind='itemRevised' order by original_time desc limit 20;

select * from event_store_messages where kind='itemEnded' order by original_time desc limit 20;
-- 获取feedback
select * from event_store_messages where kind='feedbackCreated' order by original_time desc limit 20;
select * from event_store_messages where kind='inventoryChanged' order by original_time desc limit 20;

select * from event_store_messages where kind='itemAffected' order by original_time desc limit 10;
select * from event_store_messages where kind='itemListed' order by original_time desc limit 10;

select * from event_store_messages where kind <> 'marketplaceAccountDeletion' order by original_time desc limit 20;

select * from event_store_messages where kind in ('gpsr::ReviseListingByGpsrTemplate','gpsr::CoverOriginal','gpsr::AssignTemplate','gpsr::CoverCross') order by original_time desc limit 20;

-- 查询某个删除用户
SELECT *
FROM action_logs
WHERE EXISTS (
    SELECT 1
    FROM jsonb_array_elements(data->'accounts') AS account
    WHERE account->>1 = 'dj_sage_store'
);

SELECT DATE_TRUNC('hour', created_at + interval '8 hour') AS hour,
       sum(case when (data->'msg'->>'status')='published' then 1 else 0 end) AS pub_count,
	   sum(case when (data->'msg'->>'status')!='published' then 1 else 0 end) AS error_count,
	   sum(1) AS total_count
FROM action_logs
WHERE action = 'publish_flag'
  AND (data->>'account_country') in('JP','KO')
--   and (data->'msg'->>'status')='published'
--   AND created_at BETWEEN '2025-04-12 18:00:00' AND '2025-04-12 19:00:00'
  and created_at >= '2025-04-15 16:00:00'
GROUP BY hour;

select count(1) from product_import_items;

-- 订单
SELECT *,
       array_position(
               ARRAY ['ready','not_paid','need_processing','courier_awaiting','drop_off_awaiting','failed_delivery','shipped','delivered']::varchar[],
               parcels.status) AS sort_order
FROM parcels
WHERE parcels.stale IS NULL
  AND parcels.user_id = 17
  AND parcels.id IN (SELECT parcels.id
                     FROM parcels
                              INNER JOIN parcel_orders ON parcel_orders.parcel_id = parcels.id
                              INNER JOIN orders ON orders.id = parcel_orders.order_id
                     WHERE parcels.stale IS NULL
                       AND orders.placed_at >= '2025-05-27 00:00:00')
ORDER BY sort_order ASC, id DESC
    LIMIT 10;