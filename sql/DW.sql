-- 查询所有的application
select * from ACCESS_VIEWS.DW_APPLICATIONS where app_id=1;
-- 查询修改记录
select * from ACCESS_VIEWS.DW_ITEM_REVISIONS where item_id=404718567660;
-- 查询用户的相关信息
select user_id
from ACCESS_VIEWS.DW_USERS
where
-- user_id='2335028565'
USER_SLCTD_ID='no.2ebikestore' ;

-- 打成json
CREATE TABLE P_CMP_T.emag_jp_json_data_cross_error (
                                                       json_data VARCHAR(10000)
);

INSERT INTO P_CMP_T.emag_jp_json_data_cross_error (json_data)
SELECT to_json(collect_list(named_struct(
        'item_id', item_id,
        'user_id', user_id,
        'source_id', source_id
                            ))) AS json_data
FROM (
         SELECT item_id, user_id, source_id,
                ROW_NUMBER() OVER (ORDER BY item_id) as rn
         FROM P_CMP_T.emag_jp_org_listings_with_cross_error
     ) AS numbered_rows
GROUP BY FLOOR((rn - 1) / 100);

select count(1)
from ACCESS_VIEWS.DW_LSTG_ITEM
where APPLICATION_ID=212439
  and slr_id=111
  and LSTG_STATUS_ID in (0,4)
  and AUCT_START_DT='2025-04-06'

