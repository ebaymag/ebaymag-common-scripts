#通过port方法链接GCP clone数据库
#!/bin/bash

# 查找使用端口5433的进程ID
pid=$(lsof -ti tcp:5433)

# 检查是否有进程使用该端口
if [ -z "$pid" ]; then
  echo "没有进程使用端口5433。"
else
  # 杀掉使用该端口的进程
  kill -9 $pid
  echo "已杀掉使用端口5433的进程：$pid。"
fi
/Users/yanmeng/Documents/google-cloud-sdk/bin/cloud_sql_proxy -instances=ebay-mag:europe-west4:production-v3=tcp:5433
#如果上面的不行，可以用下面的命令
#/Users/yanmeng/Documents/google-cloud-sdk/bin/cloud_sql_proxy ebay-mag:europe-west4:production-v3 -p 5433
