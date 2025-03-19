echo $1
if [ ! $1 ]; then
env="prod"
else
env=$1
fi
echo $env
cd /Users/yanmeng/Documents/workplace/ruby/ebay-mag-2-4
bin/console $env
