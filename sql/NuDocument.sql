1. Query ItemMapping by primary key
get * from ItemMappings use keys["ItemMappings:PRODUCTION_8910692", "PRODUCTION_8910692"]
2. Query ItemMapping by original item id
select * from ItemMappings where itemId="${originalItemId}"
3. Query Product by primary key
get * from Products use keys["Products:PRODUCTION_8910692", "PRODUCTION_8910692"]
4. Query CrossItem by primary key
get * from OriginalCrossItems use keys["OriginalCrossItems:${itemId}", "${itemId}"]
5. Query SellerSetting by primary key
get * from SellerSettings use keys["SellerSettings:PRODUCTION_75804", "PRODUCTION_75804"]
6. Query SyncTasks by primary key
get * from SyncTasks use keys ["SyncTasks:f7de97c8-72db-4d9d-8565-c742dd019da9:1711656955818", "f7de97c8-72db-4d9d-8565-c742dd019da9:1711656955818"]


7. Query SyncTasks by condition key
select * from SyncTasks where ebaymagSellerId="534" and kind="ITEM_CONTENT_SYNC" and deleted = false
8. Query ItemMappingLockFields by primary key
get * from ItemMappingLockFields use keys ["ItemMappingLockFields:PRODUCTION_8910692","PRODUCTION_8910692"]
9. Update Product by primary key
update Products use keys ["Products:PRODUCTION_8910692", "PRODUCTION_8910692"] set ${column} = ${value}

10. Query MotorCompatibility
select count(*) from MotorCompatibiltyConfiguration where version="2" WITH ADHOCQUERY;
select * from MotorCompatibiltyConfiguration where make="Audi" and model="100" and year="1983" and version="2"
11. Query count of Product
select count(*) from Products WITH ADHOCQUERY