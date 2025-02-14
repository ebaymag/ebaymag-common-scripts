# 获取没有同步的图片
name='patkor1'
count = 0
all_count = Account.find_by_name(name).user.images.pending.size
puts "需要发布#{all_count}张图片"
Account.find_by_name(name).user.images.pending.each do |image|
  count += 1
  puts "已经推送了#{count}张图片,还剩#{(all_count-count).to_s}张图片"
  ImageStore.transfer(image)
end


# worker 推送
Publishing::ManualPublishImagesWorker.enqueue('patkor1')

# 直接推送
name='artsvilla'
count = 0
all_count = Account.find_by_name(name).user.images.where.not(product_variation_id:nil).where(target_url: nil).size
puts "需要发布#{all_count}张图片"
Account.find_by_name(name).user.images.where.not(product_variation_id:nil).where(target_url: nil).each do |image|
  index = image.source_url.rindex('&')
  url = GoogleCloudStorage.for(:images).transfer(image.source_url.slice(0,index))
  image.update(target_url:url,error:nil)
  count += 1
  puts "已经推送了#{count}张图片,还剩#{(all_count-count).to_s}张图片"
end