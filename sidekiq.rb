# 获取正在执行的任务
jobs = Sidekiq::Workers.new
# 下面是这个job的信息
puts jobs.first
{"queue"=>"schedule",
 "payload"=>
   {"retry"=>0,
    "queue"=>"schedule",
    "class"=>"Store::Product::TransferWorker",
    "args"=>[],
    "jid"=>"838a3dd0106a7e2bbbed5adc",
    "created_at"=>1719274260.0136557,
    "enqueued_at"=>1719274260.0138853},
 "run_at"=>1719281153}

# 获取队列中的信息
queue = Sidekiq::Queue.new(name)
puts queue.first
{"retry"=>true,
 "queue"=>"_accounts",
 "args"=>[155368],
 "class"=>"Notifications::SetPreferencesWorker",
 "jid"=>"a04796278e518fb9f008717a",
 "created_at"=>1719282273.0649257,
 "enqueued_at"=>1719282273.0650215}

# 获取重试队列
jobs = Sidekiq::RetrySet.new
puts jobs.first
{"retry"=>true,
 "queue"=>"non_blocking",
 "args"=>[3321957],
 "class"=>"Shipping::ChangeProfileCurrencyWorker",
 "jid"=>"35040de97be1653d8d57ecd6",
 "created_at"=>1718100769.3094203,
 "enqueued_at"=>1719256606.6645887,
 "error_message"=>"Couldn't find Shipping::Profile",
 "error_class"=>"ActiveRecord::RecordNotFound",
 "failed_at"=>1718101251.189292,
 "retry_count"=>23,
 "retried_at"=>1719256637.9773445}

# 获取计划中队列
jobs = Sidekiq::ScheduledSet.new
puts jobs.first
{"retry"=>0, "queue"=>"_accounts",
 "class"=>"Account::CheckUnreadyAccountsWorker",
 "args"=>[155339], "jid"=>"be23ab6179bc4525afd63f98",
 "created_at"=>1719267187.5409832}

# 获取停滞队列
jobs = Sidekiq::DeadSet.new
puts jobs.first
{"retry"=>1,
 "queue"=>"_ebay_sync_fast",
 "args"=>[1933045332],
 "class"=>"Shipping::RemoveOriginalShippingExclusionWorker",
 "jid"=>"457104712b3232756bb423a9",
 "created_at"=>1719282521.5621789,
 "enqueued_at"=>1719282559.902964,
 "error_message"=>"There was a problem changing the default status of this policy",
 "error_class"=>"EbayAPI::Error",
 "failed_at"=>1719282535.5275118,
 "retry_count"=>1,
 "retried_at"=>1719282574.3241637}