echo $1
if [ ! $1 ]; then
env="prod"
else
env=$1
fi
echo $env
#下面的改为你的ebaymag的项目文件夹，
#假如进入gamma环境，运行 sh wconsole_gcp.sh gamma
#其他的环境为：beta,alpha,prod
cd /Users/yanmeng/Documents/workplace/ruby/ebay-mag-2-4
bin/console $env
