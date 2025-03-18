#使用这个脚本可以连接相关环境的数据库，使用方式，将cd 后面的信息替换为ebaymag的项目地址，
#然后使用
# sh remote_gcp.sh gamma
# 上面这个命令链接gamma环境，然后通过
# psql $DATABASE_URL
#就可以连接
echo $1
if [ ! $1 ]; then
env="prod"
else
env=$1
fi
echo $env
cd /Users/yanmeng/Documents/workplace/ruby/ebay-mag-2-7
bin/remote $env
