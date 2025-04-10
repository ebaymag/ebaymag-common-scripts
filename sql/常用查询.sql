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
