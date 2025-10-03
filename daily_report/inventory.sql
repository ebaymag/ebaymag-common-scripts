-- JP
with original_data as (
    select EXTRACT(EPOCH FROM (comp.created_at - orders.original_time)) / 60.0 AS original_diff_minutes,
           EXTRACT(EPOCH FROM (comp.created_at - orders.paid_time)) / 60.0     AS paid_diff_minutes,
           EXTRACT(EPOCH FROM (orders.original_time - orders.placed_time)) / 60.0     AS to_mag_diff_minutes,
           orders.*,
           accounts.country,
           child.kind,
           comp.created_at,
           (orders.original_time AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Shanghai')::date as beijing_date
    from (select uuid,
                 (data -> 'order' -> 'raw_data' -> 'TransactionArray' -> 'Transaction' -> 'Item' ->> 'ItemID') item_id,
                 to_timestamp(replace(replace(
                                              (data -> 'order' -> 'raw_data' -> 'CheckoutStatus' ->> 'LastModifiedTime')::text,
                                              '"', ''), 'T', ' '),
                              'YYYY-MM-DD HH24:MI:SSZ')                                                        paid_time,
                 replace(data -> 'account' ->> 'name', '"', '') as                                             account_id,
                 (data -> 'account' ->> 'uid')                                                                 uid,
                 original_time,
                 to_timestamp(replace(replace(
                                              (data -> 'order' -> 'raw_data' ->> 'CreatedTime')::text,
                                              '"', ''), 'T', ' '),
                              'YYYY-MM-DD HH24:MI:SSZ')                                                        placed_time
          from event_store_messages
          where kind = 'orderFetched'
            and original_time >= '2025-06-20 16:00:00') orders
             inner join accounts on orders.uid = accounts.uid 
             inner join event_store_messages child on orders.uuid = child.parent_uuid and
            child.kind in ('productSold', 'saleCancelled','inventoryChanged') and (child.data->>'queue') in ('inventory_jp_main','inventory_others_main')         
             inner join event_store_completions comp on child.uuid = comp.message_uuid and comp.handler in
                                                                                           ('Publishing::SaleHandler',
                                                                                            'Publishing::SaleCancelHandler',
                                                                                            'Publishing::InventoryChangeHandler')
),
daily_stats as (
    select
        beijing_date,
        count(1) as sumData,
        round(avg(paid_diff_minutes)::numeric, 2) as avgTime,
        count(case when paid_diff_minutes <= 5 then 1 end) as timeLe5,
        count(case when paid_diff_minutes > 5 and paid_diff_minutes <= 20 then 1 end) as timegt5Le20,
        count(case when paid_diff_minutes > 20 and paid_diff_minutes <= 60 then 1 end) as timegt20Le60,
        count(case when paid_diff_minutes > 60 then 1 end) as timeGt60,
        round(max(paid_diff_minutes)::numeric, 2) as maxTime,
        round(max(to_mag_diff_minutes)::numeric, 2) as toMagMaxTime,
        round(min(to_mag_diff_minutes)::numeric, 2) as toMagMinTime,
        round(avg(to_mag_diff_minutes)::numeric, 2) as toMagAvgTime
    from original_data
    group by beijing_date
)
 
select
    beijing_date,
    sumData,
    avgTime,
    timeLe5,
    ROUND((timeLe5::numeric / sumData::numeric) * 100, 2) || '%' AS le5Rate,
    timegt5Le20,
    ROUND((timegt5Le20::numeric / sumData::numeric) * 100, 2) || '%' AS gt5le20Rate,
    (timeLe5 + timegt5Le20) as timeLe20,
    ROUND(((timeLe5::numeric + timegt5Le20::numeric) / sumData::numeric) * 100, 2) || '%' AS le20Rate,     
    timeGt60,
    ROUND((timeGt60::numeric / sumData::numeric) * 100, 2) || '%' AS gt60Rate,
    maxTime
    -- timegt20Le60,
    -- ROUND((timegt20Le60::numeric / sumData::numeric) * 100, 2) || '%' AS gt20le60Rate,
    -- toMagMaxTime,
    -- toMagMinTime,
    -- toMagAvgTime
from daily_stats
order by beijing_date desc;