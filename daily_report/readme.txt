1.查询完成后下载；
2.下载的文件为csv;
3.pending-daily.sql的selected_at改为昨天的日期;
4.下载的文件名格式为：
   1.add.sql => YYYYMMDD_process_add.csv ;
   2.import.sql => YYYYMMDD_import.csv ;
   3.inventory.sql => YYYYMMDD_inventory.csv ;
   4.pending-daily.sql => YYYYMMDD_pending.csv ;
   5.pending-all.sql => YYYYMMDD_process.csv ;
   6.publish.sql => YYYYMMDD_publish.csv ;
   7.error.sql => YYYYMMDD_error.csv ;

5.所有的文件放到一个文件夹下：名字为：YYYYMMDD;
6.打包成zip格式：YYYYMMDD.zip;
7.发到slack群里；
