
# 设置日志级别
Rails.logger.level = 0
SemanticLogger.default_level = :trace
EbayRequest.logger = Rails.logger
EbayAPI.logger = Rails.logger


Account.find_by_name('zhuhjshanghai')
Account.find_by_name('jiangyi12081')

# 用户生成用户的token
Ebay::Account::GetSubscription.call(Account.find_by_name(name))
Ebay::Account::GetSubscription.call(Account.find_by_id(17))

# 检查发布前的准备条件
Preparation.call(Listing.find_by_id(l))

# 发布
Publishing::SynchronizeItem.call(Listing.find_by_id(l))
Publishing.synchronize(Listing.find_by_id(l))
Publishing.refresh(Listing.find_by_id(l))

# 获取category
Preparation::SuggestCategories.call(Listing.find_by_id(l),limit: 1,auto_select: true,)
# 更新original
Stock::Sync::UpdateItem.call(listing: Listing.find_by_id(l),sync_quantities: true,sync_content: true,**{},)
Stock::Sync::UpdateItem.call(listing: Listing.find_by_item_id(l),sync_quantities: true,sync_content: true,**{},)


Publishing::ItemMapper.call(listing: Listing.find_by_id(l))

# id为shipping_ebay_profile的id
Shipping::PublishEbayProfile.call(record:Shipping::EbayProfile.find_by_id(id))
Shipping::PublishEbayProfile.call(record:Listing.find_by_id(l).ebay_profile('fulfillment'))

item = Ebay::GetItem.call(Listing.find_by_id(l).account, Listing.find_by_id(l).site_id, [Listing.find_by_id(l).item_id])

# 获取policy
BusinessPolicies.get(account: account, site_id: site_id, ebay_id: ebay_id, kind: kind,)
# 刷新original
Publishing::RefreshOriginalItemsWorker.new.perform(l)
# 刷新daily end check
Publishing::DailyToEndCrossListingsWorker.enqueue

Ebaymagapi::SetItemFieldLock.call(Product.find_by_id(id))
Ebaymagapi::SetItemMapping.call(Product.find_by_id(id))
Ebaymagapi::PollMessage.call(Account.find_by_name('zhuhjshanghai').user)
Ebaymagapi::DeleteItemMapping.call(id)
Ebaymagapi::SetSellerSetting.call(user_id)

# 下架
EventStore::HandleWorker.enqueue(Notifications::ItemEndHandler)
EventStore::HandleWorker.enqueue(Stock::ItemClosureHandler)
EventStore::HandleWorker.enqueue(Stock::ArchivationHandler)
EventStore::HandleWorker.enqueue(Publishing::UnselectionHandler)

# 清除schedule重复job
name = "schedule"
queue = Sidekiq::Queue.new(name)
ary = []
queue.each do |job|
  next unless job.args.size == 0
  if ary.include?(job.klass)
    job.delete
  else
    ary << job.klass
  end
end
# 清除schedule重复job
Utils::CleanDuplicateTasks.call

Sidekiq::Queue.new("schedule").each do |job| puts job.klass end

Sidekiq::Queue.new("schedule").size
Sidekiq::Queue.new("events_jp").size
Sidekiq::Queue.new("events_jp").each do |job| puts job.klass end

Sidekiq::Queue.new('0_events_important').size


# 队列暂停和重启
Sidekiq::Queue.new("schedule").unpause;
Sidekiq::Queue.new("schedule").pause;
Sidekiq::Queue.new("_cleaning").unpause;
Sidekiq::Queue.new("_cleaning").pause;
Sidekiq::Queue.new("_retry_worker").pause;
Sidekiq::Queue.new("_retry_worker").unpause;
Sidekiq::Queue.new("_events_fast").pause;
Sidekiq::Queue.new("_events_fast").unpause;
Sidekiq::Queue.new("google_analytics").unpause;
Sidekiq::Queue.new("google_analytics").pause;
Sidekiq::Queue.new("_events_ebaymagapi").unpause;
Sidekiq::Queue.new("_events_ebaymagapi").pause;
Sidekiq::Queue.new("imports").pause;
Sidekiq::Queue.new("imports").unpause;
Sidekiq::Queue.new("manual_publishing").pause;
Sidekiq::Queue.new("manual_publishing").unpause;
Sidekiq::Queue.new("events_ended").pause;
Sidekiq::Queue.new("events_ended").unpause;
Sidekiq::Queue.new("mailing").pause;

# 队列暂停一段时间
Sidekiq::Queue["_cleaning"].pause_for_ms(1000 * 60 * 30) # for 30 minutes

#分布式锁的删除
RedisMutex.new('Product[700468]').unlock!(force:true)
RedisMutex.new(key).unlock!(force:true)

# 删除account
Account::Drop.call(account)

