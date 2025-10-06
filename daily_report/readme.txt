1.查询完成后下载；
2.下载的文件为csv;
3.pending-daily.sql的selected_at改为昨天的日期;
4.下载的文件名格式为：
   1.add.sql => YYYYMMDD-process-add.csv ;
   2.import.sql => YYYYMMDD-import.csv ;
   3.inventory.sql => YYYYMMDD-inventory.csv ;
   4.pending-daily.sql => YYYYMMDD-pending.csv ;
   5.pending-all.sql => YYYYMMDD-process.csv ;
   6.publish.sql => YYYYMMDD-publish.csv ;
   7.error.sql => YYYYMMDD-error.csv ;

5.所有的文件放到一个文件夹下：名字为：YYYYMMDD;
6.打包成zip格式：YYYYMMDD.zip;
7.发到slack群里；
