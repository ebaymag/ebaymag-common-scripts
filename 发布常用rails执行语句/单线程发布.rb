Publishing::ManualPublishItemSingleWorker.enqueue(name,true)
Publishing::ManualPublishItemSingleWorker.enqueue(name)

# 日本卖家发送
Account.where(country:'JP').find_by_name(name).user.listings.selected.managed.not_published.warnings_or_without_problems.limit(10000).each do |listing| Publishing::JapanPublishWorker.perform_async(listing.user_id,listing[:id]) end
# 查询有多少pending的数量
Account.find_by_name(name).user.listings.selected.managed.not_published.warnings_or_without_problems.size

# 手动推送前10卖家
[127217, 127218, 161935, 168372, 138809, 171451, 171514, 162041, 140473, 137814, 162189, 154883, 133793, 174512, 127178, 161604, 136906, 171913, 161144, 162652, 172694, 162562, 130791, 127219, 171009, 137680].each do |usr_id|

end

# 只发布没有error的
name=''
account = Account.where(country:'JP').find_by_name(name)
total_not_published_listings = account.listings.selected.managed.not_published.warnings_or_without_problems.limit(10).size
puts "total pending listings -- #{total_not_published_listings}"
account.listings.selected.managed.not_published.warnings_or_without_problems.limit(50000).each do |listing|
  Publishing::JapanPublishWorker.perform_async(listing.user_id,listing[:id])
end
puts "done"

# 全量
name=''
account = Account.where(country:'JP').find_by_name(name)
total_not_published_listings = account.listings.selected.managed.not_published.limit(10).size
puts "total pending listings -- #{total_not_published_listings}"
account.listings.selected.managed.not_published.limit(50000).each do |listing|
  Publishing::JapanPublishWorker.perform_async(listing.user_id,listing[:id])
end
puts "done"


# Detele Redis lock for showcase
# 1. 先删除这个showcase在Redis里的锁
name = 'outlet-salzmann'
site_id = 2
# us: 0
# ca: 2
# uk: 3
# au: 15
# fr: 71
# de: 77
# it: 101
# es: 186

showcase = Account.find_by(name: name).user.listings.not_published.selected.managed.where(site_id: site_id).first.showcase_id;
Redis::Pool.mutex.with {|r| r.del "RedisMutex:Publishing::CreateItem[#{showcase}]"};

# Add counters for publishing and errors
# 2. 命令2个变量来记录发布成功的listings和错误数量
published_listings_count = 0;
errors_count = 0;

# Add start time for calculating AVG speed
# 3. 添加一个开始时间记录
global_start_time = Time.now;

# Run for your user & site
# 4. 帮你的用户在指定的站点进行发布
# 4.1 先找到这个用户
user = Account.find_by(name: name).user;
# 4.2 找到这个用户修改好的但是还没发布到eBay指定站点的listings
total = user.listings.not_published.selected.managed.where(site_id: site_id).size
user.listings.not_published.selected.managed.where(site_id: site_id).find_each do |el|
  start_time = Time.now
  Publishing.synchronize(el)
  end_time = Time.now
  published_listings_count += 1
  puts "|----------------------------------"
  puts "| Completed in #{(end_time-start_time).to_s} seconds."
  puts "| Published count: #{published_listings_count}/#{total} listings."
  puts "| AVG SPEED: #{(end_time-global_start_time).to_f / published_listings_count}."
  puts "|----------------------------------"
  puts "| ERRORS COUNT: #{errors_count}"
  puts "|----------------------------------"
rescue StandardError => e
  errors_count += 1
  nil
end


# 全量发布版本
name = 'top-moebel24'
published_listings_count = 0;
errors_count = 0;
global_start_time = Time.now;
user = Account.find_by(name: name).user;
total_not_published_listings = user.listings.not_published.selected.managed.without_errors.size
user.listings.not_published.selected.managed.without_errors.find_each do |el|
  start_time = Time.now
  Publishing.synchronize(el)
  end_time = Time.now
  published_listings_count += 1
  puts "|----------------------------------"
  puts "| name-- #{name}"
  puts "| Completed in #{(end_time-start_time).to_s} seconds."
  puts "| Published count: #{published_listings_count}/#{total_not_published_listings} listings."
  puts "| AVG SPEED: #{(end_time-global_start_time).to_f / published_listings_count}."
  puts "|----------------------------------"
  puts "| ERRORS COUNT: #{errors_count}"
  puts "|----------------------------------"
rescue DistributedLock::TimeoutError, Handle::NetworkErrors => e
  errors_count += 1
  nil
end


# 全量发布版本
name = 'hertune_japan'
published_listings_count = 0;
errors_count = 0;
global_start_time = Time.now;
user = Account.find_by(name: name).user;
total_not_published_listings = user.listings.not_published.selected.managed.size
user.listings.not_published.selected.managed.find_each do |el|
  start_time = Time.now
  Publishing.synchronize(el)
  end_time = Time.now
  published_listings_count += 1
  puts "|----------------------------------"
  puts "| name-- #{name}"
  puts "| Completed in #{(end_time-start_time).to_s} seconds."
  puts "| Published count: #{published_listings_count}/#{total_not_published_listings} listings."
  puts "| AVG SPEED: #{(end_time-global_start_time).to_f / published_listings_count}."
  puts "|----------------------------------"
  puts "| ERRORS COUNT: #{errors_count}"
  puts "|----------------------------------"