# 导入某个item
ProductImport::Load.call(
  item_id:  225591800266,
  site_ids: [0],
  account:  Account.find_by_id(17),
  data_source: "from_ebay",
  )

# 连接数据库
psql $DATABASE_URL

#查询某个listing相关信息
l = 706768170
Listing.find_by_id(l).source.listings.pluck(:id,:managed,:item_id,:historical_item_ids,:site_id,:selected_at,:created_at,:updated_at,:start_time,:end_time,:publication_url)
Product.find_by_id(id).listings.pluck(:id,:managed,:item_id,:historical_item_ids,:site_id,:selected_at,:created_at,:updated_at,:start_time,:end_time,:publication_url)

# 通过ebaymag页面上的ebaymag number差order
Parcel.find_by_id(id).orders
# ebay_id查询
Order.find_by_extended_ebay_id()
# lines
Order.find_by_id().lines

# 同步库存
Publishing.update_inventory Listing.find_by_id(709076549),nil,reason: "event_handler"

# check readiness
Account::CheckReadiness.call(account)

#查询event_store_messages
uuid=''
EventStore::Message.find_by_uuid(uuid)
EventStore::Completion.where(message_uuid:uuid)
EventStore::Message.where(parent_uuid:uuid)

EventStore::HandleWorker.new.perform(uuid,'Order::FetchHandler')
EventStore::HandleWorker.new.perform(uuid,'Order::UpdateHandler')
EventStore::HandleWorker.new.perform(uuid,handler)

EventStore::HandleWorker.enqueue(Order::FetchHandler);
EventStore::HandleWorker.enqueue(Notifications::ItemRevisedHandler);
EventStore::HandleWorker.enqueue(Notifications::ItemEndHandler);
EventStore::HandleWorker.enqueue(Notifications::ItemEndHandler);

# 获取opted in用户
Account.with_business_shipping.size

#直接执行
EventStore::HandleWorker.new.perform('b62b34fa-6540-4ff3-b97d-16576c1e7371','Order::FetchHandler')
EventStore::HandleWorker.new.perform(uuid,'Publishing::InventoryChangeHandler')
#直接放入队列执行
EventStore::HandleWorker.set(queue:'_events_fast').perform_async('b62b34fa-6540-4ff3-b97d-16576c1e7371','Order::FetchHandler')
# jp order fetech
Account.accessible.where(country: "JP").each do |acc| Import::Ebay::FetchOrdersWorker.perform_async(acc.id) end
Import::Ebay::FetchOrdersForJpWorker.enqueue

Shipping::Service.search_by(time_max:time_max,international:false,site_id:site_id,used: true)

Store::Product::TransferWorker.perform_async(1)


# 开始shipping policy白名单，123 是user_id
Redis::Pool.with do |r| r.lpush('shipping_service_white_list',123) end
Redis::Pool.with do |r| r.lrange('shipping_service_white_list',0,-1) end
# 关闭shipping policy白名单
Redis::Pool.with do |r| r.lrem('shipping_service_white_list',1,123) end

# 开始shipping policy白名单，JP 是国家
Redis::Pool.with do |r| r.lpush('shipping_service_country_white_list','KR') end
Redis::Pool.with do |r| r.lrange('shipping_service_country_white_list',0,-1) end
# 关闭shipping policy白名单
Redis::Pool.with do |r| r.lrem('shipping_service_country_white_list',1,'JP') end

Import::Ebay::FetchOrdersForJpWorker.enqueue
Import::Ebay::FetchOrdersWorker.enqueue

Shipping::Service.search_by(time_max:4,international:false,site_id:3,used: true)

Shipping::PublishEbayProfile.call(record:Shipping::EbayProfile.find_by_id(l))

Shipping::Service.search_by(time_max:4,international:true,site_id:3,used: true)


# 停止scheduler里面的job
# 现在pghero里面杀掉该woker产生的sql,该woker会自动进入retry队列里面。
# 从retry队列中删除某个member
retry_queue = Sidekiq::RetrySet.new
kpi_jobs = retry_queue.select { |job| job.item["class"] == 'Category::UnbindWorker' }
kpi_jobs.each(&:delete)

# 开始ebay translation api白名单，MY 是国家
Redis::Pool.with do |r| r.lpush('translation_country_white_list','MY') end
Redis::Pool.with do |r| r.lrange('translation_country_white_list',0,-1) end
# 关闭ebay translation api白名单
Redis::Pool.with do |r| r.lrem('translation_country_white_list',1,'CN') end

# 开始ebay account api白名单，MY 是国家
Redis::Pool.with do |r| r.lpush('account_api_country_white_list','MY') end
Redis::Pool.with do |r| r.lrange('account_api_country_white_list',0,-1) end
# 关闭ebay translation api白名单
Redis::Pool.with do |r| r.lrem('account_api_country_white_list',1,'CN') end

