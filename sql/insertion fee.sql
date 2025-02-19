--获取被收费的listing
select
    fee.item_id,
    fee.AMT_USD,
    fee.ACCT_TRANS_DT,
    item.APPLICATION_ID,
    item.ITEM_SITE_ID,
    item.AUCT_START_DT,
    item.SALE_SCHED_END_DT,
    item.AUCT_END_DT,
    item.relist_parent_item_id
from ACCESS_VIEWS.DW_ACCOUNTS_FN as fee
         left join ACCESS_VIEWS.DW_LSTG_ITEM as item
                   on fee.item_id=item.item_id
where
    fee.USER_ID=261923322
  and fee.actn_code in (1, 141, 264)
  and fee.ACCT_TRANS_DT BETWEEN '2023-06-01' and CURRENT_DATE
  and fee.amt_usd<0
order by fee.ACCT_TRANS_DT desc

--首先获取user_id
select * from user_id where user_slctd_id='collectiblegiftitems';