rescue DistributedLock::TimeoutError, Handle::NetworkErrors => e
  errors_count += 1
  nil
end

# 版本1， 直接用前端update_quantity的路子去调
# 会起作用, 可以的. 不会锁库存3，就是前端此时会无法点击同步库存
# 卖家:store_subscription_level
# 类型有["Basic", "Featured", nil, "Starter", "Anchor", "Enterprise"]
# 重要度： nil < Starter < Basic < Featured < Anchor < Enterprise
# starter+nil量大约20K， Basic大约71K， Featured大约480K， Anchor大约350K， Enterprise大约300K
starter = Account.accessible.where(country: ["JP","KR"]).filter {|a|a.store_subscription_level == "Starter" || a.store_subscription_level == nil}
basic = Account.accessible.where(country: ["JP","KR"]).filter {|a|a.store_subscription_level == "Basic"}
featured = Account.accessible.where(country: ["JP","KR"]).filter {|a|a.store_subscription_level == "Featured"}
anchor = Account.accessible.where(country: ["JP","KR"]).filter {|a|a.store_subscription_level == "Anchor"}
enterprise = Account.accessible.where(country: ["JP","KR"]).filter {|a|a.store_subscription_level == "Enterprise"}
# 全量： accounts = Account.accessible.where(country: ["JP","KR"])
count = 0
jump = 0
total = enterprise.count;
enterprise.each do |account|
  user = account.user
  Stock::Sync::Start.call(user, sync_type: "quantities")
  count += 1
  puts "#{count}/#{total} - jump:#{jump}"
rescue NoMethodError, StandardError => e
  puts "Jumping..."
  jump += 1
end

# 库存同步
# 版本2， 用这个定时任务。 无论哪一个版本，最终都是使用Stock::Sync::UpdateItem.call
# Account::SyncQuantitiesFromEbayWorker.perform_async
# 能起作用，但是会刷可用库存为3，如果大于3的话会锁ebaymag库存3。
# 执行快，2秒
country = "KR"
count = 0;
jump = 0;
total = Account.accessible.where(country: country).count;
Account.accessible.where(country: country).find_each do |account|
  user = account.user
  listings = user.listings.original
  listing_size = listings.size
  l_count = 0
  listings.find_each do |listing|
    Account::SyncQuantitiesFromEbayWorker.perform_async(user.id, listing.id)
    l_count += 1
    puts "listing synced: #{l_count}/#{listing_size}"
  end
  count += 1
  puts "user: #{count}/#{total} - jump:#{jump}"
rescue NoMethodError, StandardError => e
  puts "Jumping..."
  jump += 1
end


# 多线程版本（测试）-------------------------
# Detele Redis lock for showcase
# 1. 先删除这个showcase在Redis里的锁
# us: 0
# ca: 2
# uk: 3
# au: 15
# fr: 71
# de: 77
# it: 101
# es: 186
name = 'itose_0707'
user = Account.find_by(name: name).user;
site_ids = [2,3,15,71,77,101,186]
showcase_site_ids = user.showcases.where(site_id: site_ids).where(active: true).pluck(:id, :site_id) # 8 个不同的 showcase_id

threads = showcase_site_ids.map do |showcase_id, site_id|
  Thread.new do
    Redis::Pool.mutex.with {|r| r.del "RedisMutex:Publishing::CreateItem[#{showcase_id}]"};

    # Add counters for publishing and errors
    # 2. 命令2个变量来记录发布成功的listings和错误数量
    published_listings_count = 0;
    errors_count = 0;

    # Add start time for calculating AVG speed
    # 3. 添加一个开始时间记录
    global_start_time = Time.now;

    # Run for your user & site
    # 4. 帮你的用户在指定的站点进行发布
    # 4.1 先找到这个用户
    user = Account.find_by(name: name).user;
    # 4.2 找到这个用户修改好的但是还没发布到eBay指定站点的listings
    total = user.listings.not_published.selected.managed.where(site_id: site_id).size
    user.listings.not_published.selected.managed.where(site_id: site_id).find_each do |el|
      start_time = Time.now
      Publishing.synchronize(el)
      end_time = Time.now
      published_listings_count += 1
      puts "|----------------------------------"
      puts "| name---#{name}  "
      puts "| Completed in #{(end_time-start_time).to_s} seconds."
      puts "| Published count: #{published_listings_count}/#{total} listings."
      puts "| AVG SPEED: #{(end_time-global_start_time).to_f / published_listings_count}."
      puts "|----------------------------------"
      puts "| ERRORS COUNT: #{errors_count}"
      puts "|----------------------------------"
    rescue DistributedLock::TimeoutError, Handle::NetworkErrors => e
      errors_count += 1
      nil
    end
  end
end

# Wait for all threads to finish
threads.each(&:join)