# 开始ebay account api白名单，2 是 account id
Redis::Pool.with do |r| r.lpush('account_api_account_white_list',2) end
Redis::Pool.with do |r| r.lrange('account_api_account_white_list',0,-1) end
# 关闭ebay translation api白名单
Redis::Pool.with do |r| r.lrem('account_api_account_white_list',1,2) end

# 开始ebaymag internal白名单，MY 是国家
Redis::Pool.with do |r| r.lpush('ebaymag_internal_country_white_list','CN') end
Redis::Pool.with do |r| r.lrange('ebaymag_internal_country_white_list',0,-1) end
# 关闭ebay internal api白名单
Redis::Pool.with do |r| r.lrem('ebaymag_internal_country_white_list',1,'CN') end

# 开始ebaymag internal 白名单，1 是user id
Redis::Pool.with do |r| r.lpush('ebaymag_internal_user_white_list',1) end
Redis::Pool.with do |r| r.lrange('ebaymag_internal_user_white_list',0,-1) end
# 关闭ebay internal api白名单
Redis::Pool.with do |r| r.lrem('ebaymag_internal_user_white_list',1,1) end

# 开启 ebay internal api
Redis::Pool.with do |r| r.set('ebaymag_internal',"true") end
# 关闭 ebay internal api
Redis::Pool.with do |r| r.set('ebaymag_internal',"false") end
# 获取 ebay internal api
Redis::Pool.with do |r| r.get("ebaymag_internal") end

# 开始Refurbished白名单，name 是 account name
Redis::Pool.with do |r| r.lpush('refurbished_condition_white_list','zhuhjshanghai') end
Redis::Pool.with do |r| r.lrange('refurbished_condition_white_list',0,-1) end
# 关闭ebay translation api白名单
Redis::Pool.with do |r| r.lrem('refurbished_condition_white_list',1,name) end


# 开启 new specifics mapper 白名单，MY 是国家
Redis::Pool.with do |r| r.lpush('country_new_specific_mapper_white_list','MY') end
Redis::Pool.with do |r| r.lrange('country_new_specific_mapper_white_list',0,-1) end
# 关闭ebay translation api白名单
Redis::Pool.with do |r| r.lrem('country_new_specific_mapper_white_list',1,'CN') end

# 开始 new specifics mapper 白名单，2 是 account id
Redis::Pool.with do |r| r.lpush('account_new_specific_mapper_white_list',2) end
Redis::Pool.with do |r| r.lrange('account_new_specific_mapper_white_list',0,-1) end
# 关闭ebay translation api白名单
Redis::Pool.with do |r| r.lrem('account_new_specific_mapper_white_list',1,2) end

# 添加定时推送的白名单
Redis::Pool.with do |r| r.lpush('manual_publish_images_white_list','patkor1') end
Redis::Pool.with do |r| r.lrange('manual_publish_images_white_list',0,-1) end
# 关闭添加定时推送的白名单
Redis::Pool.with do |r| r.lrem('manual_publish_images_white_list',1,'patkor1') end

# 添加GPSR template country白名单
Redis::Pool.with do |r| r.lpush('gpsr_country_white_list','CN') end
Redis::Pool.with do |r| r.lrange('gpsr_country_white_list',0,-1) end
# 关闭GPSR template country白名单
Redis::Pool.with do |r| r.lrem('gpsr_country_white_list',1,'CN') end
# 添加GPSR template user白名单
Redis::Pool.with do |r| r.lpush('gpsr_user_white_list',17) end
Redis::Pool.with do |r| r.lrange('gpsr_user_white_list',0,-1) end
# 关闭GPSR template user白名单
Redis::Pool.with do |r| r.lrem('gpsr_user_white_list',1,17) end

# 添加 PLS country白名单
Redis::Pool.with do |r| r.lpush('pls_country_white_list','CN') end
Redis::Pool.with do |r| r.lrange('pls_country_white_list',0,-1) end
# 关闭 PLS  country白名单
Redis::Pool.with do |r| r.lrem('pls_country_white_list',1,'CN') end
# 添加 PLS  user白名单
Redis::Pool.with do |r| r.lpush('pls_user_white_list',17) end
Redis::Pool.with do |r| r.lrange('pls_user_white_list',0,-1) end
# 关闭 PLS  user白名单
Redis::Pool.with do |r| r.lrem('pls_user_white_list',1,17) end

# 添加 推送 listing白名单
Redis::Pool.with do |r| r.lpush('publish_pending_listings_white_list','zhuhjshanghai') end
Redis::Pool.with do |r| r.lrange('publish_pending_listings_white_list',0,-1) end
# 关闭 推送 listing白名单
Redis::Pool.with do |r| r.lrem('publish_pending_listings_white_list',1,'zhuhjshanghai') end




